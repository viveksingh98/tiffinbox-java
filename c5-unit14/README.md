# c5-unit14 — Layered Jars and Image Caching

Course 5 · Spring Boot · Section 3 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, Docker 29.4.0
(OrbStack; client 29.5.1, buildx 0.33.0, BuildKit 0.29.0)**, 2026-10-05, on an 8-core 16 GB Apple-silicon Mac.
Change one line of TiffinBox and the jar is a whole new 16,133,950-byte file. Boot's jar already carries an index,
`BOOT-INF/layers.idx`, that sorts it into four layers; this unit counts them, changes one line and fingerprints each layer, finds
the layer that moves with **no** change at all (the build's clock inside `tiffinbox-core`'s jar), and fixes that with one
property in the root POM — `project.build.outputTimestamp`, Course 3's reproducible-build exercise, landed in the anchor. Then
Docker: three Dockerfiles in `docker/`, the bytes a one-line change makes new in a layered image and in a fat-jar image, the
clock for both rebuilds, two image IDs that differ with no layer changed, and a build cache that hands the image yesterday's
class when the layers are extracted on the host.

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it (`diff -rq -x target` empty). "Before" is
`../c5-unit13/after/` (the anchor as the last unit to change it left it), **copied** to `.harness/before/`. Nothing here writes into
another unit's folder. Clean builds, offline; every number the video speaks is asserted; three runs per capture; and no capture,
no README, no slide and **no layer of any image this unit builds** holds the demo token (masked, and counted: *The demo token*).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens, image layers included; a published-md5 mismatch stops it
```

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
matches; the script dies if one is missing). Each is run with its tag given a suffix — `recipe-on`, `recipe-at`, `fat-on`, … —
and each build context is a folder under `.harness/` that holds the jar alone (or `extracted/` alone): no `secrets/` ever.

```
docker build -f docker/Dockerfile -t tiffinbox-layers:recipe .harness/ctx-recipe
docker build -f docker/fat.Dockerfile -t tiffinbox-layers:fat .harness/ctx-fat
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
- `docker/fat.Dockerfile` — the fat-jar image: one `COPY` of the whole jar.
- `peek.sh IMAGE` — what `TiffinBoxServer`'s listening line says inside `IMAGE`, read from the image's own files and never by running
  it: a container is created (`tiffinbox-layers-peek`, never started), `/app/application.jar` is copied out, the container removed.

## The anchor change

One file changed, none new (README aside) — `change`, below, shows every changed code line:
- `pom.xml` (the root) — one property, `<project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>`, with a
  four-line comment: the same line and the same date Course 3's packaging POM carries (`../c3-unit23/pom.xml`, where its
  reproducible-build exercise put it). Every archive the build writes now stamps each entry with that instant instead of the build's
  clock (brief ⚑2).
- `README.md` (the anchor's) — a new section, *Course 5 · unit 14 — one fixed build time*: what the property changes, that the run
  command does not, which layer `tiffinbox-core` lands in and why (the reactor), and the warning about host-extracted layer folders.

**Nothing about building or running TiffinBox changes**: the build command, the jar's name and the run command are unit 13's. The
jar is now byte-reproducible: two clean builds of `after/` give one md5 (`moved`), and the four layers unpack to the same files.
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
with every image config: 0 copies (the run of record: 0 raw copies in 27 raw capture runs, in 9 captures, the READMEs, the exercise, docker/, peek.sh and receipts.md5 - and in the 8 images' 12 distinct own layers (each after the base image's 6, unpacked) and 7 distinct configs; no absolute path in any capture). The builder counts it again in the script, the deck and the
prompter: 0.

## The folders, the variables, the ports and the Docker names

