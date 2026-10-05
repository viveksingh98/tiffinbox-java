#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · Buildpacks: spring-boot:build-image — this unit's receipts. No Dockerfile: one Maven goal hands TiffinBox's jar
# to a buildpack builder, which picks a Java, a base image and a launch command. This unit reads what it picked off its log
# and off the image it made, runs the image - first with no token, then with the config tree mounted read-only - and finds
# that the container answers nothing: TiffinBox listened on 127.0.0.1, the container's own loopback. The anchor change, the
# key tiffinbox.address (default 127.0.0.1), lets a container say 0.0.0.0. Eight captures, each run three times and hashed;
# cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that
# can fail; the demo token is masked (gsub), and the last checks count 0 raw copies in every capture, every README, and
# every layer of both images this script tags.
#   change   the previous tree against after/, file by file: every changed code line; then after/'s jar and the previous
#            tree's, each run on the Mac: the listening line and the seven responses - the same
#   build    README.md's two commands: install from the root, then the web module's image, from the jar just built
#            (build-image-no-fork) - the builder pinned by digest, pulled only if absent; its log filtered (declared below),
#            counted; the image this name held before - the run's first build, of the same jar - compared layer by layer
#   root     the obvious command, spring-boot:build-image from the root (on a copy of after/): it fails on tiffinbox-core,
#            and what it leaves behind is counted, then removed
#   chose    the image's own records (docker image inspect): user, folder, entrypoint, date, labels, the launch process, the
#            JRE layer's source, the run image; the jar's Build-Jdk-Spec; /workspace copied out of a created container: 32
#            entries in BOOT-INF/lib/, one a link; the thread count one layer sets; and a shell that is not there
#   required the image run with no token: the memory calculator's line, then the failure report
#   address  the break: A TIFFINBOX_ADDRESS=0.0.0.0 · B no address · C Boot's server.address instead · A' = A; each with
#            the config tree mounted read-only at /workspace/secrets, run as this script's own user (--user), and the port
#            published on 127.0.0.1 only
#   user     whose user reads the token: the tree copied into a Docker volume, where files keep their owner and mode, as on
#            Linux - A --user "$(id -u):$(id -g)" · B the image's own user, 1002:1001 · A' = A · C the folder mounted from the
#            Mac with the image's own user (OrbStack's file sharing, on this Mac)
#   rebuild  at/ (after/ with one word changed) built into the same name: downloads, the JRE, the app layers, RootFS
#   exercise exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit14/after (the anchor as the last unit to change it left it), COPIED to .harness/before; this script
# never writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change, built in
# place, clean. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the
# secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file).
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]" and
# the exercise's own random token "[masked: the 32-character token]"; this folder's absolute path "…", the folder above it
# "…/..", the home folder "~"; a container ID that docker run -d prints, "[a container ID]"; a build-cache volume's hash,
# "<hash>" - in every line of every capture (gsub). Maven's and the buildpack's logs are kept in .harness/ and read: the
# buildpack log's kept lines are printed with Maven's "[INFO] " prefix dropped, and the lines not kept are counted. A
# container's log line is printed from its message on (the time, level, PID, thread and logger columns dropped). No image
# ID, layer digest or container ID is printed - layers are compared, and the comparison printed.
# Ports (brief ⚑10, 18860-18869): change 18860 · address 18861 · user 18862 · exercise 18866. 18425 is checked free too (the old
# default port). Containers listen on 18425 inside, which binds nothing on the Mac; every -p publishes on 127.0.0.1 only.
# Docker names (no unit number): the image tiffinbox-web:1.0.0 (Boot's default name for this module); containers
# tiffinbox-web-address, -required, -peek, -shell, -mine, -volume, -fill; the volume tiffinbox-web-secrets. The exit trap removes exactly those names, the containers
# labelled author=spring-boot that appeared during the run (with the image each was created from), Boot's ephemeral
# builder images that appeared, and the volumes named pack-* that appeared (taken before and after: the difference).
# Never a prune: a third-party container and its images live on this Docker.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement,
# on by default): startjar's "&& exec java" became "&& java && java  exec java" and java printed its usage. Switched off,
# so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no such option.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMAGE=tiffinbox-web:1.0.0
BOXES="tiffinbox-web-address tiffinbox-web-required tiffinbox-web-peek tiffinbox-web-shell tiffinbox-web-mine tiffinbox-web-volume tiffinbox-web-fill"
VOL=tiffinbox-web-secrets                            # this script's own volume: the token's tree, as Linux keeps files
pid=""; SNAP=""; VOL0=""; LAB0=""; IMG0=""; OLDIDS=""
# newboxes / newvols / newbuilders: the containers labelled author=spring-boot (Boot's buildpack client labels the
# lifecycle container it creates), the volumes named pack-*, and the images named pack.local/builder/* (Boot's ephemeral
# builder) that were NOT there when this script took its snapshot - one per line
newboxes() { local c; for c in $(docker ps -aq --no-trunc --filter label=author=spring-boot 2> /dev/null || true); do case " $LAB0 " in *" $c "*) ;; *) echo "$c" ;; esac; done; }
newvols() { local v; for v in $(docker volume ls -q 2> /dev/null | grep '^pack-' || true); do case " $VOL0 " in *" $v "*) ;; *) echo "$v" ;; esac; done; }
newbuilders() { local i; for i in $(docker images -q --no-trunc --filter 'reference=pack.local/builder/*' 2> /dev/null || true); do case " $IMG0 " in *" $i "*) ;; *) echo "$i" ;; esac; done; }
# sweep: this script's own Docker names, plus - once the snapshot exists - what Boot's client created during the run.
# Every command is guarded: a name already gone makes docker exit 1, and nothing here may end the clean-up early.
sweep() { local c i v
  docker rm -f $BOXES > /dev/null 2>&1 || true
  docker volume rm -f "$VOL" > /dev/null 2>&1 || true
  docker image rm -f "$IMAGE" $OLDIDS > /dev/null 2>&1 || true
  [ -n "$SNAP" ] || return 0
  for c in $(newboxes); do i=$(docker inspect -f '{{.Image}}' "$c" 2> /dev/null || true); docker rm -f "$c" > /dev/null 2>&1 || true
    [ -z "$i" ] || docker image rm -f "$i" > /dev/null 2>&1 || true; done
  for i in $(newbuilders); do docker image rm -f "$i" > /dev/null 2>&1 || true; done
  for v in $(newvols); do docker volume rm -f "$v" > /dev/null 2>&1 || true; done; }
# On every exit - the end, a failed check, or Ctrl-C - stop the JVM this script started in the background, if it still runs;
# remove this script's containers, images and volumes (sweep); drop the lock. A background job of a non-interactive shell
# ignores the terminal's Ctrl-C, so without the kill an interrupted run would leave TiffinBox listening. $pid is cleared
# whenever the JVM has been reaped. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e (a JVM
# stopped by SIGTERM exits 143), so it always reaches the rmdir; the script still exits 130 after an interrupt (tested:
# README.md, "Interrupted").
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; rm -rf .harness/saved 2> /dev/null || true; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
# A variable of yours must not become a property source, a JVM flag, a build setting or a buildpack setting: every
# TIFFINBOX_*, SPRING_*, BP_* and BPL_* variable, the two variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS, and the
# variables that change what docker does (DOCKER_BUILDKIT, BUILDKIT_*, BUILDX_*, DOCKER_DEFAULT_PLATFORM, SOURCE_DATE_EPOCH)
# are removed first. DOCKER_HOST and DOCKER_CONTEXT stay: they say which Docker to reach.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|BPL\{0,1\}_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\|DOCKER_BUILDKIT\|BUILDKIT_[A-Za-z0-9_]*\|BUILDX_[A-Za-z0-9_]*\|DOCKER_DEFAULT_PLATFORM\|SOURCE_DATE_EPOCH\)=.*/\1/p'); do unset "$v"; done
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
SRV=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server that every capture stops. It is written
# into a file under .harness/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
# The builder, pinned by its digest, and the run image the builder names for itself (its own metadata: 0.0.138) - both
# already on this Mac; with pullPolicy IF_NOT_PRESENT, Boot pulls neither (the build capture counts "Pulling" lines: 0).
BUILDER=paketobuildpacks/builder-noble-java-tiny@sha256:b95da27fce97b58037f0c11ae934760c50730da4c9a24976205b53638592eba9
RUNIMAGE=paketobuildpacks/ubuntu-noble-run-tiny:0.0.138
[ -f "$CURLSET" ] || die "$CURLSET is missing"
grep -q 'TiffinBox listening on http' "after/$SRV" || die "after/'s TiffinBoxServer no longer says 'TiffinBox listening on'"

