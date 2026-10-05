# c5-unit16 — A Dockerfile You Control

Course 5 · Spring Boot · Section 3 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, Docker 29.4.0
(OrbStack; client 29.5.1)**, the official `eclipse-temurin:25-jre` (Temurin 25.0.4.1+1 — the image on this Mac, as BuildKit
resolved it: `docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636`),
2026-10-05, on an 8-core 16 GB Apple-silicon Mac.
The buildpack decided everything last time. Here TiffinBox gets a Dockerfile of its own — two stages, the base, the address, the
user — and a `.dockerignore`. This unit builds the image the README's way (Maven on the Mac, offline; `docker build` packs the jar),
shows what a build context can carry and what the ignore file keeps out, runs the image with the config tree mounted read-only, asks
which user it runs as, whose files that user can read, and how much heap Java took, and stops it: in the exec form, where `docker stop`'s SIGTERM reaches Java and
TiffinBox's `@PreDestroy` method runs, and in the shell form, where it does not (the break).

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it (`diff -rq -x target` empty). "Before" is
`../c5-unit15/after/` (the anchor as the last unit to change it left it), **copied** to `.harness/before/`. Nothing here writes into
another unit's folder; two are read: `../c5-unit11/curlset.sh` (the seven requests) and `../c5-unit14/docker/Dockerfile` (the layers
lesson's two-stage recipe, compared instruction by instruction). Clean builds, offline; every number the video speaks is asserted;
three runs per capture; and no capture, no README, no slide, not the anchor's build context and **no layer of any image this unit
keeps** holds the demo token — the one image built to show the leak holds exactly one copy, counted, and is removed at once (*The demo
token*).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens, image layers included; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top.) `receipts.sh` **dies** when a capture's md5 differs from
`receipts.md5` — it prints the `DIFFERS` line first, so you can see which one moved. A whole run takes about four minutes on the
author's Mac (238-239 s, twice; the shell form's `docker stop` alone waits ten seconds, three times). **Run it on its own:** at its exit it prunes its own
build-cache records (*The demo token*), and a prune that removes a record makes BuildKit match no earlier record afterwards — for
every build on this Docker, measured — so a receipt that counts `CACHED` steps must not run beside it. **It refuses to start while an
image named `tiffinbox-docker:1.0.0` exists:** the anchor README builds that name too, so it may be yours (RED #44); remove it
yourself, then run again. It needs a running Docker (it asks `docker info`,
runs `orb start` only if Docker does not answer and the `orb` command exists, then polls for 60 s), and `eclipse-temurin:25-jre`
already on the machine (`docker pull eclipse-temurin:25-jre` once: it was here before this unit). No build here pulls: every BuildKit
log is counted for layer downloads, 0. **The two-stage build needs no JDK image:** Boot's extract tool runs on the JRE.

**The repository.** Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the script): a copy of
`../c5-unit15/.m2-demo` without its `com/tiffinbox/`, plus the Section 3 seed `spring-boot/_research/m2-seed-s3/` copied with
`rsync --ignore-existing` and without its `com/tiffinbox/` (324 MB). Every `_remote.repositories` marker says `central` (1,900 marker
lines, 0 naming a local repository). Maven downloaded nothing. Each setup build prints `built <tree> · offline: yes` (or `no - …`)
on the terminal; the captured builds are offline-only (`-o`, no fallback: a build that needed the network would stop the run).

## Commands

What `receipts.sh` reads from this section (`readme()`: the first line of this file that matches; the script dies if one is
missing), with the variable they use:

```
M2="$PWD/.m2-demo"
mvn -o -B -f after/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package
docker build --progress=plain -t tiffinbox-docker:1.0.0 after
docker run -d --name tiffinbox-docker-run -m 512m -v "$PWD/.harness/tree/secrets:/app/secrets:ro" -p 127.0.0.1:18871:18425 tiffinbox-docker:1.0.0
docker build --progress=plain -f docker/context.Dockerfile -t tiffinbox-docker:context .harness/ctx-dev
docker run --rm --entrypoint ls tiffinbox-docker:context -A /tiffinbox-ctx
docker build --progress=rawjson -t tiffinbox-docker:dev .harness/ctx-dev
docker buildx du --filter 'description~=tiffinbox-ctx' --verbose
docker buildx prune -f --filter 'description~=tiffinbox-ctx'
docker volume create tiffinbox-docker-secrets > /dev/null && docker run --rm --name tiffinbox-docker-fill --user 0 --entrypoint sh -v tiffinbox-docker-secrets:/s -v "$PWD/.harness/tree/secrets:/src:ro" eclipse-temurin:25-jre -c 'cp -R /src/. /s && chown -R "$1" /s && chmod 700 /s /s/tiffinbox && chmod 600 /s/tiffinbox/shutdown-token && stat -c "%u:%g %A" /s /s/tiffinbox /s/tiffinbox/shutdown-token' - "$(id -u):$(id -g)"
docker run -d --name tiffinbox-docker-owner -m 512m --user "$(id -u):$(id -g)" -v tiffinbox-docker-secrets:/app/secrets:ro -p 127.0.0.1:18873:18425 tiffinbox-docker:1.0.0
docker run --rm --entrypoint id eclipse-temurin:25-jre
docker run --rm --entrypoint rm tiffinbox-docker:1.0.0 /app/application.jar
docker run --rm --entrypoint sh tiffinbox-docker:1.0.0 -c 'for g in $(id -G); do [ "$g" = "$(id -g)" ] || find / -xdev -group "$g" ! -type l -exec stat -c "%A %U:%G %n" {} + 2> /dev/null; done'
docker run --rm --entrypoint head tiffinbox-docker:1.0.0 -c 1 /var/log/apt/term.log
perl -pe 's/^USER ubuntu$/RUN groupadd --system tiffinbox && useradd --system --gid tiffinbox --no-create-home --shell \/usr\/sbin\/nologin tiffinbox\nUSER tiffinbox/' after/Dockerfile > .harness/user.Dockerfile
docker build --progress=plain -f .harness/user.Dockerfile -t tiffinbox-docker:user after
docker run --rm -m 512m --entrypoint java tiffinbox-docker:1.0.0 -XshowSettings:system -XX:+PrintFlagsFinal -version
sed 's/^ENTRYPOINT \["java", "-jar", "application.jar"\]$/ENTRYPOINT java -jar application.jar/' after/Dockerfile > .harness/shell.Dockerfile
docker build --progress=plain -f .harness/shell.Dockerfile -t tiffinbox-docker:shell after
docker run -d --name tiffinbox-docker-signals -m 512m -e LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_CONTEXT_ANNOTATION=trace -v "$PWD/.harness/tree/secrets:/app/secrets:ro" -p 127.0.0.1:18872:18425 tiffinbox-docker:1.0.0 --tiffinbox.days=10
docker stop tiffinbox-docker-signals
```

- **The image takes two steps** (brief ⚑5: Maven stays on the host, with the offline `.m2-demo`). `package` from the root builds both
  modules in one reactor, so `tiffinbox-core` lands in the `application` layer (the layers lesson's index); then `docker build` with
  `after/` as the context — the folder holds the jar Maven just built, and the Dockerfile copies it from `tiffinbox-web/target/`.
- **`docker/context.Dockerfile` is not TiffinBox's** (`FROM eclipse-temurin:25-jre`, `COPY . /ctx`): it shows what a build context
  holds. `.harness/ctx-dev/` is a developer's copy of the anchor — `after/` as built, with the two files the anchor's README tells a
  developer to keep beside it and never commit: the config tree `secrets/tiffinbox/shutdown-token` (made the anchor README's way,
  with the demo token) and `tiffinbox-local.yaml` (`tiffinbox.cooks: 4`).
- **Every variant is a README command with one thing changed**, and `receipts.sh` asserts each derivation: our image's `id` (the image
  swapped) · `id ubuntu` on the base image (an argument added) · `rm` as root (`--user root` added) · memory B (`-m 512m` removed) ·
  the quiet build (`--progress=plain` → `-q`) · signals B (the image `tiffinbox-docker:shell`) · C's stop (`-t 2` added) · owner B
  (`--user "$(id -u):$(id -g)"` removed) · the own user's `id` and `head` (the image `tiffinbox-docker:user`).
