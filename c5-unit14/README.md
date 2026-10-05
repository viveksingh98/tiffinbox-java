# c5-unit14 — Layered Jars and Image Caching

Course 5 · Spring Boot · Section 3 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, Docker 29.4.0
(OrbStack; client 29.5.1, buildx 0.33.0, BuildKit 0.29.0)**, 2026-10-05, on an 8-core 16 GB Apple-silicon Mac.
Change one word of TiffinBox and the jar is a whole new file of the same size. Boot's jar already carries an index,
`BOOT-INF/layers.idx`, that sorts it into four layers; this unit counts them, changes one word and fingerprints each layer, finds
the layer that moves with **no** change at all (the build's clock inside `tiffinbox-core`'s jar), and fixes that with one
property in the root POM — `project.build.outputTimestamp`, Course 3's fixed-time exercise, landed in the anchor (A/B: the
previous tree without it, `after/` with it). Then Docker: three Dockerfiles in `docker/`, the bytes a one-word change makes new in
a layered image and in a single-jar image (Boot's jar of jars, copied whole — not a "fat jar": the executable-jar lesson keeps
that word for Course 3's flattened one), the clock for both rebuilds, two image IDs that differ with no layer changed, and a
build cache that hands the image yesterday's class when the layers are extracted on the host.

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it (`diff -rq -x target` empty). "Before" is
`../c5-unit13/after/` (the anchor as the last unit to change it left it), **copied** to `.harness/before/`. Nothing here writes into
another unit's folder. Clean builds, offline; every number the video speaks is asserted; three runs per capture; and no capture,
no README, no slide and **no layer of any image this unit builds** holds the demo token (masked, and counted: *The demo token*).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens, image layers included; a published-md5 mismatch stops it
```

**Either bash.** `./receipts.sh` runs macOS's `/bin/bash` 3.2; `bash receipts.sh` runs the first `bash` on your `PATH` — here
Homebrew's 5.3. Both give the published hashes (BLUE, 2026-10-05: every capture 3/3 under each). From bash 5.2 on, an `&` in the
replacement of `${x/pattern/replacement}` stands for the matched text (`patsub_replacement`, on by default), which broke
`startjar`'s `&& exec java`; the script switches that option off (RED #13). On a fresh clone `.m2-demo` is empty (git-ignored):
the first builds' offline attempts fail and `build()` asks Maven Central, saying so (`offline: no - …`).

(`receipts.sh` carries the same two `export` lines at its top.) `receipts.sh` **dies** when a capture's md5 differs from
`receipts.md5` — it prints the `DIFFERS` line first, so you can see which one moved. A whole run takes about four and a half minutes on the
author's Mac (5 Maven builds, then 9 captures × 3 — the timing capture alone builds 7 trees and 14 images per run). It needs a
running Docker (it asks `docker info`, runs `orb start` only if Docker does not answer and the `orb` command exists, then polls for
60 s) and the base image `eclipse-temurin:25-jre` already pulled (it was on this Mac before this unit: no build here pulls, and
every build log is counted for layer downloads — 0).

**The repository.** Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the script): a copy of
`../c5-unit13/.m2-demo`, plus the Section 3 seed `spring-boot/_research/m2-seed-s3/` copied with `rsync --ignore-existing` and
**without its `com/tiffinbox/`**. Every `_remote.repositories` marker says `central` (1,900 markers, 0 naming a local repository).
Nothing was downloaded. Each build prints `built <tree> · offline: yes` (or `no - …`) on the terminal; the timing and exercise
builds are offline-only (`-o`, no fallback: a build that needed the network would stop the run). The exercise's `install` writes
`com/tiffinbox/` into `.m2-demo` (git-ignored); no reactor build reads it.

## Commands

The three image builds and the host extraction, as `receipts.sh` reads them (`readme()`: the first line of this file that
matches; the script dies if one is missing). Each is run with its tag given a suffix — `recipe-on`, `recipe-at`, `single-on`, … —
and each build context is a folder under `.harness/` that holds the jar alone (or `extracted/` alone): no `secrets/` ever.

```
docker build -f docker/Dockerfile -t tiffinbox-layers:recipe .harness/ctx-recipe
docker build -f docker/single.Dockerfile -t tiffinbox-layers:single .harness/ctx-single
java -Djarmode=tools -jar after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --destination .harness/ctx-folders/extracted --application-filename application.jar
docker build -f docker/folders.Dockerfile -t tiffinbox-layers:folders .harness/ctx-folders
```

- `docker/Dockerfile` — **the recipe**: the two-stage shape Boot 4.1.1's reference documentation gives (Packaging › Container
  Images › Dockerfiles, read 2026-10-05): stage one copies the jar in and runs `java -Djarmode=tools -jar application.jar extract
  --layers --destination extracted`; stage two copies each layer folder, one `COPY` per layer, and starts `java -jar application.jar`.
  Three swaps, each named in its comment: the documentation's base image `bellsoft/liberica-openjre-debian:25-cds` → the official
  `eclipse-temurin:25-jre` (the only image family this course uses); its folder `/application` → `/app` (where the Section 3 brief
  mounts the config tree); its `ARG JAR_FILE=target/*.jar` → the jar's own name, the context being a folder that holds that jar alone.
- `docker/folders.Dockerfile` — B of the break: the same four layers **extracted on the host** (the third command above) and copied
  in as folders. The flipped attribute is where the jar is unpacked.
- `docker/single.Dockerfile` — the single-jar image: Boot's executable jar, a jar of jars, copied whole in one `COPY`. (Not a
  "fat jar": the executable-jar lesson keeps that word for Course 3's flattened jar.)
- `peek.sh IMAGE` — what `TiffinBoxServer`'s listening line says inside `IMAGE`, read from the image's own files and never by running
  it: a container is created (`tiffinbox-layers-peek`, never started), `/app/application.jar` is copied out, the container removed.

## The anchor change

One file changed, none new (README aside) — `change`, below, shows every changed code line:
- `pom.xml` (the root) — one property, `<project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>`, with a
  five-line comment (four until BLUE part B added part A's time-zone scope, RED #7): the same line and the same date Course 3's packaging POM carries (`../c3-unit23/pom.xml`, where its
  reproducible-build exercise put it). Every archive the build writes now stamps each entry with that instant instead of the build's
  clock (brief ⚑2).
- `README.md` (the anchor's) — a new section, *Course 5 · unit 14 — one fixed build time*: what the property changes, that the run
  command does not, which layer `tiffinbox-core` lands in and why (the reactor), and the warning about host-extracted layer folders.

**Nothing about building or running TiffinBox changes**: the build command, the jar's name and the run command are unit 13's. In
one time zone, two clean builds of `after/` now give one md5 (`moved`), and the four layers unpack to the same files. **Not in
two:** built with `TZ=UTC` and with `TZ=Asia/Kolkata`, the jars differ — every entry's name, content and date are the same (169),
but 8 entries under `BOOT-INF/classes/` carry an NTFS time field (extra field `0x000a`) 5.5 hours apart, the two zones' offset;
`tiffinbox-core`'s jar is byte for byte the same (measured, `moved`: RED #7). So this is "the same bytes in one time zone", not a
reproducible build in general. The builds here are not pinned to a zone: later units print jar md5s built in this Mac's own.
**No Dockerfile goes into the anchor** — the three here are this unit's instruments; the Dockerfile lesson gives TiffinBox its own.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token (unit 11). The one run that serves (`serve`) starts in `.harness/tree/`, which
holds a config tree, `secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that
is fake and looks it; `receipts.sh` writes it when it runs (`.harness/` is git-ignored). The token never reaches a command line:
the seven requests read it from the file (`$CURLSET PORT TOKENFILE`). **No Docker build context holds it**: every context is a
folder under `.harness/` holding a jar or `extracted/` alone, and the image runs here never mount it — the image's files are copied
out and run on the Mac. Every capture is masked — the token becomes `[masked: the 26-character token]` (`gsub`) — and `receipts.sh`
counts the raw token in each run's own output **before** masking (`.harness/raw-*`: 0 in all 27 capture runs), then in every
capture, this README, the anchor README, the exercise, `docker/`, `peek.sh` and `receipts.md5`: 0. Then **every image it built**:
the eight images are saved (`docker save`), and every layer after the base image's six is unpacked from its gzip and searched,
with every image config: 0 copies (the run of record: 0 raw copies in 27 raw capture runs, in 9 captures, the READMEs, the exercise, docker/, peek.sh and receipts.md5 - and in the 8 images' 11 distinct own layers (each after the base image's 6, unpacked) and 7 distinct configs; no absolute path in any capture). The builder counts it again in the script, the deck and the
prompter: 0.

## The folders, the variables, the ports and the Docker names

- `after/` — the frozen tree, built clean in place twice (the first build's jar kept as `.harness/after-1.jar`). `.harness/before/`
  — `../c5-unit13/after`, built clean twice (`.harness/before-1.jar`). `.harness/at/` — `after/` with one word changed:
  `TiffinBoxServer`'s listening line says `at` where it says `on` (`files` shows the one-line diff). `.harness/tick/` — `after/`,
  rebuilt by the timing capture with a fresh number at the end of that line, every round. `.harness/mine/` — the exercise's copy.
- Build contexts: `.harness/ctx-recipe/` and `.harness/ctx-single/` (a jar copied in before each build, so the jar is always new to the
  builder), `.harness/ctx-folders/` (`extracted/`, rewritten before each B build). BuildKit keeps one record per context folder of
  the files it was last sent: that record is what B trips over.
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson (the seven requests, POST
  /shutdown with the token's header read from a file) — its folder carries a unit number, so no slide prints the path;
  `$C3POM` = `../c3-unit23/pom.xml` (Course 3's packaging POM; `change` only).
- **Ports** (brief ⚑10, 18850-18859, checked free with `lsof` before anything is wiped, with 18425): `serve` 18850 — the only port
  bound. No container publishes a port.
- **Docker names** (no unit number, §R.4): images `tiffinbox-layers:recipe-on`, `-at`, `-again`, `-np1`, `-np2`, `single-on`, `single-at`,
  `folders-on`, `folders-at`, `folders-nocache`, `folders-touched`, `tick-recipe`, `tick-single`; containers `tiffinbox-layers-peek`
  and `tiffinbox-layers-copy`, each created and removed within one command line and never started. A tag is removed before it is
  rebuilt (no untagged image is left), and the exit trap removes every one of those names — after a pass, a failure or Ctrl-C.
  **BuildKit's build cache is left behind on purpose**: Docker has no selective prune, and a global prune would touch other
  people's cache on this daemon (a third-party container runs on it). `docker … prune` is never run.

## Masks, filters and hygiene — every one, declared

1. **Paths and the token:** in every line of every capture (`gsub()`, the patterns escaped as literals): the demo token →
   `[masked: the 26-character token]`; this folder's absolute path → `…`, also in its URL-encoded form; the folder above it →
   `…/..`; the home folder → `~`. A last check fails if any capture still holds `/Users/`, `/private/` or `/home/`.
2. **Docker's build logs** are kept in `.harness/` and read, never printed (they name the builder instance, and they carry image
   and layer digests). Read from them: the size `load build context` transferred (the last `transferring context:` value of that
   step), how many `COPY` steps were marked `CACHED`, lines that say `warn` (any case), layer downloads (`#N sha256:<64 hex> x / y`
   lines), `exporting attestation manifest` lines, and — in the timing capture — whether the jar's `COPY` (and the recipe's `RUN …
   extract`) ran or came from the cache.
3. **No ID or digest is printed.** Image IDs, container IDs and RootFS layer digests are compared and the comparison printed
   (`the same 10 · different 1`, `the two image IDs equal: no`); layer sizes come from `docker history --human=false` (each step's
   size, and the step as Docker records it).
4. **Durations are never in a capture.** They move from run to run — with other work on this Mac, one layered rebuild took
   3.139 s where they usually take 1.3-1.9 s — so the timing capture counts them — rebuilds under five seconds, and whether the layered image's median rebuild is the longer
   (a median of six, which one slow round cannot flip) — and the seconds themselves go to the terminal (*The timing*, below).
5. **Maven's logs** are kept in `.harness/build-*.log` (and `tick-build.log`) and read, never printed; `-q` is used only for the
   timing and exercise builds, whose exit code is checked.
6. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS`, `MAVEN_ARGS`, and the variables that change what `docker build` does or prints (`DOCKER_BUILDKIT`, `BUILDKIT_*`,
   `BUILDX_*`, `DOCKER_DEFAULT_PLATFORM`, `SOURCE_DATE_EPOCH`) before it runs anything (`DOCKER_HOST` and `DOCKER_CONTEXT` stay: they
   say which Docker to reach); it refuses to run twice at once in this folder (`.r-lock`), or with a `secrets/` in this folder; it
   removes its own image and container names before it starts.

**Interrupted.** `receipts.sh`'s exit trap stops the JVM it started in the background, if one still runs, removes its own two
container names and thirteen image tags, and drops the lock — on a failed check and on Ctrl-C alike (a background job of a
non-interactive shell ignores the terminal's Ctrl-C). Every command in the trap is guarded, so `set -e` cannot end it early, and
`$pid` is cleared after every reap. Tested 2026-10-05, the script started as its own process group with SIGINT at its default (`perl -e '$SIG{INT} = "DEFAULT"; setpgrp(0, 0); exec @ARGV' ./receipts.sh`): `SIGINT` sent to the whole group the moment `serve`'s JVM listened on 18850, with 8 of this unit's images on the daemon → `receipts.sh` exited 130; 5 s later 0 listeners on 18425 and 18850-18859, 0 java processes running the image's copied jar, 0 containers and 0 images named `tiffinbox-layers…`, and `.r-lock` gone. A second interrupt, sent mid-`docker build` in `stale` (8 images on the daemon), left the same: 0 containers, 0 images, no lock, nothing listening. (A first attempt, launched as a plain background job, could not be interrupted at all — *Found on the way*.) **Re-tested by BLUE the same day** on the new script, the same way, SIGINT to the group while the timing capture's
`tiffinbox-layers:tick-single` existed (101 s in): exit 130; 5 s later 0 listeners on 18425 and 18850-18859, 0 images named
`tiffinbox-layers:*`, 0 containers named `tiffinbox-layers-*`, 0 new images, no java process running a TiffinBox jar, `.r-lock`
gone.

## 1 · Layers — the index Boot wrote, and the four folders its tool makes

`.r-layers.out` `711aa10514a2b0c08c4a9261ee7cae40` — 22 lines

```
$ unzip -p after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar BOOT-INF/layers.idx     (each layer's lines counted)
  - "dependencies": 30 lines, every one a jar under BOOT-INF/lib/: yes
  - "spring-boot-loader": 1 line: org/
  - "snapshot-dependencies": 0 lines
  - "application": 5 lines: BOOT-INF/classes/ BOOT-INF/classpath.idx BOOT-INF/layers.idx BOOT-INF/lib/tiffinbox-core-1.0.0.jar META-INF/
  the jar: 169 entries, the index among them 1 · the manifest names it: Spring-Boot-Layers-Index: BOOT-INF/layers.idx
$ java -Djarmode=tools -jar after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar list-layers
  exit 0
  dependencies
  spring-boot-loader
  snapshot-dependencies
  application
$ java -Djarmode=tools -jar after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --launcher --destination .harness/layers
  exit 0 · printed: 0 line(s) · folders: application dependencies snapshot-dependencies spring-boot-loader
  dependencies           files 30 · bytes 15899411
  spring-boot-loader     files 99 · bytes 402297
  snapshot-dependencies  files 0 · bytes 0
  application            files 12 · bytes 37610
  the four: 141 files, 16339318 bytes · application's share of those bytes: 2.3 in 1,000
  what application holds: BOOT-INF/classes/ 5 files · BOOT-INF/classpath.idx BOOT-INF/layers.idx BOOT-INF/lib/tiffinbox-core-1.0.0.jar META-INF/MANIFEST.MF META-INF/maven/com.tiffinbox/tiffinbox-web/pom.properties META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml META-INF/services/java.nio.file.spi.FileSystemProvider
$ java -Djarmode=layertools -jar after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar list
  exit 1 · standard output 0 lines · Error: Unsupported jarmode 'layertools'
```

`BOOT-INF/layers.idx` names four layers and the paths in each — the 30 dependency jars one by one, the launcher as `org/`, nothing
for snapshots (TiffinBox has no `-SNAPSHOT` version), and the application's classes, the two indexes, `tiffinbox-core`'s jar and
`META-INF/`. The manifest points at it (`Spring-Boot-Layers-Index`). `extract --layers --launcher` writes one folder per layer,
each holding exactly what the jar holds for it: 141 files, and the application is 2.3 bytes in every 1,000 of them. The tool's
older mode name, `layertools` (what Course 3's unrendered note and many tutorials name), exits 1 on Boot 4.1.1. Course 3's "layered
jar — not a file format" still holds: an ordinary jar plus one index entry (ledger P16).

## 2 · The change — one property in the root POM

`.r-change.out` `7f9d78cc18b7ee6b3be976d2859f7077` — 7 lines

```
files, README aside: the previous tree 18 · after/ 18 · in both 18: identical 17, changed 1
  only before: (none)
  only after:  (none)
pom.xml, every changed line but comments and blanks (5 of those not shown):
+    <project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>
  removed 0 · added 1
the same line in Course 3's packaging POM ($C3POM), where its exercise put it: 1 time(s)
```

## 3 · Moved — each jar's layers, fingerprinted

`.r-moved.out` `fa0c6ce7704c36883859ef9b6a72bb01` — 46 lines

```
each jar unpacked by Boot's own tool, every layer folder hashed (each file's path and md5, sorted by path) - the flipped
  attribute: project.build.outputTimestamp, absent in the previous tree (the anchor before this lesson), present in after/:
one word changed, without it - the previous tree, then before-at/ (the same tree, TiffinBoxServer's listening line saying "at"
  where it says "on"):
$ java -Djarmode=tools -jar .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --launcher --destination .harness/moved/before
$ java -Djarmode=tools -jar .harness/before-at/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --launcher --destination .harness/moved/before-at
  the jar: 16134092 bytes, then 16134092 · md5 equal: no
  dependencies           30 files · same
  spring-boot-loader     99 files · same
  snapshot-dependencies  0 files · same
  application            12 files · moved: BOOT-INF/classes/com/tiffinbox/web/TiffinBoxServer.class BOOT-INF/lib/tiffinbox-core-1.0.0.jar
  layers that moved: 1 of 4
no change, built twice, without it - the previous tree:
$ java -Djarmode=tools -jar .harness/before-1.jar extract --layers --launcher --destination .harness/moved/before-1
  (build 2 is the previous tree's jar, unpacked above)
  the jar: 16134092 bytes, then 16134092 · md5 equal: no
  dependencies           30 files · same
  spring-boot-loader     99 files · same
  snapshot-dependencies  0 files · same
  application            12 files · moved: BOOT-INF/lib/tiffinbox-core-1.0.0.jar
  layers that moved: 1 of 4
  tiffinbox-core-1.0.0.jar, build 1 against build 2: entries 19 · the same content (CRC-32) 19 · the same time 1: META-INF/maven/com.tiffinbox/tiffinbox-core/pom.xml - it carries its source file's own time
no change, built twice, with it - after/:
$ java -Djarmode=tools -jar .harness/after-1.jar extract --layers --launcher --destination .harness/moved/after-1
$ java -Djarmode=tools -jar after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --launcher --destination .harness/moved/after
  the jar: 16133950 bytes, then 16133950 · md5 equal: yes
  dependencies           30 files · same
  spring-boot-loader     99 files · same
  snapshot-dependencies  0 files · same
  application            12 files · same
  layers that moved: 0 of 4
  tiffinbox-core-1.0.0.jar, build 1 against build 2: entries 19 · the same content (CRC-32) 19 · the same time 19 · the time every entry carries: 20260915.000000 (19 of 19)
one word changed, with it - after/, then at/ (after/ with the same word changed):
$ java -Djarmode=tools -jar .harness/at/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --launcher --destination .harness/moved/at
  (after/'s jar is unpacked above)
  the jar: 16133950 bytes, then 16133950 · md5 equal: no
  dependencies           30 files · same
  spring-boot-loader     99 files · same
  snapshot-dependencies  0 files · same
  application            12 files · moved: BOOT-INF/classes/com/tiffinbox/web/TiffinBoxServer.class
  layers that moved: 1 of 4
after/ built twice more, clean, with it - in two time zones, TZ=UTC and TZ=Asia/Kolkata:
  the jar: 16133950 bytes, then 16133950 · md5 equal: no
  tiffinbox-core-1.0.0.jar inside them, byte for byte the same: yes
  entries 169 and 169 · the same name, content (CRC-32) and date 169 · whose extra fields differ 8, every one under BOOT-INF/classes/: yes
  in what: their NTFS time field (extra field 0x000a) - 5.5 hours apart, every one
```

**A/B — the flipped attribute is the fixed time** (RED #5: the probe compared two trees that both had it). Without it (the
previous tree, and `before-at/`: the same tree with one word changed), one changed word moves **two** files of the application
layer: the changed class, and `tiffinbox-core-1.0.0.jar`, which nobody touched. With no change at all, that jar moves anyway: the
same 19 entries by content, 18 of them carrying the time of their build — the 19th, its `pom.xml`, carries the source file's own
time. With it (`after/`, then `at/`), every entry is dated `20260915.000000`, two builds have one md5, 0 of 4 layers move — and one
changed word moves one class file. Built in two named time zones, the jar differs in 8 entries' NTFS time field (above, and RED #7).

## 4 · Bytes — what one line makes new in two images

`.r-bytes.out` `d8e162ae24b2dd2b48f04de8d26dadf5` — 32 lines

```
the layered image - docker/Dockerfile, built for after/'s jar, then for at/'s (one word changed); each context holds the jar alone:
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build -f docker/Dockerfile -t tiffinbox-layers:recipe-on .harness/ctx-recipe
$ cp .harness/at/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build -f docker/Dockerfile -t tiffinbox-layers:recipe-at .harness/ctx-recipe
  exit 0, 0 · warnings in the two build logs: 0 · layer downloads in them: 0
  RootFS layers: 11 and 11 · the same 10 · different 1 · the base image's own layers first, unchanged: yes, 6 of 6
  the recipe's own steps in tiffinbox-layers:recipe-at - docker history --human=false, each one's size and step:
    0         ENTRYPOINT ["java" "-jar" "application.jar"]
    28672     COPY /builder/extracted/application/ ./ # buildkit
    0         COPY /builder/extracted/snapshot-dependencies/ ./ # buildkit
    0         COPY /builder/extracted/spring-boot-loader/ ./ # buildkit
    15966208  COPY /builder/extracted/dependencies/ ./ # buildkit
    0         WORKDIR /app
  the layer that differs, counted from the base up: 11 of 11
  the two, saved together (docker save): layers 22 · distinct layer files 10
the single-jar image - docker/single.Dockerfile, Boot's jar copied whole, the same two jars:
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-single/ && docker build -f docker/single.Dockerfile -t tiffinbox-layers:single-on .harness/ctx-single
$ cp .harness/at/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-single/ && docker build -f docker/single.Dockerfile -t tiffinbox-layers:single-at .harness/ctx-single
  exit 0, 0 · warnings in the two build logs: 0 · layer downloads in them: 0
  RootFS layers: 8 and 8 · the same 7 · different 1 · the base image's own layers first, unchanged: yes, 6 of 6
  its own steps in tiffinbox-layers:single-at - docker history --human=false, each one's size and step:
    0         ENTRYPOINT ["java" "-jar" "application.jar"]
    16134144  COPY tiffinbox-web-1.0.0.jar application.jar # buildkit
    0         WORKDIR /app
  the layer that differs, counted from the base up: 8 of 8
the layered image again - after/'s jar, nothing changed:
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build -f docker/Dockerfile -t tiffinbox-layers:recipe-again .harness/ctx-recipe
  exit 0 · RootFS layers, against tiffinbox-layers:recipe-on: 11 and 11 · the same 11 · different 0
  the two image IDs equal: no · what the ID names here: application/vnd.oci.image.index.v1+json · attestation manifests its build exported: 1
the same build twice more, with --provenance=false - no attestation in the image:
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build --provenance=false -f docker/Dockerfile -t tiffinbox-layers:recipe-np1 .harness/ctx-recipe
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build --provenance=false -f docker/Dockerfile -t tiffinbox-layers:recipe-np2 .harness/ctx-recipe
  exit 0, 0 · attestation manifests the two builds exported: 0 · RootFS layers: 11 and 11 · the same 11 · different 0 · the two image IDs equal: yes
```

The layered image is the base image's six layers, `WORKDIR`, and the four `COPY` layers; the single-jar image the six, `WORKDIR` and
one `COPY`. For the same one-word change, the layered image's 11th layer — the application `COPY`, 28,672 bytes — is the only new
one; the single-jar image's 8th — the whole jar, 16,134,144 bytes — is. (`docker history`'s sizes on this daemon — Docker 29.4.0 on
OrbStack, the containerd image store — are multiples of 4,096: `dependencies` 15,966,208, the jar 16,134,144; the files themselves
are 15,899,411 and 16,133,950 bytes. The deck says "here" beside every one: RED #20.) **Saved together** (`docker save`, an OCI
layout: one file per layer content, named by its digest), the two layered images' 22 layers are 10 files: the shared ones are kept
once — and the three empty layers (`WORKDIR`, `spring-boot-loader`, `snapshot-dependencies`) are one file. That is what layers save:
bytes to store and to move. The voice says "Saved together, the two images keep each shared layer once" and claims nothing about a
registry, which this unit does not run (RED #10). The `spring-boot-loader` layer is empty because the recipe extracts without
`--launcher`: its thin jar starts TiffinBox itself, and `/app` holds `application.jar` and `lib/` alone (`serve`; RED #21). Rebuilt with nothing
changed, the recipe's image has the same eleven layers and **another ID**: the ID is the digest of an OCI image index, and each build
adds a provenance attestation — a record of how and when the image was built — to it. Built twice with `--provenance=false`, the two
IDs are equal. Image IDs are not witnesses; compare layers (brief S3.12).

## 5 · Stale — the break: where the jar is unpacked (A/B/A′, with C and D)

`.r-stale.out` `0c8760ba3f16bc2dab18319bfbc59c09` — 40 lines

```
the change: TiffinBoxServer's listening line, "on" -> "at" - the thin jar Boot's tool writes from each, side by side:
  application.jar: 11675 bytes and 11675 · the same size: yes · the same file time: yes · md5 equal: no
A   docker/Dockerfile - Boot's extract runs INSIDE the build:
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build -f docker/Dockerfile -t tiffinbox-layers:recipe-on .harness/ctx-recipe
  exit 0
$ ./peek.sh tiffinbox-layers:recipe-on
  TiffinBox listening on
$ cp .harness/at/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build -f docker/Dockerfile -t tiffinbox-layers:recipe-at .harness/ctx-recipe
  exit 0 · transferring context: 16.14MB
$ ./peek.sh tiffinbox-layers:recipe-at
  TiffinBox listening at
B   docker/folders.Dockerfile - the same four layers, extracted on the Mac, copied in as folders:
$ rm -rf .harness/ctx-folders/extracted && java -Djarmode=tools -jar after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --destination .harness/ctx-folders/extracted --application-filename application.jar && docker build -f docker/folders.Dockerfile -t tiffinbox-layers:folders-on .harness/ctx-folders
  exit 0
$ ./peek.sh tiffinbox-layers:folders-on
  TiffinBox listening on
$ rm -rf .harness/ctx-folders/extracted && java -Djarmode=tools -jar .harness/at/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --destination .harness/ctx-folders/extracted --application-filename application.jar && docker build -f docker/folders.Dockerfile -t tiffinbox-layers:folders-at .harness/ctx-folders
  exit 0 · transferring context: 2.63kB - less than the thin jar alone (11675 bytes): yes · COPY steps CACHED: 4 of 4
$ ./peek.sh tiffinbox-layers:folders-at
  TiffinBox listening on
C   B's last build again, with --no-cache:
$ docker build --no-cache -f docker/folders.Dockerfile -t tiffinbox-layers:folders-nocache .harness/ctx-folders
  exit 0 · transferring context: 2.63kB - less than the thin jar alone (11675 bytes): yes · COPY steps CACHED: 0 of 4
$ ./peek.sh tiffinbox-layers:folders-nocache
  TiffinBox listening on
D   B's last build again, the thin jar's file time set to now first:
$ touch .harness/ctx-folders/extracted/application/application.jar && docker build -f docker/folders.Dockerfile -t tiffinbox-layers:folders-touched .harness/ctx-folders
  exit 0 · transferring context: 14.32kB - less than the thin jar alone (11675 bytes): no · COPY steps CACHED, the three layers the change leaves alone: 3 of 3
$ ./peek.sh tiffinbox-layers:folders-touched
  TiffinBox listening at
A′  A, re-run:
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build -f docker/Dockerfile -t tiffinbox-layers:recipe-on .harness/ctx-recipe
  exit 0
$ ./peek.sh tiffinbox-layers:recipe-on
  TiffinBox listening on
$ cp .harness/at/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build -f docker/Dockerfile -t tiffinbox-layers:recipe-at .harness/ctx-recipe
  exit 0 · transferring context: 16.14MB
$ ./peek.sh tiffinbox-layers:recipe-at
  TiffinBox listening at
warnings in the ten build logs: 0 · layer downloads in them: 0
```

The change keeps the thin jar's size (11,675 bytes) and its file time (the extract tool dates it from the fixed build time), and
changes its bytes. **A**, the recipe, sends the whole 16 MB jar in its context and extracts inside the build: the image says `at`.
**B** extracts on the host and copies the folders: BuildKit's context transfer compares each file's size and time with what it was
sent for that folder last time, finds the thin jar unchanged, and sends 2.63 kB — less than the jar. Every `COPY` is then
`CACHED`, and the image keeps yesterday's class: `on`. **C**, B with `--no-cache`, runs every `COPY` again — from the same stale
copy: `on`. **D**, B with the thin jar touched first, sends it (14.32 kB, no longer less than the jar) and the image says `at`. D's
capture counts only the three `COPY` steps the change leaves alone (`dependencies`, `spring-boot-loader`, `snapshot-dependencies`:
3 of 3 `CACHED`). **Corrected (RED #8):** an earlier note here said D's four `COPY` steps were all `CACHED` "because BuildKit's cache
keys on content, and this time the content was new" — new content is a cache **miss**; the fourth was `CACHED` only because an
earlier run on this Docker had already copied that content. Measured by BLUE from a fresh BuildKit cache chain of its own (a copy
of `docker/folders.Dockerfile` with a `WORKDIR` no build had used, the two jars copied with their times kept; nothing pruned):
the first touched build, all `COPY` steps 3 of 4 and the three unchanged 3 of 3; the second, 4 of 4 and 3 of 3; B's 4 of 4 and
C's 0 of 4 the same in both passes. **A′** = A, line for line. The flipped attribute is where the jar is unpacked; the trap needs
three things together (RED #9) — the fixed build time (extract dates the thin jar from the jar's own time, which the build sets to
the fixed instant), a same-size change, and an earlier transfer of the same folder; with plain `cp`, which gives the copied jars
new times, the same probe's B image said `at`. That is why the recipe extracts inside the build, and why the recap says "after a
same-size change".

## 6 · Timing — the clock, against five seconds

`.r-timing.out` `6951fe9acd3d2a29c5ddd048a787cca7` — 11 lines

```
six rounds after one warm-up round; each round: a fresh number at the end of TiffinBoxServer's listening line (never built
  before, so neither image can come from the cache), mvn -o clean package, a one-second pause, then both images rebuilt,
  each timed by bash:
$ time docker build -f docker/Dockerfile -t tiffinbox-layers:tick-recipe .harness/ctx-recipe > .harness/tick-r.log 2>&1
$ time docker build -f docker/single.Dockerfile -t tiffinbox-layers:tick-single .harness/ctx-single > .harness/tick-f.log 2>&1
  every timed build re-ran its jar step, none from the cache: 12 of 12
  rebuilds under five seconds: the layered image 6 of 6 · the single-jar image 6 of 6
  the median of the six - the layered image's longer than the single-jar image's: yes
  COPY and RUN steps each rebuild ran, not from the cache - the layered image: 3 of 6, one a java process in 6 of 6 · the single-jar image: 1 of 1 in 6 of 6
the course after Course 3 - Spring Framework Core, the c4- folders of this repository:
  folders 33 · files named Dockerfile in them 0 · files that say docker, any case 0
```

## 7 · Serve — the layered image's own files, on the Mac

`.r-serve.out` `4452d4bacab645a9fb6211f9873ca981` — 11 lines

```
the layered image's /app, copied out (the container is created, never started), then run on the Mac with the image's own command:
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-recipe/ && docker build -f docker/Dockerfile -t tiffinbox-layers:recipe-on .harness/ctx-recipe
  exit 0 · the image's ENTRYPOINT: ["java","-jar","application.jar"]
$ docker create --name tiffinbox-layers-copy tiffinbox-layers:recipe-on > /dev/null && docker cp -q tiffinbox-layers-copy:/app .harness/fromimage && docker rm tiffinbox-layers-copy > /dev/null
  exit 0 · .harness/fromimage: application.jar lib · lib/: 31 jars
  against Boot's extract of after/'s jar on the Mac (--application-filename application.jar): lib/ byte for byte the same 31 of 31 · application.jar's entries, by name and content (CRC-32), the same 15 of 15
$ cd .harness/tree && java -jar ../fromimage/application.jar --tiffinbox.port=18850
  listens on: 127.0.0.1:18850 · WARN lines 0 · ERROR lines 0
$ $CURLSET 18850 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

TiffinBox binds `127.0.0.1` in code, so a port published from a container reaches nothing until the next lesson gives it an
address (brief finding 7, ⚑3) — no container runs TiffinBox here. Instead `/app` is copied out of a created, never-started container,
compared with Boot's extract of the same jar on the Mac (lib/ byte for byte; the thin jar entry by entry, by content), and started
with the image's own command, `java -jar application.jar`: the seven responses hash to `115c36bac276128e245ca57df11c2891`.

## 8 · Exercise — which layer `tiffinbox-core` lands in

`.r-exercise.out` `0b815b353d918576021cf8d4ff5a69e9` — 21 lines

```
exercise/README.md's commands, read from the file and run as written, in order (its two export lines aside):
$ rm -rf .harness/mine && mkdir -p .harness && rsync -a --exclude target after/ .harness/mine/
  exit 0
$ mvn -o -q -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests install
  exit 0
$ perl -pi -e 's/must be 16 characters or more/must have 16 characters or more/' .harness/mine/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
  exit 0
$ mvn -o -q -B -f .harness/mine/tiffinbox-web/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
  exit 0
$ rm -rf .harness/mine-layers && java -Djarmode=tools -jar .harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --destination .harness/mine-layers
  exit 0
$ find .harness/mine-layers -name 'tiffinbox-core-*.jar'
  exit 0
  .harness/mine-layers/dependencies/lib/tiffinbox-core-1.0.0.jar
$ unzip -p "$(find .harness/mine-layers -name 'tiffinbox-core-*.jar')" com/tiffinbox/TiffinBoxProperties.class | LC_ALL=C grep -aoE 'must [a-z]+ 16 characters'
  exit 0
  must be 16 characters
the line the perl command changed, in .harness/mine's own source: 1 time(s)
the same jar's index - where layers.idx puts tiffinbox-core:
  - "dependencies":   - "BOOT-INF/lib/"
  after/'s own jar, built from the root: - "application":   - "BOOT-INF/lib/tiffinbox-core-1.0.0.jar"
```

`exercise/README.md`'s commands, read from the file and run as written (their two `export` lines aside — `receipts.sh` has them).
Built from the root, the reactor builds `tiffinbox-core` too, and Boot's index puts it in `application`; built alone, `tiffinbox-web`
takes `tiffinbox-core` from the local repository, as a library — `dependencies` lists `BOOT-INF/lib/` whole — and the copy it took
is the one installed **before** the change: `must be`, not `must have`. Measured with the edit, as the brief asked
(`exercise/solution/SOLUTION.md`: the README run exactly as written in a clean shell).

## 9 · The demo files, against the files they stand in for

`.r-files.out` `4e973b7d095b71657aba8d010728612e` — 80 lines

```
docker/Dockerfile - the recipe, whole:
  # The two-stage shape of Boot's reference documentation (4.1.1, "Dockerfiles") - its base image, its folder and its jar
  # argument swapped for eclipse-temurin:25-jre, /app and the jar's own name. Its context: a folder holding that jar alone.
  # Stage one copies the jar in and runs Boot's extract tool INSIDE the build.
  FROM eclipse-temurin:25-jre AS builder
  WORKDIR /builder
  COPY tiffinbox-web-1.0.0.jar application.jar
  RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted
  
  # Stage two copies each layer folder: one COPY, one image layer.
  FROM eclipse-temurin:25-jre
  WORKDIR /app
  COPY --from=builder /builder/extracted/dependencies/ ./
  COPY --from=builder /builder/extracted/spring-boot-loader/ ./
  COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
  COPY --from=builder /builder/extracted/application/ ./
  ENTRYPOINT ["java", "-jar", "application.jar"]
docker/folders.Dockerfile, against docker/Dockerfile:
  1,9c1,2
  < # The two-stage shape of Boot's reference documentation (4.1.1, "Dockerfiles") - its base image, its folder and its jar
  < # argument swapped for eclipse-temurin:25-jre, /app and the jar's own name. Its context: a folder holding that jar alone.
  < # Stage one copies the jar in and runs Boot's extract tool INSIDE the build.
  < FROM eclipse-temurin:25-jre AS builder
  < WORKDIR /builder
  < COPY tiffinbox-web-1.0.0.jar application.jar
  < RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted
  < 
  < # Stage two copies each layer folder: one COPY, one image layer.
  ---
  > # The same four layers, extracted on the Mac - in the context, by Boot's extract tool, before the build - and copied in as
  > # folders. Its context: a folder that holds extracted/ and nothing else.
  12,15c5,8
  < COPY --from=builder /builder/extracted/dependencies/ ./
  < COPY --from=builder /builder/extracted/spring-boot-loader/ ./
  < COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
  < COPY --from=builder /builder/extracted/application/ ./
  ---
  > COPY extracted/dependencies/ ./
  > COPY extracted/spring-boot-loader/ ./
  > COPY extracted/snapshot-dependencies/ ./
  > COPY extracted/application/ ./
docker/single.Dockerfile, against docker/Dockerfile:
  1,9c1,2
  < # The two-stage shape of Boot's reference documentation (4.1.1, "Dockerfiles") - its base image, its folder and its jar
  < # argument swapped for eclipse-temurin:25-jre, /app and the jar's own name. Its context: a folder holding that jar alone.
  < # Stage one copies the jar in and runs Boot's extract tool INSIDE the build.
  < FROM eclipse-temurin:25-jre AS builder
  < WORKDIR /builder
  < COPY tiffinbox-web-1.0.0.jar application.jar
  < RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted
  < 
  < # Stage two copies each layer folder: one COPY, one image layer.
  ---
  > # The single-jar image: Boot's executable jar - a jar of jars - copied whole, in one COPY. Its context: a folder that holds
  > # tiffinbox-web-1.0.0.jar and nothing else.
  12,15c5
  < COPY --from=builder /builder/extracted/dependencies/ ./
  < COPY --from=builder /builder/extracted/spring-boot-loader/ ./
  < COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
  < COPY --from=builder /builder/extracted/application/ ./
  ---
  > COPY tiffinbox-web-1.0.0.jar application.jar
at/'s TiffinBoxServer.java, against after/'s:
  204c204
  <         LOG.log(INFO, "TiffinBox listening on http://127.0.0.1:" + port);
  ---
  >         LOG.log(INFO, "TiffinBox listening at http://127.0.0.1:" + port);
peek.sh, whole:
  #!/bin/sh
  # peek.sh IMAGE: what TiffinBoxServer's listening line says inside IMAGE - read from the image's own files, never by running
  # it. A container is created (never started), /app/application.jar is copied out of it, and the container is removed.
  set -e
  n=tiffinbox-layers-peek
  t=$(mktemp)
  docker rm -f "$n" > /dev/null 2>&1 || true
  docker create --name "$n" "$1" > /dev/null
  docker cp -q "$n":/app/application.jar "$t"
  docker rm "$n" > /dev/null
  unzip -p "$t" com/tiffinbox/web/TiffinBoxServer.class | LC_ALL=C grep -aoE 'TiffinBox listening [a-z]+' || echo "(no listening line)"
  rm -f "$t"
```

## The timing — one run's seconds (never a capture)

The seconds the timing capture counted, as `receipts.sh` printed them on the terminal (BLUE's run of record, 2026-10-05, under
`/bin/bash`: three capture runs of six rounds; the warm-up round not counted):

```
layered 1.453 1.474 1.442 1.443 1.444 1.458 (median 1.449) / single-jar 1.173 1.163 1.128 1.196 1.189 1.167 (median 1.170)
layered 1.772 1.445 1.405 1.553 1.548 1.457 (median 1.502) / single-jar 1.363 1.167 1.197 1.154 1.175 1.152 (median 1.171)
layered 2.036 1.500 1.483 1.586 1.912 1.495 (median 1.543) / single-jar 1.259 1.195 1.140 1.181 1.232 1.147 (median 1.188)
```

In this run of record, the layered rebuilds took 1.405-2.036 s and the single-jar ones 1.128-1.363 s; every one under five
seconds, the layered median the longer in each capture run. Earlier runs the same day (the image then named "fat"): the run of
record before BLUE's changes printed layered 1.421-1.861 s and fat-jar 1.142-1.432 s; one run with this Mac heavily loaded (load
average near 10 on 8 cores) had a layered rebuild at 3.139 s — which is why the capture counts against five seconds and compares
medians. The probe's ranges (layered 0.605-1.456 s, fat 0.495-1.093 s) were faster than any run here.

## The posted Course 3 correction, against this measurement

The comment posted on Course 3 unit 23's video on 2026-10-05 makes five points (paraphrased here, except its own words "a few
seconds"): the next course (Spring Framework Core) builds no container image; images arrive in this lesson; measured on
TiffinBox, the layered image did not rebuild faster; both rebuilds took a few seconds; what the layers save is bytes — after a
small change only the small application layer is new. **This unit's measurement agrees on all five.** Course 4's 33 folders hold 0
Dockerfiles and 0 files that say docker (`timing`); the layered image was not the faster one — its median rebuild the longer in
every capture run, and each of its rebuilds runs a java process, `extract` (`timing`); every rebuild took under five seconds, 12 of
12 per capture run (`timing`); the one new layer is the application's, 28,672 bytes here, against the single-jar image's 16,134,144
(`bytes`). An earlier version of this note quoted the comment as "under two seconds" — it never said that (RED #24); "under two
seconds" was this unit's own first threshold, dropped when a heavily loaded run went past it (*The timing*, above).

## Found on the way

- **The application layer is 37,610 bytes of 16,339,318 (12 files)**, not the probe's 36,896 of 16,338,604 — this anchor's jar; the
  share is still about 2 in 1,000.
- **B's context transfer is 2.63 kB, not the probe's 2.33 kB** (this tree's folders); D's, with the thin jar touched, 14.32 kB.
- **`tiffinbox-core`'s jar without the timestamp: 18 of 19 entries dated by the build** — the 19th, `META-INF/maven/…/pom.xml`,
  keeps the source file's own time.
- **The image IDs differ because of the provenance attestation**, not the image config: with `--provenance=false`, two builds of
  the same layers have one ID (`bytes`).
- **BuildKit's `CACHED` is not the bug**: B's image is wrong because the context never carried the new content. (An earlier note
  here said D's four `COPY` steps were all `CACHED` "because the cache keys on content" — new content is a cache miss, and D's
  fourth was `CACHED` only because an earlier run had copied it: D now counts the three unchanged layers. RED #8, *Stale*.)
- **Boot's extract writes two of the thin jar's entry times in the machine's own time zone**: extracted on this Mac (CEST), the thin
  jar differs from the one the image's build extracted (UTC) in the times of `META-INF/MANIFEST.MF` and `META-INF/services/`
  (measured once while building this unit; with `TZ=UTC`, byte for byte the same). Not a capture: the result depends on the
  machine's zone. `serve` therefore compares the thin jar entry by entry, by content, and `lib/` byte for byte.
- **A run started in the background of a script ignores Ctrl-C altogether.** A non-interactive shell starts its background jobs
  with SIGINT ignored, and a shell that starts with a signal ignored cannot trap it: the first interrupt test, launched that way,
  sent SIGINT to the whole process group while `serve`'s JVM listened — and `receipts.sh` ran on to the end (exit 0, every capture
  `= published`, nothing left behind). Run it in a terminal's foreground, or give the signal back its default first, as the test
  of record does (*Interrupted*, above).
- **`docker history`'s sizes are multiples of 4,096 here** (the containerd snapshotter's disk usage): 28,672 bytes is the
  application layer's 27,250 bytes of files on disk, not a tar size.
- **The single-jar image needs no Boot tooling to build** — its rebuild is faster than the recipe's, which starts a JVM to run
  `extract` in every build where the jar changed: counted in `timing`, the layered rebuild ran 3 of its 6 `COPY` and `RUN` steps, one
  of them a java process, and the single-jar rebuild 1 of 1 (RED #19).

## For the next unit — 15 — and for RED

**Start from `c5-unit14/after/`** (copy it with `rsync -a --exclude target`, or build it in place:
`mvn -o -B -f ../c5-unit14/after/pom.xml -Dmaven.repo.local=<your .m2-demo> -DskipTests clean package`):
- **Unchanged from unit 13:** the jar runs alone (`java -jar <after>/tiffinbox-web/target/tiffinbox-web-1.0.0.jar
  --tiffinbox.port=<port>`, no `lib/`); the token from a folder holding `secrets/tiffinbox/shutdown-token` (umask 077, the token and
  a newline) or `TIFFINBOX_SHUTDOWN_TOKEN`; a harness class path from `java -Djarmode=tools -jar <jar> extract --destination
  .harness/x` (a destination that exists and is not empty stops it — remove it first), then `java -cp
  ".harness/classes:.harness/x/tiffinbox-web-1.0.0.jar:.harness/x/lib/*" <Main>`; the seven: `../c5-unit11/curlset.sh PORT
  TOKENFILE` → `115c36bac276128e245ca57df11c2891`.
- **New: the same bytes, in one time zone.** `project.build.outputTimestamp` = `2026-09-15T00:00:00Z` in the root POM: two clean
  builds of `after/` → one md5 (`927d962c91b776b2d9251f58d17cfa5c`, 16,133,950 bytes, on this Mac, in its zone, Europe/Rome); every
  entry of `tiffinbox-core`'s jar is dated `20260915.000000`. **Another zone gives another jar md5** (`moved`: UTC against
  Asia/Kolkata, 8 entries' NTFS time 5.5 hours apart): a receipt that prints a jar md5 holds in this Mac's zone only — say so, or
  build with `TZ` set and say that (RED #7). An image built twice from one jar has identical layers.
- **The layers:** `tiffinbox-core` is in `application` only in a reactor build from the root; a build of `tiffinbox-web` alone
  (`-f tiffinbox-web/pom.xml`, measured here; `-pl tiffinbox-web` without `-am`, measured by the probe) takes it from the local
  repository into `dependencies` — and takes the **installed** copy, whatever the source says (the exercise). A root `install`
  builds the jar with `tiffinbox-core` in `application` (the `layers` capture's index); that is the jar `build-image-no-fork`
  would pack — not measured here.
- **Docker, as measured here:** OrbStack, context `orbstack`, server 29.4.0, the containerd image store (an image ID is an OCI index
  digest, and each build adds a provenance attestation: compare RootFS layers, never IDs); `eclipse-temurin:25-jre` is present
  (`eclipse-temurin@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636`); BuildKit's cache holds this unit's
  layers (left on purpose). The image `tiffinbox-layers:*` names are this unit's and are removed after every run — use your own
  (⚑11: `tiffinbox-web:1.0.0` for the buildpack image).
- **If an image of yours copies host-extracted layer folders, it can ship a stale class** (`stale` B): with the fixed timestamp,
  a same-size change keeps the extracted files' size and time, and BuildKit's context transfer skips them. Extract inside the build
  (the recipe), or keep the extraction out of the context.
- **Still true:** TiffinBox binds `127.0.0.1` in code (`TiffinBoxServer.java` line 193, `new InetSocketAddress("127.0.0.1", port)`;
  `serve`: `listens on: 127.0.0.1:18850`). The probe measured that a port published from a container then answers nothing (curl
  exit 52) until ⚑3's `tiffinbox.address` lands — the next lesson's anchor change. This unit never served from a container.
- **RED:** the timing capture is the one most likely to drift on another machine or a very busy one (a rebuild past five seconds,
  or the medians flipping); the brief's 36,896 / 2.33 kB figures do not hold for this anchor (above). BLUE (2026-10-05) answered
  RED rows 5-10 and 18-24 here: `moved` is an A/B now, the TZ dependence is measured, `fat` is `single`, D counts the three
  unchanged layers, and both bashes give the published hashes.

## Exercise

`exercise/README.md` — in `.harness/mine`, a copy of `after/`: install it once, change one line of `tiffinbox-core`
(`TiffinBoxProperties`' validation message, `must be` → `must have`), package only `tiffinbox-web`, extract its layers, and find
which layer `tiffinbox-core-1.0.0.jar` landed in — and whether the changed line is in it. Done when `find` prints one path. Run
exactly as written in a clean shell (`env -i`): `exercise/solution/SOLUTION.md`.
