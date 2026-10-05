#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · A Dockerfile You Control — this unit's receipts. The buildpack decided everything last time; here TiffinBox gets a
# Dockerfile of its own (the anchor change: Dockerfile and .dockerignore at the anchor's root): two stages, the official Temurin
# 25 runtime image, the address every container needs, a user that is not root, an exec-form entrypoint. This script builds it
# the README's way (Maven on the Mac, offline; docker build packs the jar), shows what a build context can carry and what the
# ignore file keeps out, runs the image with the config tree mounted read-only, asks it which user it is and how much heap Java
# took, and stops it - in the exec form and in the shell form, which is the break. Nine captures, each run three times and
# hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check
# that can fail; the demo token is masked (gsub), and the last checks count 0 raw copies in every capture, every README, the
# anchor's build context, and every layer of every image this script keeps - and exactly 1 in the image built to show the leak.
#   change   the previous tree against after/, file by file: two new files, shown whole; the layers lesson's Dockerfile against
#            this one, instruction by instruction; both trees' jars, the same bytes
#   build    README.md's two commands: the jar (Maven, offline), then the image; the steps BuildKit ran (its log, filtered) and
#            the warnings its end-of-build summary counts; the image's own records (docker image inspect); its history - the
#            second stage's steps, with their sizes
#   context  a developer's copy of the anchor - the token's config tree and tiffinbox-local.yaml beside the README - sent to a
#            Dockerfile that copies the whole folder: A no .dockerignore · B the anchor's .dockerignore · A' = A; each image's
#            /tiffinbox-ctx listed and every layer searched for the token (counted, never printed). C: the anchor's own Dockerfile
#            on the same folder, without and with the ignore file - the bytes BuildKit sent, from its own progress record. Then
#            the leak image removed, and BuildKit's cache records of its COPY step: still there, until a prune filtered to them
#   run      README.md's run: the tree mounted read-only at /app/secrets, the port published on 127.0.0.1 only, -m 512m; Boot's
#            first line and the listening line; the seven responses; the container's exit
#   owner    whose files ubuntu can read: the token's tree copied into a Docker volume, where files keep their owner and mode,
#            as on Linux: A run as your own user (--user) · B as the image's own user, ubuntu · A' = A
#   user     the base image's user, its ubuntu, and ours (id); the app's jar, deleted: A as ubuntu · B --user root · A' = A;
#            sudo, looked for; the files ubuntu's other groups own; C a user of its own instead of ubuntu - its cost in the
#            image's history, and the log ubuntu could read
#   memory   Java in our image, its settings printed: A -m 512m · B no limit · A' = A
#   signals  the break: A the exec form · B the shell form (one line changed; the warning BuildKit's summary counts, with and
#            without -q) · C B stopped with docker stop -t 2 · A' = A; each: process 1, its command line, an argument, docker
#            stop, the log
#   exercise exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit15/after (the anchor as the last unit to change it left it), COPIED to .harness/before; this script
# never writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change, built in
# place, clean. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the
# secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file).
# Masks and filters (README.md declares each; gsub only): the demo token becomes "[masked: the 26-character token]"; this
# folder's absolute path "…", the folder above it "…/..", the home folder "~"; a 64-hex container ID that docker run -d prints
# "[a container ID]"; an image ID that docker build -q prints "[an image ID]"; the context's identity hash and start date in
# Spring's Closing line "@<hash>" and "<date>"; the heap Java takes with no limit, and the memory docker info reports, each a
# label - in every line of every capture. BuildKit's logs are kept in .harness/ and read, never printed whole: the steps it
# ran, the warnings its end-of-build summary counts (the summary, not the inline WARN line, which BuildKit prints in some runs
# and not others) and its layer downloads are taken from them. A container's log line is printed from its message on (the
# time, level, PID, thread and logger columns dropped) - the thread column alone is printed for the Closing line. Java's
# settings are filtered to three lines, the others counted. No image ID, layer digest or container ID is printed: layers are
# compared, and the comparison printed. Durations move from run to run, so no capture holds one: docker stop's time is
# printed against the wait docker stop was given (under 10 s · 10 s or more; with -t 2: 2 s or more, under 10 s), the
# seconds on the terminal only.
# Ports (brief ⚑10, 18870-18879): run 18871 · signals 18872 · owner 18873 - the only three bound. 18425 is checked free too
# (the old default port). Containers listen on 18425 inside, which binds nothing on the Mac; every -p publishes on 127.0.0.1.
# Docker names (no unit number): images tiffinbox-docker:1.0.0 (the anchor's), :shell (B), :context (the folder-copying
# Dockerfile), :dev (C), :user (a user of its own); containers tiffinbox-docker-run, -signals, -owner and -fill; the volume
# tiffinbox-docker-secrets; BuildKit's cache records whose description names /tiffinbox-ctx (the folder-copying Dockerfile's
# COPY target, this script's alone). The exit trap removes exactly those - the records with a prune filtered to them - and any
# image this run left without a tag (by its recorded ID). tiffinbox-docker:1.0.0 is also the name the anchor README builds:
# this script refuses to start while an image of that name exists, and removes it only after that check. Never an unfiltered
# prune: a third-party container and its images live on this Docker, and other people's build cache with them.
set -e
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMAGE=tiffinbox-docker:1.0.0                         # the anchor README's name too: never removed unless this run made it
TAGS="tiffinbox-docker:shell tiffinbox-docker:context tiffinbox-docker:dev tiffinbox-docker:user"
BOXES="tiffinbox-docker-run tiffinbox-docker-signals tiffinbox-docker-owner tiffinbox-docker-fill"
VOL=tiffinbox-docker-secrets                         # this script's own volume: the token's tree, as Linux keeps files
LEAK=tiffinbox-ctx                                   # docker/context.Dockerfile's COPY target, /tiffinbox-ctx: it names that step's
                                                     # cache records (a filter's value may not start with a slash: containerd reads /…/ as a regex)
pid=""; OLDIDS=""; SNAP=""
# sweep: this script's own Docker names, its volume, the images it recorded as left without a tag, and BuildKit's cache
# records whose description names $LEAK (a prune filtered to them, never an unfiltered one) - and tiffinbox-docker:1.0.0
# only once the start-up check found no image of that name (SNAP). Every command is guarded: a name already gone makes docker
# exit 1, and nothing here may end the clean-up early.
sweep() { docker rm -f $BOXES > /dev/null 2>&1 || true; docker image rm -f $TAGS $OLDIDS > /dev/null 2>&1 || true
  docker volume rm -f "$VOL" > /dev/null 2>&1 || true
  docker buildx prune -f --filter "description~=$LEAK" > /dev/null 2>&1 || true
  [ -n "$SNAP" ] || return 0; docker image rm -f "$IMAGE" > /dev/null 2>&1 || true; }
# On every exit - the end, a failed check, or Ctrl-C - stop a JVM this script started in the background, if one still runs
# (no TiffinBox runs on the Mac in this unit - every one runs in a container - so $pid stays empty; the branch is the shape
# every receipt here shares, and it costs nothing); remove this script's containers, images, volume and cache records
# (sweep); drop the lock. The
# clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still
# exits 130 after an interrupt (tested: README.md, "Interrupted").
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; rm -rf .harness/saved 2> /dev/null || true; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_* and SPRING_*
# variable, the two variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS, and the variables that change what docker build
# does or prints (DOCKER_BUILDKIT, BUILDKIT_*, BUILDX_*, DOCKER_DEFAULT_PLATFORM, SOURCE_DATE_EPOCH) are removed first.
# DOCKER_HOST and DOCKER_CONTEXT stay: they say which Docker to reach.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\|DOCKER_BUILDKIT\|BUILDKIT_[A-Za-z0-9_]*\|BUILDX_[A-Za-z0-9_]*\|DOCKER_DEFAULT_PLATFORM\|SOURCE_DATE_EPOCH\)=.*/\1/p'); do unset "$v"; done
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -e after/secrets ] || [ -e after/tiffinbox-local.yaml ] && die "after/ holds a secrets/ or a tiffinbox-local.yaml - it is the anchor's frozen copy, and the build context of the image; remove them"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server that every capture stops. It is written
# into files under .harness/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
RECIPE=../c5-unit14/docker/Dockerfile                # the layers lesson's two-stage Dockerfile (Boot's documented recipe)
BASE=eclipse-temurin:25-jre                          # both stages start FROM it - the official image, already on this Mac
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$RECIPE" ] || die "$RECIPE is missing"
[ -f after/Dockerfile ] && [ -f after/.dockerignore ] && [ -f docker/context.Dockerfile ] || die "after/Dockerfile, after/.dockerignore or docker/context.Dockerfile is missing"
grep -qx "COPY \. /$LEAK" docker/context.Dockerfile || die "docker/context.Dockerfile must copy the folder to /$LEAK: the trap's prune is filtered to that name"
# owner's B reads a tree this script's user owns, as uid 1000 (ubuntu): with your own uid 1000 the image's user would own it
[ "$(id -u)" != 1000 ] || die "your user is uid 1000, the image's ubuntu: owner's B would read the volume as its owner - run as another user"

# Docker: asked first; started only if it does not answer (OrbStack's own command, when there is one); then polled - this Mac
# has no timeout command - for 60 s at most.
if ! docker info > /dev/null 2>&1; then
  command -v orb > /dev/null 2>&1 && { orb start > /dev/null 2>&1 || true; }
  i=0; until docker info > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 60 ] || die "Docker does not answer after 60 s - start it (OrbStack: orb start; Docker Desktop: open it), then run again"; sleep 1; done; fi
