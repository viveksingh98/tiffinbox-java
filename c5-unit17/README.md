# c5-unit17 — Docker Compose for Development

Course 5 · Spring Boot · Section 3 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, Docker 29.4.0
(OrbStack; client 29.5.1), Docker Compose 5.1.3**, the official `postgres:18-alpine` (PostgreSQL 18.6 — the image on this Mac:
`docker.io/library/postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873`) and `eclipse-temurin:25-jre`
(the image run, the Dockerfile lesson's base), 2026-10-05, on an 8-core 16 GB Apple-silicon Mac.
TiffinBox gets a database for development: `compose.yaml` beside its README — one official Postgres, a fixed project name, its
port on `127.0.0.1` alone, no password, its data in a named volume — and Boot's Docker Compose support, `spring-boot-docker-compose`,
as an optional dependency, switched off in `application.yaml` and on by the profile `dev`. This unit starts TiffinBox with the
profile and prints every docker command Boot runs; opens the jar Boot ships and isolates the two plugin settings that keep the
module out; measures why the support starts switched off; starts TiffinBox every earlier way without the profile; prints what
Boot hands over for a database (and what it does not use); takes Docker away from one JVM (the break); and shows what a volume
without a name leaves behind.

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it (`diff -rq -x target` empty). "Before" is
`../c5-unit16/after/` (the anchor as the last unit to change it left it), **copied** to `.harness/before/`. Nothing here writes into
another unit's folder; one is read: `../c5-unit11/curlset.sh` (the seven requests). Clean builds, offline; every number the video
speaks is asserted; three runs per capture; and no capture, no README, no slide and nothing under `after/` holds the demo token, nor
the exercise's own (*The demo token*).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top.) `receipts.sh` **dies** when a capture's md5 differs from
`receipts.md5` — it prints the `DIFFERS` line first, so you can see which one moved. A whole run takes about five minutes on the
author's Mac. It needs a running Docker (it asks `docker info`, runs `orb start` only if Docker does not answer and the `orb` command
exists, then polls for 60 s), with `postgres:18-alpine` and `eclipse-temurin:25-jre` already on the machine (`docker pull` each once:
both were here before this unit). Nothing here pulls: every Boot log is counted for `Pulling` lines, 0. **It refuses to start while
Docker lists anything of the compose project `tiffinbox-dev`** — the anchor's project, so a developer's own dev run uses it too; this
script removes only what it creates (*The folders, the variables, the ports and the Docker names*).

**The repository.** Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the script): a copy of
`../c5-unit16/.m2-demo` without its `com/tiffinbox/`, plus the Section 3 seed `spring-boot/_research/m2-seed-s3/` copied with
`rsync --ignore-existing` and without its `com/tiffinbox/` (324 MB). It holds `spring-boot-docker-compose` 4.1.1 and the JDBC set the
details harness lists (spring-boot-jdbc, -persistence, -sql, -transaction 4.1.1, spring-jdbc and spring-tx 7.0.9, postgresql
42.7.13, checker-qual 3.55.1). Every `_remote.repositories` marker says `central` (1,900 marker lines, 0 naming a local repository).
Maven downloaded nothing. Each setup build prints `built <tree> · offline: yes` (or `no - …`) on the terminal; the captured builds
are offline-only (`-o`, no fallback: a build that needed the network would stop the run).

## Commands

What `receipts.sh` reads from this section (`readme()`: the first line of this file that matches; the script dies if one is
missing), with the variable they use:

```
M2="$PWD/.m2-demo"
mvn -o -B -f after/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package
mvn -o -B -f .harness/dev/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18880 --spring.profiles.active=dev
mvn -o -B -f .harness/jars/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package
sed -i '' 's|<artifactId>spring-boot-maven-plugin</artifactId>|&<configuration><includeOptional>true</includeOptional></configuration>|' .harness/jars/tiffinbox-web/pom.xml
cd .harness/dev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18889 --spring.profiles.active=dev --logging.level.org.springframework.boot.docker.compose.core.ProcessRunner=trace
sed -i '' '/^  docker:$/,/^      enabled: false$/d' .harness/ungated/tiffinbox-web/src/main/resources/application.yaml
cd .harness/plain && java -cp "../dev/tiffinbox-web/target/classes:$(cat ../dev/tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18882
cd .harness/dev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18885
cd .harness/dev && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
cd .harness/dev && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18886
docker build -q -t tiffinbox-nodev:1.0.0 after
docker run -d --name tiffinbox-nodev -m 512m -v "$PWD/.harness/dev/secrets:/app/secrets:ro" -p 127.0.0.1:18887:18425 tiffinbox-nodev:1.0.0
mvn -o -q -B -f harness/details/pom.xml -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/details/classpath.txt"
javac -cp ".harness/dev/tiffinbox-web/target/classes:$(cat .harness/dev/tiffinbox-web/target/classpath.txt):$(cat .harness/details/classpath.txt)" -d .harness/details/classes harness/details/Details.java
cd .harness/dev && java -cp "../details/classes:tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt):$(cat ../details/classpath.txt)" details.Details --tiffinbox.port=18883 --spring.profiles.active=dev
cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt):$(cat ../details/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18883 --spring.profiles.active=dev '--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:18881/tiffinbox?user=tiffinbox'
cd .harness/dev && DOCKER_HOST=unix:///nonexistent/docker.sock java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18884 --spring.profiles.active=dev
sed '/^    volumes:$/,/^      - data:/d; /^volumes:$/,$d' after/compose.yaml > .harness/anon/compose.yaml
docker compose -f .harness/dev/compose.yaml up -d --wait
docker compose -f .harness/dev/compose.yaml down
docker compose -p tiffinbox-dev down -v
```

- **A developer's copy.** TiffinBox starts in the folder that holds `compose.yaml` and its config tree, so every run with the profile
  starts in `.harness/dev`: `after/` copied (`rsync -a --exclude target`), a config tree beside its README, built with the README's
  second Maven command — the jar, and `tiffinbox-web/target/classpath.txt`, the class path Maven lists for the web module
  (`dependency:build-classpath`; the module and Jackson 3 are on it, the jar holds neither). Its jar is `after/`'s, byte for byte (`jar`).
- **Every variant is a README command with one thing changed**, and `receipts.sh` asserts each derivation: the lifecycle run (one
  logger at TRACE, `--logging.level.org.springframework.boot.docker.compose.core.ProcessRunner=trace`, added) · the previous tree's and
  the ungated tree's builds (the folder swapped) · jar B and D (`-Dspring-boot.repackage.excludeDockerCompose=false` added) · gate B
  (`../dev/` → `../ungated/`) · docker A (the port, 18880 → 18884) · docker B is docker A with `DOCKER_HOST=…` in front of `java`
  (asserted) · docker C (`--spring.docker.compose.enabled=false` added) · volume B (`.harness/dev/` → `.harness/anon/`) · `down -v`
  (`-v` added).
