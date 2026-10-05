#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · Layered Jars and Image Caching — this unit's receipts. Boot's jar already carries an index that sorts it into
# four layers. This unit counts them, changes one line and hashes each layer, finds the layer that moves with NO change (the
# build's clock inside tiffinbox-core's jar), and fixes that with one property in the root POM, project.build.outputTimestamp
# (the anchor change: Course 3's reproducible-build exercise, landed). Then Docker: three Dockerfiles in docker/, the bytes a
# one-word change makes new in a layered image and in a single-jar image (Boot's jar, whole, in one COPY), the clock for both
# rebuilds, two image IDs that differ with no layer changed, and a cache that hands the image yesterday's class. Nine captures, each run three times and hashed;
# cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that can
# fail; the demo token is masked (gsub), and the last checks count 0 raw copies in every capture, every README, and every
# layer of every image this script built.
#   layers   after/'s jar: BOOT-INF/layers.idx, counted; list-layers; extract --layers --launcher, each layer counted (files,
#            bytes); the tool's old name, layertools
#   change   the previous tree against after/, file by file: every changed code line; the same line in Course 3's POM
#   moved    each jar unpacked into its layers, every layer folder hashed - A/B, the flipped attribute the fixed time: one word
#            changed and no change, each built without it (the previous tree, before-at/) and with it (after/, at/), and
#            tiffinbox-core's entries compared; then after/ built in two time zones, its entries compared
#   bytes    the layered image (docker/Dockerfile) and the single-jar image (docker/single.Dockerfile), each built for after/'s
#            jar and at/'s: RootFS layers compared, docker history's sizes, the two saved together (docker save); then the
#            layered one rebuilt with no change: layers and IDs compared - and C, the same twice with --provenance=false
#   stale    the break: A docker/Dockerfile (extract inside the build) · B docker/folders.Dockerfile (extracted on the Mac,
#            copied as folders) · C B again with --no-cache · D B again with the thin jar's file time set to now · A' = A;
#            each image's class read by ./peek.sh (the image's own files, never run). D counts only the COPY steps of the three
#            layers the change leaves alone: whether its new application folder comes from the cache depends on whether any
#            earlier build - of any run, on this Docker - already copied that content
#   timing   six rounds, each a fresh one-line change, both images rebuilt and timed - counted against five seconds, the two
#            images' medians compared, and the steps each rebuild ran counted; the Spring Framework course's folders, searched
#            for a Dockerfile
#   serve    /app copied out of the layered image (created, never started) and run on the Mac with the image's own command:
#            the seven responses
#   exercise exercise/README.md's commands, read from the file and run as written: install, one line of tiffinbox-core
#            changed, only the web module packaged - which layer tiffinbox-core lands in, and whether the change is in it
#   files    every demo file against the file it stands in for (diff), and ./peek.sh whole
# "before" is ../c5-unit13/after (the anchor as the last unit to change it left it), COPIED to .harness/before; this script
# never writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change, built in
# place, clean, twice (the first build's jars kept under .harness/); at/ is a copy of after/ with one word of TiffinBoxServer
# changed. Every Docker build context is a folder under .harness/ holding the jar alone (or extracted/ alone): no secrets/.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson
# (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file).
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]", this
# folder's absolute path "…", the folder above it "…/..", and the home folder "~", in every line of every capture (gsub).
# Docker's build logs are kept in .harness/ and read, never printed: the build context's transfer size, the COPY steps marked
# CACHED, warnings and layer downloads are counted from them. No image ID, container ID or digest of a layer this script built
# is printed - layers and IDs are compared, and the comparison is printed. Maven's logs are read, never printed whole.
# Durations move from run to run, so no capture holds one: the timing capture counts them against five seconds and compares
# the two images' medians; the seconds themselves are printed on the terminal only.
# Ports (brief ⚑10, 18850-18859): serve 18850 - the only one bound. 18425 is checked free too (the old default port).
# Docker names (no unit number): images tiffinbox-layers:<variant> (TAGS below; single-* is the single-jar image, Boot's jar
# copied whole), containers tiffinbox-layers-peek and
# tiffinbox-layers-copy (created, never started). The exit trap removes exactly those names; BuildKit's cache is left (no
# selective prune exists, and a global prune would touch other people's cache).
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement,
# on by default): startjar's "&& exec java" became "&& java && java  exec java" and java printed its usage. Switched off,
# so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no such option.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
TAGS="tiffinbox-layers:recipe-on tiffinbox-layers:recipe-at tiffinbox-layers:recipe-again tiffinbox-layers:recipe-np1
 tiffinbox-layers:recipe-np2 tiffinbox-layers:single-on tiffinbox-layers:single-at tiffinbox-layers:folders-on
 tiffinbox-layers:folders-at tiffinbox-layers:folders-nocache tiffinbox-layers:folders-touched tiffinbox-layers:tick-recipe
 tiffinbox-layers:tick-single"
BOXES="tiffinbox-layers-peek tiffinbox-layers-copy"
# On every exit - the end, a failed check, or Ctrl-C - stop the JVM this script started in the background, if it still runs;
# remove this script's own containers and images, by name; drop the lock. A background job of a non-interactive shell
# ignores the terminal's Ctrl-C, so without the kill an interrupted run would leave TiffinBox listening. $pid is cleared
# whenever the JVM has been reaped. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e (a JVM
# stopped by SIGTERM exits 143; a name already gone makes docker exit 1), so it always reaches the rmdir; the script still
# exits 130 after an interrupt (tested: README.md, "Interrupted").
pid=""
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; docker rm -f $BOXES > /dev/null 2>&1 || true; docker image rm -f $TAGS > /dev/null 2>&1 || true; rmdir .r-lock 2> /dev/null || true' EXIT
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
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
CORE=tiffinbox-core/target/tiffinbox-core-1.0.0.jar
SRV=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It
# is written into a file under .harness/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
C3POM=../c3-unit23/pom.xml                           # Course 3's packaging POM: its project.build.outputTimestamp line
BASE=eclipse-temurin:25-jre                          # every image here is built FROM it - an official image, not pulled here
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$C3POM" ] || die "$C3POM is missing"
grep -q 'TiffinBox listening on http' "after/$SRV" || die "after/'s TiffinBoxServer no longer says 'TiffinBox listening on'"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which
# lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18850 18851 18852 18853 18854 18855 18856 18857 18858 18859; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# Docker: asked first; started only if it does not answer (OrbStack's own command, when there is one); then polled - this Mac
# has no timeout command - for 60 s at most.
if ! docker info > /dev/null 2>&1; then
  command -v orb > /dev/null 2>&1 && { orb start > /dev/null 2>&1 || true; }
  i=0; until docker info > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 60 ] || die "Docker does not answer after 60 s - start it (OrbStack: orb start; Docker Desktop: open it), then run again"; sleep 1; done; fi
echo "  Docker: server $(docker version -f '{{.Server.Version}}' 2> /dev/null) · $(docker info -f '{{.OperatingSystem}}' 2> /dev/null) · image store: $(docker info -f '{{range .DriverStatus}}{{if eq (index . 0) "driver-type"}}{{index . 1}}{{end}}{{end}}' 2> /dev/null | grep . || echo "the daemon's own")    (terminal only)"
docker image inspect "$BASE" > /dev/null 2>&1 || die "$BASE is not on this machine - pull it once (docker pull $BASE: network, a build-time resolution), then run again"
# This script's own names, left by an interrupted run: removed before anything else.
docker rm -f $BOXES > /dev/null 2>&1 || true; docker image rm -f $TAGS > /dev/null 2>&1 || true