docker image inspect "$BASE" > /dev/null 2>&1 || die "$BASE is not on this machine - pull it once (docker pull $BASE: network, a build-time resolution), then run again"
docker buildx version > /dev/null 2>&1 || die "docker buildx is needed: this script removes its own build-cache records with it"
# tiffinbox-docker:1.0.0 is the anchor README's name too: an image of that name now may be yours - never touched; the message
# names the way out. Only after this check is it this script's to remove (SNAP).
docker image inspect "$IMAGE" > /dev/null 2>&1 && die "an image named $IMAGE exists - the anchor README builds that name too, so it may be yours, and this script removes only what it creates; remove it yourself (docker image rm $IMAGE), then run again"
SNAP=1
# This script's own names, left by an interrupted run: removed before anything else - with the cache records its prune filter names.
docker rm -f $BOXES > /dev/null 2>&1 || true; docker image rm -f $TAGS > /dev/null 2>&1 || true; docker volume rm -f "$VOL" > /dev/null 2>&1 || true
docker buildx prune -f --filter "description~=$LEAK" > /dev/null 2>&1 || true

# The ports, BEFORE .harness/ is wiped. This script's containers were removed just above; anything still listening is not
# this run's - the message names the process.
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18870 18871 18872 18873 18874 18875 18876 18877 18878 18879; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- build: the previous tree once, and after/ once - each clean, offline - before any capture ---------------------------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target ../c5-unit15/after/ .harness/before/
# build DIR LOG: a clean build, offline first, its log kept in LOG (never printed whole); Maven Central only if the offline
# build could not resolve something - and the terminal says which (offline: yes / no), so a run that went online is never
# silent.
build() { local how=yes ec=0
  mvn -o -B -f "$1/pom.xml" -Dmaven.repo.local="$M2" -DskipTests clean package > "$2" 2>&1 || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    mvn -B -f "$1/pom.xml" -Dmaven.repo.local="$M2" -DskipTests clean package > "$2" 2>&1 || ec=$?; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $1"; }
  echo "  built $1 · offline: $how · exit $ec"; }
build .harness/before .harness/build-before.log
build after .harness/build-after.log

# ---- the folders the runs start in -----------------------------------------------------------------------------------------
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
tree .harness/tree

# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines)
raw() { local t=$1; shift; cat "$@" | grep -oF -- "$t" | wc -l | tr -d ' '; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }
# runf 'COMMAND': print it exactly as typed, run it in the foreground (eval, in a subshell, from this folder), its standard
# output to .harness/run.out and its standard error to .harness/run.err; its exit code in $ec
runf() { echo "\$ $1"; ec=0; (eval "$1") > .harness/run.out 2> .harness/run.err < /dev/null || ec=$?; }
# msg LOG PATTERN: the first log line matching PATTERN, from its message on (the time, level, PID, thread and logger columns
# dropped)
msg() { grep -m1 -- "$2" "$1" | sed -E 's/^.* : //' || true; }
# thread LOG PATTERN: the thread column of the first log line matching PATTERN, brackets kept (Boot's pattern cuts a long
# thread name to its last 15 characters)
thread() { grep -m1 -- "$2" "$1" | sed -E 's/^[^[]* --- (\[[^]]*\]) .*$/\1/' || true; }