- **`mvn spring-boot:run` is not offered here.** It would start TiffinBox in the web module's own folder, which holds neither
  `compose.yaml` nor `secrets/` — its plugin's description says the working directory defaults to the module's `basedir` — and from
  this two-module root it needs `tiffinbox-core` installed first (the anchor README's `exec:exec` note). Not measured: the brief's
  re-measure stays open.

## The anchor change

Two new files and two changed ones; the Java sources are untouched — `change` shows the new files whole and the changed ones as
diffs:
- `compose.yaml` — new, at the anchor's root: 24 lines, 10 of them comments. `name: tiffinbox-dev`; one service, `postgres`, the
  official `postgres:18-alpine`, with `POSTGRES_DB: tiffinbox`, `POSTGRES_USER: tiffinbox` and `POSTGRES_HOST_AUTH_METHOD: trust` — no
  password anywhere, nothing secret committed; its port `"127.0.0.1:18881:5432"`, published on this computer's loopback alone (on
  OrbStack the container's own address answers from the Mac too, unpublished — `lifecycle`; RED #53); and its data in a
  named volume, `data:/var/lib/postgresql` (a departure from ⚑6, argued in `volume` and *Found on the way*).
- `tiffinbox-web/pom.xml` — `spring-boot-docker-compose`, no version (Boot's parent manages it), `<optional>true</optional>`, with a
  four-line comment: 9 lines.
- `tiffinbox-web/src/main/resources/application.yaml` — under `spring:`, `docker.compose.enabled: false` — three lines, the switch —
  with a four-line comment: 7 lines.
- `tiffinbox-web/src/main/resources/application-dev.yaml` — new: the profile `dev` sets `spring.docker.compose.enabled: true`. 8 lines,
  4 of them comments.
- `README.md` (the anchor's) — a new section, *Course 5 · unit 17 — Postgres for development*.

**Not changed:** `.gitignore` and `.dockerignore` (no `.env` file: `compose.yaml` needs no secret), the `Dockerfile`, the Java
sources — and **not `TiffinBoxApp`**, so RED S2 #8 stays deferred. The jar moved for the first time since the layers lesson:
`92452ee1f9a22920d8aa7e2655f2bdc0` → `e1f081f470c491adfba5dccced932734` (16,135,212 bytes), its two YAML files and the POM's copy; still byte-reproducible
(`jar`: built twice from two copies, the same bytes).

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token (the secrets lesson). Every run that serves reads it from a config tree —
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`) in `.harness/dev` or `.harness/plain`, holding a 26-character
demo token that is fake and looks it; `receipts.sh` writes both when it runs (`.harness/` is git-ignored). In the image run the
tree is mounted read-only at `/app/secrets`. The token never reaches a command line: the seven requests read it from the file
(`$CURLSET PORT TOKENFILE`). Every capture is masked — the token becomes `[masked: the 26-character token]` (`gsub`) — and
`receipts.sh` counts the raw token in each run's own output **before** masking (`.harness/raw-*`: 0 in all 27 capture runs), and the
exercise's own token (32 random hexadecimal characters, `openssl rand -hex 16`, read back from its file) in the exercise's runs: 0;
then the demo token in every capture, this README, the anchor README, `compose.yaml`, `application-dev.yaml`, the exercise, its
solution, the harness and `receipts.md5`: 0; and in `after/`: 0 files hold it. `compose.yaml` holds no secret at all: no
`POSTGRES_PASSWORD`, `POSTGRES_HOST_AUTH_METHOD: trust` (asserted). No `.env` file exists, so `.gitignore` and `.dockerignore`
are unchanged. The builder counts the token again in the script, the deck and the prompter: 0.

## The folders, the variables, the ports and the Docker names

- `after/` — the frozen tree, built clean in place (`package`): the jar `change` compares and the image's build context.
  `.harness/before/` — `../c5-unit16/after`, built clean once, with its class path file. `.harness/dev/` — a developer's copy (above).
  `.harness/ungated/` — `after/` with the switch's three lines deleted (the README's `sed`), built the README's way. `.harness/plain/` —
  a config tree and nothing else. `.harness/anon/compose.yaml` — `after/compose.yaml` without its volume lines (the README's `sed`).
  `.harness/jars/` — one copy of `after/`, rebuilt five times by `jar`. `.harness/details/` — the harness's class path file and its
  compiled class. `.harness/mine/` — the exercise's copy, removed by its own clean-up.
- `harness/details/` — `Details.java` (package `details`, outside `com.tiffinbox`) and `pom.xml`, which is not TiffinBox's: its two
  dependencies, `spring-boot-jdbc` and `org.postgresql:postgresql`, take Boot's versions from its parent, and Maven lists their class
  path for the harness alone. They never reach the anchor.
- On screen: `$M2` = this unit's `.m2-demo`; `$PWD` = the shell's current folder, this unit's; `$CURLSET` = `../c5-unit11/curlset.sh`,
  the comparison set since the secrets lesson — its folder carries a unit number, so no slide prints the path.
- **Ports** (brief ⚑10, 18880-18889, checked free with `lsof` before anything is wiped, with 18425): `lifecycle` 18880 · **Postgres
  18881** (compose.yaml's: every run with the profile publishes it, one at a time) · `gate` 18882 · `details` 18883 · `docker` 18884 ·
  `default` 18885 (the jar), 18886 (extracted), 18887 (the image, `-p 127.0.0.1:18887:18425`) · `exercise` 18888 (its README's) ·
  `jar` 18889. Every port is published on `127.0.0.1` alone (asserted for every `docker run` line and every `ports:` entry).
- **Docker names** (no unit number, §R.4 and ⚑11): the compose project **`tiffinbox-dev`** — `compose.yaml`'s `name:` — with its
  network `tiffinbox-dev_default`, its container `tiffinbox-dev-postgres-1` and its volume `tiffinbox-dev_data`; this unit's own image
  `tiffinbox-nodev:1.0.0` and container `tiffinbox-nodev`; in `volume` B, one volume with no name, its 64-character ID recorded while
  its container runs. **Removed** after every capture run, and by the exit trap after a pass, a failure or Ctrl-C: the project with
  `docker compose -p tiffinbox-dev down -v`, repeated until Docker lists none of its containers, volumes or networks; the image and the
  container by name; the unnamed volume by its recorded ID. `tiffinbox-docker:*` (the Dockerfile lesson's) is never touched. A
  container, image or volume that was there before the run is never touched; `docker … prune` is never run (a third-party container
  and its images live on this Docker). BuildKit's cache keeps the image's layers — its context, `after/`, holds no token — and no
  prune is run: a filtered prune makes BuildKit match no earlier record afterwards, for every build on this Docker (measured in
  `../c5-unit16/`, which prunes its own leak layer at its exit).

## Masks, filters and hygiene — every one, declared

1. **Paths and the token:** in every line of every capture (`gsub()`, the patterns escaped as literals): the demo token →
   `[masked: the 26-character token]`; this folder's absolute path → `…`, also URL-encoded; the folder above it → `…/..`; the home
   folder → `~`. A last check fails if any capture still holds `/Users/`, `/private/` or `/home/`.
2. **IDs:** a line that is a 64-hex container ID → `[a container ID]`; an image ID (`sha256:` and 64 hex, what `docker build -q`
   prints) → `[an image ID]`; any other 64-hex name — the unnamed volume's — → `[a volume ID]`; the 12-hex container ID that ends the
   `docker inspect` command Boot runs → `[a container ID]`.
3. **Boot's own variable text:** an embedded H2's random database name (a UUID) → `jdbc:h2:mem:<a random name>`; a PID → `<pid>`.
4. **Boot's logs** are kept in `.harness/` and read, never printed whole. A line is printed from its message on (the time, level,
   PID, thread and logger columns dropped), trailing and leading spaces dropped. `lifecycle` prints Boot's lines about Docker Compose
   in the log's order — the active profile, `DockerComposeLifecycleManager`'s and `DockerCli`'s lines (DockerCli logs Docker
   Compose's own output), `ProcessRunner`'s `Running '…'` lines with their thread, TiffinBox's listening line — and counts the rest:
   the banner, Boot's and TiffinBox's other lines, and `ProcessRunner`'s two lines after each command (`Waiting for process exit`,
   `Process exited with exit code 0`, each counted). Elsewhere a capture prints named lines (`Healthy`, `Starting embedded database`,
   the exception, the last `Caused by:`) and counts: `lines from Boot's Docker Compose support` = the lines of those three loggers.
5. **Docker Compose's own output** (standard error of `docker compose …`) is counted, with its last line printed (`volume`); in the
   exercise it is printed whole, prefixed `stderr:`.
6. **The class path** is printed as jar names, never paths; `docker ps`, `docker volume ls` and `docker network ls` only with the
   project's label (`com.docker.compose.project=tiffinbox-dev`) or this unit's names.
7. **No duration is captured**: no `Started … in` line, no time. The run's minutes are on the terminal.
8. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*`, `SPRING_*` and `COMPOSE_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS`, `MAVEN_ARGS`, and the variables that change what Docker's builds do (`DOCKER_BUILDKIT`, `BUILDKIT_*`, `BUILDX_*`,
   `DOCKER_DEFAULT_PLATFORM`, `SOURCE_DATE_EPOCH`) before it runs anything (`DOCKER_HOST` and `DOCKER_CONTEXT` stay: they say which
   Docker to reach); it refuses to run twice at once in this folder (`.r-lock`), with a `secrets/` in this folder, or with a `secrets/`
   or `tiffinbox-local.yaml` in `after/`; it removes its own image and container names before it starts.

**Interrupted.** `receipts.sh`'s exit trap stops the JVM it started in the background, if one still runs — SIGTERM, so Boot's
shutdown hook runs `docker compose stop` — then stops any `docker compose --file <this folder>/…` command a JVM of this script left
running (a background JVM, and the docker commands it starts, ignore the terminal's Ctrl-C), removes the compose project with `down
-v` until Docker lists nothing of it, removes the image, the container and any recorded unnamed volume, and drops the lock — on a
failed check and on Ctrl-C alike. Every command in the trap is guarded, so `set -e` cannot end it early; `$pid` is cleared whenever the
JVM has been reaped.
**Tested 2026-10-05, four times.** Each time `receipts.sh` ran in the foreground of a driver shell that leads its own process group
(`perl -e '$SIG{INT} = "DEFAULT"; setpgrp(0, 0); exec @ARGV' bash driver.sh`; the driver catches SIGINT with a handler and carries on,
so `receipts.sh` starts with SIGINT at its default, as from a terminal), and a watcher sent SIGINT to the whole group: (1) during
`lifecycle`, the moment Boot's `docker compose … up` was running — the JVM starting, `tiffinbox-dev-postgres-1` `created`, the volume
made, 18881 published; (2) during `default`, `tiffinbox-nodev` running, 18887 published; (3) during `volume` B's `up` — the container
`created` with its unnamed volume, before the script had recorded the volume's ID; (4) during `volume` B after `docker compose down`
— no container, the unnamed volume left behind, its ID recorded. `receipts.sh` exited **130** each time, and 5 s later: 0 JVMs and 0
processes with this unit's path in their command line, 0 `docker compose --file <this folder>/…` processes, 0 containers, volumes or
networks of the project, 0 `tiffinbox-nodev` containers or images, 0 volumes and 0 images that were not there before the run, 0
listeners on 18425 and 18880-18889, `.r-lock` gone — and the third-party container still running. (A fifth SIGINT, sent when a
watcher gave up waiting during `docker`'s third run: 130, and nothing of the run left.) **Tested once more by BLUE part B**, after
`lifecycle` gained its `docker inspect`, `pg_isready` and `nc` lines: SIGINT the moment `lifecycle`'s TiffinBox listened on 18880,
`tiffinbox-dev-postgres-1` running with its volume → exit **130**; 5 s later 0 containers, volumes or networks of the project, 0
listeners on 18425 and 18870-18899, no process with this unit's path, `.r-lock` gone, the third-party container running.

## 1 · Change — two new files, two changed; the jar; the class path; the module

`.r-change.out` `e29660c31f5f4a3495e79da49bd11f8a` — 70 lines

```
files, README aside: the previous tree 20 · after/ 22 · in both 20: identical 18, changed 2
  only before: (none)
  only after:  compose.yaml tiffinbox-web/src/main/resources/application-dev.yaml
  changed:     tiffinbox-web/pom.xml tiffinbox-web/src/main/resources/application.yaml
  README.md, the anchor's: lines added 48 · removed 0
after/compose.yaml, whole - 24 lines, 10 of them comments:
  1  # TiffinBox's database for development: one official Postgres image. Boot's Docker Compose support starts it while the
  2  # profile "dev" is active (application-dev.yaml), from the folder TiffinBox starts in - this one - and stops it when
  3  # TiffinBox stops. Development only: the executable jar holds none of that support.
  4  # A fixed project name: the network, the container and the volume are named after it, never after this folder.
  5  name: tiffinbox-dev
  6  services:
  7    postgres:
  8      image: postgres:18-alpine
  9      environment:
 10        POSTGRES_DB: tiffinbox
 11        POSTGRES_USER: tiffinbox
 12        # No password anywhere: Postgres trusts every connection that reaches it, and the port below is published on
 13        # this computer's 127.0.0.1 alone. Nothing in this file is a secret, so the file is committed.
 14        POSTGRES_HOST_AUTH_METHOD: trust
 15      ports:
 16        # 127.0.0.1, port 18881, on this computer -> 5432, Postgres's own port, in the container.
 17        - "127.0.0.1:18881:5432"
 18      volumes:
 19        # The data, in a volume with a name, tiffinbox-dev_data: kept when the container is stopped or removed, and
 20        # deleted by docker compose -p tiffinbox-dev down -v. Without this line the image still declares a volume
 21        # there, and Docker makes one with no name: docker compose down leaves it behind, a 64-character ID its only name.
 22        - data:/var/lib/postgresql
 23  volumes:
 24    data:
after/tiffinbox-web/src/main/resources/application-dev.yaml, whole - 8 lines, 4 of them comments:
  1  # The profile "dev": Boot's Docker Compose support, switched on (application.yaml switches it off). Start TiffinBox
  2  # from this project's root folder, where compose.yaml is, on a class path that holds spring-boot-docker-compose, with
  3  # --spring.profiles.active=dev: Boot runs docker compose up and waits, then starts TiffinBox; when TiffinBox stops,
  4  # Boot runs docker compose stop. The executable jar does not hold the module, so there this profile starts nothing.
  5  spring:
  6    docker:
  7      compose:
  8        enabled: true
after/tiffinbox-web/src/main/resources/application.yaml against the previous tree's: lines added 7 · removed 0
  >   # Boot's Docker Compose support (spring-boot-docker-compose, an optional dependency of tiffinbox-web): off. On a class
  >   # path that holds the module - the one Maven lists for tiffinbox-web does; the executable jar does not - it would
  >   # otherwise run docker compose up from the folder TiffinBox starts in, and stop the start where that folder holds no
  >   # compose.yaml, or where Docker does not answer. The profile "dev" switches it on: application-dev.yaml.
  >   docker:
  >     compose:
  >       enabled: false
after/tiffinbox-web/pom.xml against the previous tree's: lines added 9 · removed 0
  >     <!-- Course 5: Boot's Docker Compose support, for development only - optional, so Boot's plugin leaves it out of
  >          the executable jar (its includeOptional is off), and with it the Jackson 3 it brings; the plugin's
  >          excludeDockerCompose, on, would keep the module out even then. It runs from a class path that holds it,
  >          and only with the profile "dev": application.yaml switches it off. -->
  >     <dependency>
  >       <groupId>org.springframework.boot</groupId>
  >       <artifactId>spring-boot-docker-compose</artifactId>
  >       <optional>true</optional>
  >     </dependency>
the two trees' jars, each built clean: md5 92452ee1f9a22920d8aa7e2655f2bdc0 and e1f081f470c491adfba5dccced932734 · bytes 16134264 and 16135212 · the same bytes: no
  entries 169 and 170 · the same name and CRC: 167 · the rest, by name:
  BOOT-INF/classes/application-dev.yaml (only after)
  BOOT-INF/classes/application.yaml (changed)
  META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml (changed)
the class path Maven lists for tiffinbox-web (dependency:build-classpath, tiffinbox-web/target/classpath.txt): the previous tree 33 jars · after/'s copy, .harness/dev, 36
  only after: jackson-core-3.1.5.jar jackson-databind-3.1.5.jar spring-boot-docker-compose-4.1.1.jar · only before: (none)
  Jackson's jars on .harness/dev's: jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-core-3.1.5.jar jackson-databind-2.22.2.jar jackson-databind-3.1.5.jar
spring-boot-docker-compose-4.1.1.jar, META-INF/spring.factories, whole:
  # Application Listeners
  org.springframework.context.ApplicationListener=\
  org.springframework.boot.docker.compose.lifecycle.DockerComposeListener,\
  org.springframework.boot.docker.compose.service.connection.DockerComposeServiceConnectionsApplicationListener
```

`compose.yaml` and `application-dev.yaml` are new, the web POM and `application.yaml` changed, the other 18 files identical (README
aside). `compose.yaml`: 24 lines, 10 of them comments. No `POSTGRES_PASSWORD`: `POSTGRES_HOST_AUTH_METHOD: trust` (asserted). The
switch is three lines of `application.yaml` (the other four are their comment). **The jar moved** for the first time since the
layers lesson: 3 of its entries differ — `application.yaml`, the new `application-dev.yaml`, and the POM's own copy under
`META-INF/maven/` — the other 167 are byte for byte the Dockerfile lesson's (name and CRC). **The class path Maven lists** for the web
module gains 3 jars: the module and Jackson 3's two (`jackson-core`, `jackson-databind` 3.1.5), beside Jackson 2.22.2. The module's
`spring.factories` names its two `ApplicationListener`s — the file SpringApplication read its listeners from in this course's first
lesson.

## 2 · Lifecycle — what Boot does with Docker, start to stop

`.r-lifecycle.out` `454a58b2a98aaa0ee43efe7d83478916` — 43 lines

```
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
$ docker image inspect -f '{{json .Config.Volumes}} {{json .Config.Healthcheck}}' postgres:18-alpine
  {"/var/lib/postgresql":{}} null
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18880 --spring.profiles.active=dev --logging.level.org.springframework.boot.docker.compose.core.ProcessRunner=trace
  listens on: 127.0.0.1:18880 · WARN lines 0 · ERROR lines 0
the compose project while TiffinBox runs: tiffinbox-dev-postgres-1 running 127.0.0.1:18881->5432/tcp
$ docker inspect -f '{{.State.Status}} · health status: {{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' tiffinbox-dev-postgres-1
  exit 0 · running · health status: none
$ docker exec tiffinbox-dev-postgres-1 pg_isready
  exit 0 · /var/run/postgresql:5432 - accepting connections (polled until it answered)
$ nc -z -G 2 "$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' tiffinbox-dev-postgres-1)" 5432
  exit 0 · the container's own address, port 5432 - which no ports: entry publishes (polled until it answered)
$ $CURLSET 18880 .harness/dev/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the log, start to exit: 53 lines · shown 22 - Boot's lines about Docker Compose, the profile and TiffinBox's listening line (README, filters); not shown 31 - the banner, Boot's and TiffinBox's other lines, and the two ProcessRunner lines after each Running line: Waiting for process exit 9 · Process exited with exit code 0 9
  The following 1 profile is active: "dev"
  Using Docker Compose file …/.harness/dev/compose.yaml
  [main] Running 'docker version --format {{.Client.Version}}'
  [main] Running 'docker compose version --format json'
  [main] Running 'docker context ls --format={{ json . }}'
  [main] Running 'docker compose --file …/.harness/dev/compose.yaml --ansi never config --format=json'
  [main] Running 'docker compose --file …/.harness/dev/compose.yaml --ansi never ps --orphans=false --format=json'
  [main] Running 'docker compose --file …/.harness/dev/compose.yaml --ansi never up --no-color --detach --wait'
  Network tiffinbox-dev_default Creating
  Network tiffinbox-dev_default Created
  Volume tiffinbox-dev_data Creating
  Volume tiffinbox-dev_data Created
  Container tiffinbox-dev-postgres-1 Creating
  Container tiffinbox-dev-postgres-1 Created
  Container tiffinbox-dev-postgres-1 Starting
  Container tiffinbox-dev-postgres-1 Started
  Container tiffinbox-dev-postgres-1 Waiting
  Container tiffinbox-dev-postgres-1 Healthy
  [main] Running 'docker compose --file …/.harness/dev/compose.yaml --ansi never ps --orphans=false --format=json'
  [main] Running 'docker inspect --format={{ json . }} [a container ID]'
  TiffinBox listening on http://127.0.0.1:18880
  [ionShutdownHook] Running 'docker compose --file …/.harness/dev/compose.yaml --ansi never stop --timeout 10'
  Running lines: 9 · on the main thread: 8 · lines that say Pulling: 0
the compose project after TiffinBox exited:
  containers: tiffinbox-dev-postgres-1 exited (exit code 0)
  volumes: tiffinbox-dev_data
  networks: tiffinbox-dev_default
```

One logger at TRACE, `ProcessRunner` — the class that runs Boot's docker commands — prints each command line. **Boot runs Docker's own
command-line tool**, 8 times on `main` before TiffinBox listens: `docker version`, `docker compose version`, `docker context ls`, then,
with the file named by `--file`, `config`, `ps`, `up --no-color --detach --wait`, `ps` again, and `docker inspect` of the container.
`Using Docker Compose file …/.harness/dev/compose.yaml`: the folder TiffinBox started in. Compose's own lines follow `up`: the network,
the volume, the container — `Creating`, `Created`, `Starting`, `Started`, `Waiting`, `Healthy`. The image declares no health check
(`null`); `Healthy` is Compose's last word, and here it means only running: while TiffinBox runs, `docker inspect` gives the
container `running · health status: none` (RED #50 caught `pg_isready` answering `no response` the moment `--wait` returned; Boot's
own readiness check is not named on screen, and not measured here). Every name Compose made starts with the project's (3 of 3).
TiffinBox then listens, the container runs with `127.0.0.1:18881->5432/tcp`, and — Postgres polled with `pg_isready` until it
accepts — the container's own address, port 5432, answers from the Mac: no `ports:` entry publishes it, OrbStack routes the
container's address (`nc -z`, polled every 0.5 s: the first connection to a project network made a moment ago failed once in five
probes, Postgres already accepting; RED #53). The seven hash to `115c36bac276128e245ca57df11c2891`. **After POST /shutdown,
Boot runs one more command, on the shutdown hook's thread** (`[ionShutdownHook]`): `stop --timeout 10`. The container is `exited
(exit code 0)` — stopped, not removed — and the volume and the network stay. `Pulling`: 0 — the image was here.

## 3 · Jar — what Boot ships, and the two settings that keep the module out

`.r-jar.out` `e401a913c778cdb0291683655585d76c` — 38 lines

```
$ rsync -a --delete --exclude target after/ .harness/jars/
  exit 0
A   Boot's plugin as the anchor declares it: no settings
$ mvn -o -B -f .harness/jars/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · offline: yes (-o) · BUILD SUCCESS lines: 1
  BOOT-INF/lib/: 31 jars · spring-boot-docker-compose: 0 · Jackson 3, jackson-core-3 and jackson-databind-3: 0
  the jar: after/'s, the same bytes: yes · .harness/dev's, the same bytes: yes
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
$ cd .harness/dev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18889 --spring.profiles.active=dev --logging.level.org.springframework.boot.docker.compose.core.ProcessRunner=trace
  listens on: 127.0.0.1:18889 · WARN lines 0 · ERROR lines 0
  the log: The following 1 profile is active: "dev" · lines from Boot's Docker Compose support: 0
$ $CURLSET 18889 .harness/dev/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  the compose project now: containers, volumes and networks 0
B   -Dspring-boot.repackage.excludeDockerCompose=false: the plugin's own exclusion, off
$ mvn -o -B -f .harness/jars/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package -Dspring-boot.repackage.excludeDockerCompose=false
  exit 0 · offline: yes (-o) · BUILD SUCCESS lines: 1
  BOOT-INF/lib/: 31 jars · spring-boot-docker-compose: 0 · Jackson 3, jackson-core-3 and jackson-databind-3: 0
C   includeOptional, on: one line of tiffinbox-web/pom.xml changed
$ sed -i '' 's|<artifactId>spring-boot-maven-plugin</artifactId>|&<configuration><includeOptional>true</includeOptional></configuration>|' .harness/jars/tiffinbox-web/pom.xml
  exit 0 · tiffinbox-web/pom.xml against after/'s, lines that differ: 2
  <         <artifactId>spring-boot-maven-plugin</artifactId>
  >         <artifactId>spring-boot-maven-plugin</artifactId><configuration><includeOptional>true</includeOptional></configuration>
$ mvn -o -B -f .harness/jars/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · offline: yes (-o) · BUILD SUCCESS lines: 1
  BOOT-INF/lib/: 33 jars · spring-boot-docker-compose: 0 · Jackson 3, jackson-core-3 and jackson-databind-3: 2
D   both: includeOptional on, excludeDockerCompose off
$ mvn -o -B -f .harness/jars/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package -Dspring-boot.repackage.excludeDockerCompose=false
  exit 0 · offline: yes (-o) · BUILD SUCCESS lines: 1
  BOOT-INF/lib/: 34 jars · spring-boot-docker-compose: 1 · Jackson 3, jackson-core-3 and jackson-databind-3: 2
A′  A re-run: the POM restored
$ cp after/tiffinbox-web/pom.xml .harness/jars/tiffinbox-web/pom.xml
  exit 0
$ mvn -o -B -f .harness/jars/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · offline: yes (-o) · BUILD SUCCESS lines: 1
  BOOT-INF/lib/: 31 jars · spring-boot-docker-compose: 0 · Jackson 3, jackson-core-3 and jackson-databind-3: 0
  the jar: after/'s, the same bytes: yes
```

**A** — the jar as the anchor declares Boot's plugin: 31 jars in `BOOT-INF/lib/`, the module 0, Jackson 3 0; `after/`'s jar, byte for
byte (and `.harness/dev`'s). Run with the profile, beside `compose.yaml`: the profile is active, and Boot's Docker Compose support
logs 0 lines — with `ProcessRunner` at TRACE, so no docker command ran — and the seven are `115c36ba…`. **B** —
`excludeDockerCompose` off: still 31 · 0 · 0, so `includeOptional`, off, keeps the module and its Jackson out. **C** —
`includeOptional` on (one POM line, by `sed`), `excludeDockerCompose` as Boot sets it: 33 · 0 · 2 — the module stays out, its Jackson
3 gets in. **D** — both: 34 · 1 · 2. **A′** = A, the POM restored. C sets `includeOptional` in the POM's plugin
configuration: the plugin's own descriptor (`META-INF/maven/plugin.xml` in `spring-boot-maven-plugin-4.1.1.jar`, read once, not a
capture) gives it no command-line property; `excludeDockerCompose` has one, `spring-boot.repackage.excludeDockerCompose` (B and D).

## 4 · Gate — why the support starts switched off

`.r-gate.out` `94b5f3c06fe2a5f8a817b99c3d6d5666` — 28 lines

```
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
every run starts in .harness/plain: a config tree (secrets/tiffinbox/shutdown-token), and compose.yaml: none
the class path file, .harness/dev's tiffinbox-web/target/classpath.txt, names spring-boot-docker-compose: 1 jar
A   after/ as built: the module on the class path, the switch off in application.yaml - no profile
$ cd .harness/plain && java -cp "../dev/tiffinbox-web/target/classes:$(cat ../dev/tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18882
  listens on: 127.0.0.1:18882 · WARN lines 0 · ERROR lines 0
  lines from Boot's Docker Compose support: 0
$ $CURLSET 18882 .harness/plain/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B   the switch's three lines deleted - Boot's default, on (.harness/ungated, built the README's way at the start)
  the module's own default for the key, from its metadata (META-INF/spring-configuration-metadata.json): spring.docker.compose.enabled = true
$ sed -i '' '/^  docker:$/,/^      enabled: false$/d' .harness/ungated/tiffinbox-web/src/main/resources/application.yaml
  application.yaml against after/'s, lines removed: 3
  <   docker:
  <     compose:
  <       enabled: false
$ cd .harness/plain && java -cp "../ungated/tiffinbox-web/target/classes:$(cat ../ungated/tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18882
  exit 1 · lines 32 · listening lines 0 · WARN lines 0 · ERROR lines 1
  java.lang.IllegalStateException: No Docker Compose file found in directory '…/.harness/plain/.'
  the compose project now: containers, volumes and networks 0
A′  A re-run
$ cd .harness/plain && java -cp "../dev/tiffinbox-web/target/classes:$(cat ../dev/tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18882
  listens on: 127.0.0.1:18882 · WARN lines 0 · ERROR lines 0
  lines from Boot's Docker Compose support: 0
$ $CURLSET 18882 .harness/plain/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

From `.harness/plain` — a config tree and no `compose.yaml`, the kind of folder a harness starts in — on the class path that holds
the module, with no profile. **A** (`after/` as built, the switch off): 0 lines from Boot's Docker Compose support, the seven
`115c36ba…`. **B** (the switch's three lines deleted, so the module's own default applies: `spring.docker.compose.enabled = true`, its
metadata says): exit 1, 0 listening lines, `java.lang.IllegalStateException: No Docker Compose file found in directory
'…/.harness/plain/.'`. **A′** = A. This is the brief's loser 1 (Boot's default), measured: here, a run on that class path from a folder
without `compose.yaml` stopped this way; with the switch, the same run served.

## 5 · Default — every earlier way, no profile

`.r-default.out` `fe6969a70cd3481ac80b869a6836a317` — 33 lines

```
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
1   the executable jar
$ cd .harness/dev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18885
  listens on: 127.0.0.1:18885 · WARN lines 0 · ERROR lines 0
  lines from Boot's Docker Compose support: 0
$ $CURLSET 18885 .harness/dev/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
2   the jar, extracted: a thin jar and lib/
$ rm -rf .harness/dev/tiffinbox-web/target/extracted
  exit 0
$ cd .harness/dev && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0 · lib/: 31 jars · spring-boot-docker-compose among them: 0
$ cd .harness/dev && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18886
  listens on: 127.0.0.1:18886 · WARN lines 0 · ERROR lines 0
  lines from Boot's Docker Compose support: 0
$ $CURLSET 18886 .harness/dev/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
3   the image, from the anchor's Dockerfile - its build context after/
$ docker build -q -t tiffinbox-nodev:1.0.0 after
  exit 0 · [an image ID]
$ docker run -d --name tiffinbox-nodev -m 512m -v "$PWD/.harness/dev/secrets:/app/secrets:ro" -p 127.0.0.1:18887:18425 tiffinbox-nodev:1.0.0
  exit 0
  the address in the listening line: 0.0.0.0:18425 · WARN lines 0 · ERROR lines 0 · lines from Boot's Docker Compose support: 0
$ $CURLSET 18887 .harness/dev/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ docker wait tiffinbox-nodev
  0
$ docker rm tiffinbox-nodev
  listeners on 18887 now: 0
  the compose project now: containers, volumes and networks 0
```

The executable jar, the jar extracted (Boot's own tool: `lib/` 31 jars, the module not among them) and the image built from the
anchor's Dockerfile — each serves the seven, `115c36ba…`, with 0 lines from Boot's Docker Compose support. With `gate`'s A (the class
path Maven lists) that is every way TiffinBox has started in this section. The image still listens on `0.0.0.0:18425` inside and runs
as the Dockerfile lesson ran it (`-m 512m`, the tree read-only at `/app/secrets`, `-p 127.0.0.1:18887:18425`); it exits 0.

## 6 · Details — what Boot hands over for a database

`.r-details.out` `637d2a6649f311e0cfd673b8324b9326` — 46 lines

```
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
the harness's class path: TiffinBox's (.harness/dev, as built), then what harness/details/pom.xml adds - set up at the start:
$ mvn -o -q -B -f harness/details/pom.xml -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/details/classpath.txt"
  jars it lists: 18 · not already on TiffinBox's: 8
  checker-qual-3.55.1.jar postgresql-42.7.13.jar spring-boot-jdbc-4.1.1.jar spring-boot-persistence-4.1.1.jar spring-boot-sql-4.1.1.jar spring-boot-transaction-4.1.1.jar spring-jdbc-7.0.9.jar spring-tx-7.0.9.jar
$ javac -cp ".harness/dev/tiffinbox-web/target/classes:$(cat .harness/dev/tiffinbox-web/target/classpath.txt):$(cat .harness/details/classpath.txt)" -d .harness/details/classes harness/details/Details.java
  classes: 1
spring-boot-jdbc-4.1.1.jar, META-INF/spring.factories: ConnectionDetailsFactory entries 8 · the ones that read Docker Compose: 7 · Postgres's:
  org.springframework.boot.jdbc.docker.compose.PostgresJdbcDockerComposeConnectionDetailsFactory,\
the harness, the dev profile on
$ cd .harness/dev && java -cp "../details/classes:tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt):$(cat ../details/classpath.txt)" details.Details --tiffinbox.port=18883 --spring.profiles.active=dev
  exit 0 · WARN lines 0 · ERROR lines 0
  the log: Container tiffinbox-dev-postgres-1 Healthy
  the log: Starting embedded database: url='jdbc:h2:mem:<a random name>;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=false', username='sa'
  beans of type JdbcConnectionDetails: 1
    jdbcConnectionDetailsForTiffinboxDevPostgres1 -> org.springframework.boot.jdbc.docker.compose.PostgresJdbcDockerComposeConnectionDetailsFactory$PostgresJdbcDockerComposeConnectionDetails
      url=jdbc:postgresql://127.0.0.1:18881/tiffinbox user=tiffinbox password=(none)
  beans of type DataSource: 1
    dataSource -> org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseFactory$EmbeddedDataSourceProxy
      connects to: H2 jdbc:h2:mem:<a random name>
  the condition report: DataSourceAutoConfiguration -> matched
      @ConditionalOnClass found required classes 'javax.sql.DataSource', 'org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseType'
      @ConditionalOnMissingBean (types: io.r2dbc.spi.ConnectionFactory; SearchStrategy: all) did not find any beans
  the condition report: DataSourceAutoConfiguration$EmbeddedDatabaseConfiguration -> matched
      EmbeddedDataSource found embedded database H2
      @ConditionalOnMissingBean (types: javax.sql.DataSource,javax.sql.XADataSource; SearchStrategy: all) did not find any beans
  the condition report: DataSourceAutoConfiguration$PooledDataSourceConfiguration -> did not match
      AnyNestedCondition 0 matched 2 did not
      NestedCondition on DataSourceAutoConfiguration.PooledDataSourceCondition.PooledDataSourceAvailable PooledDataSource did not find supported DataSource
      NestedCondition on DataSourceAutoConfiguration.PooledDataSourceCondition.ExplicitType @ConditionalOnProperty (spring.datasource.type) did not find property 'spring.datasource.type'
the compose project after the harness closed its context:
  containers: tiffinbox-dev-postgres-1 exited (exit code 0)
  volumes: tiffinbox-dev_data
  networks: tiffinbox-dev_default
$ docker compose -p tiffinbox-dev down -v
  exit 0 · lines it printed: 8 · the project now: containers, volumes and networks 0
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
TiffinBox itself, on the harness's class path - the Postgres driver on it - pointed at that Postgres
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt):$(cat ../details/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18883 --spring.profiles.active=dev '--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:18881/tiffinbox?user=tiffinbox'
  exit 1 · lines 97 · listening lines 0
  the log: Container tiffinbox-dev-postgres-1 Healthy
  the last Caused by: line, the root cause: Caused by: org.postgresql.util.PSQLException: ERROR: syntax error at or near "AUTO_INCREMENT"
the compose project after it exited:
  containers: tiffinbox-dev-postgres-1 exited (exit code 0)
  volumes: tiffinbox-dev_data
  networks: tiffinbox-dev_default
```

The harness adds 8 jars to TiffinBox's class path — `harness/details/pom.xml`'s two dependencies and what they bring:
`spring-boot-jdbc` and its three siblings, Spring's JDBC and transaction jars, the Postgres driver and `checker-qual`. `spring-boot-jdbc`'s
own `spring.factories` lists 8 `ConnectionDetailsFactory` entries, 7 of them for Docker Compose — Postgres's among them. With the
profile on, Postgres `Healthy`, the harness finds **one `JdbcConnectionDetails` bean, `jdbcConnectionDetailsForTiffinboxDevPostgres1`**
(named after the container): `url=jdbc:postgresql://127.0.0.1:18881/tiffinbox user=tiffinbox password=(none)`. **But the one
`DataSource` is `EmbeddedDatabaseFactory$EmbeddedDataSourceProxy`, an H2 in memory** — Boot logged `Starting embedded database` — and
Boot's own condition report says why: `PooledDataSourceConfiguration` did not match (`PooledDataSource did not find supported
DataSource`); `EmbeddedDatabaseConfiguration` matched (`EmbeddedDataSource found embedded database H2`). After the harness closed its
context, the container was `exited`. **TiffinBox itself**, the Postgres driver on its class path, pointed at that Postgres with the
user `compose.yaml` created (`?user=tiffinbox`; TiffinBox's own `Database` asks for `sa`): exit 1, 0 listening lines, the root cause
`org.postgresql.util.PSQLException: ERROR: syntax error at or near "AUTO_INCREMENT"`. TiffinBox's SQL is H2's; Postgres is Course 7's
subject.

## 7 · Docker — the break (A/B/A′, with C)

`.r-docker.out` `6cce244704568f58883b1dbeec161923` — 31 lines

```
A   Docker reachable: the dev profile
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18884 --spring.profiles.active=dev
  listens on: 127.0.0.1:18884 · WARN lines 0 · ERROR lines 0
  the log: Container tiffinbox-dev-postgres-1 Healthy
$ $CURLSET 18884 .harness/dev/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ docker compose -p tiffinbox-dev down -v
  exit 0 · lines it printed: 8 · the project now: containers, volumes and networks 0
B   DOCKER_HOST, set for this JVM only, names a Docker socket that does not exist; OrbStack keeps running
$ cd .harness/dev && DOCKER_HOST=unix:///nonexistent/docker.sock java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18884 --spring.profiles.active=dev
  exit 1 · lines 44 · listening lines 0 · WARN lines 0 · ERROR lines 1
  org.springframework.boot.docker.compose.core.ProcessExitException: 'docker version --format {{.Client.Version}}' failed with exit code 1.
  failed to connect to the docker API at unix:///nonexistent/docker.sock; check if the path is correct and if the daemon is running: dial unix /nonexistent/docker.sock: connect: no such file or directory
  the compose project now: containers, volumes and networks 0
C   B, with the switch off on the command line
$ cd .harness/dev && DOCKER_HOST=unix:///nonexistent/docker.sock java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18884 --spring.profiles.active=dev --spring.docker.compose.enabled=false
  listens on: 127.0.0.1:18884 · WARN lines 0 · ERROR lines 0
  lines from Boot's Docker Compose support: 0
$ $CURLSET 18884 .harness/dev/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
A′  A re-run
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18884 --spring.profiles.active=dev
  listens on: 127.0.0.1:18884 · WARN lines 0 · ERROR lines 0
  the log: Container tiffinbox-dev-postgres-1 Healthy
$ $CURLSET 18884 .harness/dev/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

**A** — the profile, Docker reachable: `Healthy`, `115c36ba…`; the project removed with `down -v` before B. **B** — `DOCKER_HOST`, set in
front of `java`, so for this JVM and the docker commands it runs, names a socket that does not exist; OrbStack keeps running (a
third-party container runs on it): exit 1, 0 listening lines, `ProcessExitException: 'docker version --format {{.Client.Version}}'
failed with exit code 1.`, and the client's own `failed to connect to the docker API at unix:///nonexistent/docker.sock …`; nothing of
the project created. **C** — B with `--spring.docker.compose.enabled=false`: 0 Compose lines, `115c36ba…` — the way out with Docker
off; the other is to start without `dev` (`gate` A). **A′** = A.

## 8 · Volume — a name, or none

`.r-volume.out` `faac1390236ca9dfdef783cb56e8e830` — 53 lines

```
A   compose.yaml as the anchor has it: the data in a volume with a name
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
$ docker compose -f .harness/dev/compose.yaml up -d --wait
  exit 0 · lines it printed: 10 · the last: Container tiffinbox-dev-postgres-1 Healthy
$ docker inspect -f '{{range .Mounts}}{{.Type}} {{.Name}} -> {{.Destination}}{{println}}{{end}}' tiffinbox-dev-postgres-1
  volume tiffinbox-dev_data -> /var/lib/postgresql
$ docker compose -f .harness/dev/compose.yaml down
  exit 0 · lines it printed: 6 · the last: Network tiffinbox-dev_default Removed
  Docker lists for the project:
  containers: (none)
  volumes: tiffinbox-dev_data
  networks: (none)
$ docker compose -f .harness/dev/compose.yaml down -v
  exit 0 · lines it printed: 2 · the last: Volume tiffinbox-dev_data Removed
  the project now: containers, volumes and networks 0
B   the same file without its volume lines (made at the start)
$ sed '/^    volumes:$/,/^      - data:/d; /^volumes:$/,$d' after/compose.yaml > .harness/anon/compose.yaml
  .harness/anon/compose.yaml against after/compose.yaml, lines removed: 7 · added: 0
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
$ docker compose -f .harness/anon/compose.yaml up -d --wait
  exit 0 · lines it printed: 8 · the last: Container tiffinbox-dev-postgres-1 Healthy
$ docker inspect -f '{{range .Mounts}}{{.Type}} {{.Name}} -> {{.Destination}}{{println}}{{end}}' tiffinbox-dev-postgres-1
  volume [a volume ID] -> /var/lib/postgresql
  the volume's name, recorded while its container runs: 64 characters
$ docker compose -f .harness/anon/compose.yaml down
  exit 0 · lines it printed: 6 · the last: Network tiffinbox-dev_default Removed
  Docker lists for the project:
  containers: (none)
  volumes: (none)
  networks: (none)
$ docker volume inspect -f '{{json .Labels}}' [a volume ID]
  exit 0 · {"com.docker.volume.anonymous":""}
$ docker compose -f .harness/anon/compose.yaml down -v
  exit 0 · lines it printed: 0 · the last: (none)
$ docker volume inspect -f '{{.Name}}' [a volume ID]
  exit 0 · still there: yes
$ docker volume rm [a volume ID]
  exit 0 · lines it printed: 1
A′  A re-run
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
$ docker compose -f .harness/dev/compose.yaml up -d --wait
  exit 0 · lines it printed: 10 · the last: Container tiffinbox-dev-postgres-1 Healthy
$ docker inspect -f '{{range .Mounts}}{{.Type}} {{.Name}} -> {{.Destination}}{{println}}{{end}}' tiffinbox-dev-postgres-1
  volume tiffinbox-dev_data -> /var/lib/postgresql
$ docker compose -f .harness/dev/compose.yaml down
  exit 0 · lines it printed: 6 · the last: Network tiffinbox-dev_default Removed
  Docker lists for the project:
  containers: (none)
  volumes: tiffinbox-dev_data
  networks: (none)
$ docker compose -f .harness/dev/compose.yaml down -v
  exit 0 · lines it printed: 2 · the last: Volume tiffinbox-dev_data Removed
  the project now: containers, volumes and networks 0
```

Docker Compose alone, no TiffinBox. **A** — `compose.yaml` as the anchor has it: the container mounts `tiffinbox-dev_data` at
`/var/lib/postgresql`; `docker compose … down` removes the container and the network and keeps the volume; `down -v` removes it.
**B** — the same file without its volume lines (7 lines, the README's `sed`): the image still declares `/var/lib/postgresql` (`lifecycle`),
so Docker gives the container a volume with no name — a 64-character ID, labelled `com.docker.volume.anonymous`. `down` removes the
container and leaves the volume; Docker no longer lists it for the project; `down -v` afterwards prints nothing and leaves it too;
`docker volume rm <its ID>` removed it — `receipts.sh` recorded the ID while the container ran. **A′** = A. This is why
`compose.yaml` names the volume (*Found on the way*).

## 9 · Exercise — Boot's other stop

`.r-exercise.out` `4312a01468bce610f26f3334564ab077` — 45 lines

```
the compose project tiffinbox-dev, before this run: containers 0 · volumes 0 · networks 0
exercise/README.md's first block, run as written (its two export lines aside: this script set both):
$ rm -rf .harness/mine && mkdir -p .harness && rsync -a --exclude target after/ .harness/mine/
  exit 0
  (nothing printed)
$ mvn -o -q -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  exit 0
  (nothing printed)
$ mkdir -p .harness/mine/secrets/tiffinbox && (umask 077 && openssl rand -hex 16 > .harness/mine/secrets/tiffinbox/shutdown-token)
  exit 0
  (nothing printed)
$ cd .harness/mine && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18888 --spring.profiles.active=dev
  (the first terminal) listens on: 127.0.0.1:18888 · WARN lines 0 · ERROR lines 0 · Compose's last line in its log: Container tiffinbox-dev-postgres-1 Healthy
its second block - a second terminal, this folder:
$ { printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18888/shutdown
  exit 0
  {"stopping":true} 200
  (the first terminal, back at its prompt) exit 0
$ docker ps -a --filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Names}}:{{.State}}'
  exit 0
  tiffinbox-dev-postgres-1:exited
the measured answer, exercise/solution/SOLUTION.md's first block:
(from .harness/mine, where the README's start line left the first terminal)
$ java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18888 --spring.profiles.active=dev --spring.docker.compose.stop.command=down
  (the first terminal) listens on: 127.0.0.1:18888 · WARN lines 0 · ERROR lines 0 · Compose's last line in its log: Container tiffinbox-dev-postgres-1 Healthy
its second block - the second terminal:
$ { printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18888/shutdown
  exit 0
  {"stopping":true} 200
  (the first terminal, back at its prompt) exit 0
$ docker ps -a --filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Names}}:{{.State}}'
  exit 0
  (nothing printed)
$ docker volume ls --filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Name}}'
  exit 0
  tiffinbox-dev_data
exercise/README.md's last block, the clean-up:
$ docker compose -p tiffinbox-dev down -v
  exit 0
  stderr: Volume tiffinbox-dev_data Removing
  stderr: Volume tiffinbox-dev_data Removed
$ rm -rf .harness/mine
  exit 0
  (nothing printed)
the compose project now: containers, volumes and networks 0 · .harness/mine: gone
```

`exercise/README.md`'s three blocks and `exercise/solution/SOLUTION.md`'s two, read from the files and run as written: the start
lines in the background — the reader's first terminal — and every line after a POST /shutdown once that TiffinBox has exited (the
README says: once the first terminal is back at its prompt). The answer's start line runs from `.harness/mine`, where the README's
start line left the first terminal. The lesson's stop leaves `tiffinbox-dev-postgres-1:exited`; the next start finds that container
and starts it again (`Starting`, no `Created`); with `--spring.docker.compose.stop.command=down` the list is empty after the stop and
`tiffinbox-dev_data` is still listed; the clean-up's `down -v` prints only the volume's two lines. Run again by hand in a clean shell
(`env -i`): `exercise/solution/SOLUTION.md`.

## What the builds downloaded

**Maven:** nothing (every build `offline: yes`; the module and the JDBC set came with the Section 3 seed). **Docker:** no pull —
`postgres:18-alpine` and `eclipse-temurin:25-jre` were on this Mac before this unit (`Pulling` lines: 0 in every Boot log; `docker
build -q` used the base already here).

## Found on the way

- **The S3 probe left a Postgres volume on this Docker.** An unnamed volume created at 12:56:58 on 2026-10-05 — inside the probe's
  window — held a PostgreSQL 18 data folder (`18/docker`), and no container used it: what `volume` B shows `down` leaving behind (and
  a `down -v` run afterwards; `down -v` on the running project removes such a volume — RED #54). It was not removed by this unit; by
  RED part B's runs the same day it was gone, and Docker listed only the third party's volume (the probe notes' errata). It is why
  `compose.yaml` names its volume.
- **The probe's "TiffinBox … user `sa`, trust → `AUTO_INCREMENT`" needs the user in the URL.** TiffinBox's `Database` connects as
  `sa`; `compose.yaml` makes Postgres's user `tiffinbox`. Measured once in a scratch copy: without `?user=tiffinbox`, `FATAL: role "sa"
  does not exist`; with it, `AUTO_INCREMENT` (`details`, three runs).
- **Boot's Docker Compose support logs nothing when it stops** at INFO: the stop is visible only at TRACE (`ProcessRunner`) and in the
  container's state.
- **Boot finds the file before it asks Docker**: `Using Docker Compose file` comes before `docker version` (`lifecycle`) — so with no
  file the failure names the file (`gate` B), and with the file but no Docker it is `docker version` (`docker` B).
- **A second start reuses the exited container**: `Starting`, no `Created` (`exercise/solution/SOLUTION.md`'s run).
- **The jar moved, the class path moved, the image did not need to change**: the Dockerfile copies the jar alone; `compose.yaml` and
  `application-dev.yaml` sit in the build context, harmless (no secret in either).

## For the next units — 19 and 20 — and for RED

**Start from `c5-unit17/after/`** (copy it with `rsync -a --exclude target`, or build it in place:
`mvn -o -B -f ../c5-unit17/after/pom.xml -Dmaven.repo.local=<your .m2-demo> -DskipTests clean package`):
- **New:** `compose.yaml` at the root (project `tiffinbox-dev`, Postgres on `127.0.0.1:18881`, volume `tiffinbox-dev_data`),
  `application-dev.yaml`, `spring.docker.compose.enabled: false` in `application.yaml`, and `spring-boot-docker-compose` (optional) in
  the web POM. **The jar is now `e1f081f470c491adfba5dccced932734`** (16,135,212 bytes — `change`), still byte-reproducible; its
  `BOOT-INF/lib/` is unchanged (31 jars, no module, no Jackson 3).
- **Default runs need nothing new.** No profile: the jar, the extracted jar, the image and Maven's class path all serve
  `115c36bac276128e245ca57df11c2891` with 0 Compose lines (`default`, `gate` A). **Never start a harness with `dev`** unless it means
  to start Postgres; a harness on Maven's class path started from a folder without `compose.yaml` works only because the switch is off.
- **Under AOT (measured once in a scratch copy, 2026-10-05 — not a receipt; re-measure):** the module checks
  `spring.aot.processing` and `AotDetector.useGeneratedArtifacts()` first (its bytecode: `Docker Compose support disabled with AOT and
  native images`). `SpringApplicationAotProcessor` run on Maven's class path — the module on it — exited 0 in about a second with 0
  Docker or Compose lines (no Docker needed at build time). The AOT-processed app, run with `-Dspring.aot.enabled=true
  --spring.profiles.active=dev` beside `compose.yaml`: TRACE says `Docker Compose support disabled with AOT and native images`, no
  container is created, the seven are `115c36ba…`. So under AOT and in a native image, `dev` starts no Postgres. Also measured
  there: `mvn spring-boot:process-aot` from the root runs on `tiffinbox-core` first and fails (`Unable to find a suitable main class`)
  — the build-image lesson's trap again; it needs the web module alone (not measured here).
- **Unchanged:** the record `TiffinBoxProperties(jdbcUrl, cooks, days, port, address, mealTypes, shutdownToken)`; the listening line
  `TiffinBox listening on http://<address>:<port>`; the token from a config tree; a harness class path from `extract`; the seven via
  `../c5-unit11/curlset.sh PORT TOKENFILE`; the image as the Dockerfile lesson built it.
- **Docker here:** `postgres:18-alpine` is on this Mac (18.6, digest above). The probe's unnamed volume is gone (above).
- **RED:** the named volume is a departure from ⚑6 (argued: `volume`); `Healthy` is Compose's word, and here it means running (the
  image has no health check, the container no health status — measured);
  the trace flag is on screen in `lifecycle` and the jar's dev run, nowhere in the anchor; `mvn spring-boot:run` stays unmeasured; the
  exercise's answer leaves the volume by design; Course 11's Testcontainers is not named anywhere in the deck.

## Exercise

`exercise/README.md` — stop TiffinBox and list the compose containers (`tiffinbox-dev-postgres-1:exited`), then make the next stop
remove Postgres instead of just stopping it: `--spring.docker.compose.stop.command=down` — the list empty, `tiffinbox-dev_data` kept.
Run exactly as written in a clean shell (`env -i`): `exercise/solution/SOLUTION.md`.