# Docker: asked first; started only if it does not answer (OrbStack's own command, when there is one); then polled - this Mac
# has no timeout command - for 60 s at most.
if ! docker info > /dev/null 2>&1; then
  command -v orb > /dev/null 2>&1 && { orb start > /dev/null 2>&1 || true; }
  i=0; until docker info > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 60 ] || die "Docker does not answer after 60 s - start it (OrbStack: orb start; Docker Desktop: open it), then run again"; sleep 1; done; fi
docker image inspect "$BUILDER" > /dev/null 2>&1 || die "the builder is not on this machine - pull it once (docker pull $BUILDER: network, a build-time resolution), then run again"
docker image inspect "$RUNIMAGE" > /dev/null 2>&1 || die "the run image is not on this machine - pull it once (docker pull $RUNIMAGE), then run again"
# This script's own names, left by an interrupted run, removed before anything else - with any container Boot's client
# left for one of this project's two image names, its image, and the volumes it mounted
docker rm -f $BOXES > /dev/null 2>&1 || true; docker image rm -f "$IMAGE" > /dev/null 2>&1 || true; docker volume rm -f "$VOL" > /dev/null 2>&1 || true
for c in $(docker ps -aq --no-trunc --filter label=author=spring-boot --filter 'label=org.springframework.boot.builderFor=docker.io/library/tiffinbox-web:1.0.0' 2> /dev/null; docker ps -aq --no-trunc --filter label=author=spring-boot --filter 'label=org.springframework.boot.builderFor=docker.io/library/tiffinbox-core:1.0.0' 2> /dev/null); do
  i=$(docker inspect -f '{{.Image}}' "$c" 2> /dev/null || true); vs=$(docker inspect -f '{{range .Mounts}}{{.Name}} {{end}}' "$c" 2> /dev/null || true)
  docker rm -f "$c" > /dev/null 2>&1 || true; [ -z "$i" ] || docker image rm -f "$i" > /dev/null 2>&1 || true
  for v in $vs; do case "$v" in pack-app-*|pack-layers-*) docker volume rm -f "$v" > /dev/null 2>&1 || true ;; esac; done; done
# The snapshot the clean-up compares against: what exists now is not this run's
VOL0=$(docker volume ls -q | grep '^pack-' | tr '\n' ' ' || true)
LAB0=$(docker ps -aq --no-trunc --filter label=author=spring-boot | tr '\n' ' ' || true)
IMG0=$(docker images -q --no-trunc --filter 'reference=pack.local/builder/*' | tr '\n' ' ' || true)
SNAP=1

# The ports, BEFORE .harness/ is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which
# lives in .harness/ - so the message names the process to kill). This script's containers were removed just above.
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18860 18861 18862 18863 18864 18865 18866 18867 18868 18869; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- build: the previous tree once, clean; at/ is built by the rebuild capture; after/ by the first build below -----------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target ../c5-unit14/after/ .harness/before/
rsync -a --exclude target after/ .harness/at/
sed 's|"TiffinBox listening on http|"TiffinBox listening at http|' "after/$SRV" > ".harness/at/$SRV"
[ "$(diff "after/$SRV" ".harness/at/$SRV" | grep -c '^[<>]')" = 2 ] || die "at/ must differ from after/ in one line"
# build DIR LOG GOAL...: a clean build, offline first, its log kept in LOG (never printed whole); Maven Central only if the
# offline build could not resolve something - and the terminal says which (offline: yes / no), so a run that went online is
# never silent.
build() { local d=$1 log=$2 how=yes ec=0; shift 2
  mvn -o -B -f "$d/pom.xml" -Dmaven.repo.local="$M2" -DskipTests clean "$@" > "$log" 2>&1 || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$log"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    mvn -B -f "$d/pom.xml" -Dmaven.repo.local="$M2" -DskipTests clean "$@" > "$log" 2>&1 || ec=$?; fi
  [ $ec = 0 ] || { tail -30 "$log" >&3; die "build failed: $d"; }
  echo "  built $d ($*) · offline: $how · exit $ec"; }
build .harness/before .harness/build-before.log package

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
# runq 'COMMAND': the same, printed by the caller in its own words (a step every run repeats, whose log is not the subject)
runq() { ec=0; (eval "$1") > .harness/run.out 2> .harness/run.err < /dev/null || ec=$?; }
# startjar 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec, so $pid is java's
# own pid), its standard output to .harness/jar.out and its standard error to .harness/jar.err
startjar() { echo "\$ $1"; (eval "${1/&& java /&& exec java }") > .harness/jar.out 2> .harness/jar.err < /dev/null & pid=$!; }
# listening: what the operating system says the process listens on (lsof), once it listens - or "nothing" once it exited
listening() { local a="" i=0
  while [ $i -lt 120 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# up: the line after a start - where it listens, and its WARN/ERROR lines so far; dies if it never listened
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/jar.out >&3; die "it never listened"; }
  echo "  listens on: $l · $(warns .harness/jar.out)"; }
# msg LOG PATTERN: the first log line matching PATTERN, from its message on (the time, level, PID, thread and logger
# columns dropped)
msg() { grep -m1 -- "$2" "$1" | sed -E 's/^.* : //' || true; }
# seven PORT: the comparison set's seven requests (POST /shutdown carries the header, read from tree/'s file), printed as
# run; the JVM must leave within 15 s of them, and the port must be free again. Never call it inside $(...): wait needs
# this shell.
seven() { local i tf=.harness/tree/$TF
  echo "\$ \$CURLSET $1 $tf"
  "$CURLSET" "$1" "$tf" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt || echo "(no POST line)"
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  e=0; wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }

# mask: the demo token becomes a label naming its length; this folder's path "…", the folder above it "…/..", the home
# folder "~"; a line that is a 64-hex container ID (docker run -d prints one) "[a container ID]"; a build-cache volume's
# hash "<hash>" - in every line (gsub)
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)) }
  { gsub(T, "[masked: the 26-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    if ($0 ~ /^ *[0-9a-f]{64}$/) gsub(/[0-9a-f]{64}/, "[a container ID]"); gsub(/pack-cache-[0-9a-f]{12}/, "pack-cache-<hash>"); print }'; }

# boxes: this script's own containers that exist right now
boxes() { docker ps -a --format '{{.Names}}' | grep -cxE 'tiffinbox-web-(address|required|peek|shell|mine|volume|fill)' || true; }
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a JVM running"
    [ "$(boxes)" = 0 ] || die "$nm left a container"
    [ "$(newboxes | grep -c . || true)" = 0 ] || die "$nm left a container labelled author=spring-boot"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot, Maven, Docker, builder or run image, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# readme PATTERN [FILE]: the first line of FILE (README.md) that matches PATTERN - so a label never claims what the README says
readme() { grep -m1 -E "$1" "${2:-README.md}" || true; }
# The commands, read from README.md's "Commands" section and asserted - receipts.sh runs them as the file gives them.
C_INSTALL=$(readme '^mvn -o -B -f after/pom\.xml -Dmaven\.repo\.local="\$M2" -DskipTests clean install$')
C_IMAGE=$(readme '^mvn -o -B -f after/pom\.xml -Dmaven\.repo\.local="\$M2" -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot\.build-image\.builder="\$BUILDER" -Dspring-boot\.build-image\.runImage="\$RUNIMAGE" -Dspring-boot\.build-image\.pullPolicy=IF_NOT_PRESENT$')
C_ROOT=$(readme '^mvn -o -B -f \.harness/root/pom\.xml -Dmaven\.repo\.local="\$M2" spring-boot:build-image -Dspring-boot\.build-image\.builder="\$BUILDER" -Dspring-boot\.build-image\.runImage="\$RUNIMAGE" -Dspring-boot\.build-image\.pullPolicy=IF_NOT_PRESENT$')
C_REQ=$(readme '^docker run --rm --name tiffinbox-web-required -m 1g tiffinbox-web:1\.0\.0$')
C_A=$(readme '^docker run -d --name tiffinbox-web-address -m 1g --user "\$\(id -u\):\$\(id -g\)" -e TIFFINBOX_ADDRESS=0\.0\.0\.0 -v "\$PWD/\.harness/tree/secrets:/workspace/secrets:ro" -p 127\.0\.0\.1:18861:18425 tiffinbox-web:1\.0\.0$')
C_FILL=$(readme '^docker volume create tiffinbox-web-secrets > /dev/null && docker run --rm --name tiffinbox-web-fill --user 0 --entrypoint sh -v tiffinbox-web-secrets:/s -v "\$PWD/\.harness/tree/secrets:/src:ro" "\$BUILDER" -c .* - "\$\(id -u\):\$\(id -g\)"$')
[ -n "$C_INSTALL" ] && [ -n "$C_IMAGE" ] && [ -n "$C_ROOT" ] && [ -n "$C_REQ" ] && [ -n "$C_A" ] && [ -n "$C_FILL" ] || die "README.md no longer gives the six commands this script runs (Commands)"
# B and C: A with one flag changed - removed (B), or swapped for Boot's own key (C); each derivation asserted
C_B=$(printf '%s\n' "$C_A" | sed 's| -e TIFFINBOX_ADDRESS=0\.0\.0\.0 | |')
C_C=$(printf '%s\n' "$C_A" | sed 's| -e TIFFINBOX_ADDRESS=0\.0\.0\.0 | -e SERVER_ADDRESS=0.0.0.0 |')
[ "$(printf '%s\n' "$C_A" | wc -w | tr -d ' ')" = $(( $(printf '%s\n' "$C_B" | wc -w | tr -d ' ') + 2 )) ] && [ "$(printf '%s\n' "$C_C" | wc -w | tr -d ' ')" = "$(printf '%s\n' "$C_A" | wc -w | tr -d ' ')" ] && [ "$C_C" != "$C_A" ] || die "B and C must be A with one flag changed"
# user: A's command with the volume in place of the folder, its own name and port (C_V); B and C, C_V and A each without
# --user; each derivation asserted
U_FLAG=' --user "$(id -u):$(id -g)"'
C_V=$(printf '%s\n' "$C_A" | sed 's|-v "\$PWD/\.harness/tree/secrets:/workspace/secrets:ro"|-v tiffinbox-web-secrets:/workspace/secrets:ro|; s|--name tiffinbox-web-address|--name tiffinbox-web-volume|; s|127\.0\.0\.1:18861:|127.0.0.1:18862:|')
C_VB=$(printf '%s\n' "$C_V" | sed 's| --user "\$(id -u):\$(id -g)"||')
C_VC=$(printf '%s\n' "$C_A" | sed 's| --user "\$(id -u):\$(id -g)"||; s|--name tiffinbox-web-address|--name tiffinbox-web-volume|; s|127\.0\.0\.1:18861:|127.0.0.1:18862:|')
case "$C_V" in *"$U_FLAG"*tiffinbox-web-secrets:/workspace/secrets:ro*18862:18425*) ;; *) die "user: A is the address A with the volume, port 18862" ;; esac
case "$C_VB$C_VC" in *--user*) die "user: B and C run as the image's own user" ;; esac
[ "$(printf '%s\n' "$C_VC" | sed 's|-v "\$PWD/\.harness/tree/secrets:/workspace/secrets:ro"|-v tiffinbox-web-secrets:/workspace/secrets:ro|')" = "$(printf '%s\n' "$C_V" | sed 's| --user "\$(id -u):\$(id -g)"||')" ] || die "user: C is A without --user, the folder mounted instead of the volume"
# at/'s two commands: the README's, with the tree swapped
C_AT_INSTALL=$(printf '%s\n' "$C_INSTALL" | sed 's|-f after/pom\.xml|-f .harness/at/pom.xml|')
C_AT_IMAGE=$(printf '%s\n' "$C_IMAGE" | sed 's|-f after/pom\.xml|-f .harness/at/pom.xml|')

# rootfs IMG: its RootFS layer digests, one per line (compared, never printed)
rootfs() { docker image inspect -f '{{range .RootFS.Layers}}{{println .}}{{end}}' "$1" | grep .; }
# lcmp FILE1 FILE2: two RootFS lists, compared position by position
lcmp() { echo "$(wc -l < "$1" | tr -d ' ') and $(wc -l < "$2" | tr -d ' ') · the same $(paste -d' ' "$1" "$2" | awk '$1 == $2' | wc -l | tr -d ' ') · different $(paste -d' ' "$1" "$2" | awk '$1 != $2' | wc -l | tr -d ' ')"; }
imgid() { docker image inspect -f '{{.Id}}' "$IMAGE" 2> /dev/null || true; }
# drop OLD: after a build that moved the name, the image the name held before is left with no tag - removed by its ID
drop() { [ -n "$1" ] && [ "$1" != "$(imgid)" ] || return 0
  [ "$(docker image inspect -f '{{len .RepoTags}}' "$1" 2> /dev/null || echo gone)" = 0 ] && { docker image rm "$1" > /dev/null 2>&1 || true; }
  docker image inspect "$1" > /dev/null 2>&1 && OLDIDS="$OLDIDS $1"; return 0; }
# The buildpack log's filter (README.md declares it): the lines below are kept, every other line counted as not shown
KEEP='Building image |buildpacks participating|\[creator\]     paketo-buildpacks/|\$BP_JVM_VERSION |\$BPL_JVM_THREAD_COUNT |Using Java version|Liberica JRE [0-9.]+: |Downloading from|Process types:|\[creator\]         web: |Creating slices|\[creator\]         (dependencies|spring-boot-loader|snapshot-dependencies|application) \(|Spring Cloud Bindings [0-9.]+: |Web Application Type: |Non-web application|app layer\(s\)|Successfully built image'
bplog() { local n k
  n=$(wc -l < "$1" | tr -d ' ')
  sed -E 's/^\[INFO\] +//' "$1" | grep -E -- "$KEEP" | sed 's/^/  /' > .harness/kept.txt || true
  k=$(wc -l < .harness/kept.txt | tr -d ' ')
  cat .harness/kept.txt
  echo "  log lines $n · shown $k · not shown $((n - k)) · lines that say Downloading from: $(grep -c 'Downloading from' "$1" || true) · lines that say Pulling: $(grep -ci 'pulling' "$1" || true)"; }

# ---- the run's first image build: after/, installed, then its image - before any capture, so every captured build finds ----
# ---- the image this name held (the cache the buildpacks read). Its downloads are printed here, never in a capture: they ---
# ---- depend on what this Docker held before the run --------------------------------------------------------------------------
build after .harness/build-after.log install
FIRST=$(printf '%s\n' "$C_IMAGE" | sed 's/^/  first build: /')
echo "$FIRST" | mask
ec=0; (eval "$C_IMAGE") > .harness/bp-first.log 2>&1 < /dev/null || ec=$?
[ $ec = 0 ] || { tail -30 .harness/bp-first.log >&3; die "the first image build failed"; }
echo "  first build: exit 0 · lines that say Downloading from: $(grep -c 'Downloading from' .harness/bp-first.log || true)$(grep -o 'Downloading from https\{0,1\}://[^/]*/[^ ]*' .harness/bp-first.log | sed -E 's#Downloading from https?://# · #' | tr -d '\n') · Pulling: $(grep -ci pulling .harness/bp-first.log || true)"
rootfs "$IMAGE" > .harness/rf-first.txt