# ---- build: after/ twice, clean, in place; the previous tree twice; at/ once - each clean, offline ------------------------------
rm -rf .harness; mkdir -p .harness/ctx-recipe .harness/ctx-single .harness/ctx-folders
rsync -a --exclude target ../c5-unit13/after/ .harness/before/
rsync -a --exclude target ../c5-unit13/after/ .harness/before-at/
for d in at tz-utc tz-ist; do rsync -a --exclude target after/ ".harness/$d/"; done
sed 's|"TiffinBox listening on http|"TiffinBox listening at http|' "after/$SRV" > ".harness/at/$SRV"
sed 's|"TiffinBox listening on http|"TiffinBox listening at http|' ".harness/before/$SRV" > ".harness/before-at/$SRV"
[ "$(diff "after/$SRV" ".harness/at/$SRV" | grep -c '^[<>]')" = 2 ] || die "at/ must differ from after/ in one line"
[ "$(diff ".harness/before/$SRV" ".harness/before-at/$SRV" | grep -c '^[<>]')" = 2 ] || die "before-at/ must differ from the previous tree in one line"
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
build after .harness/build-after-1.log
cp "after/$JAR" .harness/after-1.jar
sleep 2                                              # zip entries keep time in 2-second steps: two builds, two steps apart
build after .harness/build-after-2.log
build .harness/before .harness/build-before-1.log
cp ".harness/before/$JAR" .harness/before-1.jar
sleep 2
build .harness/before .harness/build-before-2.log
sleep 2
build .harness/before-at .harness/build-before-at.log
build .harness/at .harness/build-at.log
# after/ twice more, each in a time zone named here - so the comparison does not depend on this Mac's own zone
(export TZ=UTC; build .harness/tz-utc .harness/build-tz-utc.log) || exit 1
(export TZ=Asia/Kolkata; build .harness/tz-ist .harness/build-tz-ist.log) || exit 1

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
# mf JARFILE: its manifest, folded lines unfolded (a line starting with one space continues the line before)
mf() { unzip -p "$1" META-INF/MANIFEST.MF | tr -d '\r' | awk '/^ / { b = b substr($0, 2); next } { if (n++) print b; b = $0 } END { if (b != "") print b }' | grep .; }