- **`docker buildx du` and `docker buildx prune`** name the folder-copying Dockerfile's `COPY` target, `/tiffinbox-ctx` — this
  script's alone (a filter's value may not start with a slash: containerd reads `/…/` as a regular expression, and the prune fails).
  `context` counts the records with `du`; the exit trap runs the `prune` line, and `receipts.sh` asserts it is this one.
- **`owner`** copies the config tree into a Docker volume, `tiffinbox-docker-secrets`, with the base image as root (the `fill` line),
  then runs our image on it — as your own user (`--user`), then as the image's own (`ubuntu`).
- **The user of its own** is `after/Dockerfile` with `USER ubuntu` replaced by two lines, by the `perl` line above (three lines differ,
  asserted).
- **The shell form** is `after/Dockerfile` with its `ENTRYPOINT` line rewritten by the `sed` line above (one line differs, asserted).

## The anchor change

Two new files at the anchor's root, and nothing else (README aside) — `change` shows both whole:
- `Dockerfile` — 26 lines, 11 of them comments. Stage one, `FROM eclipse-temurin:25-jre AS builder`: the jar Maven built is copied in
  and Boot's extract tool splits it into its four layers, inside the build. Stage two, `FROM eclipse-temurin:25-jre`: `/app`, the four
  layer folders, one `COPY` each, then `ENV TIFFINBOX_ADDRESS=0.0.0.0` (the buildpack lesson's key: in a container `127.0.0.1` is the
  container's own), `USER ubuntu` (uid 1000, already in the base image, which runs as root) and `ENTRYPOINT ["java", "-jar",
  "application.jar"]`, the exec form. No JVM memory flag is baked in.
- `.dockerignore` — `secrets/` and `tiffinbox-local.yaml`, with a two-line comment.
- `README.md` (the anchor's) — a new section, *Course 5 · unit 16 — a Dockerfile of its own*.

**The jar is unchanged**, byte for byte (`92452ee1f9a22920d8aa7e2655f2bdc0`, 16,134,264 bytes): the Java sources, the POMs and
`application.yaml` are identical (`change`: 18 of 18). **Against the layers lesson's recipe** (`../c5-unit14/docker/Dockerfile`, the
two-stage shape of Boot's reference documentation): 11 instruction lines there, 13 here, 10 the same — the jar's `COPY` reads
`tiffinbox-web/target/…` because the context is now the whole project folder, and `ENV TIFFINBOX_ADDRESS=0.0.0.0` and `USER ubuntu`
are new. The exec-form `ENTRYPOINT` was already the recipe's. **Not `TiffinBoxApp`**, so RED S2 #8 stays deferred.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token (the secrets lesson). Every run that serves mounts `.harness/tree/secrets`, a
config tree — `secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`) — holding a 26-character demo token that is
fake and looks it; `receipts.sh` writes it when it runs (`.harness/` is git-ignored). The token never reaches a command line: the
seven requests read it from the file (`$CURLSET PORT TOKENFILE`), and **in a container it comes from that folder, mounted read-only
at `/app/secrets`** — the image's working folder is `/app`, and `application.yaml` imports `optional:configtree:./secrets/`. Every
capture is masked — the token becomes `[masked: the 26-character token]` (`gsub`) — and `receipts.sh` counts the raw token in each
run's own output **before** masking (`.harness/raw-*`: 0 in all 27 capture runs), then in every capture, this README, the anchor
README, the two new files, the exercise, its solution, `docker/context.Dockerfile` and `receipts.md5`: 0; and in `after/`, the
anchor's build context as the image's build sends it: 0 files hold it.

**The images.** Every image this script keeps until its end — `tiffinbox-docker:1.0.0` (as the exercise rebuilt it),
`tiffinbox-docker:shell`, `tiffinbox-docker:dev` and `tiffinbox-docker:user` — is saved (`docker save`), and every layer is unpacked and
searched, with each image's config: 0 copies. **The one exception is deliberate:** `context`'s A and A′ build `tiffinbox-docker:context` from a folder that
holds the token, with a Dockerfile that copies the whole folder — the capture counts **1 copy** in its layers (never printing it). A's
image is removed when B's build takes the tag back, and A′'s the moment the capture ends (`left: 0`). A and A′ are two of the three
builds whose context holds `secrets/` without `.dockerignore` (brief S3.13), on purpose, with the fake token; C's first build is the
third, and its image holds 0 copies. **Removing the image leaves its layer in BuildKit's build cache** (RED #45): after A′'s image
is gone, `docker buildx du` still lists the records of its `COPY` step — 2, A's and A′'s one (A′ reuses it) and B's (`context`, last
lines). `docker/context.Dockerfile` copies to `/tiffinbox-ctx`, a name no other Dockerfile here uses, so **the exit trap removes them with
a prune filtered to that name** (`docker buildx prune -f --filter 'description~=tiffinbox-ctx'`) — never an unfiltered prune. Measured
by hand, 2026-10-05 (BLUE part B, a privileged probe that only read the Docker VM's disk): the fake token's file sat in the `COPY`
step's snapshot (`…/fs/tiffinbox-ctx/secrets/tiffinbox/shutdown-token`), and the filtered prune removed it; the context's own record
("local source for context") held it only until a build with the ignore file, or with TiffinBox's Dockerfile, synced the folder again
— which `context` B and C do. **The prune's side effect, measured:** it removes only the records it names (1 of 1,568 in one probe), but
afterwards BuildKit matches no earlier record — the next build of `after/` re-ran all 8 of its steps (0 `CACHED`), and so did a build
on `postgres:18-alpine`; the one after that was cached again. Nobody's records are deleted, but every builder on this Docker pays one
uncached build — which is why the prune runs once, at the exit, and never inside a capture (`context` compares C's layers with the
image's: a prune between the two runs made 3 of 11 layers differ). Records left by runs before this fix, `COPY . /ctx`, are not this
script's to tell apart from another builder's, and stay (5 snapshots on this Docker hold the fake token). The builder counts the token
again in the script, the deck and the prompter: 0.

## The folders, the variables, the ports and the Docker names

- `after/` — the frozen tree, built clean in place (`package`). `.harness/before/` — `../c5-unit15/after`, built clean once.
  `.harness/tree/` — the config tree. `.harness/ctx-dev/` — a developer's copy (above), rebuilt for every run of `context`.
  `.harness/shell.Dockerfile` — the shell form.
- On screen: `$M2` = this unit's `.m2-demo`; `$PWD` = the shell's current folder, this unit's; `$CURLSET` = `../c5-unit11/curlset.sh`,
  the comparison set since the secrets lesson (the seven requests, POST /shutdown with the token's header read from a file) — its
  folder carries a unit number, so no slide prints the path.
- **Ports** (brief ⚑10, 18870-18879, checked free with `lsof` before anything is wiped, with 18425): `run` 18871, `signals` 18872 and
  `owner` 18873 — the only three bound; each is the Mac's side of a published port (`-p 127.0.0.1:<port>:18425`). Inside a container TiffinBox listens
  on 18425, which binds nothing on the Mac.
- **Docker names** (no unit number, §R.4 and ⚑11): images `tiffinbox-docker:1.0.0` (the anchor's), `:shell` (B), `:context` (the
  folder-copying Dockerfile), `:dev` (C) and `:user` (a user of its own); containers `tiffinbox-docker-run`, `-signals`, `-owner` and
  `-fill`; the volume `tiffinbox-docker-secrets`; the build-cache records whose description names `tiffinbox-ctx`. **Removed by the exit
  trap** — after a pass, a failure or Ctrl-C: those names, any image the exercise's rebuild left without a tag (by its recorded ID), and
  the records (the filtered prune). A rebuilt tag is removed before its build, so no other image is left untagged. **`tiffinbox-docker:1.0.0`
  is the anchor README's name too:** `receipts.sh` refuses to start while an image of that name exists, and removes it only after
  that check found none (RED #44). A container or image that was there before the run is never touched; an unfiltered `docker …
  prune` is never run (a third-party container and its images live on this Docker, and other people's build cache with them).

## Masks, filters and hygiene — every one, declared

1. **Paths and the token:** in every line of every capture (`gsub()`, the patterns escaped as literals): the demo token →
   `[masked: the 26-character token]`; this folder's absolute path → `…`, also URL-encoded; the folder above it → `…/..`; the home
   folder → `~`. A last check fails if any capture still holds `/Users/`, `/private/` or `/home/`.
2. **IDs:** a line that is a 64-hex container ID (what `docker run -d` prints) → `[a container ID]`; an image ID (`sha256:` and 64 hex,
   what `docker build -q` prints) → `[an image ID]`. No image ID, container ID or RootFS layer digest is printed: layers are compared
   position by position and the comparison printed.
3. **Spring's Closing line:** the context's identity hash → `AnnotationConfigApplicationContext@<hash>`, and its start date →
   `started on <date>`.
4. **This Docker's memory:** the heap Java takes with no limit → `[masked: the heap Java took on this Docker]`, and `docker info`'s
   `MemTotal` → `[masked: this Docker's memory, in bytes]` (both read off the same run); the share is printed to one decimal.
5. **BuildKit's logs** are kept in `.harness/` and read, never printed whole: a plain log gives the steps it names (`[stage n/m]
   instruction`, each once, sorted by stage and step, the base image's digest dropped), the warnings its **end-of-build summary** counts
   (`N warning(s) found`, then one ` - RULE: message` line per warning, printed whole, the colour codes stripped) and its layer downloads
   (counted); a `rawjson` log gives the bytes of one record, the vertex `[internal] load build context` — the build context it was sent.
   The summary, not the inline `#n WARN: …` line: RED's probe of the shell-form build found the inline line in 9 of 12 builds and the
   summary in 12 of 12 (RED #41, this capture's one failure in two of RED's three runs).
6. **Java's settings** (`-XshowSettings:system -XX:+PrintFlagsFinal -version`): three lines kept — `Memory Limit:` (standard error),
   `MaxHeapSize` and `MaxRAMPercentage` (standard output) — the spaces squeezed; every other line counted (528 of 531). The CPU count
   it also prints is this Mac's and is among the lines not shown.
7. **Container logs** are read with `docker logs`; a log line is printed from its message on (the time, level, PID, thread and logger
   columns dropped); for the Closing and destroy lines, the thread column alone is printed too. The listening line's address is
   printed without its scheme (`the address in that line: 0.0.0.0:18425`), the line itself kept in `run`: `check_unit5.py` reads a
   printed `http://0.0.0.0…` as a demo URL that is not loopback.
8. **Process 1's arguments** (`/proc/1/cmdline`, NUL-separated) are printed one quoted string each; `ls -A /ctx` is printed on one
   line, the names joined with spaces.
9. **Durations:** `docker stop`'s seconds move from run to run, so the capture holds them against the wait `docker stop` was given —
   `under 10 s` · `10 s or more` · with `-t 2`, `2 s or more, under 10 s` — and the seconds go to the terminal only (*Timing*, below).
   The old bands (under 1 s, 10-11 s, 2-3 s) drifted once on a loaded Mac: an exec-form stop took 1.34 s (RED #42).
10. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS`, `MAVEN_ARGS`, and the variables that change what Docker's builds do (`DOCKER_BUILDKIT`, `BUILDKIT_*`, `BUILDX_*`,
   `DOCKER_DEFAULT_PLATFORM`, `SOURCE_DATE_EPOCH`) before it runs anything (`DOCKER_HOST` and `DOCKER_CONTEXT` stay); it refuses to run
   twice at once in this folder (`.r-lock`), with a `secrets/` in this folder, with a `secrets/` or `tiffinbox-local.yaml` in `after/`
   (the anchor's build context), while an image named `tiffinbox-docker:1.0.0` exists, or as uid 1000 (ubuntu's: `owner` B would read
   the volume as its owner); it removes its own Docker names, its volume and its cache records before it starts. Every TiffinBox container runs with
   `-m 512m`, and so does Java in `memory` A — B, the one run without a limit, is masked.

**Interrupted.** `receipts.sh`'s exit trap stops a JVM it started in the background, if one still runs (none does in this unit: every
TiffinBox runs in a container, so `$pid` stays empty — the branch is the shape every receipt here shares); removes its four container
names, its four image names of its own and — only once the start-up check found none of the anchor README's name — `tiffinbox-docker:1.0.0`;
any image it recorded as left without a tag; its volume `tiffinbox-docker-secrets`; the build-cache records named `tiffinbox-ctx` (the
filtered prune); `.harness/saved/`; and drops the lock — on a failed check and on Ctrl-C alike. Every command in the trap is guarded,
so `set -e` cannot end it early.
**Tested 2026-10-05, three times by the unit's first BLUE**, and **once more by BLUE part B** after the changes above. Each time
`receipts.sh` ran in the foreground of a driver shell that leads its own process group (`perl -e '$SIG{INT} = "DEFAULT"; setpgrp(0, 0);
exec @ARGV' bash driver.sh`; the driver catches SIGINT and carries on, so `receipts.sh` starts with SIGINT at its default, as from a
terminal), and a watcher sent SIGINT to the whole group: (1) the moment `context`'s leak image existed; (2) while `run`'s container
published 18871; (3) during signals B, its `docker stop` waiting out Docker's ten seconds; (4, part B) the moment `owner`'s container
ran on the volume — 1 container, `tiffinbox-docker:1.0.0` and `:dev`, the volume, 2 cache records named `tiffinbox-ctx`.
`receipts.sh` exited **130** each time, and 5 s later: 0 containers named `tiffinbox-docker-*`, 0 images `tiffinbox-docker:*`, 0 images
without a tag, 0 volumes but the third party's, 0 cache records named `tiffinbox-ctx`, 0 listeners on 18425 and 18870-18899, 0
processes with this unit's path in their command line, `.r-lock` gone — and the third-party container still running.

## 1 · Change — two new files; the jar, byte for byte

`.r-change.out` `de2787df92371e0346d44617a768e62e` — 42 lines

```
files, README aside: the previous tree 18 · after/ 20 · in both 18: identical 18, changed 0
  only before: (none)
  only after:  .dockerignore Dockerfile
  README.md, the anchor's: lines added 42 · removed 0
after/Dockerfile, whole - 26 lines, 11 of them comments, 2 blank:
  1  # TiffinBox's image. Maven builds the jar on your machine first; this file only packs it:
  2  #   mvn -B package
  3  #   docker build -t tiffinbox-docker:1.0.0 .
  4  # Two stages: Boot's reference documentation's recipe, on the official Temurin 25 runtime image.
  5  
  6  # Stage one: the jar goes in, and Boot's extract tool splits it into its four layers, inside the build.
  7  FROM eclipse-temurin:25-jre AS builder
  8  WORKDIR /builder
  9  COPY tiffinbox-web/target/tiffinbox-web-1.0.0.jar application.jar
 10  RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted
 11  
 12  # Stage two: the image that runs. One COPY per layer, the layer that changes least first.
 13  FROM eclipse-temurin:25-jre
 14  WORKDIR /app
 15  COPY --from=builder /builder/extracted/dependencies/ ./
 16  COPY --from=builder /builder/extracted/spring-boot-loader/ ./
 17  COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
 18  COPY --from=builder /builder/extracted/application/ ./
 19  # In a container, 127.0.0.1 is the container's own address: listen on every address the container has, and publish
 20  # the port on the host's 127.0.0.1 alone (docker run -p 127.0.0.1:<port>:18425).
 21  ENV TIFFINBOX_ADDRESS=0.0.0.0
 22  # The base image runs as root. The user ubuntu (uid 1000) is already in it.
 23  USER ubuntu
 24  # Exec form - a JSON list, no shell: java is process 1, so docker stop's SIGTERM reaches it, and arguments after the
 25  # image name reach TiffinBox. The shell form (ENTRYPOINT java -jar application.jar) loses both.
 26  ENTRYPOINT ["java", "-jar", "application.jar"]
after/.dockerignore, whole - 4 lines, 2 of them comments, 0 blank:
  1  # Never sent to the builder, whatever a Dockerfile copies: the two files this project never commits (.gitignore),
  2  # which the README puts beside it - the config tree that holds the shutdown token, and a developer's own settings.
  3  secrets/
  4  tiffinbox-local.yaml
the layers lesson's two-stage Dockerfile against this one, instruction lines (comments and blank lines dropped): 11 and 13 · in both 10
  < COPY tiffinbox-web-1.0.0.jar application.jar
  > COPY tiffinbox-web/target/tiffinbox-web-1.0.0.jar application.jar
  > ENV TIFFINBOX_ADDRESS=0.0.0.0
  > USER ubuntu
the two trees' jars, each built clean: the same bytes: yes · md5 92452ee1f9a22920d8aa7e2655f2bdc0 · 16134264 bytes
```

The Dockerfile's 26 lines and the ignore file's 4, whole, as the anchor now holds them. Then the layers lesson's Dockerfile against
this one, comments and blank lines dropped: one `COPY` path changed (`<` there, `>` here) and two lines new. The two trees' jars,
each built clean from its own tree, are the same bytes.

## 2 · Build — README's two commands, and the image's own records

`.r-build.out` `6e2303606374e00f3d2ed72e81a0b602` — 31 lines

```
$ mvn -o -B -f after/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · offline: yes (-o) · BUILD SUCCESS lines: 1
  after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar: md5 92452ee1f9a22920d8aa7e2655f2bdc0 · 16134264 bytes
$ docker build --progress=plain -t tiffinbox-docker:1.0.0 after
  exit 0 · warnings in BuildKit's summary: 0 · layer downloads: 0 · the steps its log names, each once, by stage:
  [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre
  [builder 2/4] WORKDIR /builder
  [builder 3/4] COPY tiffinbox-web/target/tiffinbox-web-1.0.0.jar application.jar
  [builder 4/4] RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted
  [stage-1 2/6] WORKDIR /app
  [stage-1 3/6] COPY --from=builder /builder/extracted/dependencies/ ./
  [stage-1 4/6] COPY --from=builder /builder/extracted/spring-boot-loader/ ./
  [stage-1 5/6] COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
  [stage-1 6/6] COPY --from=builder /builder/extracted/application/ ./
$ docker image inspect tiffinbox-docker:1.0.0
  User ubuntu · WorkingDir /app · Entrypoint ["java", "-jar", "application.jar"] · Cmd null
  Env: 7 variables · the TIFFINBOX_ ones: TIFFINBOX_ADDRESS=0.0.0.0
  RootFS layers: 11
  the first ones, eclipse-temurin:25-jre's own, unchanged: yes, 6 of 6
$ docker history --human=false --no-trunc --format '{{.Size}} {{.CreatedBy}}' tiffinbox-docker:1.0.0
  steps: 36 · the newest 8, the second stage's (size in bytes, then the step):
    0         ENTRYPOINT ["java" "-jar" "application.jar"]
    0         USER ubuntu
    0         ENV TIFFINBOX_ADDRESS=0.0.0.0
    28672     COPY /builder/extracted/application/ ./ # buildkit
    0         COPY /builder/extracted/snapshot-dependencies/ ./ # buildkit
    0         COPY /builder/extracted/spring-boot-loader/ ./ # buildkit
    15966208  COPY /builder/extracted/dependencies/ ./ # buildkit
    0         WORKDIR /app
  the step under them: ENTRYPOINT ["/__cacert_entrypoint.sh"] - the base image's own
  stage one's steps in the history (WORKDIR /builder, its COPY of the jar, its extract RUN): 0
```

BuildKit's log names nine steps: stage one's four (`builder`) and stage two's from 2 to 6 — its `FROM` is the same image as stage
one's, so the log names that step once, as `[builder 1/4]`. `ENV`, `USER` and `ENTRYPOINT` are settings, not steps of the log.
`docker history` lists stage two's eight lines, newest first, with their sizes: the four `COPY` layers (two of them empty here:
the loader folder, because `extract` ran without `--launcher`; snapshot-dependencies, because TiffinBox has no `-SNAPSHOT`
dependency — the layers lesson measured both: with `--launcher` the loader layer holds 402,297 bytes, snapshot-dependencies 0; RED #47),
and `ENV`, `USER` and `ENTRYPOINT` at 0 bytes.
The step under them is the base image's own `ENTRYPOINT`, which ours replaces. None of stage one's three steps is in the image's
history, and its RootFS starts with the base image's six layers, unchanged: stage one built the layers and stayed behind.

## 3 · Context — what a folder carries, and what the ignore file keeps out (A/B/A′, with C)

`.r-context.out` `f30cd240efab9f68b67017e8f865b5ee` — 44 lines

```
the context, .harness/ctx-dev: after/ as built, plus a developer's two never-committed files beside its README - secrets/tiffinbox/shutdown-token (-rw-------) and tiffinbox-local.yaml
A   no .dockerignore: docker/context.Dockerfile copies the whole folder
$ rm -f .harness/ctx-dev/.dockerignore
  exit 0
$ docker build --progress=plain -f docker/context.Dockerfile -t tiffinbox-docker:context .harness/ctx-dev
  exit 0 · warnings in BuildKit's summary: 0
$ docker run --rm --entrypoint ls tiffinbox-docker:context -A /tiffinbox-ctx
  exit 0 · /tiffinbox-ctx holds: .gitignore Dockerfile README.md pom.xml secrets tiffinbox-core tiffinbox-local.yaml tiffinbox-web
  the token, raw, in the image: 1 in its 7 layers, every one unpacked · 0 in its config
B   the anchor's .dockerignore, copied in
$ cp after/.dockerignore .harness/ctx-dev/
  exit 0
$ docker build --progress=plain -f docker/context.Dockerfile -t tiffinbox-docker:context .harness/ctx-dev
  exit 0 · warnings in BuildKit's summary: 0
$ docker run --rm --entrypoint ls tiffinbox-docker:context -A /tiffinbox-ctx
  exit 0 · /tiffinbox-ctx holds: .dockerignore .gitignore Dockerfile README.md pom.xml tiffinbox-core tiffinbox-web
  the token, raw, in the image: 0 in its 7 layers, every one unpacked · 0 in its config
A′  A re-run
$ rm -f .harness/ctx-dev/.dockerignore
  exit 0
$ docker build --progress=plain -f docker/context.Dockerfile -t tiffinbox-docker:context .harness/ctx-dev
  exit 0 · warnings in BuildKit's summary: 0
$ docker run --rm --entrypoint ls tiffinbox-docker:context -A /tiffinbox-ctx
  exit 0 · /tiffinbox-ctx holds: .gitignore Dockerfile README.md pom.xml secrets tiffinbox-core tiffinbox-local.yaml tiffinbox-web
  the token, raw, in the image: 1 in its 7 layers, every one unpacked · 0 in its config
C   the anchor's own Dockerfile, on the same folder: without the ignore file, then with it - each build after touch (every file's time set to now); then once more, nothing touched
$ find .harness/ctx-dev -exec touch {} +
  exit 0
$ docker build --progress=rawjson -t tiffinbox-docker:dev .harness/ctx-dev
  exit 0 · the build context sent, in bytes (its progress record, [internal] load build context): 16138352
  the token, raw, in the image: 0 in its 11 layers, every one unpacked · 0 in its config
  its RootFS layers against tiffinbox-docker:1.0.0's, built from after/ (no secrets/ there): 11 and 11 · the same 11 · different 0
$ cp after/.dockerignore .harness/ctx-dev/ && find .harness/ctx-dev -exec touch {} +
  exit 0
$ docker build --progress=rawjson -t tiffinbox-docker:dev .harness/ctx-dev
  exit 0 · the build context sent, in bytes: 16138352
  the same bytes, with the ignore file and without it: yes · the jar alone: 16134264 bytes
$ docker build --progress=rawjson -t tiffinbox-docker:dev .harness/ctx-dev
  exit 0 · the same build again, nothing touched - the build context sent, in bytes: 141
  layer downloads in the six builds' logs: 0
the image that holds the token (A′'s), removed at once: tiffinbox-docker:context left: 0
BuildKit's build cache, after the image is gone: the records of the step COPY . /tiffinbox-ctx (A's and A′'s one, B's one) - the exit trap prunes them
$ docker buildx du --filter 'description~=tiffinbox-ctx' --verbose
  exit 0 · records: 2 · each one's description: [2/2] COPY . /tiffinbox-ctx
```

**A** — a Dockerfile that copies the whole folder, and no `.dockerignore`: `/tiffinbox-ctx` holds `secrets` and `tiffinbox-local.yaml`, and the
token is in the image — 1 copy, in one of its 7 layers, found by unpacking the saved image. **B** — the anchor's `.dockerignore`
copied into the folder: neither name arrives (the ignore file itself does), 0 copies. **A′** = A, line for line. **C** — the anchor's
own Dockerfile on the same folder, without the ignore file and then with it: BuildKit's progress record counts 16138352 bytes sent both
times — the jar is 16,134,264 of them; BuildKit reads only the paths a Dockerfile copies. C's image holds 0 copies and has the same 11
RootFS layers as the image built from `after/`, which holds no `secrets/`. **Why every file is touched first:** BuildKit re-sends a
folder it has seen only where files changed — the third build, nothing touched, is sent 141 bytes. So `.dockerignore` makes no
difference to TiffinBox's own Dockerfile today; it keeps the two files out of whatever a future Dockerfile copies (`COPY .`, the
first line of many Dockerfiles), and the voice says exactly that. **The image gone, its layer stays:** the last lines count the `COPY`
step's records in BuildKit's cache after A′'s image is removed — 2 (A′ reused A's; B made its own); the exit trap prunes them, filtered
to `tiffinbox-ctx` (*The demo token*). A, B and A′'s builds each report 0 warnings in BuildKit's summary.

