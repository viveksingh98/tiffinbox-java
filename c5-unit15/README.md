# c5-unit15 — Buildpacks: spring-boot:build-image

Course 5 · Spring Boot · Section 3 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, Docker 29.4.0
(OrbStack; client 29.5.1)**, the builder `paketobuildpacks/builder-noble-java-tiny` pinned by its digest (lifecycle 0.21.22) and
the run image `paketobuildpacks/ubuntu-noble-run-tiny:0.0.138`, 2026-10-05, on an 8-core 16 GB Apple-silicon Mac.
No Dockerfile: Boot's Maven plugin has a goal, `build-image`, that hands TiffinBox's jar to a buildpack builder, which picks a
Java, a base image and a launch command. This unit reads what it picked off its own log and off the image it made (a manifest
line, a label naming where the JRE came from, a 32nd jar, a user that is not root, a memory calculator, no shell), runs the image
— with no token, then with the config tree mounted read-only — and finds that the container answers nothing: TiffinBox listened on
`127.0.0.1`, which inside a container is the container's own. The anchor change, the key `tiffinbox.address` (default
`127.0.0.1`), lets a container say `0.0.0.0`. Then one word changes, and the image is rebuilt under the same name.

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it (`diff -rq -x target` empty). "Before" is
`../c5-unit14/after/` (the anchor as the last unit to change it left it), **copied** to `.harness/before/`. Nothing here writes into
another unit's folder. Clean builds, offline; every number the video speaks is asserted; three runs per capture; and no capture,
no README, no slide and **no layer of either image this unit tags** holds the demo token (masked, and counted: *The demo token*).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 8 captures, 3 runs each; every spoken number asserted; 0 raw tokens, image layers included; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top.) `receipts.sh` **dies** when a capture's md5 differs from
`receipts.md5` — it prints the `DIFFERS` line first, so you can see which one moved. A whole run takes about four minutes on the
author's Mac. It needs a running Docker (it asks `docker info`, runs `orb start` only if Docker does not answer and the `orb`
command exists, then polls for 60 s), and the builder and the run image already on the machine (`docker pull` each once, by the
names in *Commands*: they were here before this unit, and no build here pulls — every build log is counted for `Pulling` lines: 0).
**Network:** the run's first image build downloads, inside the build, the files its buildpacks need (*What the builds
downloaded*); no captured build downloads anything.

**The repository.** Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the script): a copy of
`../c5-unit14/.m2-demo` without its `com/tiffinbox/`, plus the Section 3 seed `spring-boot/_research/m2-seed-s3/` copied with
`rsync --ignore-existing` and without its `com/tiffinbox/`. Every `_remote.repositories` marker says `central` (1,900 marker lines,
0 naming a local repository). Maven downloaded nothing: Boot's buildpack client, `spring-boot-buildpack-platform` 4.1.1, was already
there. Each setup build prints `built <tree> · offline: yes` (or `no - …`) on the terminal; the captured builds are offline-only
(`-o`, no fallback: a build that needed the network would stop the run). The `install` builds write `com/tiffinbox/` into
`.m2-demo` (git-ignored).

## Commands

What `receipts.sh` reads from this section (`readme()`: the first line of this file that matches; the script dies if one is
missing), with the three variables they use:

```
M2="$PWD/.m2-demo"
BUILDER=paketobuildpacks/builder-noble-java-tiny@sha256:b95da27fce97b58037f0c11ae934760c50730da4c9a24976205b53638592eba9
RUNIMAGE=paketobuildpacks/ubuntu-noble-run-tiny:0.0.138
mvn -o -B -f after/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean install
mvn -o -B -f after/pom.xml -Dmaven.repo.local="$M2" -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder="$BUILDER" -Dspring-boot.build-image.runImage="$RUNIMAGE" -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
docker run --rm --name tiffinbox-web-required -m 1g tiffinbox-web:1.0.0
docker run -d --name tiffinbox-web-address -m 1g -e TIFFINBOX_ADDRESS=0.0.0.0 -v "$PWD/.harness/tree/secrets:/workspace/secrets:ro" -p 127.0.0.1:18861:18425 tiffinbox-web:1.0.0
```