# ---- change: the previous tree against after/, file by file (README aside); then both jars, on the Mac ---------------------------
# code FILE: its code lines - blank lines, and lines that are comments (Java's /**, *, /*, //; YAML's #), dropped
code() { awk '{ t = $0; sub(/^[ \t]+/, "", t) } t == "" { next } t ~ /^(\*|\/\*|\/\/|#)/ { next } { print }' "$1"; }
pm() { git diff --no-index --no-color -U0 "$1" "$2" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' || true; }   # changed lines, +/-
change() { local a b n=0 same=0 changed="" gone="" new="" f all cod
  a=$(cd .harness/before && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  b=$(cd after && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  for f in $a; do if [ -f "after/$f" ]; then n=$((n + 1)); if cmp -s ".harness/before/$f" "after/$f"; then same=$((same + 1)); else changed="$changed $f"; fi; else gone="$gone $f"; fi; done
  for f in $b; do [ -f ".harness/before/$f" ] || new="$new $f"; done
  echo "files, README aside: the previous tree $(echo "$a" | wc -l | tr -d ' ') · after/ $(echo "$b" | wc -l | tr -d ' ') · in both $n: identical $same, changed $(echo $changed | wc -w | tr -d ' ')"
  echo "  only before:${gone:- (none)}"; echo "  only after: ${new:- (none)}"
  mkdir -p .harness/code
  for f in $changed; do
    code ".harness/before/$f" > .harness/code/b; code "after/$f" > .harness/code/a
    all=$(pm ".harness/before/$f" "after/$f" | grep -c . || true); cod=$(pm .harness/code/b .harness/code/a)
    echo "$f, every changed line but comments and blanks ($(( all - $(echo "$cod" | grep -c . || true) )) of those not shown):"
    echo "${cod:-  (none)}"
    echo "  removed $(echo "$cod" | grep -c '^-' || true) · added $(echo "$cod" | grep -c '^+' || true)"; done
  echo "after/'s jar, run on the Mac:"
  startjar "cd .harness/tree && java -jar ../../after/$JAR --tiffinbox.port=18860"; up
  echo "  the log: $(msg .harness/jar.out 'TiffinBox listening')"; seven 18860
  echo "the previous tree's jar, the same way:"
  startjar "cd .harness/tree && java -jar ../before/$JAR --tiffinbox.port=18860"; up
  echo "  the log: $(msg .harness/jar.out 'TiffinBox listening')"; seven 18860; }
cap change change

# ---- build: README.md's two commands, run as the file gives them ---------------------------------------------------------------
buildcap() { local old
  runf "$C_INSTALL"; echo "  exit $ec · offline: yes (-o) · BUILD SUCCESS lines: $(grep -c 'BUILD SUCCESS' .harness/run.out || true)"
  [ $ec = 0 ] || die "build: the install failed"
  old=$(imgid); rootfs "$IMAGE" > .harness/rf-held.txt
  runf "$C_IMAGE"; echo "  exit $ec · offline: yes (-o)"; cp .harness/run.out .harness/bp-build.log
  [ $ec = 0 ] || die "build: the image build failed"
  echo "  the goals this build ran (Maven's own lines): $(grep -cE '^\[INFO\] --- ' .harness/bp-build.log || true) - $(sed -nE 's/^\[INFO\] --- ([^ ]+ \([^)]*\)) @ .*/\1/p' .harness/bp-build.log | paste -sd' ' -)"
  bplog .harness/bp-build.log
  rootfs "$IMAGE" > .harness/rf-built.txt
  echo "  RootFS layers, against the image this name held before (the run's first build, the same jar): $(lcmp .harness/rf-held.txt .harness/rf-built.txt)"
  echo "  the image ID, against that image's: equal: $([ "$old" = "$(imgid)" ] && echo yes || echo no)"; drop "$old"; }
cap build buildcap

# ---- root: the obvious command, from the root, on a copy of after/ - and what it leaves behind -----------------------------------
rootcap() { local v0 b0 i0 cs is vs nc ni nv cache temp states c i v
  rm -rf .harness/root; rsync -a --exclude target after/ .harness/root/
  v0=$(docker volume ls -q | grep '^pack-' | sort || true); b0=$(newboxes | sort); i0=$(docker images -aq --no-trunc | sort -u)
  runf "$C_ROOT"; echo "  exit $ec"
  sed -E 's/^\[INFO\] +//' .harness/run.out | grep -E "^Building image |^TiffinBox (Core|Web) \.+ " | sed -E 's/ \[ *[0-9.]+ s\]$//; s/^/  /' || true
  echo "  the error, on project $(grep -m1 -oE 'on project [a-z-]+' .harness/run.out | sed 's/on project //'): $(grep -m1 -oE 'Error packaging archive for image: [A-Za-z ]+[a-z]' .harness/run.out || echo '(none)')"
  cs=$(comm -13 <(printf '%s\n' "$b0" | grep . || true) <(newboxes | sort | grep . || true))
  is=$(for c in $cs; do docker inspect -f '{{.Image}}' "$c"; done | sort -u)
  vs=$(comm -13 <(printf '%s\n' "$v0" | grep . || true) <(docker volume ls -q | grep '^pack-' | sort || true))
  nc=$(printf '%s\n' "$cs" | grep -c . || true); ni=$(printf '%s\n' "$is" | grep -c . || true); nv=$(printf '%s\n' "$vs" | grep -c . || true)
  cache=$(printf '%s\n' "$vs" | grep -c '^pack-cache-' || true); temp=$(printf '%s\n' "$vs" | grep -cE '^pack-(app|layers)-' || true)
  states=$(for c in $cs; do docker inspect -f '{{.State.Status}}' "$c"; done | sort | uniq -c | awk '{ printf "%s%s %s", (NR > 1 ? ", " : ""), $1, $2 }')
  echo "  left behind: containers labelled author=spring-boot $nc (${states:-none}) · the images they were created from $ni, Boot's ephemeral builder, tags: $(for i in $is; do docker image inspect -f '{{len .RepoTags}}' "$i"; done | paste -sd' ' -) · new volumes named pack-: $nv - build caches $cache (pack-cache-<hash>.build and .launch), temporary $temp (pack-app-…, pack-layers-…)"
  for c in $cs; do docker rm -f "$c" > /dev/null 2>&1 || true; done
  for i in $is; do docker image rm -f "$i" > /dev/null 2>&1 || true; done
  for v in $vs; do docker volume rm -f "$v" > /dev/null 2>&1 || true; done
  echo "  removed by this script, by ID and name; left now: containers $(comm -13 <(printf '%s\n' "$b0" | grep . || true) <(newboxes | sort | grep . || true) | grep -c . || true) · images $(for i in $is; do docker image inspect "$i" > /dev/null 2>&1 && echo "$i"; done | grep -c . || true) · volumes $(comm -13 <(printf '%s\n' "$v0" | grep . || true) <(docker volume ls -q | grep '^pack-' | sort || true) | grep -c . || true)"; }
cap root rootcap

# ---- chose: what the buildpacks put into the image - its own records, its files, and what is missing -----------------------------
chosecap() {
  echo "\$ docker image inspect $IMAGE"
  docker image inspect "$IMAGE" > .harness/inspect.json
  python3 - .harness/inspect.json <<'PY'
import json, sys
i = json.load(open(sys.argv[1]))[0]; c = i["Config"]; L = c["Labels"]
print(f'  User {c["User"]} · WorkingDir {c["WorkingDir"]} · Entrypoint {json.dumps(c["Entrypoint"])} · Created {i["Created"]}')
print("  RootFS layers:", len(i["RootFS"]["Layers"]))
for k in ("org.opencontainers.image.title", "org.opencontainers.image.version", "org.springframework.boot.version"):
    print(f"  label {k} = {L[k]}")
b = json.loads(L["io.buildpacks.build.metadata"])
print("  the buildpacks that took part, the image's build record says:", len(b["buildpacks"]))
for p in b["processes"]:
    if p["type"] == b.get("buildpack-default-process-type", "web"):
        print(f'  its default process, {p["type"]}: {" ".join(p["command"] + p["args"])} · direct: {str(p["direct"]).lower()}')
m = json.loads(L["io.buildpacks.lifecycle.metadata"])
for bp in m["buildpacks"]:
    for name, layer in bp.get("layers", {}).items():
        d = (layer.get("data") or {}); dep = d.get("dependency", d if "uri" in d else None)
        if dep and "uri" in dep:
            host, f = dep["uri"].split("://", 1)[1].split("/", 1)[0], dep["uri"].rsplit("/", 1)[1]
            print(f'  the {name} layer\'s record, {bp["key"]}: {dep["name"]} {dep["version"]} · downloaded from host {host} · file {f}')
print("  the run image under it, its record says:", m["runImage"]["image"])
PY
  runf "unzip -p after/$JAR META-INF/MANIFEST.MF | grep Build-Jdk-Spec"; tr -d '\r' < .harness/run.out | sed 's/^/  /'
  rm -rf .harness/peek .harness/jarlib; mkdir -p .harness/peek
  runf "docker create --name tiffinbox-web-peek $IMAGE > /dev/null && docker cp -q tiffinbox-web-peek:/workspace .harness/peek && docker cp -q tiffinbox-web-peek:/layers/paketo-buildpacks_spring-boot/web-application-type/env.launch .harness/peek && docker cp -q tiffinbox-web-peek:/layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d .harness/peek && docker rm tiffinbox-web-peek > /dev/null"
  echo "  exit $ec"
  echo "  /workspace: $(ls .harness/peek/workspace | paste -sd' ' -) - the jar's own folders, unpacked"
  echo "  /workspace/BOOT-INF/lib/: $(ls -A .harness/peek/workspace/BOOT-INF/lib | wc -l | tr -d ' ') entries · files $(find .harness/peek/workspace/BOOT-INF/lib -type f | wc -l | tr -d ' ') · symbolic links $(find .harness/peek/workspace/BOOT-INF/lib -type l | wc -l | tr -d ' ')"
  find .harness/peek/workspace/BOOT-INF/lib -type l | while read -r l; do echo "  $(basename "$l") -> $(readlink "$l")"; done
  mkdir -p .harness/jarlib; (cd .harness/jarlib && unzip -q "../../after/$JAR" 'BOOT-INF/lib/*')
  echo "  its $(find .harness/peek/workspace/BOOT-INF/lib -type f | wc -l | tr -d ' ') files, against the jar's own BOOT-INF/lib/ ($(ls .harness/jarlib/BOOT-INF/lib | wc -l | tr -d ' ') jars): the same name and bytes $(find .harness/peek/workspace/BOOT-INF/lib -type f | while read -r f; do cmp -s "$f" ".harness/jarlib/BOOT-INF/lib/$(basename "$f")" && echo same; done | grep -c same || true)"
  echo "  the thread count one layer sets (paketo-buildpacks_spring-boot/web-application-type/env.launch/): $(cd .harness/peek/env.launch && for f in *; do printf '%s = %s' "$f" "$(cat "$f")"; done)"
  echo "  the helpers the bellsoft-liberica buildpack's layer runs before Java (helper/exec.d/): $(ls .harness/peek/exec.d | wc -l | tr -d ' ') · memory-calculator among them: $(ls .harness/peek/exec.d | grep -cx memory-calculator | sed 's/^1$/yes/; s/^0$/no/')"
  runf "docker run --rm --name tiffinbox-web-shell --entrypoint sh $IMAGE -c true"
  echo "  exit $ec · $(grep -o 'exec: "sh": [a-z ]*\$PATH' .harness/run.err || echo '(no exec line)')"
  echo "the run image under it, on its own - where the user and the missing shell come from:"
  echo "\$ docker image inspect -f '{{.Config.User}}' \$RUNIMAGE"; echo "  $(docker image inspect -f '{{.Config.User}}' "$RUNIMAGE")"
  runf "docker run --rm --name tiffinbox-web-shell --entrypoint sh \$RUNIMAGE -c true"
  echo "  exit $ec · $(grep -o 'exec: "sh": [a-z ]*\$PATH' .harness/run.err || echo '(no exec line)')"
  echo "\$ docker history --human=false $IMAGE     (the app's slices and the bill of materials: each one's size and name)"
  docker history --human=false --format '{{.Size}}	{{.CreatedBy}}' "$IMAGE" | awk -F'\t' '$2 ~ /^Application Slice: / || $2 == "Software Bill-of-Materials" { printf "    %-9s %s\n", $1, $2 }'; }
cap chose chosecap

# ---- required: the image run with no token at all ----------------------------------------------------------------------------
requiredcap() {
  runf "$C_REQ"
  echo "  exit $ec · $(warns .harness/run.out) · lines that say TiffinBox listening: $(grep -c 'TiffinBox listening' .harness/run.out || true)"
  grep -m1 'Calculated JVM Memory Configuration' .harness/run.out | sed 's/^/  /' || true
  grep -m1 -A2 'Property: tiffinbox' .harness/run.out | sed -E 's/^ +/  /' || true
  echo "  lines that name the available memory of the machine: $(grep -c 'Calculating JVM memory based on' .harness/run.out || true)"; }
cap required requiredcap

# ---- address: the break - A, B, C, A' ----------------------------------------------------------------------------------------
# drun 'COMMAND': a docker run -d line, printed exactly as typed, run; its container ID (standard output) is not printed
drun() { echo "\$ $1"; ec=0; (eval "$1") > .harness/run.out 2> .harness/run.err < /dev/null || ec=$?
  [ $ec = 0 ] || { cat .harness/run.err >&3; die "docker run failed: exit $ec"; }; }
# waitlog NAME: poll the container's log until TiffinBox says it listens, or the container stops; 30 s at most
waitlog() { local i=0; while [ $i -lt 120 ]; do docker logs "$1" > .harness/c.log 2>&1 || true; grep -q 'TiffinBox listening' .harness/c.log && break
  [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" = true ] || break; sleep 0.25; i=$((i + 1)); done
  echo "  the log: $(msg .harness/c.log 'TiffinBox listening')"
  echo "  the address in that line: $(msg .harness/c.log 'TiffinBox listening' | sed -E 's#^.*https?://##')"; }
# dseven PORT NAME: the seven requests against the published port; then the container's own exit (docker wait), removed
dseven() { local e tf=.harness/tree/$TF
  echo "\$ \$CURLSET $1 $tf"
  "$CURLSET" "$1" "$tf" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt || echo "(no POST line)"
  echo "  the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  echo "\$ docker wait $2"; e=$(docker wait "$2" 2> /dev/null || echo none); echo "  $e"
  echo "\$ docker rm $2"; docker rm "$2" > /dev/null; echo "  listeners on $1 now: $(listeners "$1")"; }
# dnone PORT NAME: one request, which the container cannot answer; then docker stop, its exit code, removed
dnone() { local e=0
  echo "\$ curl -sS http://127.0.0.1:$1/kitchen"; curl -sS "http://127.0.0.1:$1/kitchen" > .harness/curl.out 2> .harness/curl.err || e=$?
  echo "  exit $e · $(head -1 .harness/curl.err)$(head -c 200 .harness/curl.out)"
  echo "\$ docker stop $2"; docker stop "$2" > /dev/null; echo "  the container's exit code: $(docker inspect -f '{{.State.ExitCode}}' "$2")"
  echo "\$ docker rm $2"; docker rm "$2" > /dev/null; echo "  listeners on $1 now: $(listeners "$1")"; }
addresscap() {
  echo "A   the address set: TIFFINBOX_ADDRESS=0.0.0.0 - the anchor's new key, tiffinbox.address"
  drun "$C_A"; waitlog tiffinbox-web-address; dseven 18861 tiffinbox-web-address
  echo "B   no address: application.yaml's default, 127.0.0.1"
  drun "$C_B"; waitlog tiffinbox-web-address; dnone 18861 tiffinbox-web-address
  echo "C   Boot's own key instead: SERVER_ADDRESS=0.0.0.0, server.address"
  drun "$C_C"; waitlog tiffinbox-web-address; dnone 18861 tiffinbox-web-address
  echo "A′  A re-run"
  drun "$C_A"; waitlog tiffinbox-web-address; dseven 18861 tiffinbox-web-address
  echo "the config tree mounted in all four: $TF, $(stat -f '%Sp' ".harness/tree/$TF"), this script's user's · the four commands that run as that user (--user): $(printf '%s\n' "$C_A" "$C_B" "$C_C" "$C_A" | grep -cF -- "$U_FLAG") · the image's own user: $(docker image inspect -f '{{.Config.User}}' "$IMAGE")"; }
cap address addresscap

# ---- user: whose user can read the token - in a Docker volume, files keep their owner and mode, as on Linux ----------------------
usercap() { local own n i
  echo "the token's config tree, copied into a Docker volume - storage the daemon keeps itself: its files keep their owner and"
  echo "  mode, as on Linux, with no file sharing in between (the builder image, already here, copies them, as root):"
  runf "$C_FILL"
  own="$(id -u):$(id -g)"; n=$(grep -c . .harness/run.out || true)
  echo "  exit $ec · entries $n: owned by this script's user and group $(grep -c "^$own " .harness/run.out || true) of $n · their modes: $(awk '{ print $2 }' .harness/run.out | paste -sd' ' -)"
  echo "A   the volume, run as your own user: --user \"\$(id -u):\$(id -g)\""
  drun "$C_V"; waitlog tiffinbox-web-volume; dseven 18862 tiffinbox-web-volume
  echo "B   the volume, run as the image's own user, 1002:1001 - no --user"
  drun "$C_VB"; i=0
  while [ $i -lt 120 ] && [ "$(docker inspect -f '{{.State.Running}}' tiffinbox-web-volume 2> /dev/null)" = true ]; do sleep 0.25; i=$((i + 1)); done
  docker logs tiffinbox-web-volume > .harness/c.log 2>&1 || true
  if [ "$(docker inspect -f '{{.State.Running}}' tiffinbox-web-volume 2> /dev/null)" = true ]; then
    docker rm -f tiffinbox-web-volume > /dev/null; echo "  still running after 30 s - removed"
  else echo "\$ docker wait tiffinbox-web-volume"; echo "  $(docker wait tiffinbox-web-volume 2> /dev/null || echo none)"
    sed $'s/\x1b\\[[0-9;]*m//g' .harness/c.log > .harness/c.txt
    echo "  its log: $(grep -c . .harness/c.txt || true) lines · lines that say TiffinBox listening: $(grep -c 'TiffinBox listening' .harness/c.txt || true) · Boot's banner lines: $(grep -c ':: Spring Boot ::' .harness/c.txt || true) · the lines that name a cause, whole, sorted (the launcher's two streams interleave in no fixed order):"
    grep -E 'permission denied|failed to launch|Caused by: ' .harness/c.txt | LC_ALL=C sort | sed 's/^/  /' || echo "  (none)"
    echo "\$ docker rm tiffinbox-web-volume"; docker rm tiffinbox-web-volume > /dev/null; fi
  echo "  listeners on 18862 now: $(listeners 18862)"
  echo "A′  A re-run"
  drun "$C_V"; waitlog tiffinbox-web-volume; dseven 18862 tiffinbox-web-volume
  echo "C   the folder on the Mac, mounted, run as the image's own user - no --user (OrbStack's file sharing, on this Mac)"
  drun "$C_VC"; waitlog tiffinbox-web-volume; dseven 18862 tiffinbox-web-volume
  runf "docker volume rm $VOL > /dev/null"; echo "  exit $ec"; }
cap user usercap

# ---- rebuild: one word changed, the same image name ----------------------------------------------------------------------------
rebuildcap() { local old
  echo "at/ = after/ with one word changed: TiffinBoxServer's listening line says at where it says on"
  old=$(imgid); runq "$C_IMAGE"; [ $ec = 0 ] || die "rebuild: after/'s image failed"; drop "$old"
  rootfs "$IMAGE" > .harness/rf-start.txt
  echo "  the starting point, every run: after/'s image under $IMAGE, built again first (exit $ec) - its RootFS layers against the run's first build: $(lcmp .harness/rf-first.txt .harness/rf-start.txt)"
  runf "$C_AT_INSTALL"; echo "  exit $ec · offline: yes (-o) · BUILD SUCCESS lines: $(grep -c 'BUILD SUCCESS' .harness/run.out || true)"
  [ $ec = 0 ] || die "rebuild: at/'s install failed"
  old=$(imgid)
  runf "$C_AT_IMAGE"; echo "  exit $ec · offline: yes (-o)"; cp .harness/run.out .harness/bp-at.log
  [ $ec = 0 ] || die "rebuild: at/'s image failed"
  bplog .harness/bp-at.log
  rootfs "$IMAGE" > .harness/rf-at.txt
  echo "  RootFS layers, against after/'s image: $(lcmp .harness/rf-start.txt .harness/rf-at.txt) · the different one, counted from the base up: $(paste -d' ' .harness/rf-start.txt .harness/rf-at.txt | awk '$1 != $2 { printf "%s%d", (n++ ? " " : ""), NR }') of $(wc -l < .harness/rf-at.txt | tr -d ' ')"
  echo "  the image the name held before, now without a tag: $(docker image inspect -f '{{len .RepoTags}}' "$old" 2> /dev/null | sed 's/^0$/yes/') - removed by its recorded ID"
  drop "$old"; echo "  still there afterwards: $(docker image inspect "$old" > /dev/null 2>&1 && echo yes || echo no)"; }
cap rebuild rebuildcap
# searched IMG: the token in every layer of IMG - the run image's included - and in its config: the image saved (docker
# save), each layer unpacked (gzip or plain tar) and searched; a blob already searched is not searched twice
NL=0; NC=0; TL=0; NI=0
searched() { local kind p f c
  rm -rf .harness/saved; mkdir -p .harness/saved; docker save -o .harness/saved/img.tar "$1"; (cd .harness/saved && tar -xf img.tar)
  python3 -c 'import json
for m in json.load(open(".harness/saved/manifest.json")):
    print("config " + m["Config"])
    for p in m["Layers"]: print("layer " + p)' > .harness/blobs.txt
  while read -r kind p; do f=".harness/saved/$p"; [ -f "$f" ] || die "$p is missing from the saved image"
    grep -qxF "$kind $p" .harness/blobs.done 2> /dev/null && continue; echo "$kind $p" >> .harness/blobs.done
    if [ "$kind" = layer ]; then
      if [ "$(head -c 2 "$f" | od -An -tx1 | tr -d ' \n')" = 1f8b ]; then c=$(gzip -dc "$f" | grep -aoF -- "$TOKEN" | wc -l | tr -d ' '); else c=$(grep -aoF -- "$TOKEN" "$f" | wc -l | tr -d ' '); fi
      NL=$((NL + 1))
    else c=$(grep -aoF -- "$TOKEN" "$f" | wc -l | tr -d ' '); NC=$((NC + 1)); fi
    TL=$((TL + c)); done < .harness/blobs.txt
  NI=$((NI + 1)); rm -rf .harness/saved; }
# the image at/ made, searched now: the exercise builds after/'s again into the name
searched "$IMAGE"

# ---- exercise: exercise/README.md's commands, then the measured answer's, read from the files and run as written ------------------
block1() { awk '/^```bash$/ { f++; next } /^```$/ { if (f == 1) exit } f == 1 && !/^export / { print }' "$1"; }
EXL=$(block1 exercise/README.md); SOL=$(block1 exercise/solution/SOLUTION.md)
[ "$(printf '%s\n' "$EXL" | grep -c .)" -ge 8 ] || die "exercise/README.md no longer gives its commands in its first bash block"
[ "$(printf '%s\n' "$SOL" | grep -c .)" -ge 4 ] || die "exercise/solution/SOLUTION.md no longer gives its commands in its first bash block"
MINE=.harness/mine/$TF
# mine: the exercise's own token (random, 32 hexadecimal characters) becomes a label naming its length (gsub)
mine() { awk -v t="$(head -n 1 "$MINE" 2> /dev/null || echo 'no token yet')" '{ gsub(t, "[masked: the " length(t) "-character token]"); print }'; }
lines() { local l old
  while IFS= read -r l; do [ -n "$l" ] || continue
    old=$(imgid); runf "$l"; echo "  exit $ec"
    { cat .harness/run.out; grep -v '^$' .harness/run.err | sed 's/^/stderr: /' || true; } | mine | sed 's/^/  /'
    case "$l" in *spring-boot:build-image*) drop "$old" ;; esac; done <<< "$1"; }
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

# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does
# anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 after/README.md; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/' "$f" || die "$f holds an absolute path"; done
# ... nor the exercise's last random token, in any capture
[ "$(raw "$(head -n 1 "$MINE")" .r-*.out)" = 0 ] || die "a capture holds the exercise's token, raw"
# ... nor any layer of either image this script tagged (each searched right after its capture, above)
[ "$TL" = 0 ] || die "the demo token is in an image layer or config: $TL copies"
[ "$NI" = 2 ] && [ "$NL" -gt 0 ] && [ "$NC" = 2 ] || die "the two images were not both searched ($NI images, $NL layers, $NC configs)"
# LOOPBACK ONLY (brief S3.10): a docker run/create line that publishes a port must publish it on 127.0.0.1 (in a pattern of
# this script's, written 127\.0\.0\.1)
DL=$(cat receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md after/README.md | grep -E 'docker (container )?(run|create)' || true)
[ "$(printf '%s\n' "$DL" | grep -E -- ' (-p|--publish)[ =]' | grep -cvE -- ' (-p|--publish)[ =]127(\\)?\.0(\\)?\.0(\\)?\.1:' || true)" = 0 ] || die "a docker run/create line publishes a port off loopback"
echo "  ports: docker run/create lines in receipts.sh, the READMEs and the solution: $(printf '%s\n' "$DL" | grep -c . || true) · publishing a port: $(printf '%s\n' "$DL" | grep -cE -- ' (-p|--publish)[ =]' || true), every one on 127.0.0.1"
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the exercise and its solution, and receipts.md5 - and in the $NI images' $NL distinct layers (every one, unpacked) and $NC configs; the exercise's own token: 0 raw copies in the captures; no absolute path in any capture"

# "one property, in the record ... the server binds it, the log prints it ... application.yaml: 127.0.0.1 ... on the Mac,
# nothing changes: the same line, the same seven responses"
x change '^files, README aside: the previous tree 18 · after/ 18 · in both 18: identical 15, changed 3$'
CP=$(blk change 'tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java, every changed line' 'tiffinbox-web/')
printf '%s\n' "$CP" | grep -qF '+                                  @NotNull @Min(1) Integer port, @NotBlank String address,' || die "change: the record gains @NotBlank String address"
CS=$(blk change 'tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java, every changed line' 'tiffinbox-web/src/main/resources')
has1 "$CS" '+        server = HttpServer.create(new InetSocketAddress(address, port), 0);' change
has1 "$CS" '-        server = HttpServer.create(new InetSocketAddress("127.0.0.1", port), 0);' change
has1 "$CS" '+        LOG.log(INFO, "TiffinBox listening on http://" + address + ":" + port);' change
CY=$(blk change 'tiffinbox-web/src/main/resources/application.yaml, every changed line' 'after/')
has1 "$CY" '+  address: 127.0.0.1' change
has1 "$CY" '  removed 0 · added 1' change
[ "$(grep -c '^  the log: TiffinBox listening on http://127\.0\.0\.1:18860$' .r-change.out)" = 2 ] || die "change: both jars print the same listening line"
[ "$(grep -c "^  exit 0 · the seven responses: 7 lines · md5 $S115\$" .r-change.out)" = 2 ] || die "change: both jars serve the seven responses"
echo "  change: 3 files (the record +address @NotBlank, the server binds and logs it, application.yaml 127.0.0.1) · on the Mac: the same line, $S115 twice"

# "two steps: install from the root, then only the web module's image ... six of twenty-six buildpacks ... twenty-one, then
# twenty-five, extracted from the manifest ... the JRE: reused ... four slices from the layer index ... the jar launcher ...
# nothing downloaded, nothing pulled ... every layer the same"
BB=$(blk build '$ mvn -o -B -f after/pom.xml -Dmaven.repo.local="$M2" -pl tiffinbox-web' '')
has1 "$BB" "  [creator]     6 of 26 buildpacks participating" build
[ "$(printf '%s\n' "$BB" | grep -cE '^  \[creator\]     paketo-buildpacks/[a-z-]+ +[0-9.]+$')" = 6 ] || die "build: six buildpacks listed"
printf '%s\n' "$BB" | grep -qE '^  \[creator\]         \$BP_JVM_VERSION +21 +the Java version$' || die "build: BP_JVM_VERSION's default 21"
has1 "$BB" "  [creator]         Using Java version 25 extracted from MANIFEST.MF" build
has1 "$BB" "  [creator]       BellSoft Liberica JRE 25.0.4: Reusing cached layer" build
printf '%s\n' "$BB" | grep -qE '^  \[creator\]         web: +java org\.springframework\.boot\.loader\.launch\.JarLauncher \(direct\)$' || die "build: the web process, the jar launcher"
[ "$(printf '%s\n' "$BB" | grep -cE '^  \[creator\]         (dependencies|spring-boot-loader|snapshot-dependencies|application) \(')" = 4 ] || die "build: four slices"
printf '%s\n' "$BB" | grep -qE '^  \[creator\]         \$BPL_JVM_THREAD_COUNT +250 ' || die "build: the thread count's default 250"
has1 "$BB" "  [creator]     Reused 5/5 app layer(s)" build
printf '%s\n' "$BB" | grep -qE '^  log lines [0-9]+ · shown [0-9]+ · not shown [0-9]+ · lines that say Downloading from: 0 · lines that say Pulling: 0$' || die "build: no download, no pull"
has1 "$BB" "  RootFS layers, against the image this name held before (the run's first build, the same jar): 20 and 20 · the same 20 · different 0" build
has1 "$BB" "  the image ID, against that image's: equal: yes" build
has1 "$BB" "  the goals this build ran (Maven's own lines): 1 - spring-boot:4.1.1:build-image-no-fork (default-cli)" build
x build "^  Building image 'docker\.io/library/tiffinbox-web:1\.0\.0'\$"
echo "  build: 6 of 26 · BP_JVM_VERSION 21, then Java 25 from MANIFEST.MF · Liberica JRE 25.0.4 reused · 4 slices · JarLauncher · 0 downloads, 0 pulls · 20 of 20 layers the same"

# "from the root, it fails: tiffinbox-core, no main class ... a container, four volumes and an image, left behind"
x root '^  exit 1$'
x root "^  Building image 'docker\.io/library/tiffinbox-core:1\.0\.0'\$"
x root '^  TiffinBox Core \.+ FAILURE$'
x root '^  TiffinBox Web \.+ SKIPPED$'
x root '^  the error, on project tiffinbox-core: Error packaging archive for image: Unable to find main class$'
x root '^  left behind: containers labelled author=spring-boot 1 \(1 created\) · the images they were created from 1, Boot.s ephemeral builder, tags: 0 · new volumes named pack-: 4 - build caches 2 \(pack-cache-<hash>\.build and \.launch\), temporary 2 \(pack-app-…, pack-layers-…\)$'
x root '^  removed by this script, by ID and name; left now: containers 0 · images 0 · volumes 0$'
echo "  root: exit 1 on tiffinbox-core (Unable to find main class), web skipped · left 1 container, 1 image, 4 volumes - removed, 0 left"

# "it runs as user ten-oh-two ... the folder is /workspace ... January 1980 ... a thirty-second jar, a link ... fifty threads
# ... the JRE came from GitHub ... the manifest says twenty-five ... no shell"
x chose '^  User 1002:1001 · WorkingDir /workspace · Entrypoint \["/cnb/process/web"\] · Created 1980-01-01T00:00:01Z$'
x chose '^  RootFS layers: 20$'
x chose '^  label org\.springframework\.boot\.version = 4\.1\.1$'
x chose '^  the buildpacks that took part, the image.s build record says: 6$'
x chose '^  its default process, web: java org\.springframework\.boot\.loader\.launch\.JarLauncher · direct: true$'
x chose "^  the jre layer's record, paketo-buildpacks/bellsoft-liberica: BellSoft Liberica JRE 25\.0\.4 · downloaded from host github\.com · file bellsoft-jre25\.0\.4\+9-linux-aarch64\.tar\.gz\$"
x chose '^  the run image under it, its record says: docker\.io/paketobuildpacks/ubuntu-noble-run-tiny:0\.0\.138$'
x chose '^  Build-Jdk-Spec: 25$'
x chose '^  /workspace/BOOT-INF/lib/: 32 entries · files 31 · symbolic links 1$'
x chose '^  spring-cloud-bindings-2\.0\.4\.jar -> /layers/paketo-buildpacks_spring-boot/spring-cloud-bindings/spring-cloud-bindings-2\.0\.4\.jar$'
x chose "^  its 31 files, against the jar's own BOOT-INF/lib/ \(31 jars\): the same name and bytes 31\$"
x chose '^  the thread count one layer sets \(paketo-buildpacks_spring-boot/web-application-type/env\.launch/\): BPL_JVM_THREAD_COUNT\.default = 50$'
x chose "^  the helpers the bellsoft-liberica buildpack's layer runs before Java \(helper/exec\.d/\): [0-9]+ · memory-calculator among them: yes\$"
[ "$(grep -c '^  exit 127 · exec: "sh": executable file not found in \$PATH$' .r-chose.out)" = 2 ] || die "chose: no sh in the image, nor in its run image"
CR=$(blk chose 'the run image under it, on its own' '')
has1 "$CR" '  1002:1001' chose
printf '%s\n' "$CR" | grep -qE '^    0 +Application Slice: 5$' || die "chose: the fifth app layer is empty"
printf '%s\n' "$CR" | grep -qE '^    0 +Application Slice: 3$' || die "chose: the snapshot slice is empty"
[ "$(printf '%s\n' "$CR" | grep -cE '^    [0-9]+ +Application Slice: [1-5]$')" = 5 ] || die "chose: five app layers"
printf '%s\n' "$CR" | grep -qE '^    [1-9][0-9]* +Software Bill-of-Materials$' || die "chose: a bill of materials, a layer of its own"
echo "  chose: 1002:1001, /workspace, 1980 · 6 buildpacks · JarLauncher · Liberica JRE 25.0.4 from github.com · Build-Jdk-Spec 25 · 32 = 31 + 1 link · 50 threads · no sh (127)"

# "with no token: the memory calculator first - one gigabyte, fifty threads - then must not be blank"
x required '^  exit 1 · WARN lines 1 · ERROR lines 1 · lines that say TiffinBox listening: 0$'
x required '^  Calculated JVM Memory Configuration: .*\(Total Memory: 1G, Thread Count: 50, Loaded Class Count: [0-9]+, Headroom: 0%\)$'
x required '^  Property: tiffinbox\.shutdownToken$'
x required '^  Value: "null"$'
x required '^  Reason: must not be blank$'
x required '^  lines that name the available memory of the machine: 0$'
echo "  required: exit 1 · Total Memory 1G, Thread Count 50 · shutdownToken null, must not be blank · 0 lines with the VM's memory"

# "A: listening on 0.0.0.0, the seven responses, exit zero ... B: listening on 127.0.0.1, an empty reply ... C: Boot's
# key, the same empty reply ... A again"
AA=$(blk address 'A   ' 'B   '); AB=$(blk address 'B   ' 'C   '); AC=$(blk address 'C   ' 'A′  '); AA2=$(blk address 'A′  ' 'the config tree')
has1 "$AA" '  the log: TiffinBox listening on http://0.0.0.0:18425' address
has1 "$AA" '  the address in that line: 0.0.0.0:18425' address
has1 "$AA" "  the seven responses: 7 lines · md5 $S115" address
has1 "$AA" '  0' address
has1 "$AB" '  the log: TiffinBox listening on http://127.0.0.1:18425' address
has1 "$AB" '  the address in that line: 127.0.0.1:18425' address
has1 "$AB" '  exit 52 · curl: (52) Empty reply from server' address
has1 "$AB" "  the container's exit code: 143" address
has1 "$AC" '  the log: TiffinBox listening on http://127.0.0.1:18425' address
has1 "$AC" '  the address in that line: 127.0.0.1:18425' address
has1 "$AC" '  exit 52 · curl: (52) Empty reply from server' address
[ "$AA" = "$AA2" ] || die "address: A' is not A, line for line"
[ "$(grep -c '^  listeners on 18861 now: 0$' .r-address.out)" = 4 ] || die "address: the port free after every run"
x address '^the config tree mounted in all four: secrets/tiffinbox/shutdown-token, -rw-------, this script.s user.s · the four commands that run as that user \(--user\): 4 · the image.s own user: 1002:1001$'
echo "  address: A 0.0.0.0 -> $S115, exit 0 · B 127.0.0.1 -> curl 52, stop 143 · C SERVER_ADDRESS -> 127.0.0.1, curl 52 · A' = A · all four --user"

# "on Linux, a mount keeps the file's owner: only you can read it" - measured in a Docker volume, which keeps owners and modes:
# your user reads it (A, A'), the image's own user cannot (B); the folder from the Mac, OrbStack's file sharing, lets it (C)
UA=$(blk user 'A   ' 'B   '); UB=$(blk user 'B   ' 'A′  '); UA2=$(blk user 'A′  ' 'C   '); UC=$(blk user 'C   ' '')
x user '^  exit 0 · entries 3: owned by this script.s user and group 3 of 3 · their modes: drwx------ drwx------ -rw-------$'
has1 "$UA" '  the address in that line: 0.0.0.0:18425' user; has1 "$UA" "  the seven responses: 7 lines · md5 $S115" user; has1 "$UA" '  0' user
has1 "$UB" '  82' user
has1 "$UB" "  its log: 4 lines · lines that say TiffinBox listening: 0 · Boot's banner lines: 0 · the lines that name a cause, whole, sorted (the launcher's two streams interleave in no fixed order):" user
has1 "$UB" '  open /workspace/secrets: permission denied' user
has1 "$UB" "  ERROR: failed to launch: exec.d: failed to execute exec.d file at path '/layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d/memory-calculator': exit status 1" user
[ "$UA" = "$UA2" ] || die "user: A' is not A, line for line"
has1 "$UC" '  the address in that line: 0.0.0.0:18425' user; has1 "$UC" "  the seven responses: 7 lines · md5 $S115" user
[ "$(grep -c '^  listeners on 18862 now: 0$' .r-user.out)" = 4 ] || die "user: the port free after every run"
echo "  user: the volume (owner and mode kept) - A --user -> $S115 · B the image's user 1002:1001 -> exit 82 before Java: the memory calculator cannot open /workspace/secrets · A' = A · C the Mac's folder, no --user -> $S115 (OrbStack)"

# "one word changed, the same name: nothing downloaded, the JRE reused, four of five app layers reused, one added"
RB=$(blk rebuild '$ mvn -o -B -f .harness/at/pom.xml -Dmaven.repo.local="$M2" -pl tiffinbox-web' '')
has1 "$RB" "  [creator]       BellSoft Liberica JRE 25.0.4: Reusing cached layer" rebuild
has1 "$RB" "  [creator]     Reused 4/5 app layer(s)" rebuild
has1 "$RB" "  [creator]     Added 1/5 app layer(s)" rebuild
has1 "$RB" "  [creator]         Non-web application detected" rebuild
printf '%s\n' "$RB" | grep -qE '^  log lines [0-9]+ · shown [0-9]+ · not shown [0-9]+ · lines that say Downloading from: 0 · lines that say Pulling: 0$' || die "rebuild: no download, no pull"
has1 "$RB" "  RootFS layers, against after/'s image: 20 and 20 · the same 19 · different 1 · the different one, counted from the base up: 16 of 20" rebuild
has1 "$RB" "  the image the name held before, now without a tag: yes - removed by its recorded ID" rebuild
has1 "$RB" "  still there afterwards: no" rebuild
x rebuild "^  the starting point, every run: after/'s image under tiffinbox-web:1\.0\.0, built again first \(exit 0\) - its RootFS layers against the run's first build: 20 and 20 · the same 20 · different 0\$"
echo "  rebuild: 0 downloads, 0 pulls · JRE reused · Reused 4/5, Added 1/5 · 19 of 20 RootFS layers the same · the old image removed by ID"

# the exercise's end state: the folder way - 0 lines in the environment; the variable way - 1, masked
EX1=$(blk exercise "exercise/README.md's commands" 'the measured answer'); EX2=$(blk exercise 'the measured answer' '')
# nextout BLOCK TEXT: the output lines of the first command in BLOCK whose "$ " line holds TEXT (its exit line skipped)
nextout() { printf '%s\n' "$1" | awk -v p="$2" 'f == 1 && /^\$ / { exit } f == 1 && !/^  exit [0-9]+$/ { print } f == 0 && index($0, "$ ") == 1 && index($0, p) { f = 1 }'; }
[ "$(nextout "$EX1" "docker inspect -f")" = '  TIFFINBOX_ADDRESS=0.0.0.0' ] || die "exercise: with the folder, docker inspect finds the address alone"
printf '%s\n' "$EX1" | grep -qxF '  {"stopping":true} 200' || die "exercise: POST /shutdown with the folder's token"
[ "$(nextout "$EX2" "docker inspect -f")" = "$(printf '  TIFFINBOX_ADDRESS=0.0.0.0\n  TIFFINBOX_SHUTDOWN_TOKEN=[masked: the 32-character token]')" ] || die "exercise: with the variable, docker inspect lists the token, masked"
printf '%s\n' "$EX2" | grep -qxF '  {"stopping":true} 200' || die "exercise: POST /shutdown with the variable's token"
echo "  exercise: folder -> docker inspect lists TIFFINBOX_ADDRESS alone · variable -> and TIFFINBOX_SHUTDOWN_TOKEN=[masked: the 32-character token] · 200 both ways"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit15: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and image layer"