## 4 · Run — the image the README's way

`.r-run.out` `9140ba29f0721bdcd462183aaf41bd68` — 12 lines

```
$ docker run -d --name tiffinbox-docker-run -m 512m -v "$PWD/.harness/tree/secrets:/app/secrets:ro" -p 127.0.0.1:18871:18425 tiffinbox-docker:1.0.0
  the log: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 with PID 1 (/app/application.jar started by ubuntu in /app)
  the log: TiffinBox listening on http://0.0.0.0:18425
  the address in that line: 0.0.0.0:18425 · WARN lines 0 · ERROR lines 0
$ $CURLSET 18871 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ docker wait tiffinbox-docker-run
  0
$ docker rm tiffinbox-docker-run
  listeners on 18871 now: 0
the config tree mounted: secrets/tiffinbox/shutdown-token, -rw-------, this script's user's - the container's user is ubuntu
```

`-m 512m`, the config tree mounted read-only at `/app/secrets` (the image works in `/app`), the port published on the Mac's
`127.0.0.1` alone. No `-e TIFFINBOX_ADDRESS`: the image's own `ENV` sets it, and TiffinBox listens on `0.0.0.0:18425` — every address
the container has. Boot's starting line says `with PID 1` and `started by ubuntu in /app`. The seven responses hash to
`115c36bac276128e245ca57df11c2891`, the comparison set's (the brief asked for this re-measure: the probe served `/kitchen` from such
an image but never hashed the seven). The container exits 0 after POST /shutdown. The token file is `0600` and belongs to this
script's user on the Mac; user 1000 in the container read it through **OrbStack's file sharing** — on Linux file semantics it could
not: *5 · Owner*.