# mask: the demo token becomes a label naming its length; this folder's path "…", the folder above it "…/..", the home folder
# "~"; a line that is a 64-hex container ID (docker run -d prints one) "[a container ID]"; an image ID (docker build -q prints
# one) "[an image ID]"; the identity hash and the start date in Spring's Closing line; the heap Java takes with no limit, and
# the memory docker info reports (both read off this run: $HEAPX, $MEMX) - in every line (gsub)
HEAPX=""; MEMX=""
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v hx="$HEAPX" -v mx="$MEMX" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)) }
  { gsub(T, "[masked: the 26-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    if ($0 ~ /^ *[0-9a-f]{64}$/) gsub(/[0-9a-f]{64}/, "[a container ID]")
    gsub(/sha256:[0-9a-f]{64}/, "[an image ID]")
    gsub(/AnnotationConfigApplicationContext@[0-9a-f]+/, "AnnotationConfigApplicationContext@<hash>")
    gsub(/started on [A-Z][a-z][a-z] [A-Z][a-z][a-z] [ 0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] [A-Z]+ [0-9][0-9][0-9][0-9]/, "started on <date>")
    if (hx != "") gsub("MaxHeapSize = " hx " ", "MaxHeapSize = [masked: the heap Java took on this Docker] ")
    if (mx != "") gsub("^  " mx "$", "  [masked: this Docker'\''s memory, in bytes]")
    print }'; }

# boxes: this script's own containers that exist right now
boxes() { docker ps -a --format '{{.Names}}' | grep -cxE 'tiffinbox-docker-(run|signals|owner|fill)' || true; }
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a JVM running"
    [ "$(boxes)" = 0 ] || die "$nm left a container"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot, Maven, Docker or base image, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# readme PATTERN [FILE]: the first line of FILE (README.md) that matches PATTERN - so a label never claims what the README says
readme() { grep -m1 -E "$1" "${2:-README.md}" || true; }
# The commands, read from README.md's "Commands" section and asserted - receipts.sh runs them as the file gives them.
C_PACKAGE=$(readme '^mvn -o -B -f after/pom\.xml -Dmaven\.repo\.local="\$M2" -DskipTests clean package$')
C_BUILD=$(readme '^docker build --progress=plain -t tiffinbox-docker:1\.0\.0 after$')
C_RUN=$(readme '^docker run -d --name tiffinbox-docker-run -m 512m -v "\$PWD/\.harness/tree/secrets:/app/secrets:ro" -p 127\.0\.0\.1:18871:18425 tiffinbox-docker:1\.0\.0$')
C_PEEK=$(readme '^docker build --progress=plain -f docker/context\.Dockerfile -t tiffinbox-docker:context \.harness/ctx-dev$')
C_LS=$(readme '^docker run --rm --entrypoint ls tiffinbox-docker:context -A /tiffinbox-ctx$')
C_DU=$(readme "^docker buildx du --filter 'description~=tiffinbox-ctx' --verbose\$")
C_PRUNE=$(readme "^docker buildx prune -f --filter 'description~=tiffinbox-ctx'\$")
C_OURS=$(readme '^docker build --progress=rawjson -t tiffinbox-docker:dev \.harness/ctx-dev$')
C_ID0=$(readme '^docker run --rm --entrypoint id eclipse-temurin:25-jre$')
C_RM=$(readme '^docker run --rm --entrypoint rm tiffinbox-docker:1\.0\.0 /app/application\.jar$')
C_MEM=$(readme '^docker run --rm -m 512m --entrypoint java tiffinbox-docker:1\.0\.0 -XshowSettings:system -XX:\+PrintFlagsFinal -version$')
C_SHELLDF=$(grep -m1 -xF -- "sed 's/^ENTRYPOINT \\[\"java\", \"-jar\", \"application.jar\"\\]\$/ENTRYPOINT java -jar application.jar/' after/Dockerfile > .harness/shell.Dockerfile" README.md || true)
C_SHELLB=$(readme '^docker build --progress=plain -f \.harness/shell\.Dockerfile -t tiffinbox-docker:shell after$')
C_SIG=$(readme '^docker run -d --name tiffinbox-docker-signals -m 512m -e LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_CONTEXT_ANNOTATION=trace -v "\$PWD/\.harness/tree/secrets:/app/secrets:ro" -p 127\.0\.0\.1:18872:18425 tiffinbox-docker:1\.0\.0 --tiffinbox\.days=10$')
C_STOP=$(readme '^docker stop tiffinbox-docker-signals$')
C_FILL=$(readme '^docker volume create tiffinbox-docker-secrets > /dev/null && docker run --rm --name tiffinbox-docker-fill --user 0 --entrypoint sh -v tiffinbox-docker-secrets:/s -v "\$PWD/\.harness/tree/secrets:/src:ro" eclipse-temurin:25-jre -c .* - "\$\(id -u\):\$\(id -g\)"$')
C_OWN=$(readme '^docker run -d --name tiffinbox-docker-owner -m 512m --user "\$\(id -u\):\$\(id -g\)" -v tiffinbox-docker-secrets:/app/secrets:ro -p 127\.0\.0\.1:18873:18425 tiffinbox-docker:1\.0\.0$')
C_GROUPS=$(grep -m1 -xF -- "docker run --rm --entrypoint sh tiffinbox-docker:1.0.0 -c 'for g in \$(id -G); do [ \"\$g\" = \"\$(id -g)\" ] || find / -xdev -group \"\$g\" ! -type l -exec stat -c \"%A %U:%G %n\" {} + 2> /dev/null; done'" README.md || true)
C_LOG=$(readme '^docker run --rm --entrypoint head tiffinbox-docker:1\.0\.0 -c 1 /var/log/apt/term\.log$')
C_USERDF=$(grep -m1 -xF -- "perl -pe 's/^USER ubuntu\$/RUN groupadd --system tiffinbox && useradd --system --gid tiffinbox --no-create-home --shell \\/usr\\/sbin\\/nologin tiffinbox\\nUSER tiffinbox/' after/Dockerfile > .harness/user.Dockerfile" README.md || true)
C_USERB=$(readme '^docker build --progress=plain -f \.harness/user\.Dockerfile -t tiffinbox-docker:user after$')
for c in "$C_PACKAGE" "$C_BUILD" "$C_RUN" "$C_PEEK" "$C_LS" "$C_DU" "$C_PRUNE" "$C_OURS" "$C_ID0" "$C_RM" "$C_MEM" "$C_SHELLDF" "$C_SHELLB" "$C_SIG" "$C_STOP" "$C_FILL" "$C_OWN" "$C_GROUPS" "$C_LOG" "$C_USERDF" "$C_USERB"; do
  [ -n "$c" ] || die "README.md no longer gives the twenty-one commands this script runs (Commands)"; done
[ "$C_DU" = "docker buildx du --filter 'description~=$LEAK' --verbose" ] && [ "$C_PRUNE" = "docker buildx prune -f --filter 'description~=$LEAK'" ] || die "the README's du and prune must filter to $LEAK, as the exit trap's prune does"
# The variants: each is a README command with one thing changed, and each derivation is asserted
one() { [ "$(printf '%s\n' "$1" | tr ' ' '\n' | grep -c .)" = "$(( $(printf '%s\n' "$2" | tr ' ' '\n' | grep -c .) + $3 ))" ] && [ "$1" != "$2" ] || die "$4 must be its README command with one thing changed"; }
C_ID1=$(printf '%s\n' "$C_ID0" | sed 's/ eclipse-temurin:25-jre$/ tiffinbox-docker:1.0.0/'); one "$C_ID1" "$C_ID0" 0 "the image's id"
C_ROOT=$(printf '%s\n' "$C_RM" | sed 's/^docker run --rm /docker run --rm --user root /'); one "$C_ROOT" "$C_RM" 2 "rm as root"
C_MEMB=$(printf '%s\n' "$C_MEM" | sed 's/ -m 512m / /'); one "$C_MEMB" "$C_MEM" -2 "memory B"
C_SHELLQ=$(printf '%s\n' "$C_SHELLB" | sed 's/ --progress=plain / -q /'); one "$C_SHELLQ" "$C_SHELLB" 0 "the quiet build"
C_SIGB=$(printf '%s\n' "$C_SIG" | sed 's/ tiffinbox-docker:1\.0\.0 --tiffinbox/ tiffinbox-docker:shell --tiffinbox/'); one "$C_SIGB" "$C_SIG" 0 "signals B"
C_STOPC=$(printf '%s\n' "$C_STOP" | sed 's/^docker stop /docker stop -t 2 /'); one "$C_STOPC" "$C_STOP" 2 "signals C's stop"
C_OWNB=$(printf '%s\n' "$C_OWN" | sed 's| --user "\$(id -u):\$(id -g)"||'); one "$C_OWNB" "$C_OWN" -4 "owner B"
C_ID2=$(printf '%s\n' "$C_ID1" | sed 's/ tiffinbox-docker:1\.0\.0$/ tiffinbox-docker:user/'); one "$C_ID2" "$C_ID1" 0 "the own user's id"
C_LOG2=$(printf '%s\n' "$C_LOG" | sed 's/ tiffinbox-docker:1\.0\.0 / tiffinbox-docker:user /'); one "$C_LOG2" "$C_LOG" 0 "the own user's head"

# ---- Docker helpers ------------------------------------------------------------------------------------------------------------
# dbuild LOG 'COMMAND': print the command exactly as typed and run it (eval, from this folder), its whole output to LOG (read,
# never printed); its exit code in $ec. A tag it names is removed first, so a rebuilt tag never leaves an image without a tag.
dbuild() { local t; echo "\$ $2"; t=$(printf '%s\n' "$2" | sed -nE 's/.* -t ([^ ]+) .*/\1/p')
  [ -z "$t" ] || docker image rm -f "$t" > /dev/null 2>&1 || true
  ec=0; (eval "$2") > "$1" 2>&1 < /dev/null || ec=$?; }
# steps LOG: the steps a plain BuildKit log names, "[stage n/m] instruction" - each once, sorted by stage and step, the base
# image's digest dropped
steps() { grep -E '^#[0-9]+ \[[a-z0-9-]+ [0-9]+/[0-9]+\] ' "$1" | sed -E 's/^#[0-9]+ //; s/@sha256:[0-9a-f]{64}//' | sort -u | sed 's/^/  /'; }
# BuildKit's end-of-build summary: "N warning(s) found (…):", then one " - RULE: message (line N)" line per warning - printed at
# the end of every plain log that has a warning (12 of 12 builds, RED's probe), where the inline "#n WARN: …" line came in 9 of
# 12. The colour codes stripped. wsum LOG: N, or 0 when the log has no summary; wlines LOG: the summary's warning lines, whole.
plain() { sed $'s/\x1b\\[[0-9;]*m//g' "$1"; }
wsum() { plain "$1" | sed -nE 's/^ *([0-9]+) warnings? found.*$/\1/p' | tail -1 | grep . || echo 0; }
wlines() { plain "$1" | awk '/^ *[0-9]+ warnings? found/ { f = 1; next } f && /^ - / { print; next } { f = 0 }'; }
downloads() { cat "$@" | grep -cE '^#[0-9]+ sha256:[0-9a-f]{64} [0-9.]+[kMG]?B / [0-9.]+[kMG]?B' || true; }   # layer downloads
# ctxbytes LOG: the bytes BuildKit's rawjson progress record counts for the vertex "[internal] load build context" - the build
# context it was sent
ctxbytes() { python3 - "$1" <<'PY'
import json, sys
name, cur = {}, {}
for line in open(sys.argv[1]):
    try: d = json.loads(line)
    except ValueError: continue
    for v in d.get("vertexes") or []: name[v["digest"]] = v.get("name", "")
    for s in d.get("statuses") or []:
        if s.get("id", "").startswith("transferring context"):
            cur[s["vertex"]] = max(cur.get(s["vertex"], 0), s.get("current") or 0)
got = [cur[v] for v in cur if name.get(v) == "[internal] load build context"]
print(got[0] if len(got) == 1 else "(%d records)" % len(got))
PY
}
rootfs() { docker image inspect -f '{{range .RootFS.Layers}}{{println .}}{{end}}' "$1" | grep .; }
# lsame IMG1 IMG2: their RootFS layers, compared position by position (never printed)
lsame() { rootfs "$1" > .harness/r1.txt; rootfs "$2" > .harness/r2.txt
  echo "$(wc -l < .harness/r1.txt | tr -d ' ') and $(wc -l < .harness/r2.txt | tr -d ' ') · the same $(paste -d' ' .harness/r1.txt .harness/r2.txt | awk '$1 == $2' | wc -l | tr -d ' ') · different $(paste -d' ' .harness/r1.txt .harness/r2.txt | awk '$1 != $2' | wc -l | tr -d ' ')"; }
# base IMG: does IMG start with the base image's own layers, unchanged?
base() { rootfs "$BASE" > .harness/rb.txt; rootfs "$1" | head -"$(wc -l < .harness/rb.txt | tr -d ' ')" | cmp -s - .harness/rb.txt && echo "yes, $(wc -l < .harness/rb.txt | tr -d ' ') of $(wc -l < .harness/rb.txt | tr -d ' ')" || echo no; }
imgid() { docker image inspect -f '{{.Id}}' "$1" 2> /dev/null || true; }
# drop OLD TAG: after a build that moved TAG, the image TAG held before is left with no tag - removed by its recorded ID
drop() { [ -n "$1" ] && [ "$1" != "$(imgid "$2")" ] || return 0
  [ "$(docker image inspect -f '{{len .RepoTags}}' "$1" 2> /dev/null || echo gone)" = 0 ] && { docker image rm "$1" > /dev/null 2>&1 || true; }
  docker image inspect "$1" > /dev/null 2>&1 && OLDIDS="$OLDIDS $1"; return 0; }
# tcount IMG: the token in IMG - the image saved (docker save), each layer unpacked (gzip or plain tar) and searched, and its
# config: "K in its L layers, every one unpacked · Q in its config" (occurrences)
tcount() { local kind p f c k=0 l=0 q=0
  rm -rf .harness/saved; mkdir -p .harness/saved; docker save -o .harness/saved/img.tar "$1"; (cd .harness/saved && tar -xf img.tar)
  python3 -c 'import json
for m in json.load(open(".harness/saved/manifest.json")):
    print("config " + m["Config"])
    for p in m["Layers"]: print("layer " + p)' > .harness/blobs.txt
  while read -r kind p; do f=".harness/saved/$p"; [ -f "$f" ] || die "$p is missing from the saved image"
    if [ "$kind" = layer ]; then
      if [ "$(head -c 2 "$f" | od -An -tx1 | tr -d ' \n')" = 1f8b ]; then c=$(gzip -dc "$f" | grep -aoF -- "$TOKEN" | wc -l | tr -d ' '); else c=$(grep -aoF -- "$TOKEN" "$f" | wc -l | tr -d ' '); fi
      l=$((l + 1)); k=$((k + c))
    else c=$(grep -aoF -- "$TOKEN" "$f" | wc -l | tr -d ' '); q=$((q + c)); fi; done < .harness/blobs.txt
  rm -rf .harness/saved
  echo "$k in its $l layers, every one unpacked · $q in its config"; }
# drun 'COMMAND': a docker run -d line, printed exactly as typed, run; its container ID (standard output) is not printed
drun() { echo "\$ $1"; ec=0; (eval "$1") > .harness/run.out 2> .harness/run.err < /dev/null || ec=$?
  [ $ec = 0 ] || { cat .harness/run.err >&3; die "docker run failed: exit $ec"; }; }
# waitlog NAME: poll the container's log until TiffinBox says it listens, or the container stops; 30 s at most
waitlog() { local i=0; while [ $i -lt 120 ]; do docker logs "$1" > .harness/c.log 2>&1 || true; grep -q 'TiffinBox listening' .harness/c.log && break
  [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" = true ] || break; sleep 0.25; i=$((i + 1)); done
  grep -q 'TiffinBox listening' .harness/c.log || { tail -20 .harness/c.log >&3; die "$1 never listened"; }; }
# where: the address in the listening line, without its scheme (check_unit5.py reads http://0.0.0.0… as a demo URL)
where() { msg .harness/c.log 'TiffinBox listening' | sed -E 's#^.*https?://##'; }
# now: seconds since the epoch, to the millisecond (this bash has no EPOCHREALTIME)
now() { perl -MTime::HiRes=time -e 'printf "%.3f\n", time'; }
# band SECONDS WAIT: a duration against the wait docker stop was given (its -t, 10 s by default) - under it, or the wait served
# in full; a shorter wait is also set against Docker's ten. The capture holds the band, the terminal the seconds (RED #42: one
# stop of the exec form took 1.34 s on a loaded Mac, where the others took 0.11-0.17 s).
band() { awk -v s="$1" -v w="$2" 'BEGIN { if (s < w) print "under " w " s"; else if (w < 10 && s < 10) print w " s or more, under 10 s"; else print w " s or more" }'; }

# ---- change: the previous tree against after/, file by file (README aside); the two new files whole; the two jars ---------------
# code FILE: its instruction lines - blank lines, and lines that are comments (#), dropped
code() { awk '{ t = $0; sub(/^[ \t]+/, "", t) } t == "" { next } t ~ /^#/ { next } { print }' "$1"; }
change() { local a b n=0 same=0 changed="" gone="" new="" f
  a=$(cd .harness/before && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  b=$(cd after && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  for f in $a; do if [ -f "after/$f" ]; then n=$((n + 1)); if cmp -s ".harness/before/$f" "after/$f"; then same=$((same + 1)); else changed="$changed $f"; fi; else gone="$gone $f"; fi; done
  for f in $b; do [ -f ".harness/before/$f" ] || new="$new $f"; done
  echo "files, README aside: the previous tree $(echo "$a" | wc -l | tr -d ' ') · after/ $(echo "$b" | wc -l | tr -d ' ') · in both $n: identical $same, changed $(echo $changed | wc -w | tr -d ' ')"
  echo "  only before:${gone:- (none)}"; echo "  only after: ${new:- (none)}"
  echo "  README.md, the anchor's: lines added $(diff .harness/before/README.md after/README.md | grep -c '^>' || true) · removed $(diff .harness/before/README.md after/README.md | grep -c '^<' || true)"
  for f in Dockerfile .dockerignore; do
    echo "after/$f, whole - $(wc -l < "after/$f" | tr -d ' ') lines, $(grep -c '^#' "after/$f" || true) of them comments, $(grep -c '^$' "after/$f" || true) blank:"
    awk '{ printf "%3d  %s\n", NR, $0 }' "after/$f"; done
  echo "the layers lesson's two-stage Dockerfile against this one, instruction lines (comments and blank lines dropped): $(code "$RECIPE" | wc -l | tr -d ' ') and $(code after/Dockerfile | wc -l | tr -d ' ') · in both $(comm -12 <(code "$RECIPE" | sort) <(code after/Dockerfile | sort) | wc -l | tr -d ' ')"
  diff <(code "$RECIPE") <(code after/Dockerfile) | grep '^[<>]' | sed 's/^/  /' || true
  echo "the two trees' jars, each built clean: the same bytes: $(cmp -s ".harness/before/$JAR" "after/$JAR" && echo yes || echo no) · md5 $(md5 -q "after/$JAR") · $(stat -f %z "after/$JAR") bytes"; }
cap change change

# ---- build: README.md's two commands, run as the file gives them; the image's own records ---------------------------------------
buildcap() {
  runf "$C_PACKAGE"; echo "  exit $ec · offline: yes (-o) · BUILD SUCCESS lines: $(grep -c 'BUILD SUCCESS' .harness/run.out || true)"
  [ $ec = 0 ] || die "build: the package failed"
  echo "  after/$JAR: md5 $(md5 -q "after/$JAR") · $(stat -f %z "after/$JAR") bytes"
  dbuild .harness/b-build.log "$C_BUILD"
  [ $ec = 0 ] || { tail -20 .harness/b-build.log >&3; die "build: docker build failed"; }
  echo "  exit $ec · warnings in BuildKit's summary: $(wsum .harness/b-build.log) · layer downloads: $(downloads .harness/b-build.log) · the steps its log names, each once, by stage:"
  steps .harness/b-build.log
  echo "\$ docker image inspect $IMAGE"
  docker image inspect "$IMAGE" > .harness/inspect.json
  python3 - .harness/inspect.json <<'PY'
import json, sys
i = json.load(open(sys.argv[1]))[0]; c = i["Config"]
print(f'  User {c["User"]} · WorkingDir {c["WorkingDir"]} · Entrypoint {json.dumps(c["Entrypoint"])} · Cmd {json.dumps(c.get("Cmd"))}')
env = [e for e in c["Env"] if e.startswith("TIFFINBOX_")]
print(f'  Env: {len(c["Env"])} variables · the TIFFINBOX_ ones: {" ".join(env) if env else "(none)"}')
print("  RootFS layers:", len(i["RootFS"]["Layers"]))
PY
  echo "  the first ones, eclipse-temurin:25-jre's own, unchanged: $(base "$IMAGE")"
  echo "\$ docker history --human=false --no-trunc --format '{{.Size}} {{.CreatedBy}}' $IMAGE"
  docker history --human=false --no-trunc --format '{{.Size}} {{.CreatedBy}}' "$IMAGE" > .harness/history.txt
  echo "  steps: $(wc -l < .harness/history.txt | tr -d ' ') · the newest 8, the second stage's (size in bytes, then the step):"
  head -8 .harness/history.txt | awk '{ s = $1; sub(/^[^ ]+ /, ""); printf "    %-9s %s\n", s, $0 }'
  echo "  the step under them: $(sed -n 9p .harness/history.txt | sed -E 's/^[^ ]+ //') - the base image's own"
  echo "  stage one's steps in the history (WORKDIR /builder, its COPY of the jar, its extract RUN): $(grep -cE 'WORKDIR /builder|COPY tiffinbox-web/target|jarmode=tools' .harness/history.txt || true)"; }
cap build buildcap

# ---- context: what a developer's copy sends to a Dockerfile that copies the whole folder, and what the ignore file keeps out ----
# devtree: .harness/ctx-dev = after/ as built (its jar included), plus the two files a developer's own copy holds beside the
# README and never commits - the config tree with the token (made the anchor README's way, with the demo token) and
# tiffinbox-local.yaml - and no .dockerignore. Rebuilt for every run of the capture.
devtree() { rm -rf .harness/ctx-dev; rsync -a after/ .harness/ctx-dev/; rm -f .harness/ctx-dev/.dockerignore; tree .harness/ctx-dev
  printf '%s\n' "# A developer's own settings, never committed: more cooks on this machine." "tiffinbox:" "  cooks: 4" > .harness/ctx-dev/tiffinbox-local.yaml; }
peek() {
  dbuild ".harness/b-peek-$1.log" "$C_PEEK"
  [ $ec = 0 ] || { tail -20 ".harness/b-peek-$1.log" >&3; die "context: the build failed"; }
  echo "  exit $ec · warnings in BuildKit's summary: $(wsum ".harness/b-peek-$1.log")"
  runf "$C_LS"; echo "  exit $ec · /$LEAK holds: $(paste -sd' ' - < .harness/run.out)"
  echo "  the token, raw, in the image: $(tcount tiffinbox-docker:context)"; }
contextcap() { local c1 c2 c3
  devtree
  echo "the context, .harness/ctx-dev: after/ as built, plus a developer's two never-committed files beside its README - $TF ($(stat -f '%Sp' ".harness/ctx-dev/$TF")) and tiffinbox-local.yaml"
  echo "A   no .dockerignore: docker/context.Dockerfile copies the whole folder"
  runf "rm -f .harness/ctx-dev/.dockerignore"; echo "  exit $ec"; peek a
  echo "B   the anchor's .dockerignore, copied in"
  runf "cp after/.dockerignore .harness/ctx-dev/"; echo "  exit $ec"; peek b
  echo "A′  A re-run"
  runf "rm -f .harness/ctx-dev/.dockerignore"; echo "  exit $ec"; peek a2
  echo "C   the anchor's own Dockerfile, on the same folder: without the ignore file, then with it - each build after touch (every file's time set to now); then once more, nothing touched"
  runf "find .harness/ctx-dev -exec touch {} +"; echo "  exit $ec"
  dbuild .harness/b-ours1.log "$C_OURS"; [ $ec = 0 ] || die "context: C's first build failed"; c1=$(ctxbytes .harness/b-ours1.log)
  echo "  exit $ec · the build context sent, in bytes (its progress record, [internal] load build context): $c1"
  echo "  the token, raw, in the image: $(tcount tiffinbox-docker:dev)"
  echo "  its RootFS layers against $IMAGE's, built from after/ (no secrets/ there): $(lsame tiffinbox-docker:dev "$IMAGE")"
  runf "cp after/.dockerignore .harness/ctx-dev/ && find .harness/ctx-dev -exec touch {} +"; echo "  exit $ec"
  dbuild .harness/b-ours2.log "$C_OURS"; [ $ec = 0 ] || die "context: C's second build failed"; c2=$(ctxbytes .harness/b-ours2.log)
  echo "  exit $ec · the build context sent, in bytes: $c2"
  echo "  the same bytes, with the ignore file and without it: $([ "$c1" = "$c2" ] && echo yes || echo no) · the jar alone: $(stat -f %z ".harness/ctx-dev/$JAR") bytes"
  dbuild .harness/b-ours3.log "$C_OURS"; [ $ec = 0 ] || die "context: C's third build failed"; c3=$(ctxbytes .harness/b-ours3.log)
  echo "  exit $ec · the same build again, nothing touched - the build context sent, in bytes: $c3"
  echo "  layer downloads in the six builds' logs: $(downloads .harness/b-peek-a.log .harness/b-peek-b.log .harness/b-peek-a2.log .harness/b-ours1.log .harness/b-ours2.log .harness/b-ours3.log)"
  docker image rm tiffinbox-docker:context > /dev/null 2>&1 || true
  echo "the image that holds the token (A′'s), removed at once: tiffinbox-docker:context left: $(docker image inspect tiffinbox-docker:context > /dev/null 2>&1 && echo 1 || echo 0)"
  echo "BuildKit's build cache, after the image is gone: the records of the step COPY . /$LEAK (A's and A′'s one, B's one) - the exit trap prunes them"
  runf "$C_DU"; echo "  exit $ec · records: $(grep -c '^ID:' .harness/run.out || true) · each one's description: $(sed -n 's/^Description: *//p' .harness/run.out | sort -u | paste -sd'|' -)"; }
cap context contextcap

# ---- run: README.md's run - the tree mounted read-only, the port on 127.0.0.1, half a gigabyte ---------------------------------
# dseven PORT NAME: the seven requests against the published port; then the container's own exit (docker wait), removed
dseven() { local e tf=.harness/tree/$TF
  echo "\$ \$CURLSET $1 $tf"
  "$CURLSET" "$1" "$tf" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt || echo "(no POST line)"
  echo "  the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  echo "\$ docker wait $2"; e=$(docker wait "$2" 2> /dev/null || echo none); echo "  $e"
  echo "\$ docker rm $2"; docker rm "$2" > /dev/null; echo "  listeners on $1 now: $(listeners "$1")"; }
runcap() {
  drun "$C_RUN"; waitlog tiffinbox-docker-run
  echo "  the log: $(msg .harness/c.log 'Starting TiffinBoxServer')"
  echo "  the log: $(msg .harness/c.log 'TiffinBox listening')"
  echo "  the address in that line: $(where) · $(warns .harness/c.log)"
  dseven 18871 tiffinbox-docker-run
  echo "the config tree mounted: $TF, $(stat -f '%Sp' ".harness/tree/$TF"), this script's user's - the container's user is $(docker image inspect -f '{{.Config.User}}' "$IMAGE")"; }
cap run runcap

# ---- owner: whose files ubuntu can read - in a Docker volume, files keep their owner and mode, as on Linux ------------------------
# exited NAME: wait for the container to stop by itself (30 s at most); its exit code (docker wait), the lines of its log that
# name the failure and its cause, then the container removed
exited() { local i=0
  while [ $i -lt 120 ] && [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" = true ]; do sleep 0.25; i=$((i + 1)); done
  [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" = true ] && { docker rm -f "$1" > /dev/null; die "$1 was still running after 30 s"; }
  echo "\$ docker wait $1"; echo "  $(docker wait "$1" 2> /dev/null || echo none)"
  docker logs "$1" > .harness/c.log 2>&1 || true
  echo "  its log: lines that say TiffinBox listening: $(grep -c 'TiffinBox listening' .harness/c.log || true) · the exception and its cause:"
  grep -m1 -E '^[a-zA-Z.]+(Exception|Error): ' .harness/c.log | sed 's/^/  /' || echo "  (no exception line)"
  grep -m1 '^Caused by: ' .harness/c.log | sed 's/^/  /' || echo "  (no Caused by line)"
  echo "\$ docker rm $1"; docker rm "$1" > /dev/null; }
ownercap() { local own n
  echo "the token's config tree, copied into a Docker volume - storage the daemon keeps itself: its files keep their owner and"
  echo "  mode, as on Linux, with no file sharing in between (the base image copies them, as root):"
  runf "$C_FILL"
  own="$(id -u):$(id -g)"; n=$(grep -c . .harness/run.out || true)
  echo "  exit $ec · entries $n: owned by this script's user and group $(grep -c "^$own " .harness/run.out || true) of $n · their modes: $(awk '{ print $2 }' .harness/run.out | paste -sd' ' -)"
  echo "A   the volume, run as your own user, the tree's owner: --user \"\$(id -u):\$(id -g)\""
  drun "$C_OWN"; waitlog tiffinbox-docker-owner; echo "  the address in the listening line: $(where)"
  dseven 18873 tiffinbox-docker-owner
  echo "B   the volume, run as the image's own user, ubuntu (uid 1000) - no --user"
  drun "$C_OWNB"; exited tiffinbox-docker-owner; echo "  listeners on 18873 now: $(listeners 18873)"
  echo "A′  A re-run"
  drun "$C_OWN"; waitlog tiffinbox-docker-owner; echo "  the address in the listening line: $(where)"
  dseven 18873 tiffinbox-docker-owner
  runf "docker volume rm $VOL > /dev/null"; echo "  exit $ec"; }
cap owner ownercap

# ---- user: whose rights TiffinBox has -----------------------------------------------------------------------------------------
oneline() { echo "  exit $ec · $( { cat .harness/run.out; cat .harness/run.err; } | paste -sd' ' - )"; }
usercap() {
  runf "$C_ID0"; oneline
  runf "$C_ID0 ubuntu"; oneline
  runf "$C_ID1"; oneline
  echo "A   the image's own user"
  runf "$C_RM"; oneline
  echo "B   the same image, --user root"
  runf "$C_ROOT"; oneline
  echo "A′  A re-run"
  runf "$C_RM"; oneline
  runf "docker run --rm --entrypoint sh $IMAGE -c 'command -v sudo'"; echo "  exit $ec · lines printed: $(cat .harness/run.out .harness/run.err | grep -c . || true)"
  runf "$C_GROUPS"; echo "  exit $ec$([ $ec = 1 ] && echo " - find's, as ubuntu: folders it may not read") · files owned by one of ubuntu's other groups: $(grep -c . .harness/run.out || true)"; sed 's/^/  /' .harness/run.out
  runf "$C_LOG"; echo "  exit $ec · bytes read: $(wc -c < .harness/run.out | tr -d ' ')"
  echo "C   a user of its own instead of ubuntu: the USER line replaced by two"
  runf "$C_USERDF"; echo "  exit $ec · .harness/user.Dockerfile against after/Dockerfile, lines that differ: $(diff after/Dockerfile .harness/user.Dockerfile | grep -c '^[<>]' || true)"
  diff after/Dockerfile .harness/user.Dockerfile | grep '^[<>]' | sed 's/^/  /' || true
  dbuild .harness/b-user.log "$C_USERB"; [ $ec = 0 ] || { tail -20 .harness/b-user.log >&3; die "user: C's build failed"; }
  echo "  exit $ec · warnings in BuildKit's summary: $(wsum .harness/b-user.log) · RootFS layers: $(rootfs tiffinbox-docker:user | wc -l | tr -d ' '), $IMAGE's $(rootfs "$IMAGE" | wc -l | tr -d ' ')"
  docker history --human=false --no-trunc --format '{{.Size}} {{.CreatedBy}}' tiffinbox-docker:user > .harness/history-user.txt
  echo "  its history's new step (size in bytes, then the step): $(grep -c 'useradd' .harness/history-user.txt || true) · $(grep -m1 'useradd' .harness/history-user.txt | sed -E 's/ # buildkit$//')"
  runf "$C_ID2"; oneline
  runf "$C_LOG2"; oneline; }
cap user usercap

# ---- memory: Java in our image, its settings printed -----------------------------------------------------------------------------
# The filter (README.md declares it): the memory limit Java read (-XshowSettings:system, standard error), its heap limit and
# its percentage (-XX:+PrintFlagsFinal, standard output) - three lines, the spaces squeezed; every other line counted
keep() { { grep -E 'Memory Limit:' .harness/run.err; grep -E '^ +size_t MaxHeapSize |^ +double MaxRAMPercentage ' .harness/run.out; } | sed -E 's/^ +//; s/ +/ /g; s/^/  /' || true; }
memrun() { local n
  runf "$1"; n=$(cat .harness/run.out .harness/run.err | wc -l | tr -d ' ')
  echo "  exit $ec · lines $n · kept 3 · not shown $((n - 3))"; keep; }
memorycap() { local h m
  echo "A   -m 512m: a limit of half a gigabyte"; memrun "$C_MEM"
  echo "B   no -m: no limit"; memrun "$C_MEMB"
  h=$(grep -E '^ +size_t MaxHeapSize ' .harness/run.out | awk '{ print $4 }'); HEAPX=$h
  runf "docker info -f '{{.MemTotal}}'"; m=$(tr -d ' \n' < .harness/run.out); MEMX=$m; echo "  $m"
  echo "  B's MaxHeapSize, as a share of that memory: $(awk -v h="$h" -v m="$m" 'BEGIN { printf "%.1f%%", 100 * h / m }')"
  echo "A′  A re-run"; memrun "$C_MEM"; }
cap memory memorycap

# ---- signals: the break - the exec form, the shell form, Docker's wait, the exec form again ----------------------------------------
NAME=tiffinbox-docker-signals
sigrun() {
  runf "docker image inspect -f '{{json .Config.Entrypoint}}' $2"; echo "  $(cat .harness/run.out)"
  drun "$1"; waitlog $NAME; echo "  the address in the listening line: $(where)"
  runf "docker exec $NAME cat /proc/1/comm"; echo "  $(cat .harness/run.out)"
  runf "docker exec $NAME cat /proc/1/cmdline"; echo "  its arguments, each one quoted: $(tr '\0' '\n' < .harness/run.out | sed "s/.*/'&'/" | paste -sd' ' -)"
  runf "curl -sS http://127.0.0.1:18872/kitchen"; echo "  $(cat .harness/run.out)"; }
sigstop() { local t0 t1 s w=10
  case "$1" in *" -t 2 "*) w=2 ;; esac
  t0=$(now); runf "$1"; t1=$(now); s=$(awk -v a="$t0" -v b="$t1" 'BEGIN { printf "%.2f", b - a }')
  echo "  (terminal only) $2: docker stop took $s s" >&3
  docker logs $NAME > .harness/c.log 2>&1 || true
  echo "  the container's exit code: $(docker inspect -f '{{.State.ExitCode}}' $NAME) · docker stop returned in: $(band "$s" $w)"
  echo "  the log: lines that say Closing: $(grep -c 'Closing ' .harness/c.log || true) · lines that say Invoking destroy method on bean 'tiffinBoxServer': $(grep -c "Invoking destroy method on bean 'tiffinBoxServer'" .harness/c.log || true) · $(warns .harness/c.log)"
  if grep -q 'Closing ' .harness/c.log; then
    echo "  the thread both were logged on: $(thread .harness/c.log 'Closing ') · $(thread .harness/c.log 'Invoking destroy method')"
    echo "  $(msg .harness/c.log 'Closing ')"; echo "  $(msg .harness/c.log 'Invoking destroy method')"; fi
  echo "\$ docker rm $NAME"; docker rm $NAME > /dev/null; echo "  listeners on 18872 now: $(listeners 18872)"; }
signalscap() {
  echo "A   the anchor's image: the exec form"
  sigrun "$C_SIG" "$IMAGE"; sigstop "$C_STOP" A
  echo "B   one line changed: the shell form"
  runf "$C_SHELLDF"; echo "  exit $ec · .harness/shell.Dockerfile against after/Dockerfile, lines that differ: $(diff after/Dockerfile .harness/shell.Dockerfile | grep -c '^[<>]' || true)"
  diff after/Dockerfile .harness/shell.Dockerfile | grep '^[<>]' | sed 's/^/  /' || true
  dbuild .harness/b-shell.log "$C_SHELLB"; [ $ec = 0 ] || die "signals: B's build failed"
  echo "  exit $ec · warnings in BuildKit's summary, at the end of its log: $(wsum .harness/b-shell.log)"
  wlines .harness/b-shell.log | sed 's/^/  /'
  dbuild .harness/b-shellq.log "$C_SHELLQ"; [ $ec = 0 ] || die "signals: B's quiet build failed"
  echo "  exit $ec · lines it printed: $(grep -c . .harness/b-shellq.log || true) · warnings in BuildKit's summary: $(wsum .harness/b-shellq.log)"
  sed 's/^/  /' .harness/b-shellq.log
  sigrun "$C_SIGB" tiffinbox-docker:shell; sigstop "$C_STOP" B
  echo "C   B again, stopped with docker stop -t 2"
  drun "$C_SIGB"; waitlog $NAME; sigstop "$C_STOPC" C
  echo "A′  A re-run"
  sigrun "$C_SIG" "$IMAGE"; sigstop "$C_STOP" "A'"; }
cap signals signalscap

# ---- the token in every image this script keeps: the image saved, every layer unpacked and searched; a blob already searched is
# ---- not searched twice. The image built to show the leak (context A, A') was searched in its capture, and removed at once
NL=0; NC=0; TL=0; NI=0; NCL=0
searched() { local kind p f c
  rm -rf .harness/saved; mkdir -p .harness/saved; docker save -o .harness/saved/img.tar "$1"; (cd .harness/saved && tar -xf img.tar)
  python3 -c 'import json
for m in json.load(open(".harness/saved/manifest.json")):
    print("config " + m["Config"])
    for p in m["Layers"]: print("layer " + p)' > .harness/blobs.txt
  while read -r kind p; do f=".harness/saved/$p"; [ -f "$f" ] || die "$p is missing from the saved image"
    [ "$kind" = config ] && NCL=$((NCL + 1))
    grep -qxF "$kind $p" .harness/blobs.done 2> /dev/null && continue; echo "$kind $p" >> .harness/blobs.done
    if [ "$kind" = layer ]; then
      if [ "$(head -c 2 "$f" | od -An -tx1 | tr -d ' \n')" = 1f8b ]; then c=$(gzip -dc "$f" | grep -aoF -- "$TOKEN" | wc -l | tr -d ' '); else c=$(grep -aoF -- "$TOKEN" "$f" | wc -l | tr -d ' '); fi
      NL=$((NL + 1))
    else c=$(grep -aoF -- "$TOKEN" "$f" | wc -l | tr -d ' '); NC=$((NC + 1)); fi
    TL=$((TL + c)); done < .harness/blobs.txt
  NI=$((NI + 1)); rm -rf .harness/saved; }
searched tiffinbox-docker:shell; searched tiffinbox-docker:dev; searched tiffinbox-docker:user

# ---- exercise: exercise/README.md's commands, then the measured answer's, read from the files and run as written ------------------
block1() { awk '/^```bash$/ { f++; next } /^```$/ { if (f == 1) exit } f == 1 && !/^export / { print }' "$1"; }
EXL=$(block1 exercise/README.md); SOL=$(block1 exercise/solution/SOLUTION.md)
[ "$(printf '%s\n' "$EXL" | grep -c .)" -ge 3 ] || die "exercise/README.md no longer gives its commands in its first bash block"
[ "$(printf '%s\n' "$SOL" | grep -c .)" -ge 1 ] || die "exercise/solution/SOLUTION.md no longer gives its commands in its first bash block"
lines() { local l old
  while IFS= read -r l; do [ -n "$l" ] || continue
    old=$(imgid "$IMAGE"); runf "$l"; echo "  exit $ec"
    { cat .harness/run.out; grep -v '^$' .harness/run.err | sed 's/^/stderr: /' || true; } | sed 's/^/  /'
    case "$l" in "docker build "*) drop "$old" "$IMAGE" ;; esac; done <<< "$1"; }
exercisecap() {
  echo "exercise/README.md's commands, read from the file and run as written, in order (its two export lines aside):"
  lines "$EXL"
  echo "the measured answer's commands, exercise/solution/SOLUTION.md, run as written:"
  lines "$SOL"; }
cap exercise exercisecap
searched "$IMAGE"

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has1() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }     # an exact line inside a block
S115='115c36bac276128e245ca57df11c2891'

# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does anything
# this unit ships for reading, nor the anchor's build context (after/, as the image's build sends it: no secrets/ in it)
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 after/README.md after/Dockerfile after/.dockerignore docker/context.Dockerfile .harness/user.Dockerfile; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$(grep -rlF -- "$TOKEN" after 2> /dev/null | grep -c . || true)" = 0 ] || die "after/ - the anchor's build context - holds the demo token"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/' "$f" || die "$f holds an absolute path"; done
# ... nor any layer of the images this script keeps (searched above, each once)
[ "$TL" = 0 ] || die "the demo token is in an image layer or config: $TL copies"
[ "$NI" = 4 ] && [ "$NL" -gt 0 ] && [ "$NCL" = 4 ] && [ "$NC" -ge 1 ] || die "the four images were not all searched ($NI images, $NCL configs listed, $NL distinct layers, $NC distinct configs)"
# LOOPBACK ONLY (brief S3.10): a docker run/create line that publishes a port must publish it on 127.0.0.1 (in a pattern of
# this script's, written 127\.0\.0\.1)
DL=$(cat receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md after/README.md | grep -E 'docker (container )?(run|create)' || true)
[ "$(printf '%s\n' "$DL" | grep -E -- ' (-p|--publish)[ =]' | grep -cvE -- ' (-p|--publish)[ =]127(\\)?\.0(\\)?\.0(\\)?\.1:' || true)" = 0 ] || die "a docker run/create line publishes a port off loopback"
echo "  ports: docker run/create lines in receipts.sh, the READMEs and the solution: $(printf '%s\n' "$DL" | grep -c . || true) · publishing a port: $(printf '%s\n' "$DL" | grep -cE -- ' (-p|--publish)[ =]' || true), every one on 127.0.0.1"
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the exercise and its solution, the two new files, receipts.md5, and after/ (the anchor's build context) - and in the $NI images' $NL distinct layers (every one, unpacked) and $NC distinct configs ($NCL listed); no absolute path in any capture"

# "two new files beside the README, nothing else changed ... two stages, the layers lesson's recipe: one path changed, two
# lines new ... the jar, byte for byte"
x change '^files, README aside: the previous tree 18 · after/ 20 · in both 18: identical 18, changed 0$'
x change '^  only after:  \.dockerignore Dockerfile$'
[ "$(grep -cE '^ *[0-9]+  FROM eclipse-temurin:25-jre( AS builder)?$' .r-change.out)" = 2 ] || die "change: two stages, both FROM eclipse-temurin:25-jre"
for l in ' 21  ENV TIFFINBOX_ADDRESS=0.0.0.0' ' 23  USER ubuntu' ' 26  ENTRYPOINT ["java", "-jar", "application.jar"]' '  3  secrets/' '  4  tiffinbox-local.yaml'; do
  grep -qxF -- "$l" .r-change.out || die "change: expected the line: $l"; done
x change "^the layers lesson's two-stage Dockerfile against this one, instruction lines \(comments and blank lines dropped\): 11 and 13 · in both 10\$"
CR=$(blk change "the layers lesson's two-stage Dockerfile" 'the two trees')
[ "$CR" = "$(printf '%s\n' '  < COPY tiffinbox-web-1.0.0.jar application.jar' '  > COPY tiffinbox-web/target/tiffinbox-web-1.0.0.jar application.jar' '  > ENV TIFFINBOX_ADDRESS=0.0.0.0' '  > USER ubuntu')" ] || die "change: the recipe, one COPY path changed and two lines new"
x change "^the two trees' jars, each built clean: the same bytes: yes · md5 92452ee1f9a22920d8aa7e2655f2bdc0 · 16134264 bytes\$"
echo "  change: 2 new files (Dockerfile, .dockerignore), 18 of 18 identical · 2 FROM eclipse-temurin:25-jre · the recipe + ENV + USER, one COPY path · the jar the same bytes"

# "Maven builds the jar on the Mac, offline; docker build packs it, no warning ... the history: stage two's steps, the three
# settings weigh nothing, stage one is not there"
x build '^  exit 0 · offline: yes \(-o\) · BUILD SUCCESS lines: 1$'
x build "^  exit 0 · warnings in BuildKit's summary: 0 · layer downloads: 0 · the steps its log names, each once, by stage:\$"
x build '^  User ubuntu · WorkingDir /app · Entrypoint \["java", "-jar", "application\.jar"\] · Cmd null$'
x build '^  Env: [0-9]+ variables · the TIFFINBOX_ ones: TIFFINBOX_ADDRESS=0\.0\.0\.0$'
x build '^  RootFS layers: 11$'
x build "^  the first ones, eclipse-temurin:25-jre's own, unchanged: yes, 6 of 6\$"
HB=$(blk build '  steps: ' '  the step under them')
[ "$(printf '%s\n' "$HB" | grep -c .)" = 8 ] || die "build: eight steps of stage two"
for l in '    0         ENTRYPOINT ["java" "-jar" "application.jar"]' '    0         USER ubuntu' '    0         ENV TIFFINBOX_ADDRESS=0.0.0.0' '    28672     COPY /builder/extracted/application/ ./ # buildkit' '    15966208  COPY /builder/extracted/dependencies/ ./ # buildkit'; do
  has1 "$HB" "$l" build; done
x build "^  stage one's steps in the history \(WORKDIR /builder, its COPY of the jar, its extract RUN\): 0\$"
echo "  build: exit 0, offline · WARN 0, downloads 0 · ubuntu, /app, exec entrypoint, TIFFINBOX_ADDRESS · 11 layers, the base's 6 first · ENV/USER/ENTRYPOINT 0 bytes · stage one: 0 steps"

# "a developer's copy holds the token beside the README ... A: a Dockerfile that copies everything - the token in a layer, one
# copy ... B: our ignore file - both files out, zero ... A again ... C: our own Dockerfile: the same bytes, ignore file or not"
CA=$(blk context 'A   ' 'B   '); CB=$(blk context 'B   ' 'A′  '); CA2=$(blk context 'A′  ' 'C   '); CC=$(blk context 'C   ' 'the image that holds')
has1 "$CA" '  exit 0 · /tiffinbox-ctx holds: .gitignore Dockerfile README.md pom.xml secrets tiffinbox-core tiffinbox-local.yaml tiffinbox-web' context
has1 "$CA" "  exit 0 · warnings in BuildKit's summary: 0" context
has1 "$CA" '  the token, raw, in the image: 1 in its 7 layers, every one unpacked · 0 in its config' context
has1 "$CB" '  exit 0 · /tiffinbox-ctx holds: .dockerignore .gitignore Dockerfile README.md pom.xml tiffinbox-core tiffinbox-web' context
has1 "$CB" '  the token, raw, in the image: 0 in its 7 layers, every one unpacked · 0 in its config' context
[ "$CA" = "$CA2" ] || die "context: A' is not A, line for line"
[ "$(printf '%s\n' "$CC" | grep -c '^  exit 0 · the build context sent, in bytes')" = 2 ] || die "context: C's two touched builds"
has1 "$CC" '  the token, raw, in the image: 0 in its 11 layers, every one unpacked · 0 in its config' context
has1 "$CC" "  its RootFS layers against tiffinbox-docker:1.0.0's, built from after/ (no secrets/ there): 11 and 11 · the same 11 · different 0" context
has1 "$CC" '  the same bytes, with the ignore file and without it: yes · the jar alone: 16134264 bytes' context
has1 "$CC" "  layer downloads in the six builds' logs: 0" context
CC3=$(printf '%s\n' "$CC" | sed -nE 's/^  exit 0 · the same build again, nothing touched - the build context sent, in bytes: ([0-9]+)$/\1/p')
[ -n "$CC3" ] && [ "$CC3" -lt 1000 ] || die "context: untouched, BuildKit sent a few records, not the jar ($CC3)"
x context '^the image that holds the token \(A′.s\), removed at once: tiffinbox-docker:context left: 0$'
# "removing the image leaves its layer in BuildKit's cache" (chip): the step's records, after the image is gone (the exit trap
# prunes them, filtered to this script's own name - not in a capture: a prune that removes a record makes BuildKit match no
# earlier record afterwards, measured, and C's image would no longer share the image's cached layers)
CK=$(blk context "BuildKit's build cache, after the image is gone" '')
has1 "$CK" '  exit 0 · records: 2 · each one'"'"'s description: [2/2] COPY . /tiffinbox-ctx' context
CBYTES=$(printf '%s\n' "$CC" | sed -nE 's/^  exit 0 · the build context sent, in bytes.*: ([0-9]+)$/\1/p' | sort -u)
[ "$(printf '%s\n' "$CBYTES" | grep -c .)" = 1 ] && [ "$CBYTES" -gt 16134264 ] && [ "$CBYTES" -lt 16200000 ] || die "context: C sent one size, the jar and a few kilobytes more"
echo "  context: A secrets/ and tiffinbox-local.yaml in /tiffinbox-ctx, the token 1 copy · B neither, 0 · A' = A · C $CBYTES bytes both ways, 0 copies, untouched $CC3 · the image gone, its step's cache records 2 (the trap prunes them)"

# "it listens on every address ... ubuntu started it, as process one ... the seven, the same hash ... exit zero"
x run '^  the log: Starting TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1 with PID 1 \(/app/application\.jar started by ubuntu in /app\)$'
x run '^  the log: TiffinBox listening on http://0\.0\.0\.0:18425$'
x run '^  the address in that line: 0\.0\.0\.0:18425 · WARN lines 0 · ERROR lines 0$'
x run "^  the seven responses: 7 lines · md5 $S115\$"
RW=$(blk run '$ docker wait tiffinbox-docker-run' '$ docker rm'); [ "$RW" = '  0' ] || die "run: the container exits 0"
x run '^  listeners on 18871 now: 0$'
echo "  run: 0.0.0.0:18425 · PID 1, started by ubuntu in /app · $S115 · exit 0"

# owner (chip): "in a Docker volume, owner and mode kept as on Linux, ubuntu could not read a tree another user owns: exit 1,
# AccessDeniedException - run as the tree's owner, --user, and it serves"
x owner '^  exit 0 · entries 3: owned by this script.s user and group 3 of 3 · their modes: drwx------ drwx------ -rw-------$'
OA=$(blk owner 'A   ' 'B   '); OB=$(blk owner 'B   ' 'A′  '); OA2=$(blk owner 'A′  ' '$ docker volume rm')
has1 "$OA" '  the address in the listening line: 0.0.0.0:18425' owner
has1 "$OA" "  the seven responses: 7 lines · md5 $S115" owner
has1 "$OA" '  0' owner
has1 "$OB" '  1' owner
has1 "$OB" '  its log: lines that say TiffinBox listening: 0 · the exception and its cause:' owner
has1 "$OB" "  java.lang.IllegalStateException: Unable to find files in '/app/./secrets'" owner
has1 "$OB" '  Caused by: java.nio.file.AccessDeniedException: /app/./secrets' owner
[ "$OA" = "$OA2" ] || die "owner: A' is not A, line for line"
[ "$(grep -c '^  listeners on 18873 now: 0$' .r-owner.out)" = 3 ] || die "owner: the port free after every run"
echo "  owner: the tree in a volume, 3 of 3 this script's user's, 0700/0700/0600 · A --user: $S115, exit 0 · B ubuntu: exit 1, AccessDeniedException · A' = A"

# "the base image runs as root, user zero ... ours as ubuntu, user one thousand, already in the base ... as ubuntu it can't
# even delete its own jar; as root, the same image can"
x user '^  exit 0 · uid=0\(root\) gid=0\(root\) groups=0\(root\)$'
UB=$(blk user '$ docker run --rm --entrypoint id eclipse-temurin:25-jre ubuntu' '$ docker run --rm --entrypoint id tiffinbox-docker:1.0.0')
printf '%s\n' "$UB" | grep -qE '^  exit 0 · uid=1000\(ubuntu\) gid=1000\(ubuntu\) groups=1000\(ubuntu\),.*27\(sudo\)' || die "user: ubuntu is in the base image, uid 1000"
UO=$(blk user '$ docker run --rm --entrypoint id tiffinbox-docker:1.0.0' 'A   '); printf '%s\n' "$UO" | grep -qE '^  exit 0 · uid=1000\(ubuntu\) gid=1000\(ubuntu\) ' || die "user: our image runs as uid 1000"
UA=$(blk user 'A   ' 'B   '); UBB=$(blk user 'B   ' 'A′  '); UA2=$(blk user 'A′  ' '$ docker run --rm --entrypoint sh')
has1 "$UA" "  exit 1 · rm: cannot remove '/app/application.jar': Permission denied" user
has1 "$UBB" '  exit 0 · ' user
[ "$UA" = "$UA2" ] || die "user: A' is not A"
x user '^  exit 127 · lines printed: 0$'
# chip: "of ubuntu's other groups, only adm owns a file here: one log, which ubuntu can read · a user of its own: one more layer,
# 32,768 bytes, and the log out of reach"
x user "^  exit 1 - find's, as ubuntu: folders it may not read · files owned by one of ubuntu's other groups: 1\$"
x user '^  -rw-r----- root:adm /var/log/apt/term\.log$'
x user '^  exit 0 · bytes read: 1$'
[ "$(printf '%s\n' "$UB" | sed -E 's/.*groups=//' | tr ',' '\n' | grep -vc '^1000(ubuntu)$')" = 9 ] || die "user: ubuntu has nine groups besides its own"
UC=$(blk user 'C   ' '')
has1 "$UC" '  exit 0 · .harness/user.Dockerfile against after/Dockerfile, lines that differ: 3' user
has1 "$UC" '  < USER ubuntu' user
has1 "$UC" '  > USER tiffinbox' user
has1 "$UC" "  exit 0 · warnings in BuildKit's summary: 0 · RootFS layers: 12, tiffinbox-docker:1.0.0's 11" user
has1 "$UC" "  its history's new step (size in bytes, then the step): 1 · 32768 RUN /bin/sh -c groupadd --system tiffinbox && useradd --system --gid tiffinbox --no-create-home --shell /usr/sbin/nologin tiffinbox" user
has1 "$UC" '  exit 0 · uid=999(tiffinbox) gid=999(tiffinbox) groups=999(tiffinbox)' user
has1 "$UC" "  exit 1 · head: cannot open '/var/log/apt/term.log' for reading: Permission denied" user
echo "  user: base uid 0 · ubuntu uid 1000 in the base · ours uid 1000 · rm as ubuntu: Permission denied, exit 1 · as root: exit 0 · A' = A · no sudo · ubuntu's 9 other groups own 1 file, term.log, readable · C a user of its own: +1 layer, 32768 bytes, uid 999, term.log denied"

# "with half a gigabyte, a quarter for the heap: a hundred and thirty-four million bytes ... no limit: a quarter of Docker's
# machine, masked"
MA=$(blk memory 'A   ' 'B   '); MB=$(blk memory 'B   ' 'A′  '); MA2=$(blk memory 'A′  ' '')
has1 "$MA" '  Memory Limit: 512.00M' memory
has1 "$MA" '  size_t MaxHeapSize = 134217728 {product} {ergonomic}' memory
has1 "$MA" '  double MaxRAMPercentage = 25.000000 {product} {default}' memory
[ $((512 * 1024 * 1024 / 4)) = 134217728 ] || die "memory: a quarter of 512 MiB"
has1 "$MB" '  Memory Limit: Unlimited' memory
has1 "$MB" "  size_t MaxHeapSize = [masked: the heap Java took on this Docker] {product} {ergonomic}" memory
has1 "$MB" "  B's MaxHeapSize, as a share of that memory: 25.0%" memory
[ "$MA" = "$MA2" ] || die "memory: A' is not A"
echo "  memory: 512.00M -> 134217728 (25%) · no limit -> 25.0% of this Docker's memory, masked · A' = A"

# "A, the exec form: process one is java; the argument arrives, forty orders; docker stop: almost at once, long before Docker's
# ten seconds (under 10 s), 143; Closing, then
# the stop method ... B, the shell form: wrapped in a shell, the shell is process one; one hundred twenty; ten seconds, 137;
# nothing ... the build warned (its end-of-build summary, 1), -q hid it ... C: after two (2 s or more, under 10 s) ... A again"
SA=$(blk signals 'A   ' 'B   '); SB=$(blk signals 'B   ' 'C   '); SC=$(blk signals 'C   ' 'A′  '); SA2=$(blk signals 'A′  ' '')
has1 "$SA" '  ["java","-jar","application.jar"]' signals
has1 "$SA" '  java' signals
has1 "$SA" "  its arguments, each one quoted: 'java' '-jar' 'application.jar' '--tiffinbox.days=10'" signals
has1 "$SA" '  {"ordersCooked":40,"ordersValue":8100}' signals
has1 "$SA" "  the container's exit code: 143 · docker stop returned in: under 10 s" signals
has1 "$SA" "  the log: lines that say Closing: 1 · lines that say Invoking destroy method on bean 'tiffinBoxServer': 1 · WARN lines 0 · ERROR lines 0" signals
has1 "$SA" '  the thread both were logged on: [ionShutdownHook] · [ionShutdownHook]' signals
has1 "$SA" "  Invoking destroy method on bean 'tiffinBoxServer': synchronized void com.tiffinbox.web.TiffinBoxServer.stop()" signals
has1 "$SB" '  exit 0 · .harness/shell.Dockerfile against after/Dockerfile, lines that differ: 2' signals
has1 "$SB" "  exit 0 · warnings in BuildKit's summary, at the end of its log: 1" signals
has1 "$SB" '   - JSONArgsRecommended: JSON arguments recommended for ENTRYPOINT to prevent unintended behavior related to OS signals (line 26)' signals
has1 "$SB" "  exit 0 · lines it printed: 1 · warnings in BuildKit's summary: 0" signals
has1 "$SB" '  ["/bin/sh","-c","java -jar application.jar"]' signals
has1 "$SB" '  sh' signals
has1 "$SB" "  its arguments, each one quoted: '/bin/sh' '-c' 'java -jar application.jar' '--tiffinbox.days=10'" signals
has1 "$SB" '  {"ordersCooked":120,"ordersValue":24300}' signals
has1 "$SB" "  the container's exit code: 137 · docker stop returned in: 10 s or more" signals
has1 "$SB" "  the log: lines that say Closing: 0 · lines that say Invoking destroy method on bean 'tiffinBoxServer': 0 · WARN lines 0 · ERROR lines 0" signals
has1 "$SC" "  the container's exit code: 137 · docker stop returned in: 2 s or more, under 10 s" signals
has1 "$SC" "  the log: lines that say Closing: 0 · lines that say Invoking destroy method on bean 'tiffinBoxServer': 0 · WARN lines 0 · ERROR lines 0" signals
grep -qxF ' 26  ENTRYPOINT ["java", "-jar", "application.jar"]' .r-change.out || die "signals: the warning's line 26 is the ENTRYPOINT"
[ "$SA" = "$SA2" ] || die "signals: A' is not A, line for line"
[ "$(grep -c '^  listeners on 18872 now: 0$' .r-signals.out)" = 4 ] || die "signals: the port free after every run"
echo "  signals: A java, 40 orders, 143 under 10 s, Closing 1 + stop() · B sh, the argument dropped (120), 137 after 10 s or more, 0 · summary 1 warning, -q 0 · C -t 2: 137, 2 s or more, under 10 s · A' = A"

# the exercise's end state: 134217728 with the lesson's run, 402653184 with three quarters
EX1=$(blk exercise "exercise/README.md's commands" 'the measured answer'); EX2=$(blk exercise 'the measured answer' '')
printf '%s\n' "$EX1" | grep -qE '^     size_t MaxHeapSize += 134217728 +\{product\} \{ergonomic\}$' || die "exercise: the lesson's run, MaxHeapSize = 134217728"
printf '%s\n' "$EX2" | grep -qE '^     size_t MaxHeapSize += 402653184 +\{product\} \{ergonomic\}$' || die "exercise: three quarters, MaxHeapSize = 402653184"
printf '%s\n' "$EX2" | grep -qxF '  stderr: Picked up JAVA_TOOL_OPTIONS: -XX:MaxRAMPercentage=75' || die "exercise: Java picked the option up"
[ $((512 * 1024 * 1024 * 3 / 4)) = 402653184 ] || die "exercise: three quarters of 512 MiB"
echo "  exercise: -m 512m -> MaxHeapSize = 134217728 · JAVA_TOOL_OPTIONS=-XX:MaxRAMPercentage=75 -> 402653184, picked up"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit16: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, the anchor's build context and every kept image's layers; 1 in the leak image, removed - its cache records pruned by the exit trap, filtered to tiffinbox-ctx"