- **The image takes two steps (brief ⚑4).** `install` from the root builds both modules in one reactor, so `tiffinbox-core` lands in
  the `application` layer (unit 14's index); then `build-image-no-fork` runs on `tiffinbox-web` alone and packs the jar the first
  step built. No image name is given: Boot's default is the module's, `docker.io/library/tiffinbox-web:1.0.0` (`build`'s log).
- **The builder is pinned by its digest** (`$BUILDER`, the image already on this Mac), and the run image is the one the builder's
  own metadata names, `docker.io/paketobuildpacks/ubuntu-noble-run-tiny:0.0.138`. With `pullPolicy=IF_NOT_PRESENT`, Boot pulls
  neither: 0 `Pulling` lines in every build log. The probe's default policy re-checked the builder against the registry on every build.
- **The obvious command** — the goal from the root — is run on a copy of `after/` (`.harness/root/`), so its failure touches
  nothing else:

```
mvn -o -B -f .harness/root/pom.xml -Dmaven.repo.local="$M2" spring-boot:build-image -Dspring-boot.build-image.builder="$BUILDER" -Dspring-boot.build-image.runImage="$RUNIMAGE" -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
```

- **B and C are A with one flag changed** — B without `-e TIFFINBOX_ADDRESS=0.0.0.0`, C with `-e SERVER_ADDRESS=0.0.0.0` in its
  place; `receipts.sh` derives both from A's line and asserts the one difference. **at/** — `after/` with one word of
  `TiffinBoxServer`'s listening line changed (`on` → `at`) — is built with the two build commands, the tree swapped.

## The anchor change

Three files changed, none new (README aside) — `change`, below, shows every changed code line:
- `tiffinbox-core/…/TiffinBoxProperties.java` — the record gains `@NotBlank String address` after `port` (the key
  `tiffinbox.address`); its `toString()` prints it; its Javadoc gains the `@param address` line, and `port`'s line no longer says
  "on 127.0.0.1".
- `tiffinbox-web/…/TiffinBoxServer.java` — a field `address`, read from the record; the server binds `new InetSocketAddress(address,
  port)` where it bound `"127.0.0.1"`; the listening line prints the address: `TiffinBox listening on http://<address>:<port>`.
- `tiffinbox-web/src/main/resources/application.yaml` — `address: 127.0.0.1` under `tiffinbox`, with a two-line comment (a container
  sets `TIFFINBOX_ADDRESS=0.0.0.0` and publishes the port on the Mac's `127.0.0.1` alone).
- `README.md` (the anchor's) — a new section, *Course 5 · unit 15 — an address a container can reach*.

**Not `TiffinBoxApp`** (brief ⚑3), so RED S2 #8 stays deferred. **On the Mac nothing changes:** the run command, the listening
line and the seven responses (`change`: both jars, `TiffinBox listening on http://127.0.0.1:18860`, `115c36bac276128e245ca57df11c2891`).
The record has one more component, so anything that constructs it by hand (a harness) passes the address too.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token (unit 11). Every run that serves starts in, or mounts, `.harness/tree/`, a
config tree — `secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`) — holding a 26-character demo token that is
fake and looks it; `receipts.sh` writes it when it runs (`.harness/` is git-ignored). The token never reaches a command line: the
seven requests read it from the file (`$CURLSET PORT TOKENFILE`), and **in a container it comes from that folder, mounted
read-only at `/workspace/secrets`** — the image's working folder is `/workspace`, and `application.yaml` imports
`optional:configtree:./secrets/`. **No image holds it:** Boot's build sends the builder the jar alone. Every capture is masked — the
token becomes `[masked: the 26-character token]` (`gsub`) — and `receipts.sh` counts the raw token in each run's own output
**before** masking (`.harness/raw-*`: 0 in all 24 capture runs), then in every capture, this README, the anchor README, the
exercise, its solution and `receipts.md5`: 0. Then **both images it tags** — `tiffinbox-web:1.0.0` as at/ built it and as after/
built it — are saved (`docker save`), and every layer (the run image's too) is unpacked and searched, with each image config: 0
copies (the run of record: 0 raw copies in 24 raw capture runs, in 8 captures, the READMEs, the exercise and its solution, and receipts.md5 - and in the 2 images' 21 distinct layers (every one, unpacked) and 2 configs; the exercise's own token: 0 raw copies in the captures; no absolute path in any capture). The builder counts it again in the script, the deck and the prompter: 0.

**The exercise's token is the viewer's own:** 32 random hexadecimal characters (`openssl rand -hex 16`), written by the exercise's
own commands into `.harness/mine/`. The exercise's answer puts it in an environment variable, and `docker inspect` then prints it —
that is the lesson. The capture masks it (`[masked: the 32-character token]`, `gsub` of that run's token), and a last check counts
the last one raw in every capture: 0.

## The folders, the variables, the ports and the Docker names

- `after/` — the frozen tree, built clean in place (`install`). `.harness/before/` — `../c5-unit14/after`, built clean once (`package`).
  `.harness/at/` — `after/` with one word changed (`rebuild`). `.harness/root/` — a fresh copy of `after/` for each run of the obvious
  command. `.harness/tree/` — the config tree. `.harness/peek/` — what `chose` copies out of the image. `.harness/mine/` — the
  exercise's.
- On screen: `$M2` = this unit's `.m2-demo`; `$BUILDER` and `$RUNIMAGE` (*Commands*); `$PWD` = the shell's current folder, this unit's;
  `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson (the seven requests, POST /shutdown with the
  token's header read from a file) — its folder carries a unit number, so no slide prints the path.
- **Ports** (brief ⚑10, 18860-18869, checked free with `lsof` before anything is wiped, with 18425): `change` 18860 (the jars, on the
  Mac) · `address` 18861 (the Mac's side of every published port: `-p 127.0.0.1:18861:18425`) · `exercise` 18866. Inside the
  container TiffinBox listens on 18425, which binds nothing on the Mac.
- **Docker names** (no unit number, §R.4): the image `tiffinbox-web:1.0.0` (Boot's default name for this module, brief ⚑11);
  containers `tiffinbox-web-address`, `-required`, `-peek` (created, never started), `-shell`, `-mine`. **Removed by the exit trap**
  — after a pass, a failure or Ctrl-C: those names; the containers labelled `author=spring-boot` that appeared during the run, with
  the image each was created from (Boot's ephemeral builder); images named `pack.local/builder/*` that appeared; and every volume
  named `pack-*` that appeared during the run — the buildpack's two cache volumes for the image's name included (taken before and
  after: the difference, brief S3.4). A volume, container or image that was there before the run is never touched; `docker …
  prune` is never run (a third-party container and its images live on this Docker).

## Masks, filters and hygiene — every one, declared

1. **Paths and the tokens:** in every line of every capture (`gsub()`, the patterns escaped as literals): the demo token →
   `[masked: the 26-character token]`; the exercise's token → `[masked: the 32-character token]`; this folder's absolute path →
   `…`, also URL-encoded; the folder above it → `…/..`; the home folder → `~`. A last check fails if any capture still holds
   `/Users/`, `/private/` or `/home/`.
2. **IDs:** a line that is a 64-hex container ID (what `docker run -d` prints) → `[a container ID]`; a build-cache volume's hash →
   `pack-cache-<hash>`. No image ID, container ID or RootFS layer digest is printed: layers are compared position by position and the
   comparison printed (`the same 19 · different 1`).
3. **The buildpack log** is kept in `.harness/` and filtered: Maven's `[INFO] ` prefix (and the spaces after it) dropped, and only the
   lines that match this list kept — `Building image `, `buildpacks participating`, the participating buildpacks
   (`[creator]     paketo-buildpacks/…`), `$BP_JVM_VERSION`, `$BPL_JVM_THREAD_COUNT`, `Using Java version`, `Liberica JRE …: `,
   `Downloading from`, `Process types:`, the `web:` process, `Creating slices` and the four slice lines, `Spring Cloud Bindings …: `,
   `Web Application Type: `, `Non-web application`, `app layer(s)`, `Successfully built image`. The capture then counts the log's
   lines, the lines shown, the lines not shown, and the lines that say `Downloading from` and `Pulling`.
4. **Container logs** are read with `docker logs`; a log line is printed from its message on (the time, level, PID, thread and logger
   columns dropped). The `address` capture prints the listening line, then the address in it without its scheme
   (`the address in that line: 0.0.0.0:18425`) — the deck shows that second line, because `check_unit5.py` reads a printed
   `http://0.0.0.0…` as a demo URL that is not loopback.
5. **The image's records** (`chose`) are read from `docker image inspect`'s JSON by a few lines of Python: the user, the working folder,
   the entrypoint, the creation date, three labels, the number of buildpacks in the build record, the default process, the source of
   every layer whose record names a download (printed as host and file name, never as a URL), and the run image.
6. **Maven's logs** are kept in `.harness/` and read, never printed; `-q` is used only by the exercise, whose README says so.
7. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*`, `SPRING_*`, `BP_*` and `BPL_*` variable, `JAVA_TOOL_OPTIONS`,
   `JDK_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS`, and the variables that change what Docker's builds do (`DOCKER_BUILDKIT`,
   `BUILDKIT_*`, `BUILDX_*`, `DOCKER_DEFAULT_PLATFORM`, `SOURCE_DATE_EPOCH`) before it runs anything (`DOCKER_HOST` and
   `DOCKER_CONTEXT` stay); it refuses to run twice at once in this folder (`.r-lock`), or with a `secrets/` in this folder; it removes
   its own names, and any container Boot's client left for `tiffinbox-web:1.0.0` or `tiffinbox-core:1.0.0` (with its image and its two
   scratch volumes), before it starts. Every container runs with `-m 1g`, so the buildpack's memory calculator prints the limit, never
   this Mac's memory (`required`: 0 lines naming the machine's memory).

**Interrupted.** `receipts.sh`'s exit trap stops the JVM it started in the background, if one still runs; removes its five container names and its
image, the containers labelled `author=spring-boot` that appeared during the run (with the image each was created from), any
`pack.local/builder/*` image that appeared, and the `pack-*` volumes that appeared; and drops the lock — on a failed check and on
Ctrl-C alike. Every command in the trap is guarded, so `set -e` cannot end it early, and `$pid` is cleared after every reap.
**Tested 2026-10-05, three times.** Each time `receipts.sh` ran in the foreground of a driver shell that leads its own process
group (`perl -e '$SIG{INT} = "DEFAULT"; setpgrp(0, 0); exec @ARGV' bash driver.sh`; the driver catches SIGINT and carries on, so
`receipts.sh` starts with SIGINT at its default, as from a terminal), and a watcher sent SIGINT to the whole group: (1) the moment
`change`'s JVM listened on 18860, with 1 image and 2 `pack-` volumes on the daemon; (2) during `build`'s image build, with the
lifecycle's container running (1 `author=spring-boot` container, 1 image, 4 `pack-` volumes); (3) while `address`'s container
published 18861. `receipts.sh` exited **130** each time, and 5 s later: 0 listeners on 18425 and 18860-18869, 0 java processes
running this unit's jar, 0 containers named `tiffinbox-web-*`, 0 labelled `author=spring-boot`, 0 images `tiffinbox-web:1.0.0` or
`pack.local/builder/*`, 0 `pack-*` volumes, and `.r-lock` gone.

## 1 · Change — the address, in three files; on the Mac, nothing moves

`.r-change.out` `3a498c2cb3d2774fe9b105f612b7cb80` — 37 lines

```
files, README aside: the previous tree 18 · after/ 18 · in both 18: identical 15, changed 3
  only before: (none)
  only after:  (none)
tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java, every changed line but comments and blanks (4 of those not shown):
-                                  @NotNull @Min(1) Integer port, @NotEmpty List<MealType> mealTypes,
-                                  @NotBlank String shutdownToken) {
+                                  @NotNull @Min(1) Integer port, @NotBlank String address,
+                                  @NotEmpty List<MealType> mealTypes, @NotBlank String shutdownToken) {
-                + ", mealTypes=" + mealTypes + ", shutdownToken=" + (shutdownToken == null ? "null" : "[not shown]") + "]";
+                + ", address=" + address + ", mealTypes=" + mealTypes
+                + ", shutdownToken=" + (shutdownToken == null ? "null" : "[not shown]") + "]";
  removed 3 · added 4
tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java, every changed line but comments and blanks (0 of those not shown):
+    private final String address;
+        this.address = settings.address();
-        server = HttpServer.create(new InetSocketAddress("127.0.0.1", port), 0);
+        server = HttpServer.create(new InetSocketAddress(address, port), 0);
-        LOG.log(INFO, "TiffinBox listening on http://127.0.0.1:" + port);
+        LOG.log(INFO, "TiffinBox listening on http://" + address + ":" + port);
  removed 2 · added 4
tiffinbox-web/src/main/resources/application.yaml, every changed line but comments and blanks (2 of those not shown):
+  address: 127.0.0.1
  removed 0 · added 1
after/'s jar, run on the Mac:
$ cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18860
  listens on: 127.0.0.1:18860 · WARN lines 0 · ERROR lines 0
  the log: TiffinBox listening on http://127.0.0.1:18860
$ $CURLSET 18860 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the previous tree's jar, the same way:
$ cd .harness/tree && java -jar ../before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18860
  listens on: 127.0.0.1:18860 · WARN lines 0 · ERROR lines 0
  the log: TiffinBox listening on http://127.0.0.1:18860
$ $CURLSET 18860 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

The record's other changed line is its `toString()` (one line became two); the Javadoc lines are among the "not shown" ones. Both
jars start in `.harness/tree/` and serve the comparison set: the same listening line, the same seven responses — the address
change is invisible on the Mac.

## 2 · Build — README's two commands, and what the log says it chose

`.r-build.out` `3d15a88b547d21c12b903009efcf52bb` — 29 lines

```
$ mvn -o -B -f after/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean install
  exit 0 · offline: yes (-o) · BUILD SUCCESS lines: 1
$ mvn -o -B -f after/pom.xml -Dmaven.repo.local="$M2" -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder="$BUILDER" -Dspring-boot.build-image.runImage="$RUNIMAGE" -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
  exit 0 · offline: yes (-o)
  Building image 'docker.io/library/tiffinbox-web:1.0.0'
  [creator]     6 of 26 buildpacks participating
  [creator]     paketo-buildpacks/ca-certificates   3.13.0
  [creator]     paketo-buildpacks/bellsoft-liberica 11.9.0
  [creator]     paketo-buildpacks/syft              2.41.0
  [creator]     paketo-buildpacks/executable-jar    6.16.0
  [creator]     paketo-buildpacks/dist-zip          5.13.0
  [creator]     paketo-buildpacks/spring-boot       5.37.0
  [creator]         $BP_JVM_VERSION              21                                                           the Java version
  [creator]         $BPL_JVM_THREAD_COUNT        250                                                          the number of threads in memory calculation
  [creator]         Using Java version 25 extracted from MANIFEST.MF
  [creator]       BellSoft Liberica JRE 25.0.4: Reusing cached layer
  [creator]       Process types:
  [creator]         web:            java org.springframework.boot.loader.launch.JarLauncher (direct)
  [creator]       Creating slices from layers index
  [creator]         dependencies (15.2 MB)
  [creator]         spring-boot-loader (398.1 KB)
  [creator]         snapshot-dependencies (0.0 B)
  [creator]         application (20.9 KB)
  [creator]       Spring Cloud Bindings 2.0.4: Reusing cached layer
  [creator]       Web Application Type: Reusing cached layer
  [creator]     Reused 5/5 app layer(s)
  Successfully built image 'docker.io/library/tiffinbox-web:1.0.0'
  log lines 152 · shown 23 · not shown 129 · lines that say Downloading from: 0 · lines that say Pulling: 0
  RootFS layers, against the image this name held before (the run's first build, the same jar): 20 and 20 · the same 20 · different 0
```

Every captured build finds, under the same name, the image the same jar made a moment before — the run's first build (*What the
builds downloaded*) — so it downloads nothing and reuses all five app layers; its 20 RootFS layers are the previous image's 20. What
the log says it chose, read off it: 6 of 26 buildpacks took part; `$BP_JVM_VERSION` is printed with its default, 21, and then
`Using Java version 25 extracted from MANIFEST.MF` (`chose` shows the manifest's line, `Build-Jdk-Spec: 25`); the JRE layer is
BellSoft Liberica 25.0.4; the slices are the jar's own layer index, the four of unit 14; the `web` process starts Boot's
`JarLauncher` (unit 13). `$BPL_JVM_THREAD_COUNT` is printed with its default, 250 (`required` shows what the image uses).

## 3 · Root — the obvious command fails, and leaves things behind

`.r-root.out` `e9150f2ae13f42d24be33ada73d9e41e` — 8 lines

```
$ mvn -o -B -f .harness/root/pom.xml -Dmaven.repo.local="$M2" spring-boot:build-image -Dspring-boot.build-image.builder="$BUILDER" -Dspring-boot.build-image.runImage="$RUNIMAGE" -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
  exit 1
  Building image 'docker.io/library/tiffinbox-core:1.0.0'
  TiffinBox Core ..................................... FAILURE
  TiffinBox Web ...................................... SKIPPED
  the error, on project tiffinbox-core: Error packaging archive for image: Unable to find main class
  left behind: containers labelled author=spring-boot 1 (1 created) · the images they were created from 1, Boot's ephemeral builder, tags: 0 · new volumes named pack-: 4 - build caches 2 (pack-cache-<hash>.build and .launch), temporary 2 (pack-app-…, pack-layers-…)
  removed by this script, by ID and name; left now: containers 0 · images 0 · volumes 0
```

From the root, Maven runs the goal on every module in order, `tiffinbox-core` first: Boot builds an image named after it, finds no
class with a `main` method to launch, and stops the reactor (`tiffinbox-web` skipped). By then its client has created Boot's
ephemeral builder image, the lifecycle's container (`Created`, never removed by Boot) and four volumes — two build caches named after
the image (`pack-cache-<hash>.build`, `.launch`) and two scratch volumes. The capture counts what appeared during its own run and
removes exactly that, by ID and name: 0 left. (The container mounts the Docker socket; it never started.)

## 4 · Chose — the image's own records, its files, and what is not there

`.r-chose.out` `d11baba21ee754fdd2bb6c933303a9a7` — 23 lines

```
$ docker image inspect tiffinbox-web:1.0.0
  User 1002:1001 · WorkingDir /workspace · Entrypoint ["/cnb/process/web"] · Created 1980-01-01T00:00:01Z
  RootFS layers: 20
  label org.opencontainers.image.title = TiffinBox Web
  label org.opencontainers.image.version = 1.0.0
  label org.springframework.boot.version = 4.1.1
  the buildpacks that took part, the image's build record says: 6
  its default process, web: java org.springframework.boot.loader.launch.JarLauncher · direct: true
  the jre layer's record, paketo-buildpacks/bellsoft-liberica: BellSoft Liberica JRE 25.0.4 · downloaded from host github.com · file bellsoft-jre25.0.4+9-linux-aarch64.tar.gz
  the spring-cloud-bindings layer's record, paketo-buildpacks/spring-boot: Spring Cloud Bindings 2.0.4 · downloaded from host repo1.maven.org · file spring-cloud-bindings-2.0.4.jar
  the run image under it, its record says: docker.io/paketobuildpacks/ubuntu-noble-run-tiny:0.0.138
$ unzip -p after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF | grep Build-Jdk-Spec
  Build-Jdk-Spec: 25
$ docker create --name tiffinbox-web-peek tiffinbox-web:1.0.0 > /dev/null && docker cp -q tiffinbox-web-peek:/workspace .harness/peek && docker cp -q tiffinbox-web-peek:/layers/paketo-buildpacks_spring-boot/web-application-type/env.launch .harness/peek && docker cp -q tiffinbox-web-peek:/layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d .harness/peek && docker rm tiffinbox-web-peek > /dev/null
  exit 0
  /workspace: BOOT-INF META-INF org - the jar's own folders, unpacked
  /workspace/BOOT-INF/lib/: 32 entries · files 31 · symbolic links 1
  spring-cloud-bindings-2.0.4.jar -> /layers/paketo-buildpacks_spring-boot/spring-cloud-bindings/spring-cloud-bindings-2.0.4.jar
  its 31 files, against the jar's own BOOT-INF/lib/ (31 jars): the same name and bytes 31
  the thread count one layer sets (paketo-buildpacks_spring-boot/web-application-type/env.launch/): BPL_JVM_THREAD_COUNT.default = 50
  the helpers the bellsoft-liberica buildpack's layer runs before Java (helper/exec.d/): 11 · memory-calculator among them: yes
$ docker run --rm --name tiffinbox-web-shell --entrypoint sh tiffinbox-web:1.0.0 -c true
  exit 127 · exec: "sh": executable file not found in $PATH
```

- The image runs as `1002:1001` — a user and a group, by number; not root — from `/workspace`, which holds the jar unpacked
  (`BOOT-INF META-INF org`). Its entrypoint is the buildpacks' launcher for the `web` process, which the image's build record names:
  `java org.springframework.boot.loader.launch.JarLauncher`, run directly. Its creation date is fixed, `1980-01-01T00:00:01Z`: the
  same jar gave the same 20 layers (`build`), so `docker images` calls it 46 years old.
- The image's lifecycle label records the source of each downloaded layer: the JRE from github.com, the bindings jar from
  repo1.maven.org — printed as host and file name.
- `/workspace/BOOT-INF/lib/` holds **32 entries: the jar's own 31 jars, the same name and bytes, and one symbolic link**,
  `spring-cloud-bindings-2.0.4.jar`, into the spring-boot buildpack's own layer. The jar has 31.
- The web-application-type layer sets `BPL_JVM_THREAD_COUNT.default = 50` (the default the build log prints is 250; when the layer ran,
  in `rebuild`, it said `Non-web application detected`). The bellsoft-liberica buildpack's helper layer holds the programs that run
  before Java; `memory-calculator` is one of them.
- **There is no shell**: `--entrypoint sh` → exit 127, `exec: "sh": executable file not found in $PATH`. Look inside with `docker cp`
  and `docker inspect`, as this capture does (the container is created, copied from and removed; it never starts).

## 5 · Required — the image with no token

`.r-required.out` `fde9aa84ac377a5c19f226780351c725` — 7 lines

```
$ docker run --rm --name tiffinbox-web-required -m 1g tiffinbox-web:1.0.0
  exit 1 · WARN lines 1 · ERROR lines 1 · lines that say TiffinBox listening: 0
  Calculated JVM Memory Configuration: -XX:MaxDirectMemorySize=10M -Xmx668186K -XX:MaxMetaspaceSize=73189K -XX:ReservedCodeCacheSize=240M -Xss1M (Total Memory: 1G, Thread Count: 50, Loaded Class Count: 10508, Headroom: 0%)
  Property: tiffinbox.shutdownToken
  Value: "null"
  Reason: must not be blank
  lines that name the available memory of the machine: 0
```

Before Java starts, the buildpack's memory calculator prints its plan — for a one-gigabyte container (`-m 1g`) and 50 threads. Without
`-m`, it reads the VM's memory instead, and prints it (`Calculating JVM memory based on …K available memory`, measured once while
building this unit; that number is this Mac's, so no capture runs without `-m`). Then Boot binds the record and stops the start: unit
11's rule, in a container. The run also prints Java's native-memory summary at exit (the buildpack switches that tracking on); it is
not shown, and its numbers move.

## 6 · Address — the break (A/B/A′, with C)

`.r-address.out` `7fc571c23df4915849fb116a62808630` — 43 lines

```
A   the address set: TIFFINBOX_ADDRESS=0.0.0.0 - the anchor's new key, tiffinbox.address
$ docker run -d --name tiffinbox-web-address -m 1g -e TIFFINBOX_ADDRESS=0.0.0.0 -v "$PWD/.harness/tree/secrets:/workspace/secrets:ro" -p 127.0.0.1:18861:18425 tiffinbox-web:1.0.0
  the log: TiffinBox listening on http://0.0.0.0:18425
  the address in that line: 0.0.0.0:18425
$ $CURLSET 18861 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ docker wait tiffinbox-web-address
  0
$ docker rm tiffinbox-web-address
  listeners on 18861 now: 0
B   no address: application.yaml's default, 127.0.0.1
$ docker run -d --name tiffinbox-web-address -m 1g -v "$PWD/.harness/tree/secrets:/workspace/secrets:ro" -p 127.0.0.1:18861:18425 tiffinbox-web:1.0.0
  the log: TiffinBox listening on http://127.0.0.1:18425
  the address in that line: 127.0.0.1:18425
$ curl -sS http://127.0.0.1:18861/kitchen
  exit 52 · curl: (52) Empty reply from server
$ docker stop tiffinbox-web-address
  the container's exit code: 143
$ docker rm tiffinbox-web-address
  listeners on 18861 now: 0
C   Boot's own key instead: SERVER_ADDRESS=0.0.0.0, server.address
$ docker run -d --name tiffinbox-web-address -m 1g -e SERVER_ADDRESS=0.0.0.0 -v "$PWD/.harness/tree/secrets:/workspace/secrets:ro" -p 127.0.0.1:18861:18425 tiffinbox-web:1.0.0
  the log: TiffinBox listening on http://127.0.0.1:18425
  the address in that line: 127.0.0.1:18425
$ curl -sS http://127.0.0.1:18861/kitchen
  exit 52 · curl: (52) Empty reply from server
$ docker stop tiffinbox-web-address
  the container's exit code: 143
$ docker rm tiffinbox-web-address
  listeners on 18861 now: 0
A′  A re-run
$ docker run -d --name tiffinbox-web-address -m 1g -e TIFFINBOX_ADDRESS=0.0.0.0 -v "$PWD/.harness/tree/secrets:/workspace/secrets:ro" -p 127.0.0.1:18861:18425 tiffinbox-web:1.0.0
  the log: TiffinBox listening on http://0.0.0.0:18425
  the address in that line: 0.0.0.0:18425
$ $CURLSET 18861 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ docker wait tiffinbox-web-address
  0
$ docker rm tiffinbox-web-address
  listeners on 18861 now: 0
the config tree mounted in all four: secrets/tiffinbox/shutdown-token, -rw-------, this script's user's - the container's user is 1002:1001
```

The flipped attribute is the address TiffinBox binds inside the container. **A** sets the new key through the environment,
`TIFFINBOX_ADDRESS=0.0.0.0` — every interface of the container — and the published port answers the comparison set:
`115c36bac276128e245ca57df11c2891`; POST /shutdown stops TiffinBox and the container exits 0 (`docker wait`). **B** sets nothing:
application.yaml's `127.0.0.1` — the container's own loopback — and the Mac's `curl` gets `curl: (52) Empty reply from server`
while the log says TiffinBox listens; `docker stop` then ends it (143: SIGTERM). **C** is the brief's loser C, measured: Boot's own
`server.address` (`SERVER_ADDRESS=0.0.0.0`) is a key TiffinBox's `HttpServer` never reads, so C behaves like B. **A′** = A, line for line.
B never sends POST /shutdown (a stop capture must not, brief S3.4). The Mac side of every run is `127.0.0.1:18861` only. **On this
Mac** the container's user, 1002, read the `0600` token file owned by the Mac's user through OrbStack's file sharing; on a Linux
host that read is unmeasured.

## 7 · Rebuild — one word, the same name

`.r-rebuild.out` `76f9c7785966c569720a1482237ba722` — 35 lines

```
at/ = after/ with one word changed: TiffinBoxServer's listening line says at where it says on
  the starting point, every run: after/'s image under tiffinbox-web:1.0.0, built again first (exit 0) - its RootFS layers against the run's first build: 20 and 20 · the same 20 · different 0
$ mvn -o -B -f .harness/at/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean install
  exit 0 · offline: yes (-o) · BUILD SUCCESS lines: 1
$ mvn -o -B -f .harness/at/pom.xml -Dmaven.repo.local="$M2" -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder="$BUILDER" -Dspring-boot.build-image.runImage="$RUNIMAGE" -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
  exit 0 · offline: yes (-o)
  Building image 'docker.io/library/tiffinbox-web:1.0.0'
  [creator]     6 of 26 buildpacks participating
  [creator]     paketo-buildpacks/ca-certificates   3.13.0
  [creator]     paketo-buildpacks/bellsoft-liberica 11.9.0
  [creator]     paketo-buildpacks/syft              2.41.0
  [creator]     paketo-buildpacks/executable-jar    6.16.0
  [creator]     paketo-buildpacks/dist-zip          5.13.0
  [creator]     paketo-buildpacks/spring-boot       5.37.0
  [creator]         $BP_JVM_VERSION              21                                                           the Java version
  [creator]         $BPL_JVM_THREAD_COUNT        250                                                          the number of threads in memory calculation
  [creator]         Using Java version 25 extracted from MANIFEST.MF
  [creator]       BellSoft Liberica JRE 25.0.4: Reusing cached layer
  [creator]       Process types:
  [creator]         web:            java org.springframework.boot.loader.launch.JarLauncher (direct)
  [creator]       Creating slices from layers index
  [creator]         dependencies (15.2 MB)
  [creator]         spring-boot-loader (398.1 KB)
  [creator]         snapshot-dependencies (0.0 B)
  [creator]         application (20.9 KB)
  [creator]       Spring Cloud Bindings 2.0.4: Reusing cached layer
  [creator]       Web Application Type: Contributing to layer
  [creator]         Non-web application detected
  [creator]     Reused 4/5 app layer(s)
  [creator]     Added 1/5 app layer(s)
  Successfully built image 'docker.io/library/tiffinbox-web:1.0.0'
  log lines 155 · shown 25 · not shown 130 · lines that say Downloading from: 0 · lines that say Pulling: 0
  RootFS layers, against after/'s image: 20 and 20 · the same 19 · different 1 · the different one, counted from the base up: 16 of 20
  the image the name held before, now without a tag: yes - removed by its recorded ID
  still there afterwards: no
```

Each run starts from after/'s image under the name (built again first, its log not shown: in the first run nothing changes, in the
next two it replaces at/'s), then installs at/ and builds its image under the same name. Nothing is downloaded, the JRE layer is
reused, the web-application-type layer runs again (`Non-web application detected`), and **4 of the 5 app layers are reused, 1 added**;
**19 of the 20 RootFS layers are the same** — the 16th, counted from the base up, differs. The image the name held before is left
without a tag, and removed by its recorded ID.

## 8 · Exercise — the token, in the environment instead of the folder

`.r-exercise.out` `03dba61d1448b9c7694051372312efdd` — 39 lines

```
exercise/README.md's commands, read from the file and run as written, in order (its two export lines aside):
$ mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean install
  exit 0
$ mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder=paketobuildpacks/builder-noble-java-tiny@sha256:b95da27fce97b58037f0c11ae934760c50730da4c9a24976205b53638592eba9 -Dspring-boot.build-image.runImage=paketobuildpacks/ubuntu-noble-run-tiny:0.0.138 -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
  exit 0
$ rm -rf .harness/mine && mkdir -p .harness/mine/secrets/tiffinbox && (umask 077 && openssl rand -hex 16 > .harness/mine/secrets/tiffinbox/shutdown-token)
  exit 0
$ docker run -d --name tiffinbox-web-mine -m 1g -e TIFFINBOX_ADDRESS=0.0.0.0 -v "$PWD/.harness/mine/secrets:/workspace/secrets:ro" -p 127.0.0.1:18866:18425 tiffinbox-web:1.0.0
  exit 0
  [a container ID]
$ i=0; until docker logs tiffinbox-web-mine 2>&1 | grep -q 'TiffinBox listening'; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 1; done
  exit 0
$ docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' tiffinbox-web-mine | grep '^TIFFINBOX_' | sort
  exit 0
  TIFFINBOX_ADDRESS=0.0.0.0
$ { printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18866/shutdown
  exit 0
  {"stopping":true} 200
$ docker wait tiffinbox-web-mine && docker rm tiffinbox-web-mine
  exit 0
  0
  tiffinbox-web-mine
the measured answer's commands, exercise/solution/SOLUTION.md, run as written:
$ docker run -d --name tiffinbox-web-mine -m 1g -e TIFFINBOX_ADDRESS=0.0.0.0 -e TIFFINBOX_SHUTDOWN_TOKEN="$(head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token)" -p 127.0.0.1:18866:18425 tiffinbox-web:1.0.0
  exit 0
  [a container ID]
$ i=0; until docker logs tiffinbox-web-mine 2>&1 | grep -q 'TiffinBox listening'; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 1; done
  exit 0
$ docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' tiffinbox-web-mine | grep '^TIFFINBOX_' | sort
  exit 0
  TIFFINBOX_ADDRESS=0.0.0.0
  TIFFINBOX_SHUTDOWN_TOKEN=[masked: the 32-character token]
$ { printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18866/shutdown
  exit 0
  {"stopping":true} 200
$ docker wait tiffinbox-web-mine && docker rm tiffinbox-web-mine
  exit 0
  0
  tiffinbox-web-mine
```

`exercise/README.md`'s commands (its first bash block, the two `export` lines aside) and then `exercise/solution/SOLUTION.md`'s, read
from the files and run as written. With the folder mounted, `docker inspect` lists one `TIFFINBOX_` variable, the address; with the
token in `-e`, it lists the token too — anyone who can run `docker inspect` on this Docker can read it. POST /shutdown answers 200 both
ways. (The first run of the three replaces at/'s image with after/'s; the image left without a tag is removed by its recorded ID,
silently — a step of the harness, not of the exercise.)

## What the builds downloaded

**Maven:** nothing (every build `offline: yes`). **Docker:** no pull (0 `Pulling` lines in every build log; the builder, pinned by
digest, and the run image were on this Mac before this unit). **Inside the buildpacks — network, in the build step (contract §1):**
the first image build of every run, printed on the terminal and never captured (it depends on what this Docker held before the run):

```
first build: mvn -o -B -f after/pom.xml -Dmaven.repo.local="$M2" -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder="$BUILDER" -Dspring-boot.build-image.runImage="$RUNIMAGE" -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
first build: exit 0 · lines that say Downloading from: 3 · github.com/bell-sw/Liberica/releases/download/25.0.4+9/bellsoft-jre25.0.4+9-linux-aarch64.tar.gz · github.com/anchore/syft/releases/download/v1.51.1/syft_1.51.1_linux_arm64.tar.gz · repo1.maven.org/maven2/org/springframework/cloud/spring-cloud-bindings/2.0.4/spring-cloud-bindings-2.0.4.jar · Pulling: 0
```

The BellSoft Liberica JRE 25.0.4+9 tarball for linux-aarch64 and syft 1.51.1 come from github.com, spring-cloud-bindings 2.0.4 (77,441
bytes, the probe) from repo1.maven.org. **Why every run downloads again:** the run ends by removing its image and the `pack-*` volumes
it created (S3.4). The JRE is a *launch* layer: the buildpack reuses it only from the previous image under the same name — measured
while building this unit: with the image removed and both cache volumes kept, the next build downloaded the JRE again (and reused syft
and the bindings, which are *cache* layers, from the build cache). Every captured build finds the run's first image: 0 downloads.

## Found on the way

- **A one-word rebuild reuses 4 of the 5 app layers, not the probe's 3**, and 19 of the 20 RootFS layers are the same.
- **The JRE re-downloads whenever the previous image is gone**, under the same name and with the cache volumes kept (above). The
  probe's "per fresh image name" is one case of that.
- **Pinned by digest with `IF_NOT_PRESENT`, the builder is never pulled**: 0 `Pulling` lines. **A build that finds its previous image
  logs 152 lines; a first build, 177** (the probe's 181). The application slice is 20.9 KB (the probe's 19.9 KB, before the address).
- **The order of a container's environment in `docker inspect` is not stable**: two runs of the same command listed the two
  `TIFFINBOX_` variables in different orders. The exercise sorts them.
- **A container that fails to start with `--entrypoint sh` and no `--rm` stays behind, `Created`**; this unit uses `--rm`.
- **Image IDs:** a buildpack image built twice from the same jar had the same ID here (no build attestation, unlike BuildKit's in
  unit 14). Still, layers are what this unit compares.
- **The `docker run -d` ID and a container's environment order are the only run-to-run differences** the exercise capture had before
  its masks and its sort.

## For the next unit — 16 — and for RED

**Start from `c5-unit15/after/`** (copy it with `rsync -a --exclude target`, or build it in place:
`mvn -o -B -f ../c5-unit15/after/pom.xml -Dmaven.repo.local=<your .m2-demo> -DskipTests clean install`):
- **New: `tiffinbox.address`**, a record component after `port` — `TiffinBoxProperties(jdbcUrl, cooks, days, port, address,
  mealTypes, shutdownToken)` — `@NotBlank`, default `127.0.0.1` in application.yaml, printed by `toString()`. The server binds it, and
  the listening line prints it: `TiffinBox listening on http://<address>:<port>`. **A container needs `TIFFINBOX_ADDRESS=0.0.0.0`**
  (brief ⚑5's `ENV TIFFINBOX_ADDRESS=0.0.0.0`); with it unset, a published port answers `curl: (52) Empty reply from server` (B, on
  OrbStack). `SERVER_ADDRESS` does nothing (C). A harness that constructs the record by hand needs the new argument.
- **Unchanged:** the jar runs alone and is byte-reproducible (`after/`'s jar: `92452ee1f9a22920d8aa7e2655f2bdc0`, 16,134,264 bytes, on this Mac); the token
  from a config tree (`secrets/tiffinbox/shutdown-token`, umask 077, the token and a newline) or `TIFFINBOX_SHUTDOWN_TOKEN`; a harness
  class path from `java -Djarmode=tools -jar <jar> extract --destination <a folder that does not exist>`; the seven:
  `../c5-unit11/curlset.sh PORT TOKENFILE` → `115c36bac276128e245ca57df11c2891` — measured here on the Mac (`change`) and from a
  container (`address` A).
- **In a container:** mount the config tree read-only where the image's working folder is (`/workspace/secrets` here; the brief's
  `/app/secrets` for a Dockerfile image working in `/app`); publish on `127.0.0.1:<port>:18425`; give `-m` (without it, Java — and
  this buildpack's calculator — read the VM's memory, which is machine-specific). POST /shutdown stops TiffinBox and the container
  exits 0; `docker stop` sends SIGTERM and Java exits 143 here (the buildpack's launcher runs Java as PID 1 directly).
- **Docker here:** OrbStack, context `orbstack`, server 29.4.0, the containerd image store. `tiffinbox-web:1.0.0` is this unit's
  name; `receipts.sh` removes it and its two cache volumes at the end of every run — use your own (⚑11: `tiffinbox-docker:*`).
  `eclipse-temurin:25-jre`, the builder and the run image are on this Mac.
- **RED:** the curl error for B is OrbStack's (another Docker may say `Connection reset`, exit 56); the 0600 read by uid 1002 is
  OrbStack's file sharing; the first build of every run needs github.com and repo1.maven.org (the run stops if they are unreachable);
  the exercise's build commands repeat the README's with the variables written out.

## Exercise

`exercise/README.md` — build the image, make a token of your own, run the image the lesson's way (the folder mounted) and read its
environment with `docker inspect`; then start it with the token in an environment variable instead, and find it with `docker
inspect`. Done when the same line lists `TIFFINBOX_SHUTDOWN_TOKEN=` and your token beside the address, and POST /shutdown still
answers 200. Run exactly as written in a clean shell (`env -i`): `exercise/solution/SOLUTION.md`.