## 5 · Owner — whose files ubuntu can read (A/B/A′)

`.r-owner.out` `80ef3c40402b68d82581a77f12c4b7ad` — 35 lines

```
the token's config tree, copied into a Docker volume - storage the daemon keeps itself: its files keep their owner and
  mode, as on Linux, with no file sharing in between (the base image copies them, as root):
$ docker volume create tiffinbox-docker-secrets > /dev/null && docker run --rm --name tiffinbox-docker-fill --user 0 --entrypoint sh -v tiffinbox-docker-secrets:/s -v "$PWD/.harness/tree/secrets:/src:ro" eclipse-temurin:25-jre -c 'cp -R /src/. /s && chown -R "$1" /s && chmod 700 /s /s/tiffinbox && chmod 600 /s/tiffinbox/shutdown-token && stat -c "%u:%g %A" /s /s/tiffinbox /s/tiffinbox/shutdown-token' - "$(id -u):$(id -g)"
  exit 0 · entries 3: owned by this script's user and group 3 of 3 · their modes: drwx------ drwx------ -rw-------
A   the volume, run as your own user, the tree's owner: --user "$(id -u):$(id -g)"
$ docker run -d --name tiffinbox-docker-owner -m 512m --user "$(id -u):$(id -g)" -v tiffinbox-docker-secrets:/app/secrets:ro -p 127.0.0.1:18873:18425 tiffinbox-docker:1.0.0
  the address in the listening line: 0.0.0.0:18425
$ $CURLSET 18873 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ docker wait tiffinbox-docker-owner
  0
$ docker rm tiffinbox-docker-owner
  listeners on 18873 now: 0
B   the volume, run as the image's own user, ubuntu (uid 1000) - no --user
$ docker run -d --name tiffinbox-docker-owner -m 512m -v tiffinbox-docker-secrets:/app/secrets:ro -p 127.0.0.1:18873:18425 tiffinbox-docker:1.0.0
$ docker wait tiffinbox-docker-owner
  1
  its log: lines that say TiffinBox listening: 0 · the exception and its cause:
  java.lang.IllegalStateException: Unable to find files in '/app/./secrets'
  Caused by: java.nio.file.AccessDeniedException: /app/./secrets
$ docker rm tiffinbox-docker-owner
  listeners on 18873 now: 0
A′  A re-run
$ docker run -d --name tiffinbox-docker-owner -m 512m --user "$(id -u):$(id -g)" -v tiffinbox-docker-secrets:/app/secrets:ro -p 127.0.0.1:18873:18425 tiffinbox-docker:1.0.0
  the address in the listening line: 0.0.0.0:18425
$ $CURLSET 18873 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ docker wait tiffinbox-docker-owner
  0
$ docker rm tiffinbox-docker-owner
  listeners on 18873 now: 0
$ docker volume rm tiffinbox-docker-secrets > /dev/null
  exit 0
```