# mask: the demo token becomes a label naming its length; this folder's path "…", the folder above it "…/..", the home
# folder "~" - in every line (gsub)
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)) }
  { gsub(T, "[masked: the 26-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); print }'; }

# boxes: this script's own containers that exist right now (peek and copy are created and removed within one command line)
boxes() { docker ps -a --format '{{.Names}}' | grep -cxE 'tiffinbox-layers-(peek|copy)' || true; }
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
LAYERS="dependencies spring-boot-loader snapshot-dependencies application"

# ---- layers: the index Boot wrote, and the four folders its tool makes ----------------------------------------------------------
AJ=after/$JAR
layers() { local l n b tf tb f
  echo "\$ unzip -p $AJ BOOT-INF/layers.idx     (each layer's lines counted)"
  unzip -p "$AJ" BOOT-INF/layers.idx > .harness/layers.idx
  awk '/^- "/ { if (name != "") out(); name = $0; n = 0; list = ""; nonjar = 0; next }
       /^  - "/ { x = $0; sub(/^  - "/, "", x); sub(/"$/, "", x); n++; list = list " " x; if (x !~ /^BOOT-INF\/lib\/[^\/]+\.jar$/) nonjar++; next }
       function out() { printf "  %s %d line%s", name, n, (n == 1 ? "" : "s"); if (n > 5) printf ", every one a jar under BOOT-INF/lib/: %s", (nonjar == 0 ? "yes" : "no"); else if (n > 0) printf ":%s", list; printf "\n" }
       END { if (name != "") out() }' .harness/layers.idx
  echo "  the jar: $(unzip -Z1 "$AJ" | wc -l | tr -d ' ') entries, the index among them $(unzip -Z1 "$AJ" | grep -cx 'BOOT-INF/layers.idx') · the manifest names it: $(mf "$AJ" | grep '^Spring-Boot-Layers-Index: ' || echo '(no such line)')"
  runf "java -Djarmode=tools -jar $AJ list-layers"
  echo "  exit $ec"; sed 's/^/  /' .harness/run.out
  rm -rf .harness/layers
  runf "java -Djarmode=tools -jar $AJ extract --layers --launcher --destination .harness/layers"
  echo "  exit $ec · printed: $(cat .harness/run.out .harness/run.err | grep -c . || true) line(s) · folders: $(ls .harness/layers | paste -sd' ' -)"
  tf=0; tb=0
  for l in $LAYERS; do
    n=$(find ".harness/layers/$l" -type f | wc -l | tr -d ' ')
    b=$(find ".harness/layers/$l" -type f -exec stat -f %z {} + 2> /dev/null | awk '{ s += $1 } END { print s + 0 }')
    printf '  %-22s files %s · bytes %s\n' "$l" "$n" "$b"; tf=$((tf + n)); tb=$((tb + b)); done
  b=$(find .harness/layers/application -type f -exec stat -f %z {} + | awk '{ s += $1 } END { print s + 0 }')
  echo "  the four: $tf files, $tb bytes · application's share of those bytes: $(awk -v a="$b" -v t="$tb" 'BEGIN { printf "%.1f", a * 1000 / t }') in 1,000"
  echo "  what application holds: $(cd .harness/layers/application && find . -type f | sed 's|^\./||' | sort | awk -F/ '{ if ($1 == "BOOT-INF" && $2 == "classes") c++; else o = o " " $0 } END { printf "BOOT-INF/classes/ %d files ·%s", c, o }')"
  runf "java -Djarmode=layertools -jar $AJ list"
  echo "  exit $ec · standard output $(grep -c . .harness/run.out || true) lines · $(grep -m1 . .harness/run.err || echo '(nothing on standard error)')"; }
cap layers layers

# ---- change: the previous tree against after/, file by file (README aside) -----------------------------------------------------
# code FILE: its code lines - blank lines and XML comments dropped (a comment may span lines)
code() { awk '{ t = $0; sub(/^[ \t]+/, "", t) }
  inc { if (index(t, "-->")) inc = 0; next }
  index(t, "<!--") == 1 { if (!index(t, "-->")) inc = 1; next }
  t == "" { next }
  { print }' "$1"; }
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
  echo "the same line in Course 3's packaging POM (\$C3POM), where its exercise put it: $(grep -cxF '    <project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>' "$C3POM" || true) time(s)"; }
cap change change

# ---- moved: each jar's layers, hashed ---------------------------------------------------------------------------------------
# ex JAR DEST: Boot's tool unpacks JAR's layers into DEST (the launcher too, so every layer holds what the jar holds)
ex() { rm -rf "$2"; echo "\$ java -Djarmode=tools -jar $1 extract --layers --launcher --destination $2"
       java -Djarmode=tools -jar "$1" extract --layers --launcher --destination "$2" > .harness/ex.out 2>&1 || { cat .harness/ex.out >&3; die "extract failed: $1"; }; }
# files DIR: every file under DIR, as "path md5", sorted by path
files_of() { (cd "$1" 2> /dev/null && find . -type f | sed 's|^\./||' | sort | while read -r f; do echo "$f $(md5 -q "$f")"; done); }
# lcmp D1 D2: each layer - its file count, and same or moved (with the files that differ: changed, added or gone)
lcmp() { local l n d m=0
  for l in $LAYERS; do
    files_of "$1/$l" > .harness/l1.txt; files_of "$2/$l" > .harness/l2.txt; n=$(wc -l < .harness/l2.txt | tr -d ' ')
    if cmp -s .harness/l1.txt .harness/l2.txt; then printf '  %-22s %s files · same\n' "$l" "$n"
    else m=$((m + 1)); d=$(diff .harness/l1.txt .harness/l2.txt | sed -n 's/^[<>] \([^ ]*\) .*/\1/p' | sort -u | paste -sd' ' -)
         printf '  %-22s %s files · moved: %s\n' "$l" "$n" "$d"; fi; done
  echo "  layers that moved: $m of 4"; }
# ents JAR1 JAR2: the two jars' entries, compared - by content (CRC-32) and by the time each entry carries
ents() { local n c t
  unzip -v "$1" | awk 'NF >= 8 && $7 ~ /^[0-9a-f]{8}$/ { print $8, $7 }' | sort > .harness/c1.txt
  unzip -v "$2" | awk 'NF >= 8 && $7 ~ /^[0-9a-f]{8}$/ { print $8, $7 }' | sort > .harness/c2.txt
  zipinfo -T "$1" | awk 'NF >= 8 && $1 ~ /^[-d]/ { print $8, $7 }' | sort > .harness/t1.txt
  zipinfo -T "$2" | awk 'NF >= 8 && $1 ~ /^[-d]/ { print $8, $7 }' | sort > .harness/t2.txt
  n=$(wc -l < .harness/c2.txt | tr -d ' '); c=$(comm -12 .harness/c1.txt .harness/c2.txt | wc -l | tr -d ' '); t=$(comm -12 .harness/t1.txt .harness/t2.txt | wc -l | tr -d ' ')
  echo -n "  tiffinbox-core-1.0.0.jar, build 1 against build 2: entries $n · the same content (CRC-32) $c · the same time $t"
  if [ "$t" = "$n" ]; then echo " · the time every entry carries: $(awk '{ print $2 }' .harness/t2.txt | sort -u | paste -sd' ' -) ($(wc -l < .harness/t2.txt | tr -d ' ') of $n)"
  elif [ "$t" -gt 0 ]; then echo ": $(comm -12 .harness/t1.txt .harness/t2.txt | awk '{ print $1 }' | paste -sd' ' -) - it carries its source file's own time"; else echo; fi; }
md5eq() { [ "$(md5 -q "$1")" = "$(md5 -q "$2")" ] && echo yes || echo no; }
ICORE=application/BOOT-INF/lib/tiffinbox-core-1.0.0.jar
# jarline JAR1 JAR2: the two jars' sizes, and whether their md5s are equal
jarline() { echo "  the jar: $(stat -f %z "$1") bytes, then $(stat -f %z "$2") · md5 equal: $(md5eq "$1" "$2")"; }
# tzcmp JAR1 JAR2: two builds of the same sources, compared entry by entry - by name, content (CRC-32) and the date each entry
# carries; then the entries whose extra fields still differ, where they sit, and by how much their NTFS time field (extra
# field 0x000a: a modification time in 100-nanosecond steps) differs
tzcmp() { python3 - "$1" "$2" <<'PYZ'
import sys, zipfile, struct
def ents(p): return {i.filename: i for i in zipfile.ZipFile(p).infolist()}
a, b = ents(sys.argv[1]), ents(sys.argv[2])
same = [k for k in a if k in b and (a[k].CRC, a[k].date_time) == (b[k].CRC, b[k].date_time)]
diff = sorted(k for k in a if k in b and a[k].extra != b[k].extra)
def ntfs(ex):
    i = 0
    while i + 4 <= len(ex):
        hid, sz = struct.unpack("<HH", ex[i:i + 4])
        if hid == 0x000a and sz >= 16: return struct.unpack("<Q", ex[i + 12:i + 20])[0]
        i += 4 + sz
    return None
gaps = sorted({abs(ntfs(b[k].extra) - ntfs(a[k].extra)) / 1e7 / 3600 for k in diff if ntfs(a[k].extra) is not None and ntfs(b[k].extra) is not None})
under = "yes" if diff and all(k.startswith("BOOT-INF/classes/") for k in diff) else "no"
print(f"  entries {len(a)} and {len(b)} · the same name, content (CRC-32) and date {len(same)} · whose extra fields differ {len(diff)}, every one under BOOT-INF/classes/: {under}")
print("  in what: their NTFS time field (extra field 0x000a) - " + (f"{gaps[0]:g} hours apart, every one" if len(gaps) == 1 else f"apart by {gaps}"))
PYZ
}
moved() {
  echo "each jar unpacked by Boot's own tool, every layer folder hashed (each file's path and md5, sorted by path) - the flipped"
  echo "  attribute: project.build.outputTimestamp, absent in the previous tree (the anchor before this lesson), present in after/:"
  echo "one word changed, without it - the previous tree, then before-at/ (the same tree, TiffinBoxServer's listening line saying \"at\""
  echo "  where it says \"on\"):"
  ex ".harness/before/$JAR" .harness/moved/before; ex ".harness/before-at/$JAR" .harness/moved/before-at
  jarline ".harness/before/$JAR" ".harness/before-at/$JAR"
  lcmp .harness/moved/before .harness/moved/before-at
  echo "no change, built twice, without it - the previous tree:"
  ex .harness/before-1.jar .harness/moved/before-1
  echo "  (build 2 is the previous tree's jar, unpacked above)"
  jarline .harness/before-1.jar ".harness/before/$JAR"
  lcmp .harness/moved/before-1 .harness/moved/before
  ents .harness/moved/before-1/$ICORE .harness/moved/before/$ICORE
  echo "no change, built twice, with it - after/:"
  ex .harness/after-1.jar .harness/moved/after-1; ex "$AJ" .harness/moved/after
  jarline .harness/after-1.jar "$AJ"
  lcmp .harness/moved/after-1 .harness/moved/after
  ents .harness/moved/after-1/$ICORE .harness/moved/after/$ICORE
  echo "one word changed, with it - after/, then at/ (after/ with the same word changed):"
  ex ".harness/at/$JAR" .harness/moved/at
  echo "  (after/'s jar is unpacked above)"
  jarline "$AJ" ".harness/at/$JAR"
  lcmp .harness/moved/after .harness/moved/at
  echo "after/ built twice more, clean, with it - in two time zones, TZ=UTC and TZ=Asia/Kolkata:"
  jarline ".harness/tz-utc/$JAR" ".harness/tz-ist/$JAR"
  echo "  tiffinbox-core-1.0.0.jar inside them, byte for byte the same: $(unzip -p ".harness/tz-utc/$JAR" BOOT-INF/lib/tiffinbox-core-1.0.0.jar | md5 -q | grep -cxF "$(unzip -p ".harness/tz-ist/$JAR" BOOT-INF/lib/tiffinbox-core-1.0.0.jar | md5 -q)" | sed 's/^1$/yes/; s/^0$/no/')"
  tzcmp ".harness/tz-utc/$JAR" ".harness/tz-ist/$JAR"; }
cap moved moved

# ---- Docker helpers ------------------------------------------------------------------------------------------------------------
# dbuild LOG 'COMMAND': print the command exactly as typed and run it (eval, from this folder), its whole output to LOG (read,
# never printed); its exit code in $ec. A tag it names is removed first, so a rebuilt tag never leaves an untagged image.
dbuild() { local t; echo "\$ $2"; t=$(printf '%s\n' "$2" | sed -nE 's/.* -t ([^ ]+) .*/\1/p')
  [ -z "$t" ] || docker image rm -f "$t" > /dev/null 2>&1 || true
  ec=0; (eval "$2") > "$1" 2>&1 < /dev/null || ec=$?; }
# ctxsize LOG: what "load build context" transferred - the build context sent to the builder
ctxsize() { awk '/^#[0-9]+ \[internal\] load build context$/ { s = $1 } s != "" && $1 == s && /transferring context: / { v = $0; sub(/.*transferring context: /, "", v); sub(/ .*/, "", v) } END { print (v == "" ? "(none)" : v) }' "$1"; }
# copies LOG: the COPY steps the log names, and how many of them it marked CACHED
# sent LOG BYTES: the build context's transfer, and whether it was smaller than BYTES (the thin jar alone)
sent() { local v; v=$(ctxsize "$1")
  echo "transferring context: $v - less than the thin jar alone ($2 bytes): $(awk -v v="$v" -v b="$2" 'BEGIN { n = v + 0; u = v; sub(/^[0-9.]+/, "", u); m = (u == "kB" ? 1000 : u == "MB" ? 1000000 : u == "B" ? 1 : -1); if (m < 0) { print "(unknown unit " u ")"; exit } print (n * m < b ? "yes" : "no") }')"; }
copies() { awk '/^#[0-9]+ \[[^]]*\] COPY / { c[$1] = 1 } /^#[0-9]+ CACHED$/ { k[$1] = 1 } END { for (x in c) { n++; if (x in k) m++ } printf "COPY steps CACHED: %d of %d", m, n }' "$1"; }
# copies3 LOG: the COPY steps of the three layers a one-word change leaves alone - dependencies, spring-boot-loader,
# snapshot-dependencies - and how many of them the log marked CACHED. The application folder's COPY is left out on purpose:
# when its content is new to this run, BuildKit still finds it CACHED if any earlier build on this Docker copied the same
# content (BuildKit keys its cache on content), so that count depends on the daemon's past, not on this run
copies3() { awk '/^#[0-9]+ \[[^]]*\] COPY extracted\/(dependencies|spring-boot-loader|snapshot-dependencies)\/ / { c[$1] = 1 } /^#[0-9]+ CACHED$/ { k[$1] = 1 } END { for (x in c) { n++; if (x in k) m++ } printf "COPY steps CACHED, the three layers the change leaves alone: %d of %d", m, n }' "$1"; }
# saved IMG...: the images saved together (docker save, an OCI layout: one file per blob, named by its digest), counted - the
# layers their manifests list, and the distinct layer files the archive holds
saved() { rm -rf .harness/sv; mkdir -p .harness/sv; docker save -o .harness/sv/all.tar "$@" && (cd .harness/sv && tar -xf all.tar)
  python3 -c 'import json; m = json.load(open(".harness/sv/manifest.json")); L = [l for x in m for l in x["Layers"]]; print(f"layers {len(L)} · distinct layer files {len(set(L))}")'
  rm -rf .harness/sv; }
dwarn() { cat "$@" | grep -ci 'warn' || true; }                                                   # warning lines in build logs
downloads() { cat "$@" | grep -cE '^#[0-9]+ sha256:[0-9a-f]{64} [0-9.]+[kMG]?B / [0-9.]+[kMG]?B' || true; }   # layer downloads
rootfs() { docker image inspect -f '{{range .RootFS.Layers}}{{println .}}{{end}}' "$1" | grep .; }
# lsame IMG1 IMG2: their RootFS layers, compared position by position
lsame() { rootfs "$1" > .harness/r1.txt; rootfs "$2" > .harness/r2.txt
  echo "$(wc -l < .harness/r1.txt | tr -d ' ') and $(wc -l < .harness/r2.txt | tr -d ' ') · the same $(paste -d' ' .harness/r1.txt .harness/r2.txt | awk '$1 == $2' | wc -l | tr -d ' ') · different $(paste -d' ' .harness/r1.txt .harness/r2.txt | awk '$1 != $2' | wc -l | tr -d ' ')"; }
# base IMG: does IMG start with the base image's own layers, unchanged?
base() { rootfs "$BASE" > .harness/rb.txt; rootfs "$1" | head -"$(wc -l < .harness/rb.txt | tr -d ' ')" | cmp -s - .harness/rb.txt && echo "yes, $(wc -l < .harness/rb.txt | tr -d ' ') of $(wc -l < .harness/rb.txt | tr -d ' ')" || echo no; }
# own IMG N: the image's own N newest steps, from docker history (--human=false: bytes) - each step's size and what made it
own() { docker history --human=false --no-trunc --format '{{.Size}}	{{.CreatedBy}}' "$1" | head -"$2" | awk -F'\t' '{ printf "    %-9s %s\n", $1, $2 }'; }
# atts LOG...: the attestation manifests the builds exported - each one's "done" line (a step's progress line may come first,
# or not, depending on timing: counting lines would count that)
atts() { cat "$@" | grep -cE '^#[0-9]+ exporting attestation manifest sha256:[0-9a-f]{64} .*done$' || true; }
idsame() { [ "$(docker image inspect -f '{{.Id}}' "$1")" = "$(docker image inspect -f '{{.Id}}' "$2")" ] && echo yes || echo no; }
peek() { echo "\$ ./peek.sh $1"; ./peek.sh "$1" | sed 's/^/  /'; }

# The build commands, read from README.md's "Commands" section - each run with its tag given a suffix (on, at, …).
RBUILD=$(readme '^docker build -f docker/Dockerfile -t tiffinbox-layers:recipe \.harness/ctx-recipe$')
SBUILD=$(readme '^docker build -f docker/single\.Dockerfile -t tiffinbox-layers:single \.harness/ctx-single$')
BBUILD=$(readme '^docker build -f docker/folders\.Dockerfile -t tiffinbox-layers:folders \.harness/ctx-folders$')
BEXTRACT=$(readme '^java -Djarmode=tools -jar [^ ]+ extract --layers --destination \.harness/ctx-folders/extracted --application-filename application\.jar$')
[ -n "$RBUILD" ] && [ -n "$SBUILD" ] && [ -n "$BBUILD" ] && [ -n "$BEXTRACT" ] || die "README.md no longer gives the three build commands and the extract command for the folders"
tagged() { printf '%s\n' "$1" | sed "s/ -t \(tiffinbox-layers:[a-z]*\) / -t \1-$2 /"; }                 # tagged CMD SUFFIX
jarin() { printf 'cp %s %s/ && ' "$1" "$2"; }                                                           # jarin JAR CONTEXT
BEX() { printf '%s\n' "$BEXTRACT" | sed "s|-jar [^ ]* extract|-jar $1 extract|"; }                         # BEX JAR

# ---- bytes: the two images, and what one line makes new ---------------------------------------------------------------------
bytes() {
  echo "the layered image - docker/Dockerfile, built for after/'s jar, then for at/'s (one word changed); each context holds the jar alone:"
  dbuild .harness/b-recipe-on.log "$(jarin "$AJ" .harness/ctx-recipe)$(tagged "$RBUILD" on)"; e1=$ec
  dbuild .harness/b-recipe-at.log "$(jarin ".harness/at/$JAR" .harness/ctx-recipe)$(tagged "$RBUILD" at)"; e2=$ec
  echo "  exit $e1, $e2 · warnings in the two build logs: $(dwarn .harness/b-recipe-on.log .harness/b-recipe-at.log) · layer downloads in them: $(downloads .harness/b-recipe-on.log .harness/b-recipe-at.log)"
  echo "  RootFS layers: $(lsame tiffinbox-layers:recipe-on tiffinbox-layers:recipe-at) · the base image's own layers first, unchanged: $(base tiffinbox-layers:recipe-at)"
  echo "  the recipe's own steps in tiffinbox-layers:recipe-at - docker history --human=false, each one's size and step:"
  own tiffinbox-layers:recipe-at 6
  echo "  the layer that differs, counted from the base up: $(paste -d' ' .harness/r1.txt .harness/r2.txt | awk '$1 != $2 { print NR }' | paste -sd' ' -) of $(wc -l < .harness/r2.txt | tr -d ' ')"
  echo "  the two, saved together (docker save): $(saved tiffinbox-layers:recipe-on tiffinbox-layers:recipe-at)"
  echo "the single-jar image - docker/single.Dockerfile, Boot's jar copied whole, the same two jars:"
  dbuild .harness/b-single-on.log "$(jarin "$AJ" .harness/ctx-single)$(tagged "$SBUILD" on)"; e1=$ec
  dbuild .harness/b-single-at.log "$(jarin ".harness/at/$JAR" .harness/ctx-single)$(tagged "$SBUILD" at)"; e2=$ec
  echo "  exit $e1, $e2 · warnings in the two build logs: $(dwarn .harness/b-single-on.log .harness/b-single-at.log) · layer downloads in them: $(downloads .harness/b-single-on.log .harness/b-single-at.log)"
  echo "  RootFS layers: $(lsame tiffinbox-layers:single-on tiffinbox-layers:single-at) · the base image's own layers first, unchanged: $(base tiffinbox-layers:single-at)"
  echo "  its own steps in tiffinbox-layers:single-at - docker history --human=false, each one's size and step:"
  own tiffinbox-layers:single-at 3
  echo "  the layer that differs, counted from the base up: $(paste -d' ' .harness/r1.txt .harness/r2.txt | awk '$1 != $2 { print NR }' | paste -sd' ' -) of $(wc -l < .harness/r2.txt | tr -d ' ')"
  echo "the layered image again - after/'s jar, nothing changed:"
  dbuild .harness/b-recipe-again.log "$(jarin "$AJ" .harness/ctx-recipe)$(tagged "$RBUILD" again)"
  echo "  exit $ec · RootFS layers, against tiffinbox-layers:recipe-on: $(lsame tiffinbox-layers:recipe-on tiffinbox-layers:recipe-again)"
  echo "  the two image IDs equal: $(idsame tiffinbox-layers:recipe-on tiffinbox-layers:recipe-again) · what the ID names here: $(docker image inspect -f '{{.Descriptor.MediaType}}' tiffinbox-layers:recipe-again) · attestation manifests its build exported: $(atts .harness/b-recipe-again.log)"
  echo "the same build twice more, with --provenance=false - no attestation in the image:"
  dbuild .harness/b-recipe-np1.log "$(jarin "$AJ" .harness/ctx-recipe)$(tagged "$RBUILD" np1 | sed 's/^docker build /docker build --provenance=false /')"; e1=$ec
  dbuild .harness/b-recipe-np2.log "$(jarin "$AJ" .harness/ctx-recipe)$(tagged "$RBUILD" np2 | sed 's/^docker build /docker build --provenance=false /')"; e2=$ec
  echo "  exit $e1, $e2 · attestation manifests the two builds exported: $(atts .harness/b-recipe-np1.log .harness/b-recipe-np2.log) · RootFS layers: $(lsame tiffinbox-layers:recipe-np1 tiffinbox-layers:recipe-np2) · the two image IDs equal: $(idsame tiffinbox-layers:recipe-np1 tiffinbox-layers:recipe-np2)"
  docker image rm -f tiffinbox-layers:recipe-again tiffinbox-layers:recipe-np1 tiffinbox-layers:recipe-np2 > /dev/null 2>&1 || true; }
cap bytes bytes

# ---- stale: the break - where the jar is unpacked ------------------------------------------------------------------------------
XA=.harness/ctx-folders/extracted/application/application.jar
stale() { local s1 s2 t1 t2 m1 m2
  echo "the change: TiffinBoxServer's listening line, \"on\" -> \"at\" - the thin jar Boot's tool writes from each, side by side:"
  rm -rf .harness/thin && mkdir -p .harness/thin
  java -Djarmode=tools -jar "$AJ" extract --layers --destination .harness/thin/on --application-filename application.jar > /dev/null 2>&1
  java -Djarmode=tools -jar ".harness/at/$JAR" extract --layers --destination .harness/thin/at --application-filename application.jar > /dev/null 2>&1
  s1=$(stat -f %z .harness/thin/on/application/application.jar); s2=$(stat -f %z .harness/thin/at/application/application.jar)
  t1=$(stat -f %m .harness/thin/on/application/application.jar); t2=$(stat -f %m .harness/thin/at/application/application.jar)
  echo "  application.jar: $s1 bytes and $s2 · the same size: $([ "$s1" = "$s2" ] && echo yes || echo no) · the same file time: $([ "$t1" = "$t2" ] && echo yes || echo no) · md5 equal: $(md5eq .harness/thin/on/application/application.jar .harness/thin/at/application/application.jar)"
  echo "A   docker/Dockerfile - Boot's extract runs INSIDE the build:"
  dbuild .harness/s-a-on.log "$(jarin "$AJ" .harness/ctx-recipe)$(tagged "$RBUILD" on)"; echo "  exit $ec"; peek tiffinbox-layers:recipe-on
  dbuild .harness/s-a-at.log "$(jarin ".harness/at/$JAR" .harness/ctx-recipe)$(tagged "$RBUILD" at)"
  echo "  exit $ec · transferring context: $(ctxsize .harness/s-a-at.log)"; peek tiffinbox-layers:recipe-at
  echo "B   docker/folders.Dockerfile - the same four layers, extracted on the Mac, copied in as folders:"
  dbuild .harness/s-b-on.log "rm -rf .harness/ctx-folders/extracted && $(BEX "$AJ") && $(tagged "$BBUILD" on)"; echo "  exit $ec"; peek tiffinbox-layers:folders-on
  dbuild .harness/s-b-at.log "rm -rf .harness/ctx-folders/extracted && $(BEX ".harness/at/$JAR") && $(tagged "$BBUILD" at)"
  echo "  exit $ec · $(sent .harness/s-b-at.log "$s2") · $(copies .harness/s-b-at.log)"; peek tiffinbox-layers:folders-at
  echo "C   B's last build again, with --no-cache:"
  dbuild .harness/s-c.log "$(tagged "$BBUILD" nocache | sed 's/^docker build /docker build --no-cache /')"
  echo "  exit $ec · $(sent .harness/s-c.log "$s2") · $(copies .harness/s-c.log)"; peek tiffinbox-layers:folders-nocache
  echo "D   B's last build again, the thin jar's file time set to now first:"
  dbuild .harness/s-d.log "touch $XA && $(tagged "$BBUILD" touched)"
  echo "  exit $ec · $(sent .harness/s-d.log "$s2") · $(copies3 .harness/s-d.log)"; peek tiffinbox-layers:folders-touched
  echo "A′  A, re-run:"
  dbuild .harness/s-a2-on.log "$(jarin "$AJ" .harness/ctx-recipe)$(tagged "$RBUILD" on)"; echo "  exit $ec"; peek tiffinbox-layers:recipe-on
  dbuild .harness/s-a2-at.log "$(jarin ".harness/at/$JAR" .harness/ctx-recipe)$(tagged "$RBUILD" at)"
  echo "  exit $ec · transferring context: $(ctxsize .harness/s-a2-at.log)"; peek tiffinbox-layers:recipe-at
  echo "warnings in the ten build logs: $(dwarn .harness/s-*.log) · layer downloads in them: $(downloads .harness/s-*.log)"; }
cap stale stale

# ---- timing: the clock, against five seconds -----------------------------------------------------------------------------------
# Each round changes TiffinBoxServer's listening line afresh - a number never built before goes at its end - so neither image
# can come from the cache; then mvn -o clean package, a one-second pause, then both images rebuilt, each timed by bash (real
# seconds). Round 0 is a warm-up, built and not counted. The seconds go to the terminal only: they move from run to run - with
# other work on this Mac one layered rebuild took 3.139 s where they usually take 1.3-1.9 s (README.md, "The timing") - so the
# capture counts them against five seconds, and compares the two images' medians, which one slow round cannot flip.
SECS_ALL=""
TR="${RBUILD/:recipe /:tick-recipe }"; TST="${SBUILD/:single /:tick-single }"     # the README's two build commands, each with its own tag
# ran LOG: the build's COPY and RUN steps, and how many of them ran (not CACHED), and whether a RUN that starts java ran
ran() { awk '/^#[0-9]+ \[[^]]*\] (COPY|RUN) / { c[$1] = 1; if ($0 ~ /\] RUN java /) j[$1] = 1 } /^#[0-9]+ CACHED$/ { k[$1] = 1 } END { for (x in c) { n++; if (!(x in k)) { r++; if (x in j) jr++ } } printf "%d of %d%s", r, n, (jr ? ", one a java process" : "") }' "$1"; }
timing() { local r n secr secf er ef under_r=0 under_f=0 real=0 sr="" sf="" mr mf rr="" rf=""
  rm -rf .harness/tick; rsync -a --exclude target after/ .harness/tick/
  echo "six rounds after one warm-up round; each round: a fresh number at the end of TiffinBoxServer's listening line (never built"
  echo "  before, so neither image can come from the cache), mvn -o clean package, a one-second pause, then both images rebuilt,"
  echo "  each timed by bash:"
  echo "\$ time $TR > .harness/tick-r.log 2>&1"
  echo "\$ time $TST > .harness/tick-f.log 2>&1"
  for r in 0 1 2 3 4 5 6; do
    n="$(date +%s)$$$r"
    sed "s|\"TiffinBox listening on http://127.0.0.1:\" + port);|\"TiffinBox listening on http://127.0.0.1:\" + port + \" $n\");|" "after/$SRV" > ".harness/tick/$SRV"
    grep -q " $n\");" ".harness/tick/$SRV" || die "timing: the line did not change"
    mvn -o -q -B -f .harness/tick/pom.xml -Dmaven.repo.local="$M2" -DskipTests clean package > .harness/tick-build.log 2>&1 || { tail -20 .harness/tick-build.log >&3; die "timing: the offline build failed"; }
    cp ".harness/tick/$JAR" .harness/ctx-recipe/; cp ".harness/tick/$JAR" .harness/ctx-single/
    docker image rm -f tiffinbox-layers:tick-recipe tiffinbox-layers:tick-single > /dev/null 2>&1 || true
    sleep 1
    er=0; ef=0; TIMEFORMAT=%3R
    { time eval "$TR" > .harness/tick-r.log 2>&1 ; } 2> .harness/secs-r.txt || er=$?
    { time eval "$TST" > .harness/tick-f.log 2>&1 ; } 2> .harness/secs-f.txt || ef=$?
    [ $er = 0 ] && [ $ef = 0 ] || die "timing: a build failed (round $r)"
    [ $r = 0 ] && continue
    secr=$(tail -1 .harness/secs-r.txt); secf=$(tail -1 .harness/secs-f.txt); sr="$sr $secr"; sf="$sf $secf"
    rr="$rr|$(ran .harness/tick-r.log)"; rf="$rf|$(ran .harness/tick-f.log)"
    # a real rebuild: the jar's COPY ran (not CACHED) in both, and extract ran in the layered one
    awk '/^#[0-9]+ \[[^]]*\] (COPY tiffinbox-web-1\.0\.0\.jar application\.jar|RUN java -Djarmode=tools)/ { s[$1] = 1 } /^#[0-9]+ CACHED$/ { c[$1] = 1 } END { for (x in s) { n++; if (x in c) k++ } exit !(n == 2 && k == 0) }' .harness/tick-r.log && real=$((real + 1))
    awk '/^#[0-9]+ \[[^]]*\] COPY tiffinbox-web-1\.0\.0\.jar application\.jar/ { s[$1] = 1 } /^#[0-9]+ CACHED$/ { c[$1] = 1 } END { for (x in s) { n++; if (x in c) k++ } exit !(n == 1 && k == 0) }' .harness/tick-f.log && real=$((real + 1))
    awk -v a="$secr" 'BEGIN { exit !(a < 5.0) }' && under_r=$((under_r + 1))
    awk -v a="$secf" 'BEGIN { exit !(a < 5.0) }' && under_f=$((under_f + 1)); done
  med() { printf '%s\n' $1 | sort -n | awk '{ v[NR] = $1 } END { printf "%.3f", (v[3] + v[4]) / 2 }'; }
  mr=$(med "$sr"); mf=$(med "$sf")
  docker image rm -f tiffinbox-layers:tick-recipe tiffinbox-layers:tick-single > /dev/null 2>&1 || true
  SECS_ALL="$SECS_ALL|layered$sr (median $mr) / single-jar$sf (median $mf)"
  echo "  every timed build re-ran its jar step, none from the cache: $real of 12"
  echo "  rebuilds under five seconds: the layered image $under_r of 6 · the single-jar image $under_f of 6"
  echo "  the median of the six - the layered image's longer than the single-jar image's: $(awk -v a="$mr" -v b="$mf" 'BEGIN { print (a > b ? "yes" : "no") }')"
  echo "  COPY and RUN steps each rebuild ran, not from the cache - the layered image: $(printf '%s\n' "$rr" | tr '|' '\n' | grep . | sort | uniq -c | awk '{ c = $1; $1 = ""; printf "%s%s in %d of 6", (NR > 1 ? " / " : ""), substr($0, 2), c }') · the single-jar image: $(printf '%s\n' "$rf" | tr '|' '\n' | grep . | sort | uniq -c | awk '{ c = $1; $1 = ""; printf "%s%s in %d of 6", (NR > 1 ? " / " : ""), substr($0, 2), c }')"
  echo "the course after Course 3 - Spring Framework Core, the c4- folders of this repository:"
  echo "  folders $(ls -d ../c4-* | wc -l | tr -d ' ') · files named Dockerfile in them $(find ../c4-* -name Dockerfile -not -path '*/.m2-demo/*' | wc -l | tr -d ' ') · files that say docker, any case $(grep -rli docker ../c4-* --exclude-dir=.m2-demo --exclude-dir=target 2> /dev/null | wc -l | tr -d ' ')"; }
cap timing timing
echo "  timing, the seconds of each capture run (terminal only - they move from run to run):"
printf '%s\n' "${SECS_ALL#|}" | tr '|' '\n' | sed 's/^/    /'

# ---- serve: the layered image's own files, on the Mac ----------------------------------------------------------------------
serve() { local n
  echo "the layered image's /app, copied out (the container is created, never started), then run on the Mac with the image's own command:"
  dbuild .harness/v.log "$(jarin "$AJ" .harness/ctx-recipe)$(tagged "$RBUILD" on)"; echo "  exit $ec · the image's ENTRYPOINT: $(docker image inspect -f '{{json .Config.Entrypoint}}' tiffinbox-layers:recipe-on)"
  rm -rf .harness/fromimage
  runf "docker create --name tiffinbox-layers-copy tiffinbox-layers:recipe-on > /dev/null && docker cp -q tiffinbox-layers-copy:/app .harness/fromimage && docker rm tiffinbox-layers-copy > /dev/null"
  echo "  exit $ec · .harness/fromimage: $(ls .harness/fromimage | paste -sd' ' -) · lib/: $(ls .harness/fromimage/lib | grep -c '\.jar$') jars"
  rm -rf .harness/thinref; java -Djarmode=tools -jar "$AJ" extract --destination .harness/thinref --application-filename application.jar > /dev/null 2>&1
  n=0; for f in $(cd .harness/thinref/lib && ls); do cmp -s ".harness/thinref/lib/$f" ".harness/fromimage/lib/$f" && n=$((n + 1)); done
  unzip -v .harness/thinref/application.jar | awk 'NF >= 8 && $7 ~ /^[0-9a-f]{8}$/ { print $8, $7 }' | sort > .harness/c1.txt
  unzip -v .harness/fromimage/application.jar | awk 'NF >= 8 && $7 ~ /^[0-9a-f]{8}$/ { print $8, $7 }' | sort > .harness/c2.txt
  echo "  against Boot's extract of after/'s jar on the Mac (--application-filename application.jar): lib/ byte for byte the same $n of $(ls .harness/thinref/lib | wc -l | tr -d ' ') · application.jar's entries, by name and content (CRC-32), the same $(comm -12 .harness/c1.txt .harness/c2.txt | wc -l | tr -d ' ') of $(wc -l < .harness/c1.txt | tr -d ' ')"
  startjar "cd .harness/tree && java -jar ../fromimage/application.jar --tiffinbox.port=18850"; up; seven 18850; }
cap serve serve

# ---- exercise: exercise/README.md's commands, read from the file and run as written ---------------------------------------------
EXL=$(awk '/^```bash$/ { f++; next } /^```$/ { if (f == 1) exit } f == 1 && !/^export / { print }' exercise/README.md)
[ "$(printf '%s\n' "$EXL" | grep -c .)" -ge 6 ] || die "exercise/README.md no longer gives its commands in its first bash block"
exercise() { local l
  echo "exercise/README.md's commands, read from the file and run as written, in order (its two export lines aside):"
  while IFS= read -r l; do [ -n "$l" ] || continue; runf "$l"
    echo "  exit $ec"; sed 's/^/  /' .harness/run.out; grep -v '^$' .harness/run.err | sed 's/^/  stderr: /' || true; done <<< "$EXL"
  echo "the line the perl command changed, in .harness/mine's own source: $(grep -c 'must have 16 characters or more' .harness/mine/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java || true) time(s)"
  echo "the same jar's index - where layers.idx puts tiffinbox-core:"
  unzip -p .harness/mine/$JAR BOOT-INF/layers.idx | awk '/^- "/ { name = $0; next } /tiffinbox-core|"BOOT-INF\/lib\/"$/ { print "  " name " " $0 }'
  echo "  after/'s own jar, built from the root: $(unzip -p "$AJ" BOOT-INF/layers.idx | awk '/^- "/ { name = $0; next } /tiffinbox-core/ { print name " " $0 }')"; }
cap exercise exercise

# ---- files: every demo file, against the file it stands in for ---------------------------------------------------------------
files() {
  against() { if cmp -s "$1" "$2"; then echo "$2: $3, byte for byte"
              else echo "$2, against $3:"; diff "$1" "$2" | sed 's/^/  /' || true; fi; }
  echo "docker/Dockerfile - the recipe, whole:"; sed 's/^/  /' docker/Dockerfile
  against docker/Dockerfile docker/folders.Dockerfile "docker/Dockerfile"
  against docker/Dockerfile docker/single.Dockerfile "docker/Dockerfile"
  echo "at/'s TiffinBoxServer.java, against after/'s:"; diff "after/$SRV" ".harness/at/$SRV" | sed 's/^/  /' || true
  echo "peek.sh, whole:"; sed 's/^/  /' peek.sh; }
cap files files

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
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 after/README.md docker/* peek.sh; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/' "$f" || die "$f holds an absolute path"; done
# ... nor any layer of any image this script built: each image saved (docker save), its own layers - every one after the base
# image's - unpacked from their gzip and searched, and its config too
for t in tiffinbox-layers:recipe-on tiffinbox-layers:recipe-at tiffinbox-layers:single-on tiffinbox-layers:single-at tiffinbox-layers:folders-on tiffinbox-layers:folders-at tiffinbox-layers:folders-nocache tiffinbox-layers:folders-touched; do
  docker image inspect "$t" > /dev/null 2>&1 || die "$t is gone before its layers were searched"
  [ "$(base "$t")" != no ] || die "$t does not start with the base image's layers"; done
rm -rf .harness/saved; mkdir -p .harness/saved
docker save -o .harness/saved/all.tar tiffinbox-layers:recipe-on tiffinbox-layers:recipe-at tiffinbox-layers:single-on tiffinbox-layers:single-at tiffinbox-layers:folders-on tiffinbox-layers:folders-at tiffinbox-layers:folders-nocache tiffinbox-layers:folders-touched
(cd .harness/saved && tar -xf all.tar)
NB=$(rootfs "$BASE" | wc -l | tr -d ' ')
python3 - "$NB" > .harness/saved/own.txt <<'PY'
import json, sys
nb = int(sys.argv[1]); seen = set()
for m in json.load(open(".harness/saved/manifest.json")):
    for p in [m["Config"]] + m["Layers"][nb:]:
        if p not in seen: seen.add(p); print(("config " if p == m["Config"] else "layer ") + p)
PY
NL=0; NC=0; TL=0
while read -r kind p; do
  if [ "$kind" = layer ]; then c=$(gzip -dc ".harness/saved/$p" | grep -aoF -- "$TOKEN" | wc -l | tr -d ' '); NL=$((NL + 1))
  else c=$(grep -aoF -- "$TOKEN" ".harness/saved/$p" | wc -l | tr -d ' '); NC=$((NC + 1)); fi
  TL=$((TL + c)); done < .harness/saved/own.txt
[ "$TL" = 0 ] || die "the demo token is in an image layer or config: $TL copies"
[ "$NL" -gt 0 ] && [ "$NC" -gt 0 ] || die "no image layer or config was searched ($NL, $NC)"
rm -rf .harness/saved
# LOOPBACK ONLY (brief S3.10): a docker run/create line that publishes a port must publish it on 127.0.0.1 - and none here does
DL=$(cat receipts.sh peek.sh README.md exercise/README.md docker/* | grep -E 'docker (container )?(run|create)' || true)
[ "$(printf '%s\n' "$DL" | grep -E -- ' (-p|--publish)[ =]' | grep -cvE -- ' (-p|--publish)[ =]127\.0\.0\.1:' || true)" = 0 ] || die "a docker run/create line publishes a port off loopback"
echo "  ports: docker run/create lines in receipts.sh, peek.sh, the READMEs and docker/: $(printf '%s\n' "$DL" | grep -c . || true) · publishing a port: $(printf '%s\n' "$DL" | grep -cE -- ' (-p|--publish)[ =]' || true)"
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the exercise, docker/, peek.sh and receipts.md5 - and in the 8 images' $NL distinct own layers (each after the base image's $NB, unpacked) and $NC distinct configs; no absolute path in any capture"

# "Boot wrote the list into the jar: a file called layers dot idx ... its tools mode lists four layers ... about sixteen
# million bytes ... TiffinBox's own: about two bytes in every thousand ... an ordinary jar plus one index file ... layertools
# now fails"
x layers '^  - "dependencies": 30 lines, every one a jar under BOOT-INF/lib/: yes$'
x layers '^  - "spring-boot-loader": 1 line: org/$'
x layers '^  - "snapshot-dependencies": 0 lines$'
x layers '^  - "application": 5 lines: BOOT-INF/classes/ BOOT-INF/classpath\.idx BOOT-INF/layers\.idx BOOT-INF/lib/tiffinbox-core-1\.0\.0\.jar META-INF/$'
x layers '^  the jar: 169 entries, the index among them 1 · the manifest names it: Spring-Boot-Layers-Index: BOOT-INF/layers\.idx$'
[ "$(blk layers '$ java -Djarmode=tools -jar after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar list-layers' '$ ' | grep -vc '^  exit ')" = 4 ] || die "layers: list-layers names four layers"
x layers '^  dependencies           files 30 · bytes 15[0-9]{6}$'
x layers '^  spring-boot-loader     files 99 · bytes [0-9]+$'
x layers '^  snapshot-dependencies  files 0 · bytes 0$'
x layers '^  application            files 12 · bytes [0-9]+$'
x layers '^  the four: 141 files, 16[0-9]{6} bytes · application.s share of those bytes: 2\.[0-4] in 1,000$'
x layers "^  exit 1 · standard output 0 lines · Error: Unsupported jarmode 'layertools'\$"
echo "  layers: layers.idx 30 / 1 / 0 / 5 lines · list-layers 4 · extract: 30 / 99 / 0 / 12 files, application ~2 in 1,000 · layertools: exit 1, Unsupported jarmode"

# "one property, project dot build dot output timestamp ... the last course's exercise ... today it lands in TiffinBox"
x change '^files, README aside: the previous tree 18 · after/ 18 · in both 18: identical 17, changed 1$'
CP=$(blk change 'pom.xml, every changed line' '  removed ')
has1 "$CP" '+    <project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>' change
x change '^  removed 0 · added 1$'
x change "^the same line in Course 3's packaging POM \(\\\$C3POM\), where its exercise put it: 1 time\(s\)\$"
echo "  change: the root POM +1 code line, project.build.outputTimestamp 2026-09-15T00:00:00Z - Course 3's line, the same"

# "one word changed: application moved, two files - the changed class, and tiffinbox-core's jar, which nobody touched; the
# other three stayed the same ... build twice with no change and that jar still moves: the same contents, eighteen of its
# nineteen entries dated by their build ... with it: every entry carries that date; in one time zone, two clean builds give
# the same bytes, and not one layer moves; one changed word moves one class file" - and the time zone, measured
M1=$(blk moved 'one word changed, without it' 'no change, built twice, without it'); M2B=$(blk moved 'no change, built twice, without it' 'no change, built twice, with it')
M3=$(blk moved 'no change, built twice, with it' 'one word changed, with it'); M4=$(blk moved 'one word changed, with it' 'after/ built twice more'); MT=$(blk moved 'after/ built twice more' '')
has1 "$M1" '  application            12 files · moved: BOOT-INF/classes/com/tiffinbox/web/TiffinBoxServer.class BOOT-INF/lib/tiffinbox-core-1.0.0.jar' moved
has1 "$M1" '  layers that moved: 1 of 4' moved
printf '%s\n' "$M1" | grep -qE '^  the jar: (16[0-9]{6}) bytes, then \1 · md5 equal: no$' || die "moved: one word, without it - the same size, a new jar"
has1 "$M2B" '  application            12 files · moved: BOOT-INF/lib/tiffinbox-core-1.0.0.jar' moved
has1 "$M2B" '  layers that moved: 1 of 4' moved
printf '%s\n' "$M2B" | grep -qE '^  the jar: [0-9]+ bytes, then [0-9]+ · md5 equal: no$' || die "moved: no change, no timestamp - two jars"
has1 "$M2B" "  tiffinbox-core-1.0.0.jar, build 1 against build 2: entries 19 · the same content (CRC-32) 19 · the same time 1: META-INF/maven/com.tiffinbox/tiffinbox-core/pom.xml - it carries its source file's own time" moved
printf '%s\n' "$M3" | grep -qE '^  the jar: ([0-9]+) bytes, then \1 · md5 equal: yes$' || die "moved: with the timestamp - the same bytes"
has1 "$M3" '  layers that moved: 0 of 4' moved
has1 "$M3" '  tiffinbox-core-1.0.0.jar, build 1 against build 2: entries 19 · the same content (CRC-32) 19 · the same time 19 · the time every entry carries: 20260915.000000 (19 of 19)' moved
has1 "$M4" '  application            12 files · moved: BOOT-INF/classes/com/tiffinbox/web/TiffinBoxServer.class' moved
has1 "$M4" '  layers that moved: 1 of 4' moved
printf '%s\n' "$M4" | grep -qE '^  the jar: (16[0-9]{6}) bytes, then \1 · md5 equal: no$' || die "moved: one word, with it - the same size, a new jar"
[ "$(printf '%s\n' "$M1" "$M2B" "$M3" "$M4" | grep -cE '^  (dependencies|spring-boot-loader|snapshot-dependencies) +[0-9]+ files · same$')" = 12 ] || die "moved: the other three layers stay the same in all four comparisons"
printf '%s\n' "$MT" | grep -qE '^  the jar: ([0-9]+) bytes, then \1 · md5 equal: no$' || die "moved: two time zones - the same size, two jars"
has1 "$MT" '  tiffinbox-core-1.0.0.jar inside them, byte for byte the same: yes' moved
has1 "$MT" '  entries 169 and 169 · the same name, content (CRC-32) and date 169 · whose extra fields differ 8, every one under BOOT-INF/classes/: yes' moved
has1 "$MT" '  in what: their NTFS time field (extra field 0x000a) - 5.5 hours apart, every one' moved
echo "  moved: one word, without it -> application: TiffinBoxServer.class + tiffinbox-core's jar · no change, without it -> tiffinbox-core (18 of 19 entries dated by the build) · with it: no change -> 0 of 4, md5 equal; one word -> TiffinBoxServer.class alone · two time zones: 8 entries' NTFS time 5.5 h apart, md5 differs"

# "the layered image: eleven layers, ten shared, one new - under thirty thousand bytes ... saved together, the two keep those
# ten layers once ... the single-jar image: eight layers, one new - about sixteen million ... rebuild with no change: not one
# layer differs, yet the two image IDs do ... a record of the build ... compare layers, not IDs"
BL=$(blk bytes 'the layered image - docker/Dockerfile' 'the single-jar image'); BF=$(blk bytes 'the single-jar image' 'the layered image again'); BA=$(blk bytes 'the layered image again' '')
has1 "$BL" '  the two, saved together (docker save): layers 22 · distinct layer files 10' bytes
has1 "$BL" '  RootFS layers: 11 and 11 · the same 10 · different 1 · the base image'"'"'s own layers first, unchanged: yes, 6 of 6' bytes
printf '%s\n' "$BL" | grep -qE '^    28672 +COPY /builder/extracted/application/ \./ # buildkit$' || die "bytes: the application layer, 28672 bytes"
printf '%s\n' "$BL" | grep -qE '^    15[0-9]{6} +COPY /builder/extracted/dependencies/ \./ # buildkit$' || die "bytes: the dependencies layer"
has1 "$BL" '  the layer that differs, counted from the base up: 11 of 11' bytes
printf '%s\n' "$BL" | grep -qE '^  exit 0, 0 · warnings in the two build logs: 0 · layer downloads in them: 0$' || die "bytes: the layered builds"
has1 "$BF" '  RootFS layers: 8 and 8 · the same 7 · different 1 · the base image'"'"'s own layers first, unchanged: yes, 6 of 6' bytes
printf '%s\n' "$BF" | grep -qE '^    16134144 +COPY tiffinbox-web-1\.0\.0\.jar application\.jar # buildkit$' || die "bytes: the single jar's layer, 16134144 bytes"
has1 "$BF" '  the layer that differs, counted from the base up: 8 of 8' bytes
printf '%s\n' "$BF" | grep -qE '^  exit 0, 0 · warnings in the two build logs: 0 · layer downloads in them: 0$' || die "bytes: the single-jar builds"
has1 "$BA" '  exit 0 · RootFS layers, against tiffinbox-layers:recipe-on: 11 and 11 · the same 11 · different 0' bytes
has1 "$BA" '  the two image IDs equal: no · what the ID names here: application/vnd.oci.image.index.v1+json · attestation manifests its build exported: 1' bytes
has1 "$BA" '  exit 0, 0 · attestation manifests the two builds exported: 0 · RootFS layers: 11 and 11 · the same 11 · different 0 · the two image IDs equal: yes' bytes
echo "  bytes: layered 11 layers, 10 the same, 1 new (application, 28672); saved together 22 layers in 10 files · single-jar 8, 7, 1 new (16134144) · no change: 0 differ, IDs differ (an index with an attestation); --provenance=false: IDs equal"

# "the change is one word, on to at: the same size ... A: the image says at ... B: the build sends two kilobytes, every copy
# comes from the cache, and the image still says on ... no cache didn't help ... touch it, and the build sends it ... A again"
x stale '^  application\.jar: ([0-9]+) bytes and \1 · the same size: yes · the same file time: yes · md5 equal: no$'
SA=$(blk stale 'A   ' 'B   '); SB=$(blk stale 'B   ' 'C   '); SC=$(blk stale 'C   ' 'D   '); SD=$(blk stale 'D   ' 'A′  '); SA2=$(blk stale 'A′  ' 'warnings in the ten')
has1 "$SA" '  TiffinBox listening on' stale; has1 "$SA" '  TiffinBox listening at' stale; has1 "$SA" '  exit 0 · transferring context: 16.14MB' stale
[ "$(printf '%s\n' "$SB" | grep -cx '  TiffinBox listening on')" = 2 ] && ! printf '%s\n' "$SB" | grep -q 'listening at' || die "stale: B's image says on, before and after the change"
TJ=$(sed -nE 's/^  application\.jar: ([0-9]+) bytes and .*/\1/p' .r-stale.out)
printf '%s\n' "$SB" | grep -qE "^  exit 0 · transferring context: [0-9.]+kB - less than the thin jar alone \($TJ bytes\): yes · COPY steps CACHED: 4 of 4\$" || die "stale: B sent less than the jar, and every COPY came from the cache"
printf '%s\n' "$SC" | grep -qE "^  exit 0 · transferring context: [0-9.]+kB - less than the thin jar alone \($TJ bytes\): yes · COPY steps CACHED: 0 of 4\$" || die "stale: C sent less than the jar, and nothing came from the cache"
has1 "$SC" '  TiffinBox listening on' stale
printf '%s\n' "$SD" | grep -qE "^  exit 0 · transferring context: [0-9.]+kB - less than the thin jar alone \($TJ bytes\): no · COPY steps CACHED, the three layers the change leaves alone: 3 of 3\$" || die "stale: D sent the jar; the three layers it leaves alone came from the cache"
has1 "$SD" '  TiffinBox listening at' stale
[ "$(printf '%s\n' "$SA" | grep -v '^\$ ')" = "$(printf '%s\n' "$SA2" | grep -v '^\$ ')" ] || die "stale: A' is not A, line for line"
x stale '^warnings in the ten build logs: 0 · layer downloads in them: 0$'
echo "  stale: same size, same time, new md5 · A at · B less than the jar sent, 4 of 4 CACHED, on · C --no-cache on · D touched, the jar sent -> at · A' = A"

# "every rebuild took under five seconds, and the layered image was not the faster one ... the next course built no image ...
# both rebuilds took seconds"
x timing '^  every timed build re-ran its jar step, none from the cache: 12 of 12$'
x timing '^  rebuilds under five seconds: the layered image 6 of 6 · the single-jar image 6 of 6$'
x timing "^  the median of the six - the layered image's longer than the single-jar image's: yes\$"
# "its recipe starts Java, to run extract, in every build": the layered rebuild ran three steps, one a java process; the
# single-jar rebuild one
x timing '^  COPY and RUN steps each rebuild ran, not from the cache - the layered image: 3 of 6, one a java process in 6 of 6 · the single-jar image: 1 of 1 in 6 of 6$'
x timing '^  folders [0-9]+ · files named Dockerfile in them 0 · files that say docker, any case 0$'
echo "  timing: 12 of 12 real rebuilds · under 5 s: 6 of 6 and 6 of 6 · the layered median the longer · Course 4: 0 Dockerfiles"

# "copy the image's app folder out, and start it with the image's own command, here on the Mac: the same seven responses"
x serve '^  exit 0 · the image.s ENTRYPOINT: \["java","-jar","application\.jar"\]$'
x serve '^  exit 0 · \.harness/fromimage: application\.jar lib · lib/: 31 jars$'
x serve '^  against Boot.s extract of after/.s jar on the Mac \(--application-filename application\.jar\): lib/ byte for byte the same 31 of 31 · application\.jar.s entries, by name and content \(CRC-32\), the same ([0-9]+) of \1$'
x serve "^  exit 0 · the seven responses: 7 lines · md5 $S115\$"
echo "  serve: /app out of the image (application.jar + 31 jars, = the Mac's extract) -> java -jar on 18850 -> 115c36ba..."

# the exercise's end state: tiffinbox-core in dependencies, without the changed line
x exercise '^  \.harness/mine-layers/dependencies/lib/tiffinbox-core-1\.0\.0\.jar$'
x exercise '^  must be 16 characters$'
x exercise "^the line the perl command changed, in \.harness/mine's own source: 1 time\(s\)\$"
x exercise '^  - "dependencies": +- "BOOT-INF/lib/"$'
x exercise '^  after/.s own jar, built from the root: - "application":   - "BOOT-INF/lib/tiffinbox-core-1\.0\.0\.jar"$'
echo "  exercise: the README's commands -> tiffinbox-core-1.0.0.jar under dependencies/ (web alone), without the changed line; from the root, under application"

# the demo files: the folder copy and the single-jar image each differ from the recipe where they say; at/ is one line
[ "$(blk files 'at/'"'"'s TiffinBoxServer.java' 'peek.sh' | grep -c '^  [<>] ')" = 2 ] || die "files: at/ is one line"
echo "  files: folders.Dockerfile and single.Dockerfile against the recipe · at/ one line · peek.sh whole"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit14: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and image layer"