- `after/` — the frozen tree, built clean in place twice (the first build's jar kept as `.harness/after-1.jar`). `.harness/before/`
  — `../c5-unit13/after`, built clean twice (`.harness/before-1.jar`). `.harness/at/` — `after/` with one word changed:
  `TiffinBoxServer`'s listening line says `at` where it says `on` (`files` shows the one-line diff). `.harness/tick/` — `after/`,
  rebuilt by the timing capture with a fresh number at the end of that line, every round. `.harness/mine/` — the exercise's copy.
- Build contexts: `.harness/ctx-recipe/` and `.harness/ctx-fat/` (a jar copied in before each build, so the jar is always new to the
  builder), `.harness/ctx-folders/` (`extracted/`, rewritten before each B build). BuildKit keeps one record per context folder of
  the files it was last sent: that record is what B trips over.
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson (the seven requests, POST
  /shutdown with the token's header read from a file) — its folder carries a unit number, so no slide prints the path;
  `$C3POM` = `../c3-unit23/pom.xml` (Course 3's packaging POM; `change` only).
- **Ports** (brief ⚑10, 18850-18859, checked free with `lsof` before anything is wiped, with 18425): `serve` 18850 — the only port
  bound. No container publishes a port.
- **Docker names** (no unit number, §R.4): images `tiffinbox-layers:recipe-on`, `-at`, `-again`, `-np1`, `-np2`, `fat-on`, `fat-at`,
  `folders-on`, `folders-at`, `folders-nocache`, `folders-touched`, `tick-recipe`, `tick-fat`; containers `tiffinbox-layers-peek`
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
`$pid` is cleared after every reap. Tested 2026-10-05, the script started as its own process group with SIGINT at its default (`perl -e '$SIG{INT} = "DEFAULT"; setpgrp(0, 0); exec @ARGV' ./receipts.sh`): `SIGINT` sent to the whole group the moment `serve`'s JVM listened on 18850, with 8 of this unit's images on the daemon → `receipts.sh` exited 130; 5 s later 0 listeners on 18425 and 18850-18859, 0 java processes running the image's copied jar, 0 containers and 0 images named `tiffinbox-layers…`, and `.r-lock` gone. A second interrupt, sent mid-`docker build` in `stale` (8 images on the daemon), left the same: 0 containers, 0 images, no lock, nothing listening. (A first attempt, launched as a plain background job, could not be interrupted at all — *Found on the way*.)

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

`.r-change.out` `462d56c770cc8b6bb46582a6cd2809bd` — 7 lines

```
files, README aside: the previous tree 18 · after/ 18 · in both 18: identical 17, changed 1
  only before: (none)
  only after:  (none)
pom.xml, every changed line but comments and blanks (4 of those not shown):
+    <project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>
  removed 0 · added 1
the same line in Course 3's packaging POM ($C3POM), where its exercise put it: 1 time(s)
```

## 3 · Moved — each jar's layers, fingerprinted

`.r-moved.out` `eba7734243a3910b46a734bd9f843d41` — 30 lines

```
each jar unpacked by Boot's own tool, every layer folder hashed (each file's path and md5, sorted by path):
one line changed - after/, then at/ (after/ with TiffinBoxServer's listening line saying "at" where it says "on"):
$ java -Djarmode=tools -jar after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --launcher --destination .harness/moved/after
$ java -Djarmode=tools -jar .harness/at/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --launcher --destination .harness/moved/at
  the jar: 16133950 bytes, then 16133950 · md5 equal: no
  dependencies           30 files · same
  spring-boot-loader     99 files · same
  snapshot-dependencies  0 files · same
  application            12 files · moved: BOOT-INF/classes/com/tiffinbox/web/TiffinBoxServer.class
  layers that moved: 1 of 4
no change, built twice - the previous tree (the anchor before this lesson: no project.build.outputTimestamp):
$ java -Djarmode=tools -jar .harness/before-1.jar extract --layers --launcher --destination .harness/moved/before-1
$ java -Djarmode=tools -jar .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --launcher --destination .harness/moved/before-2
  the jar: 16134092 bytes, then 16134092 · md5 equal: no
  dependencies           30 files · same
  spring-boot-loader     99 files · same
  snapshot-dependencies  0 files · same
  application            12 files · moved: BOOT-INF/lib/tiffinbox-core-1.0.0.jar
  layers that moved: 1 of 4
  tiffinbox-core-1.0.0.jar, build 1 against build 2: entries 19 · the same content (CRC-32) 19 · the same time 1: META-INF/maven/com.tiffinbox/tiffinbox-core/pom.xml - it carries its source file's own time
no change, built twice - after/, with it:
$ java -Djarmode=tools -jar .harness/after-1.jar extract --layers --launcher --destination .harness/moved/after-1
  (build 2 is after/'s jar, unpacked above)
  the jar: 16133950 bytes, then 16133950 · md5 equal: yes
  dependencies           30 files · same
  spring-boot-loader     99 files · same
  snapshot-dependencies  0 files · same
  application            12 files · same
  layers that moved: 0 of 4
  tiffinbox-core-1.0.0.jar, build 1 against build 2: entries 19 · the same content (CRC-32) 19 · the same time 19 · the time every entry carries: 20260915.000000 (19 of 19)
```

One changed word moves one class file, and only the application layer. With no change at all, the previous tree's application
layer moves anyway: `tiffinbox-core-1.0.0.jar` has the same 19 entries by content, and 18 of them carry the time of their build —
the 19th, its `pom.xml`, carries the source file's own time. With the timestamp, every entry is dated `20260915.000000`, the two
Boot jars have one md5, and not one layer moves.

## 4 · Bytes — what one line makes new in two images

`.r-bytes.out` `0e70a8721068f621f4ae8cba481b3555` — 31 lines

```
the layered image - docker/Dockerfile, built for after/'s jar, then for at/'s (one line changed); each context holds the jar alone:
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
the fat-jar image - docker/fat.Dockerfile, the same two jars:
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-fat/ && docker build -f docker/fat.Dockerfile -t tiffinbox-layers:fat-on .harness/ctx-fat
$ cp .harness/at/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/ctx-fat/ && docker build -f docker/fat.Dockerfile -t tiffinbox-layers:fat-at .harness/ctx-fat
  exit 0, 0 · warnings in the two build logs: 0 · layer downloads in them: 0
  RootFS layers: 8 and 8 · the same 7 · different 1 · the base image's own layers first, unchanged: yes, 6 of 6
  its own steps in tiffinbox-layers:fat-at - docker history --human=false, each one's size and step:
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

The layered image is the base image's six layers, `WORKDIR`, and the four `COPY` layers; the fat-jar image the six, `WORKDIR` and one
`COPY`. For the same one-line change, the layered image's 11th layer — the application `COPY`, 28,672 bytes — is the only new one;
the fat-jar image's 8th — the whole jar, 16,134,144 bytes — is. (`docker history`'s sizes on this daemon are multiples of 4,096:
`dependencies` 15,966,208, the jar 16,134,144; the files themselves are 15,899,411 and 16,133,950 bytes.) Rebuilt with nothing
changed, the recipe's image has the same eleven layers and **another ID**: the ID is the digest of an OCI image index, and each build
adds a provenance attestation — a record of how and when the image was built — to it. Built twice with `--provenance=false`, the two
IDs are equal. Image IDs are not witnesses; compare layers (brief S3.12).

## 5 · Stale — the break: where the jar is unpacked (A/B/A′, with C and D)

`.r-stale.out` `c13325fdc6333a00515459b8cb66238d` — 40 lines

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
  exit 0 · transferring context: 14.32kB - less than the thin jar alone (11675 bytes): no · COPY steps CACHED: 4 of 4
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
copy: `on`. **D**, B with the thin jar touched first, sends it (14.32 kB, no longer less than the jar) and the image says `at` —
its `COPY` steps still all `CACHED`, because BuildKit's cache keys on content, and this time the content was new. **A′** = A, line
for line. The flipped attribute is where the jar is unpacked; the fixed build time is what makes B's trap possible, and why the
recipe extracts inside the build.

## 6 · Timing — the clock, against five seconds

`.r-timing.out` `7b26717b2775f067a0185c4a28768b3b` — 10 lines

```
six rounds after one warm-up round; each round: a fresh number at the end of TiffinBoxServer's listening line (never built
  before, so neither image can come from the cache), mvn -o clean package, a one-second pause, then both images rebuilt,
  each timed by bash:
$ time docker build -f docker/Dockerfile -t tiffinbox-layers:tick-recipe .harness/ctx-recipe > .harness/tick-r.log 2>&1
$ time docker build -f docker/fat.Dockerfile -t tiffinbox-layers:tick-fat .harness/ctx-fat > .harness/tick-f.log 2>&1
  every timed build re-ran its jar step, none from the cache: 12 of 12
  rebuilds under five seconds: the layered image 6 of 6 · the fat-jar image 6 of 6
  the median of the six - the layered image's longer than the fat-jar image's: yes
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

`.r-files.out` `18407500e4450135ef3d7849e6580ddc` — 79 lines

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
docker/fat.Dockerfile, against docker/Dockerfile:
  1,9c1
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
  > # The fat-jar image: the whole jar, in one COPY. Its context: a folder that holds tiffinbox-web-1.0.0.jar and nothing else.
  12,15c4
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

The seconds the timing capture counted, as `receipts.sh` printed them on the terminal (the run of record, three capture runs of six
rounds; the warm-up round not counted):

```
layered 1.477 1.455 1.468 1.482 1.558 1.689 (median 1.480) / fat 1.205 1.154 1.180 1.188 1.183 1.174 (median 1.181)
layered 1.518 1.697 1.689 1.861 1.481 1.713 (median 1.693) / fat 1.196 1.325 1.299 1.303 1.363 1.432 (median 1.314)
layered 1.458 1.636 1.421 1.459 1.464 1.449 (median 1.458) / fat 1.145 1.390 1.204 1.158 1.166 1.142 (median 1.162)
```

In this run of record, the layered rebuilds took 1.421-1.861 s and the fat-jar ones 1.142-1.432 s; under two seconds: 18 of 18 layered, 18 of 18 fat. The other full runs today, three capture runs of six rounds each: two printed every rebuild at 1.083-1.859 s, and one at 1.099-1.971 s. One more, with this Mac heavily loaded (load average near 10 on 8 cores), stopped on the timing capture when it still counted against two seconds: its capture runs had 5, 6 and 3 of 6 layered rebuilds under two seconds (and 6, 6 and 5 of 6 fat-jar ones), and its last layered rebuild took 3.139 s - so the capture now counts against five seconds and compares medians. And the full run the first interrupt test turned into (it could not be interrupted: *Found on the way*) had its first capture run at layered 2.192, 2.052, 2.249, 1.432, 1.354, 1.413 s and fat 1.650, 1.644, 1.661, 1.154, 1.131, 1.154 s - three layered rebuilds over two seconds while this unit's deck was being rendered beside it. The probe's ranges (layered 0.605-1.456 s, fat 0.495-1.093 s) were faster than any run here.

## The posted Course 3 correction, against this measurement

The comment posted on Course 3 unit 23's video on 2026-10-05 says: the next course (Spring Framework Core) builds no container image;
images arrive in this lesson; measured on TiffinBox, the layered image did not rebuild faster — both rebuilds under two seconds; what
the layers save is bytes — after a one-line change only the small application layer is new, instead of a whole new fat jar.
**This unit's measurement agrees on four of its five points, and qualifies the fifth.** Course 4's 33 folders hold 0 Dockerfiles and 0
files that say docker (`timing`); the layered image was not the faster one — its median rebuild the longer in every capture run
(`timing`); the one new layer is the application's, 28,672 bytes, against the fat-jar image's 16,134,144 (`bytes`); both rebuilds took
seconds, not minutes. **"Under two seconds" held on a quiet Mac only:** with this Mac heavily loaded, one capture run had
3 of 6 layered rebuilds at two seconds or more, one of them 3.139 s. So the deck says "seconds", and the capture
asserts under five seconds — never "under two". The deck shows the rest on screen (slides 6 and 7).

## Found on the way

- **The application layer is 37,610 bytes of 16,339,318 (12 files)**, not the probe's 36,896 of 16,338,604 — this anchor's jar; the
  share is still about 2 in 1,000.
- **B's context transfer is 2.63 kB, not the probe's 2.33 kB** (this tree's folders); D's, with the thin jar touched, 14.32 kB.
- **`tiffinbox-core`'s jar without the timestamp: 18 of 19 entries dated by the build** — the 19th, `META-INF/maven/…/pom.xml`,
  keeps the source file's own time.
- **The image IDs differ because of the provenance attestation**, not the image config: with `--provenance=false`, two builds of
  the same layers have one ID (`bytes`).
- **BuildKit's `CACHED` is not the bug**: D's `COPY` steps are all `CACHED` and its image is right — the cache keys on content; B's
  is wrong because the context never carried the new content.
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
- **The fat-jar image needs no Boot tooling to build** — its rebuild is faster than the recipe's, which starts a JVM to run `extract`
  in every build where the jar changed.

## For the next unit — 15 — and for RED

**Start from `c5-unit14/after/`** (copy it with `rsync -a --exclude target`, or build it in place:
`mvn -o -B -f ../c5-unit14/after/pom.xml -Dmaven.repo.local=<your .m2-demo> -DskipTests clean package`):
- **Unchanged from unit 13:** the jar runs alone (`java -jar <after>/tiffinbox-web/target/tiffinbox-web-1.0.0.jar
  --tiffinbox.port=<port>`, no `lib/`); the token from a folder holding `secrets/tiffinbox/shutdown-token` (umask 077, the token and
  a newline) or `TIFFINBOX_SHUTDOWN_TOKEN`; a harness class path from `java -Djarmode=tools -jar <jar> extract --destination
  .harness/x` (a destination that exists and is not empty stops it — remove it first), then `java -cp
  ".harness/classes:.harness/x/tiffinbox-web-1.0.0.jar:.harness/x/lib/*" <Main>`; the seven: `../c5-unit11/curlset.sh PORT
  TOKENFILE` → `115c36bac276128e245ca57df11c2891`.
- **New: the jar is reproducible.** `project.build.outputTimestamp` = `2026-09-15T00:00:00Z` in the root POM: two clean builds of
  `after/` → one md5 (`927d962c91b776b2d9251f58d17cfa5c`, 16,133,950 bytes, on this Mac); every entry of `tiffinbox-core`'s jar is dated `20260915.000000`. A
  receipt can now hash the jar itself, and an image built twice from it has identical layers.
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
  or the medians flipping); the brief's 36,896 / 2.33 kB figures do not hold for this anchor (above); unit 13's script calls Course 3 "the last
  course" twice (the fat-jar and transformer lines) — Course 4 is the last course from Course 5; this unit says "Course 3".

## Exercise

`exercise/README.md` — in `.harness/mine`, a copy of `after/`: install it once, change one line of `tiffinbox-core`
(`TiffinBoxProperties`' validation message, `must be` → `must have`), package only `tiffinbox-web`, extract its layers, and find
which layer `tiffinbox-core-1.0.0.jar` landed in — and whether the changed line is in it. Done when `find` prints one path. Run
exactly as written in a clean shell (`env -i`): `exercise/solution/SOLUTION.md`.