The config tree copied into a Docker volume — storage the daemon keeps itself, where files keep their owner and mode, as on Linux —
by the base image, as root: 3 entries, all this script's user's, `drwx------ drwx------ -rw-------` (the volume, not the Mac's folder:
OrbStack's file sharing is what let `ubuntu` read the folder in *4 · Run*). **A**, run as your own user (`--user "$(id -u):$(id -g)"`,
the tree's owner): TiffinBox listens on `0.0.0.0:18425` and serves the seven, `115c36bac276128e245ca57df11c2891`, exit 0. **B**, the image's
own user, `ubuntu` (uid 1000), no `--user`: TiffinBox stops before it listens — `java.lang.IllegalStateException: Unable to find files in
'/app/./secrets'`, caused by `java.nio.file.AccessDeniedException: /app/./secrets` — exit 1 (RED #46 measured the same denial with `cat`).
**A′** = A. **The fix, stated in the anchor's README:** run the container as the token tree's owner, `--user "$(id -u):$(id -g)"` in the
`docker run` line. As that user Boot's starting line says `started by ?` (measured by hand: the uid has no name in the image), so the capture prints the
listening address, not that line. A user whose uid is 1000 owns such a tree as `ubuntu` does — `receipts.sh` refuses to run as uid 1000.

## 6 · User — not root

`.r-user.out` `dba0d53bcd0c4ee47329a3310278e6d2` — 35 lines

```
$ docker run --rm --entrypoint id eclipse-temurin:25-jre
  exit 0 · uid=0(root) gid=0(root) groups=0(root)
$ docker run --rm --entrypoint id eclipse-temurin:25-jre ubuntu
  exit 0 · uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu),4(adm),20(dialout),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev)
$ docker run --rm --entrypoint id tiffinbox-docker:1.0.0
  exit 0 · uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu),4(adm),20(dialout),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev)
A   the image's own user
$ docker run --rm --entrypoint rm tiffinbox-docker:1.0.0 /app/application.jar
  exit 1 · rm: cannot remove '/app/application.jar': Permission denied
B   the same image, --user root
$ docker run --rm --user root --entrypoint rm tiffinbox-docker:1.0.0 /app/application.jar
  exit 0 · 
A′  A re-run
$ docker run --rm --entrypoint rm tiffinbox-docker:1.0.0 /app/application.jar
  exit 1 · rm: cannot remove '/app/application.jar': Permission denied
$ docker run --rm --entrypoint sh tiffinbox-docker:1.0.0 -c 'command -v sudo'
  exit 127 · lines printed: 0
$ docker run --rm --entrypoint sh tiffinbox-docker:1.0.0 -c 'for g in $(id -G); do [ "$g" = "$(id -g)" ] || find / -xdev -group "$g" ! -type l -exec stat -c "%A %U:%G %n" {} + 2> /dev/null; done'
  exit 1 - find's, as ubuntu: folders it may not read · files owned by one of ubuntu's other groups: 1
  -rw-r----- root:adm /var/log/apt/term.log
$ docker run --rm --entrypoint head tiffinbox-docker:1.0.0 -c 1 /var/log/apt/term.log
  exit 0 · bytes read: 1
C   a user of its own instead of ubuntu: the USER line replaced by two
$ perl -pe 's/^USER ubuntu$/RUN groupadd --system tiffinbox && useradd --system --gid tiffinbox --no-create-home --shell \/usr\/sbin\/nologin tiffinbox\nUSER tiffinbox/' after/Dockerfile > .harness/user.Dockerfile
  exit 0 · .harness/user.Dockerfile against after/Dockerfile, lines that differ: 3
  < USER ubuntu
  > RUN groupadd --system tiffinbox && useradd --system --gid tiffinbox --no-create-home --shell /usr/sbin/nologin tiffinbox
  > USER tiffinbox
$ docker build --progress=plain -f .harness/user.Dockerfile -t tiffinbox-docker:user after
  exit 0 · warnings in BuildKit's summary: 0 · RootFS layers: 12, tiffinbox-docker:1.0.0's 11
  its history's new step (size in bytes, then the step): 1 · 32768 RUN /bin/sh -c groupadd --system tiffinbox && useradd --system --gid tiffinbox --no-create-home --shell /usr/sbin/nologin tiffinbox
$ docker run --rm --entrypoint id tiffinbox-docker:user
  exit 0 · uid=999(tiffinbox) gid=999(tiffinbox) groups=999(tiffinbox)
$ docker run --rm --entrypoint head tiffinbox-docker:user -c 1 /var/log/apt/term.log
  exit 1 · head: cannot open '/var/log/apt/term.log' for reading: Permission denied
```

The base image runs as root (`uid=0`); its `ubuntu` user already exists (uid 1000), and our image runs as it — `USER ubuntu`. **A**:
as `ubuntu`, deleting the app's own jar fails, `Permission denied` (exit 1). **B**: the same image with `--user root` deletes it (exit
0, in that container's own writable layer; the image is unchanged). **A′** = A. `ubuntu` belongs to Ubuntu's default groups, `sudo`
and `adm` among them; the image has no `sudo` command (`command -v sudo`: exit 127, nothing printed). (`touch` was the first idea;
on a file you cannot write it fails with `setting times of …`, which says less.) **The groups' reach** (RED #48): of `ubuntu`'s 9
other groups, only `adm` owns a file in the image — `/var/log/apt/term.log`, `-rw-r----- root:adm` — and `ubuntu` reads it (`head -c 1`:
1 byte); `find` exits 1 because, as `ubuntu`, it may not read every folder. **C, a user of its own** — `USER ubuntu` replaced by
`RUN groupadd --system tiffinbox && useradd --system --gid tiffinbox --no-create-home --shell /usr/sbin/nologin tiffinbox` and
`USER tiffinbox`: one more layer (RootFS 12 against 11), 32,768 bytes in the history, `uid=999(tiffinbox)` in its own group alone, and
`term.log` → `Permission denied`. ⚑5's choice stands — `ubuntu` reads one log and owns nothing of the app — and RED B advised keeping it.

## 7 · Memory — the limit Java reads

`.r-memory.out` `95d5cd62148c46b68b55f490f86e7a35` — 21 lines

```
A   -m 512m: a limit of half a gigabyte
$ docker run --rm -m 512m --entrypoint java tiffinbox-docker:1.0.0 -XshowSettings:system -XX:+PrintFlagsFinal -version
  exit 0 · lines 531 · kept 3 · not shown 528
  Memory Limit: 512.00M
  size_t MaxHeapSize = 134217728 {product} {ergonomic}
  double MaxRAMPercentage = 25.000000 {product} {default}
B   no -m: no limit
$ docker run --rm --entrypoint java tiffinbox-docker:1.0.0 -XshowSettings:system -XX:+PrintFlagsFinal -version
  exit 0 · lines 531 · kept 3 · not shown 528
  Memory Limit: Unlimited
  size_t MaxHeapSize = [masked: the heap Java took on this Docker] {product} {ergonomic}
  double MaxRAMPercentage = 25.000000 {product} {default}
$ docker info -f '{{.MemTotal}}'
  [masked: this Docker's memory, in bytes]
  B's MaxHeapSize, as a share of that memory: 25.0%
A′  A re-run
$ docker run --rm -m 512m --entrypoint java tiffinbox-docker:1.0.0 -XshowSettings:system -XX:+PrintFlagsFinal -version
  exit 0 · lines 531 · kept 3 · not shown 528
  Memory Limit: 512.00M
  size_t MaxHeapSize = 134217728 {product} {ergonomic}
  double MaxRAMPercentage = 25.000000 {product} {default}
```

Java run in our image (`--entrypoint java`, not TiffinBox), its settings printed. **A**, `-m 512m`: Java reads the limit
(`Memory Limit: 512.00M`) and lets its heap grow to a quarter of it — `MaxHeapSize = 134217728`, 128 MiB, by its default
`MaxRAMPercentage = 25`. **B**, no limit: `Memory Limit: Unlimited`, and the heap is a quarter of the memory Docker's Linux machine
has (OrbStack's VM here: masked, it depends on the machine). **A′** = A. Nothing runs before Java in this image — the entrypoint
is `java` itself (`signals`) — so no memory calculator decides, as the buildpack lesson's did: `MaxRAMPercentage` is Java's own
default, `{default}`.

## 8 · Signals — the break (A/B/A′, with C)

`.r-signals.out` `e3d088e362018883c2df6d273d016b9a` — 71 lines

```
A   the anchor's image: the exec form
$ docker image inspect -f '{{json .Config.Entrypoint}}' tiffinbox-docker:1.0.0
  ["java","-jar","application.jar"]
$ docker run -d --name tiffinbox-docker-signals -m 512m -e LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_CONTEXT_ANNOTATION=trace -v "$PWD/.harness/tree/secrets:/app/secrets:ro" -p 127.0.0.1:18872:18425 tiffinbox-docker:1.0.0 --tiffinbox.days=10
  the address in the listening line: 0.0.0.0:18425
$ docker exec tiffinbox-docker-signals cat /proc/1/comm
  java
$ docker exec tiffinbox-docker-signals cat /proc/1/cmdline
  its arguments, each one quoted: 'java' '-jar' 'application.jar' '--tiffinbox.days=10'
$ curl -sS http://127.0.0.1:18872/kitchen
  {"ordersCooked":40,"ordersValue":8100}
$ docker stop tiffinbox-docker-signals
  the container's exit code: 143 · docker stop returned in: under 10 s
  the log: lines that say Closing: 1 · lines that say Invoking destroy method on bean 'tiffinBoxServer': 1 · WARN lines 0 · ERROR lines 0
  the thread both were logged on: [ionShutdownHook] · [ionShutdownHook]
  Closing org.springframework.context.annotation.AnnotationConfigApplicationContext@<hash>, started on <date>
  Invoking destroy method on bean 'tiffinBoxServer': synchronized void com.tiffinbox.web.TiffinBoxServer.stop()
$ docker rm tiffinbox-docker-signals
  listeners on 18872 now: 0
B   one line changed: the shell form
$ sed 's/^ENTRYPOINT \["java", "-jar", "application.jar"\]$/ENTRYPOINT java -jar application.jar/' after/Dockerfile > .harness/shell.Dockerfile
  exit 0 · .harness/shell.Dockerfile against after/Dockerfile, lines that differ: 2
  < ENTRYPOINT ["java", "-jar", "application.jar"]
  > ENTRYPOINT java -jar application.jar
$ docker build --progress=plain -f .harness/shell.Dockerfile -t tiffinbox-docker:shell after
  exit 0 · warnings in BuildKit's summary, at the end of its log: 1
   - JSONArgsRecommended: JSON arguments recommended for ENTRYPOINT to prevent unintended behavior related to OS signals (line 26)
$ docker build -q -f .harness/shell.Dockerfile -t tiffinbox-docker:shell after
  exit 0 · lines it printed: 1 · warnings in BuildKit's summary: 0
  [an image ID]
$ docker image inspect -f '{{json .Config.Entrypoint}}' tiffinbox-docker:shell
  ["/bin/sh","-c","java -jar application.jar"]
$ docker run -d --name tiffinbox-docker-signals -m 512m -e LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_CONTEXT_ANNOTATION=trace -v "$PWD/.harness/tree/secrets:/app/secrets:ro" -p 127.0.0.1:18872:18425 tiffinbox-docker:shell --tiffinbox.days=10
  the address in the listening line: 0.0.0.0:18425
$ docker exec tiffinbox-docker-signals cat /proc/1/comm
  sh
$ docker exec tiffinbox-docker-signals cat /proc/1/cmdline
  its arguments, each one quoted: '/bin/sh' '-c' 'java -jar application.jar' '--tiffinbox.days=10'
$ curl -sS http://127.0.0.1:18872/kitchen
  {"ordersCooked":120,"ordersValue":24300}
$ docker stop tiffinbox-docker-signals
  the container's exit code: 137 · docker stop returned in: 10 s or more
  the log: lines that say Closing: 0 · lines that say Invoking destroy method on bean 'tiffinBoxServer': 0 · WARN lines 0 · ERROR lines 0
$ docker rm tiffinbox-docker-signals
  listeners on 18872 now: 0
C   B again, stopped with docker stop -t 2
$ docker run -d --name tiffinbox-docker-signals -m 512m -e LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_CONTEXT_ANNOTATION=trace -v "$PWD/.harness/tree/secrets:/app/secrets:ro" -p 127.0.0.1:18872:18425 tiffinbox-docker:shell --tiffinbox.days=10
$ docker stop -t 2 tiffinbox-docker-signals
  the container's exit code: 137 · docker stop returned in: 2 s or more, under 10 s
  the log: lines that say Closing: 0 · lines that say Invoking destroy method on bean 'tiffinBoxServer': 0 · WARN lines 0 · ERROR lines 0
$ docker rm tiffinbox-docker-signals
  listeners on 18872 now: 0
A′  A re-run
$ docker image inspect -f '{{json .Config.Entrypoint}}' tiffinbox-docker:1.0.0
  ["java","-jar","application.jar"]
$ docker run -d --name tiffinbox-docker-signals -m 512m -e LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_CONTEXT_ANNOTATION=trace -v "$PWD/.harness/tree/secrets:/app/secrets:ro" -p 127.0.0.1:18872:18425 tiffinbox-docker:1.0.0 --tiffinbox.days=10
  the address in the listening line: 0.0.0.0:18425
$ docker exec tiffinbox-docker-signals cat /proc/1/comm
  java
$ docker exec tiffinbox-docker-signals cat /proc/1/cmdline
  its arguments, each one quoted: 'java' '-jar' 'application.jar' '--tiffinbox.days=10'
$ curl -sS http://127.0.0.1:18872/kitchen
  {"ordersCooked":40,"ordersValue":8100}
$ docker stop tiffinbox-docker-signals
  the container's exit code: 143 · docker stop returned in: under 10 s
  the log: lines that say Closing: 1 · lines that say Invoking destroy method on bean 'tiffinBoxServer': 1 · WARN lines 0 · ERROR lines 0
  the thread both were logged on: [ionShutdownHook] · [ionShutdownHook]
  Closing org.springframework.context.annotation.AnnotationConfigApplicationContext@<hash>, started on <date>
  Invoking destroy method on bean 'tiffinBoxServer': synchronized void com.tiffinbox.web.TiffinBoxServer.stop()
$ docker rm tiffinbox-docker-signals
  listeners on 18872 now: 0
```

No POST /shutdown in this capture: every container is stopped by `docker stop`, which sends SIGTERM to process 1. **A**, the exec form:
process 1 is `java`, the argument after the image name is Java's last argument and arrives (10 days, 40 orders); `docker stop` returns
almost at once — under 10 s, Docker's wait, in the capture; 0.12-0.16 s on the terminal — exit 143 (128 + 15, SIGTERM); the log shows the context closing and TiffinBox's `@PreDestroy` method, both on the
shutdown hook's thread (`[ionShutdownHook]`, the column's last 15 characters). TRACE on `org.springframework.context.annotation` is what
prints the destroy method (`CommonAnnotationBeanPostProcessor`); DEBUG would print `Closing …` alone. **B**, the shell form: one line
changed; the plain build's end-of-build summary counts 1 warning (`- JSONArgsRecommended: …`, line 26 — the `ENTRYPOINT`), `-q` prints
the image's ID and no warning;
Docker stores the entrypoint as `["/bin/sh","-c","java -jar application.jar"]`; process 1 is `sh`, and our argument is its fourth
argument, after the command string — POSIX `sh` makes such a word `$0`, the command's name — so Java never gets it (120 orders, the
default 30 days); `docker stop`: SIGTERM reaches the shell, nothing happens, Docker waits its ten seconds and kills the container:
exit 137 (128 + 9, SIGKILL), no `Closing`, no destroy method, and no WARN or ERROR line — nothing looks broken. **C**: B stopped with
`docker stop -t 2` — the same kill, after 2 s or more, under 10: the wait is Docker's setting, not TiffinBox's. **A′** = A, line for line
(its `docker run` line, shown on the slide too).

## 9 · Exercise — half a gigabyte, and three quarters of it

`.r-exercise.out` `22233bc49313555829db97b8b90eed5b` — 20 lines

```
exercise/README.md's commands, read from the file and run as written, in order (its two export lines aside):
$ mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
  exit 0
$ docker build -q -t tiffinbox-docker:1.0.0 after
  exit 0
  [an image ID]
$ docker run --rm -m 512m --entrypoint java tiffinbox-docker:1.0.0 -XX:+PrintFlagsFinal -version | grep -w MaxHeapSize
  exit 0
     size_t MaxHeapSize                              = 134217728                                 {product} {ergonomic}
  stderr: openjdk version "25.0.4.1" 2026-08-18 LTS
  stderr: OpenJDK Runtime Environment Temurin-25.0.4.1+1 (build 25.0.4.1+1-LTS)
  stderr: OpenJDK 64-Bit Server VM Temurin-25.0.4.1+1 (build 25.0.4.1+1-LTS, mixed mode, sharing)
the measured answer's commands, exercise/solution/SOLUTION.md, run as written:
$ docker run --rm -m 512m -e JAVA_TOOL_OPTIONS=-XX:MaxRAMPercentage=75 --entrypoint java tiffinbox-docker:1.0.0 -XX:+PrintFlagsFinal -version | grep -w MaxHeapSize
  exit 0
     size_t MaxHeapSize                              = 402653184                                 {product} {ergonomic}
  stderr: Picked up JAVA_TOOL_OPTIONS: -XX:MaxRAMPercentage=75
  stderr: openjdk version "25.0.4.1" 2026-08-18 LTS
  stderr: OpenJDK Runtime Environment Temurin-25.0.4.1+1 (build 25.0.4.1+1-LTS)
  stderr: OpenJDK 64-Bit Server VM Temurin-25.0.4.1+1 (build 25.0.4.1+1-LTS, mixed mode, sharing)
```

`exercise/README.md`'s commands (its first bash block, the two `export` lines aside) and then `exercise/solution/SOLUTION.md`'s, read
from the files and run as written. The lesson's run prints `MaxHeapSize = 134217728`; with `-e JAVA_TOOL_OPTIONS=-XX:MaxRAMPercentage=75`
Java says `Picked up JAVA_TOOL_OPTIONS: -XX:MaxRAMPercentage=75` and prints `402653184` — 384 MiB, three quarters of 512 MiB. (The
exercise's `docker build -q` replaces the image under `tiffinbox-docker:1.0.0`; the image left without a tag is removed by its
recorded ID, silently — a step of the harness, not of the exercise.)

## Timing — on the terminal only

`docker stop`, BLUE part B's two runs of record (2026-10-05, `./receipts.sh` and `bash receipts.sh`, the three runs of `signals` in
each; three earlier full runs the same evening were the warm-up, A up to 0.24 s), on this Mac (Apple M1 8-core, 16 GB, OrbStack, load
average about 4): **A** 0.12-0.13 s and **A′** 0.12-0.15 s (exit 143) · **B** 10.18-10.20 s (exit 137) · **C** 2.16-2.20 s (`-t 2`, exit
137). RED measured one A at 1.34 s, load average 7.19 on 8 cores. The capture holds each
against the wait `docker stop` was given: under 10 s · 10 s or more · 2 s or more, under 10 s. The ten seconds are `docker stop`'s
default wait, not TiffinBox's (C).

