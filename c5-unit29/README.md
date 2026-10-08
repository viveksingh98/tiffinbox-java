# c5-unit29 — Capstone: TiffinBox Boots

Course 5 · Spring Boot · Section 5, its third unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, GraalVM CE
25.3.4.1** (native-image 25.0.4.1), **Docker 29.4.0 on OrbStack**, 2026-10-08. One tree, five forms: the executable jar, the same jar
ahead of time (Spring's AOT), the native binary, the image (the anchor's `Dockerfile`), and the developer's class path with its
database (the anchor's `compose.yaml`). Each one says ready and serves the same seven answers (`115c36bac276128e245ca57df11c2891`).
Actuator, the meters, the logs, failure analysis and the bare-argument refusal are shown on the forms that carry them, and the
course's first promise — auto-configuration · Actuator · one runnable jar · Docker — gets one capture line each.

**The anchor does not change (brief ⚑11).** The tree is `../c5-unit27/after`, reached through the link `anchor` (so no capture
prints a unit folder). It is read and copied under `.harness/`, never built in place. When this unit was measured,
`diff -rq -x target ../c5-tiffinbox anchor/` was empty: this tree is the anchor, and it goes on to the next course (ledger P3).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 8 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`), with `eclipse-temurin:25-jre` and `postgres:18-alpine` already on it: the script never pulls.
**Runs of record (2026-10-08):** **705 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0, all 8 captures = published, every check passed); under `bash receipts.sh` (Homebrew bash 5.3.9) 714 s with all 8 = published before two checks of `dev` were corrected (a trailing space in an expected line; the published hashes unchanged); and the sealed clone below (bash 5.3.9). Load averages about 3-5.
It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native build per capture run
(three per receipt), judged against a bound (1 minute or more, under 20 minutes); its seconds go to the terminal only.
Published hashes: image `31d8517b037a1d25e208d9102d65d3a2` · fails `d9a95cb41787309d171b7ce65aca65c6` · ops `b93ca576258b3f2779332b302ad39bcc` · dev `eae6ca9394d7bdb5b8f83645896969db` · promises `a56e8e8973fecab3122c709e8991107b` · exercise `324ae3a7f055b97d3c4d0ad4dfc55627` · native `fbe1571e6f5d96d081d790453a08387e` · forms `fdadcbc199f2349e3902cb97a878f396`

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `native`
and `forms` (the binary is one of the five) need it. **Without a GraalVM** the script still fills `.m2-demo`, makes `image`, `fails`,
`ops`, `dev`, `promises` and `exercise`, each checked against `receipts.md5`, then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-boot/_research/m2-seed-s5/` **less `com/tiffinbox/`** (5,568 files; brief S5.3). **Nothing was downloaded** for this
unit: every build said `offline: yes`. The first build is the README's native install (it fills `.m2-demo` on a fresh clone,
GraalVM's metadata zip included); the second is the README's class-path line (Maven's dependency plugin, which no earlier build
fetches — unit 27's finding), both before the captures; every build log is searched for the native plugin's own download line —
found, the run stops. **Docker:** no pull. `docker build` printed 0 lines that say `pull` (base `eclipse-temurin:25-jre`, digest
`sha256:fcd7fd7b387f…`, already on the daemon); Compose printed 0 `Pulling` lines (`postgres:18-alpine` already there). At run time
nothing leaves 127.0.0.1 — a container listens on its own addresses, published on the host's `127.0.0.1` alone.

**From a clone, sealed (2026-10-08, brief S5.2).** The repository was cloned (`git clone` of the local repository at this unit's
first commit) into an empty folder — nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*`; `README.md` is the only file
changed since, by this paragraph and the runs-of-record note. `bash receipts.sh` (Homebrew bash 5.3.9) ran under `env -i`, with a
`HOME` whose `.mavenrc` points Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`) and every Java
proxy property at a port that refuses (127.0.0.1:9); Maven settings that send every repository to a `file://` copy of Central's
files made from `.m2-demo` (4,164 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`,
`resolver-status.properties` and `.DS_Store` left out, `maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`,
`https_proxy`, their capitals and `ALL_PROXY` at the same refusing port; `GRAALVM_HOME` set; and `DOCKER_CONFIG` at the account's
`~/.docker` (the docker CLI's context — OrbStack — and its Compose plugin live there; nothing of Maven's). **Exit 0 after 735 s** —
all 8 captures = published, every spoken number asserted, 0 raw demo tokens. Two builds said `offline: no` — the first (GraalVM's
metadata repository was not in the empty `.m2-demo`) and the class-path line's pre-capture build (Maven's dependency plugin) — every
file they took came from the `file://` copy (the sealed `HOME`'s `.m2` ended holding its `settings.xml` alone); every capture's build
said `offline: yes`; `.m2-demo` ended with 1,856 files; 0 lines of the native plugin's metadata download in any build log; Docker
pulled nothing.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it;
a container gets the same tree mounted read-only at `/app/secrets` and runs as your user (`--user "$(id -u):$(id -g)"`, S5.27).
The token never reaches a command line: the seven requests and `harness/shutdown.sh` read it from the file. Every capture is
masked, and `receipts.sh` counts the raw token in each run's own output **before** masking (0 in all 24 capture runs); in the log of
**every start that ended by itself** (standard output and error), of **every JVM that served** (the token and the header's name
`X-Shutdown-Token`, in any case), and of **every container** (`docker logs`): 0 each; then in every capture, this README, the
exercise, the harness, `receipts.md5` and the **bytes of the binary**: 0 each. The builder counts it again in the script, the deck
and the prompter: 0. `.dockerignore` keeps `secrets/` out of every build context (`image` prints it), so no image layer and no build
cache entry holds it.

## The folders, the names and the ports

- `anchor` → `../c5-unit27/after` (a link, committed). `.harness/pre/` — the tree, the two pre-capture builds. `.harness/serve/` —
  the tree with a config tree, built the README's plain way in `image` and with its class-path line in `fails` (later captures
  run it: `ops`, `dev`, `promises`, `forms`); its `compose.yaml` is the tree's, byte for byte (`dev`). `.harness/nat/` — the tree,
  the README's two native lines (`native`, `forms`). The exercise: `.harness/mine/`.
- **The harness** is two shell scripts: `harness/six.sh PORT` — the comparison set's six GETs (no token, no shutdown), so a server
  can be scraped after them; `harness/shutdown.sh PORT TOKENFILE` — POST /shutdown, the token read from the file (the failure
  lesson's). No harness class: every run passes options only, except the three that show the refusal (brief ⚑18).
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`; `$M2` = this unit's `.m2-demo`; `$GRAALVM_HOME`; `$PWD` and `$(id -u)`/`$(id -g)`
  in the docker lines — the folder the command runs from, and your user and group.
- **The layouts** (S4.18): the executable jar (`java -jar`) in `fails`, `ops`, `promises`, `forms`; the AOT jar in `forms`; the
  binary in `native`, `forms`; the image's jar in `image`, `fails` (D), `promises`, `forms`, the exercise; Maven's class path
  (`target/classes` + `classpath.txt`, Jackson 3 on it) in `dev`, `forms`.
- **Docker names** (no unit number, S5.17): image `tiffinbox-capstone:1.0.0`, container `tiffinbox-capstone`; the exercise's
  `tiffinbox-mine:1.0.0` and `tiffinbox-mine`; the Compose project `tiffinbox-dev` (compose.yaml's `name:`, brief ⚑12). Each is checked
  absent before the first run (it may be yours: the script dies, and removes only what it creates), and removed on every exit:
  containers `docker rm -f`, images by name and by every ID a build of this run recorded, the project `docker compose -p
  tiffinbox-dev down -v`. Docker's build cache is not pruned (no secret in it). **`tiffinbox-dev` is one unit's at a time:** never run
  this beside RED part B or another unit's dev capture.
- **Ports** (brief ⚑1, 19150-19159; checked free with `lsof` before anything is wiped; 18425, 8080 and 18881 too): `fails` A, A′ and
  the taken port, `forms`' jar 19150 · **the bare argument 19151, never bound** · `ops` 19152 · `promises`' jar 19153 · `forms`' AOT
  jar 19154 · the image 19155 · dev 19156 · the binary 19157 · the exercise 19159 · Compose's Postgres `127.0.0.1:18881` (the anchor's
  file). 18425 is bound only inside a container.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user** (`gsub()`, literals escaped), in every line: the token → `[masked: the 26-character
   token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…` (so Compose's `Using Docker Compose file …/.harness/serve/compose.yaml`);
   the folder above → `…/..`; home → `~`; the user name → `<user>`. A last check fails if any capture holds `/Users/`, `/private/`,
   `/home/`, `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line, a log time, a thread number, a stack frame,
   or a `sha256:` ID other than the base image's digest.
2. **A start that ended by itself** (`fails()`, and for a container `dfails()`) is read after it exited, never printed whole: the
   failure lesson's shape (`APPLICATION FAILED TO START`, frames, `Caused by:` and folded frames counted; WARN/ERROR lines from their
   level on, a WARN cut after its exception's class; each exception's first line; Boot's hint; the analysis from `Description:` on);
   how far it got (the banner's `:: Spring Boot ::` line, `TiffinBox listening`, counted). **Never a line total** (S5.30).
3. **A running TiffinBox's log** is read after it stopped: Boot's first line cut before ` with PID` (in a container it goes on
   `started by ? in /app`: never printed); TiffinBox's `orders cooked:` and listening lines from their message on; TiffinBox's DEBUG
   lines (logger `tiffinbox`) from their message on (`ops`); Compose's lines (`DockerCli`) that say `Created`, `Started` or `Healthy`,
   **sorted** — Compose creates the network and the volume side by side, so their order moves — and the lines that say `Pulling`,
   WARN and ERROR, counted (`dev`).
4. **JSON from Actuator** is printed with its keys sorted, marked `(keys sorted)` where that changed the text (the bridge writes keys
   in reflection's order, which moved under load: the health lesson's finding).
5. **A scrape** (`/actuator/prometheus`) is filtered to TiffinBox's own meters: the two counters and the timer's `_count` lines; the
   timer's `_sum` and `_max` lines (seconds) are counted; the rest — the JVM's, the process's and the system's meters, whose number
   moves (measured: 173 and 180 in two runs) — is bounded, "over 100", never counted (S5.6).
6. **`docker build --progress=plain`** through a filter: its `load metadata` line, its `FROM` line (the base image's digest) and its
   naming line, step numbers and timings cut — BuildKit ends a step with ` done` or, when the step took measurable time, with
   ` 0.0s done`; both forms are cut (`s/( [0-9]+\.[0-9]+s)? done$//`). The first published filter cut ` done` alone, so a fresh
   clone printed `naming to … 0.0s` beside `naming to …` and `image` drifted (RED C5-S5 #41, two sealed runs of two); the fixed
   filter is checked on a planted log (three naming lines, one out) before any capture — and the old filter, given that log, gives
   three. And the lines that say `pull`, counted. **Its other lines are not counted**: how many
   there are depends on Docker's build cache (a cached step prints fewer), which this script does not prune — a count would move the
   hash with the cache. Open for RED.
7. **`--debug`'s condition evaluation report** (`promises`) is read, never printed: an entry of the jar's imports files is "applied"
   when its class is a top-level positive match or an unconditional class, "skipped" when it is a negative match; the line prints
   both counts and the entries that are neither (0). **Maven's and native-image's logs**: each build's `offline`/`exit` line;
   native-image's goal, GraalVM, Java, warnings (URL cut), stages, warning count and result, the rest counted.
8. **No duration is captured** (brief ⚑13).
9. **Hygiene:** the S5.15 loop (`sed -E`, a planted canary under every name, the run stops if one survives) over every `TIFFINBOX_*`,
   `SPRING_*`, `MANAGEMENT_*`, `SERVER_*`, `LOGGING_*`, **`COMPOSE_*`**, `BUILDKIT_*`, `BUILDX_*` variable, `DEBUG`, `JAVA_TOOL_OPTIONS`,
   `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS`, `NATIVE_IMAGE_OPTIONS`, `DOCKER_BUILDKIT`, `DOCKER_DEFAULT_PLATFORM`,
   `SOURCE_DATE_EPOCH`; `GRAALVM_HOME`, `DOCKER_HOST` and `DOCKER_CONTEXT` stay. `127.0.0.1` first in `no_proxy`/`NO_PROXY`. One run at
   a time (`.r-lock`). A last check fails if any `docker run` line in this script, this README or the exercise publishes a port
   without `127.0.0.1:`.

**Interrupted.** `receipts.sh`'s exit trap stops the processes it started in the background — a serving TiffinBox (`$pid`)
and a start expected to end by itself (`$fpid`) — if they still run, then `sweep()`s this run's process group (a TiffinBox JVM, a
binary, native-image's driver or builder, a `docker compose --file …` command Boot's Compose support started) — TERM, then KILL after
5 s — then `dclean()`: `docker rm -f` of its containers, `docker compose -p tiffinbox-dev down -v` until the project is empty, and
its images by name and by every recorded ID (only once the start-up checks found none of those names: it never removes what it
did not create). After an interrupt it deletes the capture runs left unfinished (`.r-NAME.1-3`), then drops the lock. **Tested
2026-10-08 on the final script, from the sealed clone**, `receipts.sh` as a job of its own process group and `SIGINT` sent to the
whole group twice: (1) during `ops`, once its JVM listened on 19152 (8 processes in the group); (2) during `dev`, once Compose's
Postgres listened on 127.0.0.1:18881 and the image `tiffinbox-capstone:1.0.0` existed (6 processes). Each time: **exit 130**; 5 s
later 0 processes in the group, 0 TiffinBox JVMs; 18425, 8080, 18881 and 19150-19159 free; 0 containers and 0 images named
`tiffinbox*`, 0 containers and 0 volumes of `tiffinbox-dev`; `.r-lock` gone; 0 unfinished capture files.

**Planted faults** (S5.18, 2026-10-08), each on a copy of the published captures, each run once: `ops`' DEBUG count made 5 → `ops:
expected … - 6:`; an image ID (`sha256:` + 64 hex) appended to `image` → `holds an ID other than the base image's digest`; a `docker
run -p 19155:18425` line appended to the README → `publishes a port on every address`; `forms`' summary made `4 of 5` → `forms:
expected …`; `dev`'s leftover-variable name made `tiffinbox-dev` → `dev: expected /^  name: planted-canary$/`; `promises`' `neither 0`
made `neither 1` → `promises: expected …`. Each check died on its fault, and every check passed on the published captures.

## 1 · the image: the README's two lines, then its run line

Maven's plain build, then `docker build` with plain progress and this receipt's own tag (the README's line, two declared changes), through its filter; the base image's digest; the image's user, entrypoint and `/app`; the README's run line with `--user`, the receipt's name and tag and port 19155: readiness, `docker port`, your uid in the container, the seven, `docker wait` 0, the container's log.

`.r-image.out` · md5 `31d8517b037a1d25e208d9102d65d3a2` · 3 of 3

```
the tree, copied to .harness/serve with a config tree beside the README - the README's two lines, Maven then Docker:
$ cd .harness/serve && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the tree · offline: yes · exit 0
  .dockerignore beside the Dockerfile keeps out: secrets/ tiffinbox-local.yaml
$ cd .harness/serve && docker build --progress=plain -t tiffinbox-capstone:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-capstone:1.0.0
  its lines that say pull: 0 · its other lines: not shown
  the base image on this Docker: eclipse-temurin@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
  the image: user ubuntu · entrypoint ["java","-jar","application.jar"] · /app holds: application.jar lib
the README's run line - your user added, the port published on 127.0.0.1:19155:
$ cd .harness/serve && docker run -d --name tiffinbox-capstone --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19155:18425 tiffinbox-capstone:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19155/actuator/health/readiness
  {"status":"UP"} 200
  docker port: 18425/tcp -> 127.0.0.1:19155
  the container's user id is yours (id -u): yes
$ $CURLSET 19155 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-capstone
  0
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  its log: orders cooked:  120 · TiffinBox listening on http://0.0.0.0:18425 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · fails — the break (A/B/A′), one argument; a port taken; D and E (labelled), the image

A the jar on 19150, the seven; B the same line and a bare `19151`: exit 2, the two sentences, 0 frames, 0 banner, neither port bound; A′ = A; then a second start on the taken port: exit 1, the failure lesson's two sentences; D the image with `19151` after its name: `docker wait` 2, `argument 1 of 1`. **E** (labelled) — D's action followed: `--tiffinbox.port=19157` after the image name, published as before on `127.0.0.1:19155:18425`: TiffinBox listens on `0.0.0.0:19157` **inside** the container, `docker port` still says `18425/tcp -> 127.0.0.1:19155`, readiness on 19155 answers `000`, and nothing listens on the host's 19157; `docker stop` → `docker wait` 143. In a container, publish your port with `docker run -p`, and leave TiffinBox's own (RED C5-S5 #43; the voice says so, and the anchor README).

`.r-fails.out` · md5 `d9a95cb41787309d171b7ce65aca65c6` · 3 of 3

```
the tree, copied to .harness/serve with a config tree, built with the README's class-path line (offline):
$ cd .harness/serve && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  built the tree · offline: yes · exit 0
A - the jar, the README's run line, port 19150:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19150
  listens on: 127.0.0.1:19150
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19150/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19150 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same line, and a bare 19151:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19150 19151
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 2 of 2 is 19151.
  Action:
  To set the port, give it as an option: --tiffinbox.port=19151.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19150 0 · 19151 0
A' - A again:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19150
  listens on: 127.0.0.1:19150
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19150/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19150 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the failure lesson's analysis, on the jar - the same line while the first one holds the port:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19150
  listens on: 127.0.0.1:19150
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19150/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19150
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  TiffinBox could not listen on 127.0.0.1:19150: something else already listens there.
  Action:
  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.
  its log: the banner's :: Spring Boot :: line 1 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
$ $CURLSET 19150 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
D (labelled) - the image, a bare 19151 after the image name:
$ cd .harness/serve && docker run -d --name tiffinbox-capstone --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19155:18425 tiffinbox-capstone:1.0.0 19151
$ docker wait tiffinbox-capstone
  2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 1 of 1 is 19151.
  Action:
  To set the port, give it as an option: --tiffinbox.port=19151.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its log (docker logs): the demo token 0 times
  listening now: 19155 0 · 19151 0
E (labelled) - the image, D's action followed: --tiffinbox.port=19157 after the image name, published as before (127.0.0.1:19155):
$ cd .harness/serve && docker run -d --name tiffinbox-capstone --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19155:18425 tiffinbox-capstone:1.0.0 --tiffinbox.port=19157
  its log: TiffinBox listening on http://0.0.0.0:19157
  docker port: 18425/tcp -> 127.0.0.1:19155
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19155/actuator/health/readiness
  000
  listening on this machine: 19155 Docker · 19157 0
$ docker stop tiffinbox-capstone
$ docker wait tiffinbox-capstone
  143
  its log (docker logs): the demo token 0 times
```

## 3 · ops — operating it, on the JVM

The README's loggers line plus the health lesson's show-components flag: readiness = `kitchen` + `readinessState`; health with its groups; `/kitchen`; 0 DEBUG lines at INFO; the POST to `loggers/kitchen` → 204; six requests; the scrape (two counters, five timer series); POST /shutdown; then 6 DEBUG lines.

`.r-ops.out` · md5 `b93ca576258b3f2779332b302ad39bcc` · 3 of 3

```
the jar (.harness/serve) - the README's loggers line, with the health lesson's flag; port 19152:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19152 --management.endpoints.web.exposure.include=health,prometheus,loggers --management.endpoint.health.show-components=always
  listens on: 127.0.0.1:19152
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19152/actuator/health/readiness
  {"components":{"kitchen":{"status":"UP"},"readinessState":{"status":"UP"}},"status":"UP"} 200    (keys sorted)
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19152/actuator/health
  {"components":{"diskSpace":{"status":"UP"},"kitchen":{"status":"UP"},"livenessState":{"status":"UP"},"ping":{"status":"UP"},"readinessState":{"status":"UP"},"ssl":{"status":"UP"}},"groups":["liveness","readiness"],"status":"UP"} 200    (keys sorted)
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19152/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
  TiffinBox's DEBUG lines so far: 0
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19152/actuator/loggers/kitchen
   204
$ harness/six.sh 19152
  GET   /customers  -> 200
  GET   /revenue    -> 200
  GET   /dashboard  -> 200
  GET   /kitchen    -> 200
  GET   /nowhere    -> 404
  GET   /shutdown   -> 405
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19152/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  tiffinbox_orders_cooked_total 120.0
  tiffinbox_orders_value_total 24300.0
  tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
  tiffinbox_requests_seconds_count{route="GET /dashboard",status="200"} 1
  tiffinbox_requests_seconds_count{route="GET /kitchen",status="200"} 2
  tiffinbox_requests_seconds_count{route="GET /revenue",status="200"} 1
  tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 1
  the timer's sum and max lines (seconds): 10, not shown · the scrape's other lines (the JVM's, the process's, the system's: their number moves): over 100, not shown
$ harness/shutdown.sh 19152 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19152 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  TiffinBox's DEBUG lines, from the POST on - 6:
    GET /customers -> 200
    GET /revenue -> 200
    GET /dashboard -> 200
    GET /kitchen -> 200
    UNKNOWN -> 405
    POST /shutdown -> 200
```

## 4 · dev — Compose for development, on the anchor's own compose.yaml

The file TiffinBox starts beside, against the anchor's own (`../c5-tiffinbox/compose.yaml`, not the folder it was copied from — a comparison with its own source could not fail: RED C5-S5 #52): the same bytes; its project name read back (`tiffinbox-dev`), and with a leftover `COMPOSE_PROJECT_NAME` (`planted-canary`); the project empty and 18881 free; the README's dev line on 19156: Postgres on `127.0.0.1:18881`, the seven, Compose's lines, 0 Pulling/WARN/ERROR, Jackson 3 on the class path 2 / in the jar 0 (the jar's side counted with `jackson-[a-z-]+-3\.`, which also counts a hyphenated artifact such as `jackson-dataformat-yaml-3.…` — the first pattern, `[a-z]*`, missed it: RED C5-S5 #51, a planted listing gives 1 old, 2 new); `exited (exit 0)`; `down -v` → none.

`.r-dev.out` · md5 `eae6ca9394d7bdb5b8f83645896969db` · 3 of 3

```
the compose.yaml in .harness/serve (the folder TiffinBox starts in), against the anchor's own, ../c5-tiffinbox/compose.yaml: the same
$ cd .harness/serve && docker compose config --format json    # its project name, read back
  name: tiffinbox-dev
$ cd .harness/serve && COMPOSE_PROJECT_NAME=planted-canary docker compose config --format json    # a leftover variable
  name: planted-canary
the project tiffinbox-dev before the run: containers, volumes and networks 0 · listening on 18881: 0
the README's dev line - Maven's class path, the profile dev; port 19156:
$ cd .harness/serve && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19156 --spring.profiles.active=dev
  listens on: 127.0.0.1:19156
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19156/actuator/health/readiness
  {"status":"UP"} 200
  the project while TiffinBox runs: tiffinbox-dev-postgres-1 running 127.0.0.1:18881->5432/tcp
$ $CURLSET 19156 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: The following 1 profile is active: "dev" · Using Docker Compose file …/.harness/serve/compose.yaml
  Compose's lines in its log that say Created, Started or Healthy, sorted:
    Container tiffinbox-dev-postgres-1 Created
    Container tiffinbox-dev-postgres-1 Healthy
    Container tiffinbox-dev-postgres-1 Started
    Network tiffinbox-dev_default Created
    Volume tiffinbox-dev_data Created
  lines that say Pulling: 0 · WARN lines: 0 · ERROR lines: 0
  Jackson 3 (tools.jackson) on this class path: 2 jars · in the executable jar's lib/: 0
the project after TiffinBox exited (Boot's stop):
  containers: tiffinbox-dev-postgres-1 exited (exit 0)
  volumes: tiffinbox-dev_data
  networks: tiffinbox-dev_default
$ docker compose -p tiffinbox-dev down -v
  exit 0
the project now:
  containers: (none)
  volumes: (none)
  networks: (none)
```

## 5 · promises — the course's first promise, one line each

Auto-configuration: the jar's 6 imports files, 74 entries; `--debug`'s report: applied 31, skipped 43, neither 0. Actuator: health with its groups and the scrape's `120.0`. One runnable jar: `java -jar`, the seven. Docker: the image, the seven.

`.r-promises.out` · md5 `a56e8e8973fecab3122c709e8991107b` · 3 of 3

```
auto-configuration - the executable jar's lib/ (.harness/serve), its AutoConfiguration.imports files and their entries:
    spring-boot-actuator-autoconfigure-4.1.1.jar: 24
    spring-boot-autoconfigure-4.1.1.jar: 12
    spring-boot-health-4.1.1.jar: 7
    spring-boot-micrometer-metrics-4.1.1.jar: 28
    spring-boot-micrometer-observation-4.1.1.jar: 2
    spring-boot-validation-4.1.1.jar: 1
  files: 6 · entries: 74
  how many applied - the README's --debug line (Boot's condition evaluation report), port 19153:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19153 --debug
  listens on: 127.0.0.1:19153
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19153/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19153 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the condition report: of the 74 entries listed, applied 31 (positive matches 20, unconditional 11) · skipped 43 (negative matches) · neither 0
Actuator, and one runnable jar - the README's run line, port 19153:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19153
  listens on: 127.0.0.1:19153
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19153/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19153/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} 200    (keys sorted)
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19153/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  tiffinbox_orders_cooked_total 120.0
  tiffinbox_orders_value_total 24300.0
$ $CURLSET 19153 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
Docker - the image (tiffinbox-capstone:1.0.0, the image capture's), the README's run line with your user:
$ cd .harness/serve && docker run -d --name tiffinbox-capstone --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19155:18425 tiffinbox-capstone:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19155/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19155 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-capstone
  0
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  its log: orders cooked:  120 · TiffinBox listening on http://0.0.0.0:18425 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · exercise — the exercise, run as written

exercise/README.md's commands, then SOLUTION.md's one line, exactly as written: `{"ordersCooked":40,"ordersValue":8100}` from the image with `--tiffinbox.days=10` after its name; nothing listens on 19159, no container left; the image removed.

`.r-exercise.out` · md5 `324ae3a7f055b97d3c4d0ad4dfc55627` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 6 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target anchor/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && docker build -q -t tiffinbox-mine:1.0.0 . > /dev/null)
  exit 0 · printed: 0 line(s)
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ cd .harness/mine/after && docker run -d --name tiffinbox-mine --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19159:18425 tiffinbox-mine:1.0.0 --tiffinbox.days=10 > /dev/null && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19159/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && k=$(curl -s http://127.0.0.1:19159/kitchen) && ../../../harness/shutdown.sh 19159 secrets/tiffinbox/shutdown-token > /dev/null && docker wait tiffinbox-mine > /dev/null && docker rm tiffinbox-mine > /dev/null && echo "the kitchen, ten days, in the image: $k"
the kitchen, ten days, in the image: {"ordersCooked":40,"ordersValue":8100}
  exit 0 · listening on 19159 now: 0 · the container tiffinbox-mine: 0
$ docker image rm tiffinbox-mine:1.0.0
  removed
```

## 7 · native — the binary

The README's two native lines, offline: 8 of 8 stages, `Mach-O`, 0 token bytes; the binary with `loggers` by flag: readiness, health with groups, the scrape `120.0`, `loggers` 404; a second binary on the taken port: exit 1, the two sentences; the seven; C the binary with a bare `19151`: exit 2, never bound.

`.r-native.out` · md5 `fbe1571e6f5d96d081d790453a08387e` · 3 of 3

```
the tree, copied to .harness/nat with a config tree; the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
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
the binary - the README's loggers line, port 19157:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19157 --management.endpoints.web.exposure.include=health,prometheus,loggers
  listens on: 127.0.0.1:19157
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19157/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19157/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} 200    (keys sorted)
$ cd .harness/nat && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19157/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  tiffinbox_orders_cooked_total 120.0
  tiffinbox_orders_value_total 24300.0
$ cd .harness/nat && curl -s -o loggers.json -w '%{http_code}\n' http://127.0.0.1:19157/actuator/loggers
  404
a port taken - the README's line, while the first binary holds 19157:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19157
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN o.s.c.support.GenericApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox could not listen on 127.0.0.1:19157: something else already listens there.
  Action:
  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.
  its log: the banner's :: Spring Boot :: line 1 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
$ $CURLSET 19157 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the binary, the README's line and a bare 19151:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19157 19151
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 2 of 2 is 19151.
  Action:
  To set the port, give it as an option: --tiffinbox.port=19151.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19157 0 · 19151 0
```

## 8 · forms — one tree, five forms

The jar, the AOT jar, the binary, the image and the dev class path, one after the other: each one's command, readiness `{"status":"UP"} 200`, the seven `115c36ba…`; the summary: 5 of 5.

`.r-forms.out` · md5 `fdadcbc199f2349e3902cb97a878f396` · 3 of 3

```
1 the jar - .harness/serve, the README's run line, port 19150:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19150
  listens on: 127.0.0.1:19150
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19150/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19150 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19154:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19154
  listens on: 127.0.0.1:19154
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19154/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19154 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19157:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19157
  listens on: 127.0.0.1:19157
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19157/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19157 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - tiffinbox-capstone:1.0.0 (the image capture's), the README's run line with your user, port 19155:
$ cd .harness/serve && docker run -d --name tiffinbox-capstone --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19155:18425 tiffinbox-capstone:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19155/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19155 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-capstone
  0
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  its log: orders cooked:  120 · TiffinBox listening on http://0.0.0.0:18425 · the demo token 0 times · X-Shutdown-Token 0 times
5 the dev class path - .harness/serve, the README's dev line (Compose starts compose.yaml's Postgres), port 19156:
$ cd .harness/serve && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19156 --spring.profiles.active=dev
  listens on: 127.0.0.1:19156
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19156/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19156 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then docker compose -p tiffinbox-dev down -v: containers, volumes and networks 0
five forms, one tree: the seven's md5 5 of 5 times 115c36bac276128e245ca57df11c2891 · readiness {"status":"UP"} 200 5 of 5
```


## Exercise

**Your turn:** start the image with ten days instead of thirty, then read what the kitchen cooked. `exercise/README.md` has the
commands (copy the anchor with a random token of its own, build the jar offline, build `tiffinbox-mine:1.0.0`); done is the line
`the kitchen, ten days, in the image: {"ordersCooked":40,"ordersValue":8100}` — the argument after the image name reaches TiffinBox
(the Dockerfile lesson's exec form); without it the kitchen cooks 120. Measured answer: `exercise/solution/SOLUTION.md`.

## RE-MEASURE — the brief's items this unit settles

| Item (brief) | Before | This unit (receipts, 2026-10-08) |
|---|---|---|
| 4 · a bare argument after the image name; `--tiffinbox.days=10` after it | jar only | **`docker wait` 2, `argument 1 of 1 is 19151`, 0 frames, never bound** (`fails` D); **`{"ordersCooked":40,"ordersValue":8100}`** in the image (`exercise`) |
| 5 · the binary on 27's tree: the seven, readiness, the scrape, the analyzer | 26's tree, no scrape | **readiness 200, health with groups, `tiffinbox_orders_cooked_total 120.0`, a taken port's two sentences (exit 1, 0 frames), the seven** (`native`); `loggers` by flag `404` |
| The image on the Section 4 anchor (probe) | measured once | **the same on 27's tree**: user `ubuntu`, exec form, readiness, the seven, `docker wait` 0, the token 0 in its log; your uid in the container (`image`) |
| Compose for development (probe, a renamed copy of the file) | measured once | **on the anchor's own `compose.yaml`**: `tiffinbox-dev`, `127.0.0.1:18881`, the seven, 0 Pulling, 0 WARN, `exited (exit 0)`, `down -v` → none (`dev`) |
| `COMPOSE_PROJECT_NAME` overrides `name:` (S5.17) | measured once | **`planted-canary`** read back by `docker compose config` (`dev`); the receipts unset every `COMPOSE_*` first |
| "6 imports files, 74 entries, 31 applied here" (§Unit 29) | the probe's listing; 31 from the Actuator lesson | **6 · 74 · applied 31 (20 positive, 11 unconditional), skipped 43, neither 0** (`promises`) |

## Found on the way

- **In a container, the refusal's action names the wrong port to change.** `docker run … tiffinbox-capstone:1.0.0 19151` gives
  `To set the port, give it as an option: --tiffinbox.port=19151.` — but inside the container TiffinBox's port is the image's 18425,
  published by `-p 127.0.0.1:19155:18425`; following the action moves the port inside the container, and the published one then
  reaches nothing. The guard cannot know it runs in a container. Measured since (BLUE, `fails` E) and said in the voice and the
  anchor README; the guard's wording is unchanged.
- **A scrape cannot follow the seven**: their seventh request, POST /shutdown, ends the JVM. `ops` scrapes after six of them
  (`harness/six.sh`), and the seven's md5 is in every other capture.
- **Exposing `conditions` changes what applies**: with `conditions` in the exposure list, `ConditionsReportEndpointAutoConfiguration`
  joins the positive matches. "Applied here" is therefore read from `--debug`'s report, on the anchor's own exposure.
- **The image's `/app` holds two entries**, `application.jar` and `lib`: Boot's extract tool, with `--layers`, writes the jar's thin
  form and its libraries, and the four layer folders all land in `/app`.
- **The scrape's line count moves** between runs of one jar (173 and 180: the JVM's meters gain series as it runs) — so it is bounded,
  never counted.

## For unit 30 — and RED

- **No anchor change**: units 28, 29 and 30 all read `../c5-unit27/after` (= `../c5-tiffinbox`). If RED or BLUE changes 27's tree,
  re-run this receipt (about 17 minutes) — `forms`, `native` and `promises` would move.
- **`tiffinbox-dev` and 18881 are this unit's while it runs** (⚑12); 19150-19159 are free after it ends, and Docker holds nothing of it.
- **For RED part B:** the container's action-port wording (above); `docker build`'s uncounted lines (mask 6); whether `ops` should
  show `loggers` locked (`access=read-only`) beside the open write; units 21-26's "not … yet" terminal notes (S5.26, LOW).