## What the builds downloaded

**Maven:** nothing (every build `offline: yes`). **Docker:** no pull, and 0 layer downloads in every BuildKit log this unit reads;
`eclipse-temurin:25-jre` was on this Mac before this unit. No JDK image was needed.

## Found on the way

- **Here, BuildKit read only the paths the Dockerfile copies.** The probe's "without `.dockerignore`, the token is sent to the daemon" holds
  for a Dockerfile that copies the folder (A) — not for TiffinBox's own, which is sent the same 16138352 bytes with or without the ignore
  file (C). The ignore file still ships: it is what keeps the token out of the next Dockerfile's `COPY .`.
- **An image built from a developer's folder with TiffinBox's Dockerfile has the same 11 RootFS layers as the one built from
  `after/`** (C) — nothing of the folder got in.
- **The recipe's `ENTRYPOINT` was already the exec form**: TiffinBox's file adds two lines to it, not three.
- **`ubuntu` is in `sudo`, `adm` and Ubuntu's other default groups**; the image has no `sudo`; of the 9, only `adm` owns a file here,
  one log `ubuntu` can read. The brief's loser 2, a dedicated user, measured (`user` C): one more layer, 32,768 bytes, and that log out
  of reach. ⚑5's choice stands, as RED B advised.
- **BuildKit's inline `WARN:` line is not printed in every plain build**; its end-of-build summary is (RED #41).
- **A filtered `docker buildx prune` resets BuildKit's cache matching** for every build on the daemon, though it deletes only what it
  names (*The demo token*).
- **A filter value may not start with `/`** (`description~=/tiffinbox-ctx`: "quoted literal not terminated") — the name is filtered
  without its slash.
- **BuildKit's log names the shared `FROM` once**, as stage one's step — stage two's list starts at 2/6.
- **The base image's own `ENTRYPOINT`** (`/__cacert_entrypoint.sh`) is replaced by ours; the history's step under ours shows it.
- **A context BuildKit has seen is re-sent only where files changed** (141 bytes, nothing touched) — the reason C touches every file.
- **`command -v` in the image's `sh` exits 127** for a missing command.

## For the next unit — 17 — and for RED

**Start from `c5-unit16/after/`** (copy it with `rsync -a --exclude target`, or build it in place:
`mvn -o -B -f ../c5-unit16/after/pom.xml -Dmaven.repo.local=<your .m2-demo> -DskipTests clean package`):
- **New:** `Dockerfile` and `.dockerignore` at the root (above). The image: `mvn package` from the root, then `docker build -t <name>
  <the root>`; it runs as `ubuntu` (uid 1000) from `/app`, sets `TIFFINBOX_ADDRESS=0.0.0.0`, and starts in the exec form. Run it with
  `-m`, the config tree mounted read-only at `/app/secrets`, and `-p 127.0.0.1:<port>:18425`; POST /shutdown → exit 0; `docker stop` →
  143 almost at once (0.1-0.2 s here; the capture holds it as under Docker's 10 s), with TiffinBox's `@PreDestroy` run. `tiffinbox-docker:*` are this unit's names, removed at the end of
  every run (`:1.0.0` is the anchor README's too: `receipts.sh` refuses to start while one exists) — use your own (⚑11: the Compose project `tiffinbox-dev`). A Compose service built from this Dockerfile inherits all of it.
- **`.dockerignore` lists `secrets/` and `tiffinbox-local.yaml` only.** `compose.yaml` and any `application-dev.yaml` will be in the
  build context, harmless while the Dockerfile copies the jar alone (and ⚑6's compose file holds no secret). A Compose `.env` file,
  if one appears, belongs in both `.gitignore` and `.dockerignore`.
- **Unchanged:** the jar is byte-reproducible (`92452ee1f9a22920d8aa7e2655f2bdc0`, 16,134,264 bytes, on this Mac); the record
  `TiffinBoxProperties(jdbcUrl, cooks, days, port, address, mealTypes, shutdownToken)`; the listening line `TiffinBox listening on
  http://<address>:<port>`; the token from a config tree (`secrets/tiffinbox/shutdown-token`, umask 077, the token and a newline) or
  `TIFFINBOX_SHUTDOWN_TOKEN`; a harness class path from `java -Djarmode=tools -jar <jar> extract --destination <a new folder>`; the
  seven: `../c5-unit11/curlset.sh PORT TOKENFILE` → `115c36bac276128e245ca57df11c2891` — measured here from the Dockerfile image.
- **Docker here:** OrbStack, context `orbstack`, server 29.4.0, the containerd image store (compare RootFS layers, never image IDs);
  `eclipse-temurin:25-jre` and `postgres:18-alpine` are on this Mac. This unit's leak layer leaves BuildKit's cache at every exit (the
  filtered prune) — and that prune makes the next build of anything here uncached, once.
- **RED:** the 0600 token read by uid 1000 is OrbStack's file sharing — on Linux file semantics, measured (`owner`): denied, exit 1;
  `ubuntu`'s groups (⚑5 vs its loser 2, both measured); the leak is shown with a
  folder-copying Dockerfile, and the anchor's own measured not to need the ignore file — the voice is scoped to that; the bytes come from
  BuildKit's `rawjson` progress record (Docker 29.4.0's format); the bands' thresholds (1 s, 3 s, 11 s) sit 0.81 s or more above the slowest
  stop of the run of record; process 1's `$0` rule is POSIX's, attributed on a chip, not driven.

## Exercise

`exercise/README.md` — build the lesson's image, read Java's heap limit with half a gigabyte (`MaxHeapSize = 134217728`), then give
Java three quarters of the same limit at run time. Done when the line says `MaxHeapSize = 402653184` and Java says it picked the option
up. Run exactly as written in a clean shell (`env -i`): `exercise/solution/SOLUTION.md`.
