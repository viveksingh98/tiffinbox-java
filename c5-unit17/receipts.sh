#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · Docker Compose for Development — this unit's receipts. TiffinBox gets a database for development (the anchor
# change: compose.yaml at the anchor's root - one official Postgres, a fixed project name, a loopback port, no password, the
# data in a named volume - and Boot's Docker Compose support as an optional dependency, switched off in application.yaml and on
# by the profile "dev", application-dev.yaml). This script builds the tree, starts TiffinBox with the profile and watches what
# Boot does with Docker, opens the jar Boot ships, measures why the support is switched off by default, starts TiffinBox every
# earlier way without the profile, prints what Boot hands over for a database, takes Docker away from one JVM (the break), and
# shows what a volume without a name leaves behind. Nine captures, each run three times and hashed; cap() DIES when a hash
# differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is
# masked (gsub), and the last checks count 0 raw copies of it - and of the exercise's own token - in every capture and file.
#   change    the previous tree against after/, file by file: the two new files whole, the two changed ones as diffs; both
#             trees' jars, entry by entry; the class path Maven lists for tiffinbox-web, before and after; the new module's
#             META-INF/spring.factories, whole
#   lifecycle README.md's dev run (a developer's copy of after/: compose.yaml and a config tree beside the README, built the
#             README's way), one logger at TRACE: every docker command Boot runs, Compose's own lines, the container while
#             TiffinBox runs, the seven responses, the command Boot runs when TiffinBox stops, and what is left
#   jar       the jar Boot ships: one copy of after/, built five times - A as declared · B excludeDockerCompose off · C
#             includeOptional on · D both · A' = A - each jar's entries counted; and A's jar run with the profile, beside
#             compose.yaml
#   gate      from a folder with a config tree and no compose.yaml, on the class path that holds the module, no profile: A
#             after/ as built · B the switch's three lines deleted (Boot's default) · A' = A
#   default   no profile, the earlier ways TiffinBox starts: the executable jar; the jar extracted; the image from the
#             anchor's Dockerfile - each serving the seven
#   details   a harness on TiffinBox's class path plus spring-boot-jdbc and the Postgres driver (harness/details/pom.xml), the
#             profile on: the connection details Boot registers, the DataSource, the condition report's verdict; then
#             TiffinBox itself, pointed at that Postgres
#   docker    the break: A the profile, Docker reachable · B DOCKER_HOST, for this JVM only, a socket that does not exist · C
#             B with the switch off on the command line · A' = A
#   volume    Docker Compose alone, no TiffinBox: A compose.yaml as the anchor has it, up then down · B the same file without
#             its volume lines · A' = A
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit16/after (the anchor as the last unit to change it left it), COPIED to .harness/before; this script
# never writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change, built in
# place, clean. Every run of TiffinBox on the Mac starts in a folder under .harness/: .harness/dev (after/ copied, built the
# README's way, a config tree beside its README - a developer's own copy), .harness/plain (a config tree, no compose.yaml),
# .harness/mine (the exercise's). Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison
# set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from
# the file).
# Masks and filters (README.md declares each; gsub only): the demo token becomes "[masked: the 26-character token]"; this
# folder's absolute path "…", the folder above it "…/..", the home folder "~"; a line that is a 64-hex container ID "[a container
# ID]"; an image ID "[an image ID]"; any other 64-hex name "[a volume ID]"; the 12-hex container ID in a "docker inspect" command
# Boot runs "[a container ID]"; an embedded H2's random name "<a random name>"; a PID "<pid>" - in every line of every capture. A
# Boot log line is printed from its message on (the time, level, PID, thread and logger columns dropped), trailing spaces
# dropped; ProcessRunner's lines keep their thread, in brackets. Long logs are filtered, and the lines a filter drops are counted.
# No duration is captured: no "Started ... in" line, no time.
# Ports (brief ⚑10, 18880-18889): lifecycle 18880 · Postgres 18881 (compose.yaml's: every run with the profile publishes it) ·
# gate 18882 · details 18883 · docker 18884 · default 18885 (jar), 18886 (extracted), 18887 (image) · exercise 18888 (its
# README's) · jar 18889. 18425 is checked free too (TiffinBox's default port). Every port is published on 127.0.0.1 only.
# Docker names (no unit number): the compose project tiffinbox-dev - the anchor's (compose.yaml's name:) - with its network
# tiffinbox-dev_default, its container tiffinbox-dev-postgres-1 and its volume tiffinbox-dev_data; the image tiffinbox-nodev:1.0.0
# and the container tiffinbox-nodev, this unit's own; in volume B, one volume with no name, its ID recorded while its container
# runs. The exit trap removes exactly those: the project with docker compose -p tiffinbox-dev down -v (repeated until Docker
# lists none of its containers, volumes or networks), the image and the container by name, the volume by its recorded ID.
# The project is the anchor's, so a developer's own dev run uses it too: this script refuses to start while Docker lists
# anything of it, and touches it only after that check. BuildKit's cache is left: no selective prune exists, and a global
# prune would touch other people's cache. Never a prune: a third-party container and its images live on this Docker.
set -e
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
PROJ=tiffinbox-dev                                   # the anchor's compose project: compose.yaml says name: tiffinbox-dev
IMAGE=tiffinbox-nodev:1.0.0; BOX=tiffinbox-nodev     # this unit's own image and container (default, the image run)
U="$PWD"; UP="$(cd .. && pwd)"
pid=""; VOLS=""; SNAP=""; XTOK=""
# projcount: the containers, volumes and networks Docker lists for the project right now
projcount() { local c v n
  c=$(docker ps -aq --filter "label=com.docker.compose.project=$PROJ" 2> /dev/null | grep -c . || true)
  v=$(docker volume ls -q --filter "label=com.docker.compose.project=$PROJ" 2> /dev/null | grep -c . || true)
  n=$(docker network ls -q --filter "label=com.docker.compose.project=$PROJ" 2> /dev/null | grep -c . || true)
  echo $((c + v + n)); }
# reapcli: Docker's command-line tool, started by a JVM of this script for this folder's compose files (Boot runs it as a
# child process: "docker compose --file <this folder>/.harness/…/compose.yaml …"), still running after that JVM is gone -
# stopped, so it cannot create anything after the clean-up. Every command is guarded.
reapcli() { local k=0 p
  while [ $k -lt 20 ]; do p=$(pgrep -f -- "compose --file $U/" 2> /dev/null || true); [ -n "$p" ] || return 0
    kill $p 2> /dev/null || true; sleep 0.5; k=$((k + 1)); done; return 0; }
# sweep: this script's own Docker names - and, once the start-up check has found the project empty (SNAP), the project and the
# volumes recorded as having no name. Every command is guarded: a name already gone makes docker exit 1, and nothing here may
# end the clean-up early. The project is removed with down -v, repeated until Docker lists nothing of it (15 s at most).
sweep() { local k=0 v
  docker rm -f "$BOX" > /dev/null 2>&1 || true; docker image rm -f "$IMAGE" > /dev/null 2>&1 || true
  [ -n "$SNAP" ] || return 0
  while [ $k -lt 15 ]; do docker compose -p "$PROJ" down -v > /dev/null 2>&1 || true
    [ "$(projcount)" = 0 ] && break; k=$((k + 1)); sleep 1; done
  for v in $VOLS; do docker volume rm -f "$v" > /dev/null 2>&1 || true; done; return 0; }
# On every exit - the end, a failed check, or Ctrl-C - stop the JVM this script started in the background, if it still runs
# (SIGTERM: Boot's shutdown hook then runs docker compose stop); stop any docker command a JVM of this script left running
# (reapcli); remove this script's Docker names and the project (sweep); drop the lock. A background job of a non-interactive
# shell ignores the terminal's Ctrl-C - so do the docker commands a JVM starts - so without these an interrupted run would
# leave TiffinBox listening and Postgres running. $pid is cleared whenever the JVM has been reaped. The clean-up ignores a second
# Ctrl-C, and nothing in it can fail under set -e (a JVM stopped by SIGTERM exits 143), so it always reaches the rmdir; the
# script still exits 130 after an interrupt (tested: README.md, "Interrupted").
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; reapcli || true; sweep || true; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v openssl > /dev/null || die "openssl is needed: the exercise's README makes its own token with it"
# A variable of yours must not become a property source, a JVM flag, a build setting or a Compose setting: every TIFFINBOX_*,
# SPRING_* and COMPOSE_* variable, the two variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS, and the variables that
# change what docker build does (DOCKER_BUILDKIT, BUILDKIT_*, BUILDX_*, DOCKER_DEFAULT_PLATFORM, SOURCE_DATE_EPOCH) are removed
# first. DOCKER_HOST and DOCKER_CONTEXT stay: they say which Docker to reach.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|COMPOSE_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\|DOCKER_BUILDKIT\|BUILDKIT_[A-Za-z0-9_]*\|BUILDX_[A-Za-z0-9_]*\|DOCKER_DEFAULT_PLATFORM\|SOURCE_DATE_EPOCH\)=.*/\1/p'); do unset "$v"; done
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -e after/secrets ] || [ -e after/tiffinbox-local.yaml ] && die "after/ holds a secrets/ or a tiffinbox-local.yaml - it is the anchor's frozen copy, and the image's build context; remove them"
M2="$PWD/.m2-demo"
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
CPF=tiffinbox-web/target/classpath.txt               # the class path file README.md's build writes (dependency:build-classpath)
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server that every capture stops. It is written
# into files under .harness/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f after/compose.yaml ] && [ -f after/tiffinbox-web/src/main/resources/application-dev.yaml ] || die "after/compose.yaml or after/…/application-dev.yaml is missing"
[ -f harness/details/pom.xml ] && [ -f harness/details/Details.java ] || die "harness/details/ is missing its pom.xml or Details.java"

# Docker: asked first; started only if it does not answer (OrbStack's own command, when there is one); then polled - this Mac
# has no timeout command - for 60 s at most.
if ! docker info > /dev/null 2>&1; then
  command -v orb > /dev/null 2>&1 && { orb start > /dev/null 2>&1 || true; }
  i=0; until docker info > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 60 ] || die "Docker does not answer after 60 s - start it (OrbStack: orb start; Docker Desktop: open it), then run again"; sleep 1; done; fi
for img in postgres:18-alpine eclipse-temurin:25-jre; do
  docker image inspect "$img" > /dev/null 2>&1 || die "$img is not on this machine - pull it once (docker pull $img: network, a build-time resolution), then run again"; done
# This script's own names, left by an interrupted run: removed before anything else.
docker rm -f "$BOX" > /dev/null 2>&1 || true; docker image rm -f "$IMAGE" > /dev/null 2>&1 || true
# The project is the anchor's: anything Docker lists of it now is not this run's - never touched; the message names the way out.
[ "$(projcount)" = 0 ] || die "Docker lists containers, volumes or networks of the compose project $PROJ - a dev run of TiffinBox left them, or a run of this script that could not clean up. This script removes only what it creates; remove them yourself (docker compose -p $PROJ down -v), then run again"
SNAP=1

# The ports, BEFORE .harness/ is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which
# lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18880 18881 18882 18883 18884 18885 18886 18887 18888 18889; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# readme PATTERN [FILE]: the first line of FILE (README.md) that matches PATTERN - so a label never claims what the README says
readme() { grep -m1 -E "$1" "${2:-README.md}" || true; }
# The commands, read from README.md's "Commands" section and asserted - receipts.sh runs them as the file gives them.
C_PACKAGE=$(readme '^mvn -o -B -f after/pom\.xml -Dmaven\.repo\.local="\$M2" -DskipTests clean package$')
C_DEVBUILD=$(readme '^mvn -o -B -f \.harness/dev/pom\.xml -Dmaven\.repo\.local="\$M2" -DskipTests clean package dependency:build-classpath -Dmdep\.outputFile=target/classpath\.txt$')
C_DEV=$(readme '^cd \.harness/dev && java -cp "tiffinbox-web/target/classes:\$\(cat tiffinbox-web/target/classpath\.txt\)" com\.tiffinbox\.web\.TiffinBoxServer --tiffinbox\.port=18880 --spring\.profiles\.active=dev$')
C_JARS=$(readme '^mvn -o -B -f \.harness/jars/pom\.xml -Dmaven\.repo\.local="\$M2" -DskipTests clean package$')
C_INCOPT=$(grep -m1 -xF -- "sed -i '' 's|<artifactId>spring-boot-maven-plugin</artifactId>|&<configuration><includeOptional>true</includeOptional></configuration>|' .harness/jars/tiffinbox-web/pom.xml" README.md || true)
C_JARDEV=$(readme '^cd \.harness/dev && java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=18889 --spring\.profiles\.active=dev --logging\.level\.org\.springframework\.boot\.docker\.compose\.core\.ProcessRunner=trace$')
C_UNGSED=$(grep -m1 -xF -- "sed -i '' '/^  docker:\$/,/^      enabled: false\$/d' .harness/ungated/tiffinbox-web/src/main/resources/application.yaml" README.md || true)
C_GATE=$(readme '^cd \.harness/plain && java -cp "\.\./dev/tiffinbox-web/target/classes:\$\(cat \.\./dev/tiffinbox-web/target/classpath\.txt\)" com\.tiffinbox\.web\.TiffinBoxServer --tiffinbox\.port=18882$')
C_JAR=$(readme '^cd \.harness/dev && java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=18885$')
C_EXTRACT=$(readme '^cd \.harness/dev && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar extract --destination tiffinbox-web/target/extracted$')
C_XCP=$(readme '^cd \.harness/dev && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1\.0\.0\.jar:tiffinbox-web/target/extracted/lib/\*" com\.tiffinbox\.web\.TiffinBoxServer --tiffinbox\.port=18886$')
C_BUILD=$(readme '^docker build -q -t tiffinbox-nodev:1\.0\.0 after$')
C_RUN=$(readme '^docker run -d --name tiffinbox-nodev -m 512m -v "\$PWD/\.harness/dev/secrets:/app/secrets:ro" -p 127\.0\.0\.1:18887:18425 tiffinbox-nodev:1\.0\.0$')
C_HCP=$(readme '^mvn -o -q -B -f harness/details/pom\.xml -Dmaven\.repo\.local="\$M2" dependency:build-classpath -Dmdep\.outputFile="\$PWD/\.harness/details/classpath\.txt"$')
C_JAVAC=$(readme '^javac -cp "\.harness/dev/tiffinbox-web/target/classes:\$\(cat \.harness/dev/tiffinbox-web/target/classpath\.txt\):\$\(cat \.harness/details/classpath\.txt\)" -d \.harness/details/classes harness/details/Details\.java$')
C_DETAILS=$(readme '^cd \.harness/dev && java -cp "\.\./details/classes:tiffinbox-web/target/classes:\$\(cat tiffinbox-web/target/classpath\.txt\):\$\(cat \.\./details/classpath\.txt\)" details\.Details --tiffinbox\.port=18883 --spring\.profiles\.active=dev$')
C_ONPG=$(grep -m1 -xF -- "cd .harness/dev && java -cp \"tiffinbox-web/target/classes:\$(cat tiffinbox-web/target/classpath.txt):\$(cat ../details/classpath.txt)\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18883 --spring.profiles.active=dev '--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:18881/tiffinbox?user=tiffinbox'" README.md || true)
C_DOCKB=$(readme '^cd \.harness/dev && DOCKER_HOST=unix:///nonexistent/docker\.sock java -cp "tiffinbox-web/target/classes:\$\(cat tiffinbox-web/target/classpath\.txt\)" com\.tiffinbox\.web\.TiffinBoxServer --tiffinbox\.port=18884 --spring\.profiles\.active=dev$')
C_ANON=$(grep -m1 -xF -- "sed '/^    volumes:\$/,/^      - data:/d; /^volumes:\$/,\$d' after/compose.yaml > .harness/anon/compose.yaml" README.md || true)
C_UP=$(readme '^docker compose -f \.harness/dev/compose\.yaml up -d --wait$')
C_DOWN=$(readme '^docker compose -f \.harness/dev/compose\.yaml down$')
C_CLEAN=$(readme '^docker compose -p tiffinbox-dev down -v$')
for c in "$C_PACKAGE" "$C_DEVBUILD" "$C_DEV" "$C_JARS" "$C_INCOPT" "$C_JARDEV" "$C_UNGSED" "$C_GATE" "$C_JAR" "$C_EXTRACT" "$C_XCP" "$C_BUILD" "$C_RUN" "$C_HCP" "$C_JAVAC" "$C_DETAILS" "$C_ONPG" "$C_DOCKB" "$C_ANON" "$C_UP" "$C_DOWN" "$C_CLEAN"; do
  [ -n "$c" ] || die "README.md no longer gives the twenty-two commands this script runs (Commands)"; done
# The variants: each is a README command with one thing changed, and each derivation is asserted
one() { [ "$(printf '%s\n' "$1" | tr ' ' '\n' | grep -c .)" = "$(( $(printf '%s\n' "$2" | tr ' ' '\n' | grep -c .) + $3 ))" ] && [ "$1" != "$2" ] || die "$4 must be its README command with one thing changed"; }
TRACE=--logging.level.org.springframework.boot.docker.compose.core.ProcessRunner=trace
C_LIFE="$C_DEV $TRACE"; one "$C_LIFE" "$C_DEV" 1 "the lifecycle run (one logger at TRACE)"
C_BEFORE=${C_DEVBUILD/.harness\/dev\//.harness/before/}; one "$C_BEFORE" "$C_DEVBUILD" 0 "the previous tree's build"
C_UNGBUILD=${C_DEVBUILD/.harness\/dev\//.harness/ungated/}; one "$C_UNGBUILD" "$C_DEVBUILD" 0 "the ungated tree's build"
C_JARSX="$C_JARS -Dspring-boot.repackage.excludeDockerCompose=false"; one "$C_JARSX" "$C_JARS" 1 "jar B's build"
C_GATEB=${C_GATE//..\/dev\//..\/ungated\/}; one "$C_GATEB" "$C_GATE" 0 "gate B"
C_DOCKA=${C_DEV/--tiffinbox.port=18880/--tiffinbox.port=18884}; one "$C_DOCKA" "$C_DEV" 0 "docker A (the port)"
[ "${C_DOCKB/DOCKER_HOST=unix:\/\/\/nonexistent\/docker.sock /}" = "$C_DOCKA" ] || die "docker B must be docker A with DOCKER_HOST in front of java"
C_DOCKC="$C_DOCKB --spring.docker.compose.enabled=false"; one "$C_DOCKC" "$C_DOCKB" 1 "docker C"
C_UPB=${C_UP/.harness\/dev\//.harness/anon/}; one "$C_UPB" "$C_UP" 0 "volume B's up"
C_DOWNB=${C_DOWN/.harness\/dev\//.harness/anon/}; one "$C_DOWNB" "$C_DOWN" 0 "volume B's down"
C_DOWNV="$C_DOWN -v"; one "$C_DOWNV" "$C_DOWN" 1 "down -v"
C_DOWNBV="$C_DOWNB -v"; one "$C_DOWNBV" "$C_DOWNB" 1 "volume B's down -v"

# ---- build: the previous tree, after/ and a developer's copy of it - each clean, offline - before any capture ---------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target ../c5-unit16/after/ .harness/before/
# mbuild 'COMMAND' LOG LABEL: README's Maven command, run as written (eval), its log kept in LOG (never printed whole); Maven
# Central only if the offline build could not resolve something - and the terminal says which (offline: yes / no), so a run
# that went online is never silent.
mbuild() { local how=yes ec=0
  (eval "$1") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${1/mvn -o /mvn }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
mbuild "$C_BEFORE" .harness/build-before.log ".harness/before (the previous tree)"
mbuild "$C_PACKAGE" .harness/build-after.log "after/"
rsync -a --exclude target after/ .harness/dev/; tree .harness/dev
mbuild "$C_DEVBUILD" .harness/build-dev.log ".harness/dev (after/ copied, with a config tree)"
rsync -a --exclude target after/ .harness/ungated/
(eval "$C_UNGSED") || die "the ungated tree's sed failed"
[ "$(diff after/tiffinbox-web/src/main/resources/application.yaml .harness/ungated/tiffinbox-web/src/main/resources/application.yaml | grep -c '^<')" = 3 ] || die "the ungated tree must lose three lines"
mbuild "$C_UNGBUILD" .harness/build-ungated.log ".harness/ungated (the switch's three lines deleted)"
mkdir -p .harness/plain; tree .harness/plain
mkdir -p .harness/anon .harness/details
(eval "$C_ANON") || die "the unnamed-volume compose file could not be made"
mbuild "$C_HCP" .harness/build-details.log "the harness's class path (harness/details/pom.xml)"
(eval "$C_JAVAC") > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile"; }
echo "  compiled harness/details/Details.java"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines)
raw() { local t=$1; shift; cat "$@" | grep -oF -- "$t" | wc -l | tr -d ' '; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }
# runf 'COMMAND': print it exactly as typed, run it in the foreground (eval, in a subshell, from this folder), its standard
# output to .harness/run.out and its standard error to .harness/run.err; its exit code in $ec
runf() { echo "\$ $1"; ec=0; (eval "$1") > .harness/run.out 2> .harness/run.err < /dev/null || ec=$?; }
# startjar 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec in front of java, so
# $pid is java's own pid), its standard output to .harness/jar.out and its standard error to .harness/jar.err
startjar() { echo "\$ $1"; (eval "${1/ java / exec java }") > .harness/jar.out 2> .harness/jar.err < /dev/null & pid=$!; }
# jrun 'COMMAND': the same, for a run that ends by itself - a start that must fail, or the harness, which stops itself; waits
# for its exit, 60 s at most; its exit code in $ec
jrun() { local i=0; startjar "$1"
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && die "it was still running 60 s later (the exit trap stops it)"
  ec=0; wait "$pid" || ec=$?; pid=""; }
# listening: what the operating system says the process listens on (lsof), once it listens - or "nothing" once it exited
listening() { local a="" i=0
  while [ $i -lt 160 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# up: the line after a start - where it listens, and its WARN/ERROR lines so far, once its log says it listens; dies if it
# never listened
up() { local l i=0; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/jar.out >&3; die "it never listened"; }
  while ! grep -q 'TiffinBox listening' .harness/jar.out && [ $i -lt 40 ]; do sleep 0.25; i=$((i + 1)); done
  echo "  listens on: $l · $(warns .harness/jar.out)"; }
# seven PORT FOLDER: the comparison set's seven requests (POST /shutdown carries the header, read from FOLDER's config tree),
# printed as run; the JVM must leave within 15 s of them, and the port must be free again. Never call it inside $(...): wait
# needs this shell.
seven() { local i e tf=$2/$TF
  echo "\$ \$CURLSET $1 $tf"
  "$CURLSET" "$1" "$tf" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt || echo "(no POST line)"
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && die "the server on $1 was still running 15 s after POST /shutdown"
  e=0; wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }
# msg LOG PATTERN: the first log line matching PATTERN, from its message on (the time, level, PID, thread and logger columns
# dropped), trailing spaces dropped
msg() { grep -m1 -- "$2" "$1" | sed -E 's/^[^]]*\] +[^ ]+ +: //; s/^ +//; s/ +$//' || true; }
# lastmsg LOG PATTERN: the same, for the last line matching PATTERN
lastmsg() { grep -- "$2" "$1" | tail -1 | sed -E 's/^[^]]*\] +[^ ]+ +: //; s/^ +//; s/ +$//' || true; }
# clines LOG: Boot's lines about Docker Compose, in the log's order, each from its message on, trailing spaces dropped - the
# active profile; DockerComposeLifecycleManager's and DockerCli's lines (DockerCli logs Docker Compose's own output);
# ProcessRunner's "Running '…'" lines, with their thread; TiffinBox's listening line
clines() { grep -E 'profile is active|DockerComposeLifecycleManager +:|\.compose\.core\.DockerCli +:|ProcessRunner +: Running |TiffinBox listening' "$1" \
  | sed -E 's/ +$//; s/^[^[]*\[ *([^]]*)\] +([^ ]+) +: /\2 [\1] /' \
  | awk '{ l = $1; t = $2; sub(/^[^ ]+ \[[^]]*\] /, ""); sub(/^ +/, ""); if (l ~ /ProcessRunner$/) print "  " t " " $0; else print "  " $0 }' || true; }
# composelines LOG: how many of the log's lines come from Boot's Docker Compose support (its lifecycle manager, its docker
# client, its process runner)
composelines() { grep -cE 'DockerComposeLifecycleManager +:|\.compose\.core\.DockerCli +:|ProcessRunner +:' "$1" || true; }
# state: what Docker lists for the compose project now - each container with its state and exit code, each volume, each network
state() { local c
  c=$(docker ps -a --filter "label=com.docker.compose.project=$PROJ" --format '{{.Names}}' | sort | paste -sd' ' -)
  echo "  containers: ${c:-(none)}$(for x in $c; do printf ' %s' "$(docker inspect -f '{{.State.Status}} (exit code {{.State.ExitCode}})' "$x")"; done)"
  c=$(docker volume ls -q --filter "label=com.docker.compose.project=$PROJ" | sort | paste -sd' ' -); echo "  volumes: ${c:-(none)}"
  c=$(docker network ls --filter "label=com.docker.compose.project=$PROJ" --format '{{.Name}}' | sort | paste -sd' ' -); echo "  networks: ${c:-(none)}"; }
# fresh: the project, empty, before a run that starts it - printed, and fatal if not
fresh() { [ "$(projcount)" = 0 ] || die "the compose project is not empty before a run"
  echo "the compose project $PROJ, before this run: containers 0 · volumes 0 · networks 0"; }
# clean: README's clean-up command, run between two runs of one capture; its output counted, never printed
clean() { runf "$C_CLEAN"; echo "  exit $ec · lines it printed: $(cat .harness/run.out .harness/run.err | grep -c . || true) · the project now: containers, volumes and networks $(projcount)"; }
# cleanproj: the same, silently, after every run of every capture - repeated until Docker lists nothing of the project
cleanproj() { local k=0; while [ "$(projcount)" != 0 ] && [ $k -lt 15 ]; do docker compose -p "$PROJ" down -v > /dev/null 2>&1 || true; k=$((k + 1)); [ "$(projcount)" = 0 ] || sleep 1; done
  [ "$(projcount)" = 0 ] || die "the compose project could not be removed"; }
# lines in a jar
entries() { local j=$1
  echo "  BOOT-INF/lib/: $(unzip -Z1 "$j" | grep -cE '^BOOT-INF/lib/.+\.jar$' || true) jars · spring-boot-docker-compose: $(unzip -Z1 "$j" | grep -cE '^BOOT-INF/lib/spring-boot-docker-compose-' || true) · Jackson 3, jackson-core-3 and jackson-databind-3: $(unzip -Z1 "$j" | grep -cE '^BOOT-INF/lib/jackson-(core|databind)-3\.' || true)"; }

# mask: the demo token becomes a label naming its length; this folder's path "…", the folder above it "…/..", the home folder
# "~"; a line that is a 64-hex container ID "[a container ID]"; an image ID "[an image ID]"; any other 64-hex name "[a volume
# ID]"; the 12-hex container ID that ends a "docker inspect" command Boot runs "[a container ID]"; an embedded H2's random
# name "<a random name>"; a PID "<pid>" - in every line (gsub)
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)) }
  { gsub(T, "[masked: the 26-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    if ($0 ~ /^ *[0-9a-f]{64}$/) gsub(/[0-9a-f]{64}/, "[a container ID]")
    gsub(/sha256:[0-9a-f]{64}/, "[an image ID]"); gsub(/[0-9a-f]{64}/, "[a volume ID]")
    gsub(/json \. \}\} [0-9a-f]{12}/, "json . }} [a container ID]")
    gsub(/jdbc:h2:mem:[0-9a-f-]{36}/, "jdbc:h2:mem:<a random name>")
    gsub(/with PID [0-9]+/, "with PID <pid>")
    print }'; }

# boxes: this script's own container, if it exists right now
boxes() { docker ps -a --format '{{.Names}}' | grep -cx "$BOX" || true; }
unpub=""
cap() { local nm=$1 h pub i r; shift
  for i in 1 2 3; do XTOK=""; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a JVM running"
    [ "$(boxes)" = 0 ] || die "$nm left a container"
    r=$(raw "$TOKEN" .harness/cap.raw); [ -z "$XTOK" ] || r=$((r + $(raw "$XTOK" .harness/cap.raw)))
    echo "$r" > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"
    cleanproj; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot, Maven, Docker or Compose, another postgres:18-alpine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- change: the previous tree against after/; the two jars; the class path Maven lists; the new module's spring.factories ------
# ents JAR: the jar's entries, one per line, "name crc" (unzip -v), sorted
ents() { unzip -v "$1" | awk 'NR > 3 && $NF !~ /^-+$/ && NF >= 8 { print $8, $7 }' | sort; }
changecap() { local a b n=0 same=0 changed="" gone="" new="" f j1 j2 dc
  a=$(cd .harness/before && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  b=$(cd after && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  for f in $a; do if [ -f "after/$f" ]; then n=$((n + 1)); if cmp -s ".harness/before/$f" "after/$f"; then same=$((same + 1)); else changed="$changed $f"; fi; else gone="$gone $f"; fi; done
  for f in $b; do [ -f ".harness/before/$f" ] || new="$new $f"; done
  echo "files, README aside: the previous tree $(echo "$a" | wc -l | tr -d ' ') · after/ $(echo "$b" | wc -l | tr -d ' ') · in both $n: identical $same, changed $(echo $changed | wc -w | tr -d ' ')"
  echo "  only before:${gone:- (none)}"; echo "  only after: ${new:- (none)}"; echo "  changed:    ${changed:- (none)}"
  echo "  README.md, the anchor's: lines added $(diff .harness/before/README.md after/README.md | grep -c '^>' || true) · removed $(diff .harness/before/README.md after/README.md | grep -c '^<' || true)"
  for f in compose.yaml tiffinbox-web/src/main/resources/application-dev.yaml; do
    echo "after/$f, whole - $(wc -l < "after/$f" | tr -d ' ') lines, $(grep -cE '^ *#' "after/$f" || true) of them comments:"
    awk '{ printf "%3d  %s\n", NR, $0 }' "after/$f"; done
  for f in tiffinbox-web/src/main/resources/application.yaml tiffinbox-web/pom.xml; do
    echo "after/$f against the previous tree's: lines added $(diff ".harness/before/$f" "after/$f" | grep -c '^>' || true) · removed $(diff ".harness/before/$f" "after/$f" | grep -c '^<' || true)"
    diff ".harness/before/$f" "after/$f" | grep '^[<>]' | sed 's/^/  /' || true; done
  j1=".harness/before/$JAR"; j2="after/$JAR"
  echo "the two trees' jars, each built clean: md5 $(md5 -q "$j1") and $(md5 -q "$j2") · bytes $(stat -f %z "$j1") and $(stat -f %z "$j2") · the same bytes: $(cmp -s "$j1" "$j2" && echo yes || echo no)"
  ents "$j1" > .harness/e1.txt; ents "$j2" > .harness/e2.txt
  echo "  entries $(wc -l < .harness/e1.txt | tr -d ' ') and $(wc -l < .harness/e2.txt | tr -d ' ') · the same name and CRC: $(comm -12 .harness/e1.txt .harness/e2.txt | wc -l | tr -d ' ') · the rest, by name:"
  dc=$( { comm -23 .harness/e1.txt .harness/e2.txt | awk '{ print $1 }'; comm -13 .harness/e1.txt .harness/e2.txt | awk '{ print $1 }'; } | sort | uniq -c | awk '{ print $2 ($1 == 2 ? " (changed)" : "") }')
  printf '%s\n' "$dc" | while read -r f; do case "$f" in *" (changed)") echo "  $f" ;; *) grep -q "^${f} " .harness/e1.txt && echo "  $f (only before)" || echo "  $f (only after)" ;; esac; done
  echo "the class path Maven lists for tiffinbox-web (dependency:build-classpath, $CPF): the previous tree $(tr ':' '\n' < ".harness/before/$CPF" | grep -c .) jars · after/'s copy, .harness/dev, $(tr ':' '\n' < ".harness/dev/$CPF" | grep -c .)"
  tr ':' '\n' < ".harness/before/$CPF" | sed 's|.*/||' | sort > .harness/cp1.txt; tr ':' '\n' < ".harness/dev/$CPF" | sed 's|.*/||' | sort > .harness/cp2.txt
  a=$(comm -13 .harness/cp1.txt .harness/cp2.txt | paste -sd' ' -); b=$(comm -23 .harness/cp1.txt .harness/cp2.txt | paste -sd' ' -)
  echo "  only after: ${a:-(none)} · only before: ${b:-(none)}"
  echo "  Jackson's jars on .harness/dev's: $(grep -E '^jackson-' .harness/cp2.txt | paste -sd' ' -)"
  j1=$(tr ':' '\n' < ".harness/dev/$CPF" | grep '/spring-boot-docker-compose-[0-9.]*\.jar$')
  echo "$(basename "$j1"), META-INF/spring.factories, whole:"
  unzip -p "$j1" META-INF/spring.factories | sed 's/^/  /'; }
cap change changecap

# ---- lifecycle: README's dev run, one logger at TRACE: what Boot does with Docker when TiffinBox starts, and when it stops -----
lifecyclecap() { local n
  fresh
  runf "docker image inspect -f '{{json .Config.Volumes}} {{json .Config.Healthcheck}}' postgres:18-alpine"; echo "  $(cat .harness/run.out)"
  startjar "$C_LIFE"; up
  docker ps -a --filter "label=com.docker.compose.project=$PROJ" --format '{{.Names}} {{.State}} {{.Ports}}' > .harness/ps.txt
  echo "the compose project while TiffinBox runs: $(cat .harness/ps.txt)"
  seven 18880 .harness/dev
  n=$(grep -c . .harness/jar.out); clines .harness/jar.out > .harness/cl.txt
  echo "the log, start to exit: $n lines · shown $(grep -c . .harness/cl.txt) - Boot's lines about Docker Compose, the profile and TiffinBox's listening line (README, filters); not shown $((n - $(grep -c . .harness/cl.txt))) - the banner, Boot's and TiffinBox's other lines, and the two ProcessRunner lines after each Running line: Waiting for process exit $(grep -cE 'ProcessRunner +: Waiting for process exit' .harness/jar.out || true) · Process exited with exit code 0 $(grep -cE 'ProcessRunner +: Process exited with exit code 0' .harness/jar.out || true)"
  cat .harness/cl.txt
  echo "  Running lines: $(grep -cE 'ProcessRunner +: Running ' .harness/jar.out || true) · on the main thread: $(grep -cE '\[ +main\] o\.s\.b\.docker\.compose\.core\.ProcessRunner +: Running ' .harness/jar.out || true) · lines that say Pulling: $(grep -c 'Pulling' .harness/jar.out || true)"
  echo "the compose project after TiffinBox exited:"; state; }
cap lifecycle lifecyclecap

# ---- jar: the jar Boot ships - one copy of after/, five builds; A's jar run with the profile, beside compose.yaml ---------------
jbuild() { runf "$1"; [ $ec = 0 ] || { tail -20 .harness/run.out >&3; die "jar: the build failed"; }
  echo "  exit $ec · offline: yes (-o) · BUILD SUCCESS lines: $(grep -c 'BUILD SUCCESS' .harness/run.out || true)"; entries ".harness/jars/$JAR"; }
jarcap() {
  runf "rsync -a --delete --exclude target after/ .harness/jars/"; echo "  exit $ec"
  echo "A   Boot's plugin as the anchor declares it: no settings"
  jbuild "$C_JARS"
  echo "  the jar: after/'s, the same bytes: $(cmp -s ".harness/jars/$JAR" "after/$JAR" && echo yes || echo no) · .harness/dev's, the same bytes: $(cmp -s ".harness/dev/$JAR" "after/$JAR" && echo yes || echo no)"
  fresh
  startjar "$C_JARDEV"; up
  echo "  the log: $(msg .harness/jar.out 'profile is active') · lines from Boot's Docker Compose support: $(composelines .harness/jar.out)"
  seven 18889 .harness/dev
  echo "  the compose project now: containers, volumes and networks $(projcount)"
  echo "B   -Dspring-boot.repackage.excludeDockerCompose=false: the plugin's own exclusion, off"
  jbuild "$C_JARSX"
  echo "C   includeOptional, on: one line of tiffinbox-web/pom.xml changed"
  runf "$C_INCOPT"; echo "  exit $ec · tiffinbox-web/pom.xml against after/'s, lines that differ: $(diff after/tiffinbox-web/pom.xml .harness/jars/tiffinbox-web/pom.xml | grep -c '^[<>]' || true)"
  diff after/tiffinbox-web/pom.xml .harness/jars/tiffinbox-web/pom.xml | grep '^[<>]' | sed 's/^/  /' || true
  jbuild "$C_JARS"
  echo "D   both: includeOptional on, excludeDockerCompose off"
  jbuild "$C_JARSX"
  echo "A′  A re-run: the POM restored"
  runf "cp after/tiffinbox-web/pom.xml .harness/jars/tiffinbox-web/pom.xml"; echo "  exit $ec"
  jbuild "$C_JARS"
  echo "  the jar: after/'s, the same bytes: $(cmp -s ".harness/jars/$JAR" "after/$JAR" && echo yes || echo no)"; }
cap jar jarcap

# ---- gate: the class path that holds the module, a folder with no compose.yaml, no profile - the switch, and Boot's default ----
gatecap() { local n
  fresh
  echo "every run starts in .harness/plain: a config tree ($TF), and compose.yaml: $([ -e .harness/plain/compose.yaml ] && echo there || echo none)"
  echo "the class path file, .harness/dev's $CPF, names spring-boot-docker-compose: $(tr ':' '\n' < ".harness/dev/$CPF" | grep -c '/spring-boot-docker-compose-[0-9.]*\.jar$' || true) jar"
  echo "A   after/ as built: the module on the class path, the switch off in application.yaml - no profile"
  startjar "$C_GATE"; up; echo "  lines from Boot's Docker Compose support: $(composelines .harness/jar.out)"
  seven 18882 .harness/plain
  echo "B   the switch's three lines deleted - Boot's default, on (.harness/ungated, built the README's way at the start)"
  echo "  the module's own default for the key, from its metadata (META-INF/spring-configuration-metadata.json): $(unzip -p "$(tr ':' '\n' < ".harness/dev/$CPF" | grep '/spring-boot-docker-compose-[0-9.]*\.jar$')" META-INF/spring-configuration-metadata.json | python3 -c 'import json, sys
d = [p for p in json.load(sys.stdin)["properties"] if p["name"] == "spring.docker.compose.enabled"]
print(d[0]["name"] + " = " + str(d[0].get("defaultValue")).lower() if len(d) == 1 else "(not one entry)")')"
  echo "\$ $C_UNGSED"
  echo "  application.yaml against after/'s, lines removed: $(diff after/tiffinbox-web/src/main/resources/application.yaml .harness/ungated/tiffinbox-web/src/main/resources/application.yaml | grep -c '^<' || true)"
  diff after/tiffinbox-web/src/main/resources/application.yaml .harness/ungated/tiffinbox-web/src/main/resources/application.yaml | grep '^<' | sed 's/^/  /' || true
  jrun "$C_GATEB"; n=$(grep -c . .harness/jar.out)
  echo "  exit $ec · lines $n · listening lines $(grep -c 'TiffinBox listening' .harness/jar.out || true) · $(warns .harness/jar.out)"
  echo "  $(grep -m1 -E '^[a-zA-Z.]+(Exception|Error): ' .harness/jar.out || echo '(no exception line)')"
  echo "  the compose project now: containers, volumes and networks $(projcount)"
  echo "A′  A re-run"
  startjar "$C_GATE"; up; echo "  lines from Boot's Docker Compose support: $(composelines .harness/jar.out)"
  seven 18882 .harness/plain; }
cap gate gatecap

# ---- default: no profile, the earlier ways TiffinBox starts ------------------------------------------------------------------------
# waitlog NAME: poll the container's log until TiffinBox says it listens, or the container stops; 30 s at most
waitlog() { local i=0; while [ $i -lt 120 ]; do docker logs "$1" > .harness/c.log 2>&1 || true; grep -q 'TiffinBox listening' .harness/c.log && break
  [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" = true ] || break; sleep 0.25; i=$((i + 1)); done
  grep -q 'TiffinBox listening' .harness/c.log || { tail -20 .harness/c.log >&3; die "$1 never listened"; }; }
defaultcap() { local e
  fresh
  echo "1   the executable jar"
  startjar "$C_JAR"; up; echo "  lines from Boot's Docker Compose support: $(composelines .harness/jar.out)"
  seven 18885 .harness/dev
  echo "2   the jar, extracted: a thin jar and lib/"
  runf "rm -rf .harness/dev/tiffinbox-web/target/extracted"; echo "  exit $ec"
  runf "$C_EXTRACT"; echo "  exit $ec · lib/: $(ls .harness/dev/tiffinbox-web/target/extracted/lib | grep -c '\.jar$' || true) jars · spring-boot-docker-compose among them: $(ls .harness/dev/tiffinbox-web/target/extracted/lib | grep -c '^spring-boot-docker-compose-' || true)"
  startjar "$C_XCP"; up; echo "  lines from Boot's Docker Compose support: $(composelines .harness/jar.out)"
  seven 18886 .harness/dev
  echo "3   the image, from the anchor's Dockerfile - its build context after/"
  docker image rm -f "$IMAGE" > /dev/null 2>&1 || true
  runf "$C_BUILD"; echo "  exit $ec · $(cat .harness/run.out)"; [ $ec = 0 ] || die "default: docker build failed"
  runf "$C_RUN"; echo "  exit $ec"; [ $ec = 0 ] || { cat .harness/run.err >&3; die "default: docker run failed"; }
  waitlog "$BOX"
  echo "  the address in the listening line: $(msg .harness/c.log 'TiffinBox listening' | sed -E 's#^.*https?://##') · $(warns .harness/c.log) · lines from Boot's Docker Compose support: $(composelines .harness/c.log)"
  echo "\$ \$CURLSET 18887 .harness/dev/$TF"
  "$CURLSET" 18887 ".harness/dev/$TF" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt || echo "(no POST line)"
  echo "  the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  echo "\$ docker wait $BOX"; e=$(docker wait "$BOX" 2> /dev/null || echo none); echo "  $e"
  echo "\$ docker rm $BOX"; docker rm "$BOX" > /dev/null; echo "  listeners on 18887 now: $(listeners 18887)"
  docker image rm "$IMAGE" > /dev/null 2>&1 || true
  echo "  the compose project now: containers, volumes and networks $(projcount)"; }
cap default defaultcap

# ---- details: what Boot hands over for a database - a harness with spring-boot-jdbc and the Postgres driver --------------------
detailscap() { local n
  fresh
  echo "the harness's class path: TiffinBox's (.harness/dev, as built), then what harness/details/pom.xml adds - set up at the start:"
  echo "\$ $C_HCP"
  tr ':' '\n' < .harness/details/classpath.txt | sed 's|.*/||' | sort > .harness/hcp.txt
  tr ':' '\n' < ".harness/dev/$CPF" | sed 's|.*/||' | sort > .harness/dcp.txt
  echo "  jars it lists: $(grep -c . .harness/hcp.txt) · not already on TiffinBox's: $(comm -23 .harness/hcp.txt .harness/dcp.txt | grep -c .)"
  echo "  $(comm -23 .harness/hcp.txt .harness/dcp.txt | paste -sd' ' -)"
  echo "\$ $C_JAVAC"
  echo "  classes: $(find .harness/details/classes -name '*.class' | grep -c .)"
  n=$(tr ':' '\n' < .harness/details/classpath.txt | grep '/spring-boot-jdbc-[0-9.]*\.jar$')
  echo "$(basename "$n"), META-INF/spring.factories: ConnectionDetailsFactory entries $(unzip -p "$n" META-INF/spring.factories | awk '/^org\.springframework\.boot\.autoconfigure\.service\.connection\.ConnectionDetailsFactory=/ { f = 1; next } f && /^[^ ]/ && !/,\\$/ { print; f = 0; next } f' | grep -c . ) · the ones that read Docker Compose: $(unzip -p "$n" META-INF/spring.factories | grep -c '\.docker\.compose\.' || true) · Postgres's:"
  unzip -p "$n" META-INF/spring.factories | grep 'PostgresJdbcDockerCompose' | sed 's/^/  /'
  echo "the harness, the dev profile on"
  jrun "$C_DETAILS"
  echo "  exit $ec · $(warns .harness/jar.out)"
  echo "  the log: $(msg .harness/jar.out 'Container tiffinbox-dev-postgres-1 Healthy')"
  echo "  the log: $(msg .harness/jar.out 'Starting embedded database')"
  sed -n '/^beans of type JdbcConnectionDetails: /,$p' .harness/jar.out | grep -vE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T' | sed 's/^/  /'
  echo "the compose project after the harness closed its context:"; state
  clean; fresh
  echo "TiffinBox itself, on the harness's class path - the Postgres driver on it - pointed at that Postgres"
  jrun "$C_ONPG"; n=$(grep -c . .harness/jar.out)
  echo "  exit $ec · lines $n · listening lines $(grep -c 'TiffinBox listening' .harness/jar.out || true)"
  echo "  the log: $(msg .harness/jar.out 'Container tiffinbox-dev-postgres-1 Healthy')"
  echo "  the last Caused by: line, the root cause: $(grep '^Caused by: ' .harness/jar.out | tail -1)"
  echo "the compose project after it exited:"; state; }
cap details detailscap

# ---- docker: the break - Docker reachable or not ----------------------------------------------------------------------------------
dockerA() { fresh; startjar "$C_DOCKA"; up
  echo "  the log: $(msg .harness/jar.out 'Container tiffinbox-dev-postgres-1 Healthy')"
  seven 18884 .harness/dev; }
dockercap() { local n
  echo "A   Docker reachable: the dev profile"
  dockerA; clean
  echo "B   DOCKER_HOST, set for this JVM only, names a Docker socket that does not exist; OrbStack keeps running"
  jrun "$C_DOCKB"; n=$(grep -c . .harness/jar.out)
  echo "  exit $ec · lines $n · listening lines $(grep -c 'TiffinBox listening' .harness/jar.out || true) · $(warns .harness/jar.out)"
  echo "  $(grep -m1 -E '^[a-zA-Z.]+(Exception|Error): ' .harness/jar.out || echo '(no exception line)')"
  echo "  $(grep -m1 -A1 '^Stderr:' .harness/jar.out | tail -1)"
  echo "  the compose project now: containers, volumes and networks $(projcount)"
  echo "C   B, with the switch off on the command line"
  startjar "$C_DOCKC"; up; echo "  lines from Boot's Docker Compose support: $(composelines .harness/jar.out)"
  seven 18884 .harness/dev
  echo "A′  A re-run"
  dockerA; }
cap docker dockercap

# ---- volume: Docker Compose alone - the volume with a name, and without one ---------------------------------------------------------
# compose output: the lines a docker compose command printed (standard error), counted; the last one shown
cout() { local l; l=$(sed 's/ *$//; s/^ *//' .harness/run.err | grep . | tail -1 || true)
  echo "  exit $ec · lines it printed: $(sed 's/ *$//' .harness/run.err | grep -c . || true) · the last: ${l:-(none)}"; }
mounts() { runf "docker inspect -f '{{range .Mounts}}{{.Type}} {{.Name}} -> {{.Destination}}{{println}}{{end}}' tiffinbox-dev-postgres-1"; grep . .harness/run.out | sed 's/^/  /' || true; }
volA() { fresh
  runf "$C_UP"; cout; mounts
  runf "$C_DOWN"; cout
  echo "  Docker lists for the project:"; state
  runf "$C_DOWNV"; cout; echo "  the project now: containers, volumes and networks $(projcount)"; }
volumecap() { local v
  echo "A   compose.yaml as the anchor has it: the data in a volume with a name"
  volA
  echo "B   the same file without its volume lines (made at the start)"
  echo "\$ $C_ANON"
  echo "  .harness/anon/compose.yaml against after/compose.yaml, lines removed: $(diff after/compose.yaml .harness/anon/compose.yaml | grep -c '^<' || true) · added: $(diff after/compose.yaml .harness/anon/compose.yaml | grep -c '^>' || true)"
  fresh
  runf "$C_UPB"; cout
  v=$(docker inspect -f '{{range .Mounts}}{{.Name}}{{end}}' tiffinbox-dev-postgres-1); VOLS="$VOLS $v"
  mounts
  echo "  the volume's name, recorded while its container runs: $(printf '%s' "$v" | wc -c | tr -d ' ') characters"
  runf "$C_DOWNB"; cout
  echo "  Docker lists for the project:"; state
  runf "docker volume inspect -f '{{json .Labels}}' $v"; echo "  exit $ec · $(cat .harness/run.out)"
  runf "$C_DOWNBV"; cout
  runf "docker volume inspect -f '{{.Name}}' $v"; echo "  exit $ec · still there: $([ $ec = 0 ] && echo yes || echo no)"
  runf "docker volume rm $v"; echo "  exit $ec · lines it printed: $(grep -c . .harness/run.out || true)"; VOLS=${VOLS% $v}
  echo "A′  A re-run"
  volA; }
cap volume volumecap

# ---- exercise: exercise/README.md's commands and the measured answer's, read from the files and run as written -----------------
# blockn FILE N: the lines of FILE's Nth ```bash block
blockn() { awk -v n="$2" '/^```bash$/ { k++; if (k == n) f = 1; next } f && /^```$/ { exit } f' "$1"; }
EX1=$(blockn exercise/README.md 1); EX2=$(blockn exercise/README.md 2); EX3=$(blockn exercise/README.md 3)
SOL1=$(blockn exercise/solution/SOLUTION.md 1); SOL2=$(blockn exercise/solution/SOLUTION.md 2)
[ "$(printf '%s\n' "$EX1" | grep -c ' java -cp ')" = 1 ] && [ "$(printf '%s\n' "$EX1" | tail -1 | grep -c '^cd \.harness/mine && java -cp ')" = 1 ] || die "exercise/README.md's first bash block must end with its one start line"
[ "$(printf '%s\n' "$SOL1" | grep -c .)" = 1 ] && [ "$(printf '%s\n' "$SOL1" | grep -c '^java -cp ')" = 1 ] || die "SOLUTION.md's first bash block must be its one start line"
[ -n "$EX2" ] && [ -n "$EX3" ] && [ -n "$SOL2" ] || die "exercise/README.md or SOLUTION.md no longer gives its blocks"
# xstart 'LINE' FOLDER: a start line - the first terminal: in the background, its pid kept; run from FOLDER when one is given
# (the answer's line, typed where the README's start line left the first terminal); then where it listens, and Compose's last
# line in its log
xstart() { local c=$1; [ -z "$2" ] || { echo "(from $2, where the README's start line left the first terminal)"; c="cd $2 && $1"; }
  echo "\$ $1"; (eval "${c/ java / exec java }") > .harness/jar.out 2> .harness/jar.err < /dev/null & pid=$!
  echo "  (the first terminal) $(up | sed 's/^  //') · Compose's last line in its log: $(lastmsg .harness/jar.out 'Container tiffinbox-dev-postgres-1 ')"; }
# xwait: the first terminal back at its prompt - that TiffinBox's exit, 15 s at most after POST /shutdown
xwait() { local i=0 e=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && die "exercise: TiffinBox was still running 15 s after POST /shutdown"
  wait "$pid" || e=$?; pid=""; echo "  (the first terminal, back at its prompt) exit $e"; }
xlines() { local l
  while IFS= read -r l; do [ -n "$l" ] || continue
    case "$l" in
      "export "*) continue ;;
      *"java -cp "*) xstart "$l" "$2" ;;
      *) runf "$l"; echo "  exit $ec"
         { sed 's/ *$//' .harness/run.out; sed 's/ *$//; s/^ *//' .harness/run.err | grep . | sed 's/^/stderr: /' || true; } | sed 's/^/  /'
         [ -s .harness/run.out ] || [ -s .harness/run.err ] || echo "  (nothing printed)"
         [ -z "$XTOK" ] && [ -f ".harness/mine/$TF" ] && XTOK=$(head -n 1 ".harness/mine/$TF")
         case "$l" in *"-X POST http"*"/shutdown") xwait ;; esac ;;
    esac; done <<< "$1"; }
exercisecap() {
  fresh
  echo "exercise/README.md's first block, run as written (its two export lines aside: this script set both):"; xlines "$EX1"
  echo "its second block - a second terminal, this folder:"; xlines "$EX2"
  echo "the measured answer, exercise/solution/SOLUTION.md's first block:"; xlines "$SOL1" .harness/mine
  echo "its second block - the second terminal:"; xlines "$SOL2"
  echo "exercise/README.md's last block, the clean-up:"; xlines "$EX3"
  echo "the compose project now: containers, volumes and networks $(projcount) · .harness/mine: $([ -e .harness/mine ] && echo there || echo gone)"; }
cap exercise exercisecap

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has1() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }     # an exact line inside a block
S115='115c36bac276128e245ca57df11c2891'

# THE TOKENS: no capture holds the demo token or the exercise's own, raw - counted on each run's own output BEFORE masking -
# and neither does anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held a token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 after/README.md after/compose.yaml after/tiffinbox-web/src/main/resources/application-dev.yaml harness/details/Details.java harness/details/pom.xml; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$(grep -rlF -- "$TOKEN" after 2> /dev/null | grep -c . || true)" = 0 ] || die "after/ - the anchor's copy and the image's build context - holds the demo token"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/' "$f" || die "$f holds an absolute path"; done
# LOOPBACK ONLY (brief S3.10): a docker run/create line that publishes a port, and every Compose ports: entry, must publish it on
# 127.0.0.1 (in a pattern of this script's, written 127\.0\.0\.1)
DL=$(cat receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md after/README.md | grep -E 'docker (container )?(run|create)' || true)
[ "$(printf '%s\n' "$DL" | grep -E -- ' (-p|--publish)[ =]' | grep -cvE -- ' (-p|--publish)[ =]127(\\)?\.0(\\)?\.0(\\)?\.1:' || true)" = 0 ] || die "a docker run/create line publishes a port off loopback"
for f in after/compose.yaml .harness/anon/compose.yaml; do
  [ "$(awk '/^    ports:$/ { f = 1; next } f && /^      - / { print } f && !/^      / { f = 0 }' "$f" | grep -cv '^      - "127\.0\.0\.1:' || true)" = 0 ] || die "$f publishes a port off loopback"
  [ "$(awk '/^    ports:$/ { f = 1; next } f && /^      - / { print } f && !/^      / { f = 0 }' "$f" | grep -c '^      - "127\.0\.0\.1:18881:5432"$' || true)" = 1 ] || die "$f must publish 127.0.0.1:18881:5432"; done
echo "  ports: docker run/create lines in receipts.sh and the READMEs: $(printf '%s\n' "$DL" | grep -c . || true), every published port on 127.0.0.1 · compose.yaml's ports: entry 127.0.0.1:18881:5432, and nothing else"
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs (the exercise's own token counted too), in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the exercise, the harness, receipts.md5 and after/; no absolute path in any capture"
# "TiffinBox's new compose file: one official Postgres image, a fixed project name ... its port on this Mac's loopback only,
# no password ... the data in a named volume ... then a switch: application.yaml turns it off, a new file turns it on for dev"
x change '^files, README aside: the previous tree 20 · after/ 22 · in both 20: identical 18, changed 2$'
x change '^  only after:  compose\.yaml tiffinbox-web/src/main/resources/application-dev\.yaml$'
x change '^  changed:     tiffinbox-web/pom\.xml tiffinbox-web/src/main/resources/application\.yaml$'
for l in '  5  name: tiffinbox-dev' '  8      image: postgres:18-alpine' ' 14        POSTGRES_HOST_AUTH_METHOD: trust' ' 17        - "127.0.0.1:18881:5432"' ' 22        - data:/var/lib/postgresql' ' 23  volumes:' '  8        enabled: true'; do
  grep -qxF -- "$l" .r-change.out || die "change: expected the line: $l"; done
[ "$(grep -cE '^ *[0-9]+  .*POSTGRES_PASSWORD' .r-change.out || true)" = 0 ] || die "change: compose.yaml must hold no password"
CA=$(blk change 'after/tiffinbox-web/src/main/resources/application.yaml against' 'after/tiffinbox-web/pom.xml against')
[ "$(printf '%s\n' "$CA" | grep -c '^  > ')" = 7 ] && has1 "$CA" '  >       enabled: false' change
CP=$(blk change 'after/tiffinbox-web/pom.xml against' 'the two trees')
has1 "$CP" '  >       <artifactId>spring-boot-docker-compose</artifactId>' change; has1 "$CP" '  >       <optional>true</optional>' change
[ "$(printf '%s\n' "$CP" | grep -c '^  < ' || true)" = 0 ] || die "change: the POM only gains lines"
x change '^the two trees. jars, each built clean: md5 92452ee1f9a22920d8aa7e2655f2bdc0 and [0-9a-f]{32} · bytes 16134264 and [0-9]+ · the same bytes: no$'
CJ=$(blk change '  entries ' 'the class path Maven lists')
[ "$CJ" = "$(printf '%s\n' '  BOOT-INF/classes/application-dev.yaml (only after)' '  BOOT-INF/classes/application.yaml (changed)' '  META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml (changed)')" ] || die "change: the jars differ in the two YAML files and the POM's copy, nothing else"
x change '^  entries 169 and 170 · the same name and CRC: 167 · the rest, by name:$'
x change '^the class path Maven lists for tiffinbox-web \(dependency:build-classpath, tiffinbox-web/target/classpath\.txt\): the previous tree 33 jars · after/.s copy, \.harness/dev, 36$'
x change '^  only after: jackson-core-3\.1\.5\.jar jackson-databind-3\.1\.5\.jar spring-boot-docker-compose-4\.1\.1\.jar · only before: \(none\)$'
x change '^  Jackson.s jars on \.harness/dev.s: jackson-annotations-2\.22\.jar jackson-core-2\.22\.2\.jar jackson-core-3\.1\.5\.jar jackson-databind-2\.22\.2\.jar jackson-databind-3\.1\.5\.jar$'
SF=$(blk change 'spring-boot-docker-compose-4.1.1.jar, META-INF/spring.factories, whole:' '')
[ "$(printf '%s\n' "$SF" | grep -c '^  org\.springframework\.boot\.docker\.compose\.[a-z.]*\.[A-Za-z]*Listener')" = 2 ] || die "change: the module's spring.factories names two listeners"
has1 "$SF" '  org.springframework.context.ApplicationListener=\' change
echo "  change: compose.yaml (tiffinbox-dev, postgres:18-alpine, trust, 127.0.0.1:18881, a named volume) and application-dev.yaml new · 7 lines in application.yaml, 9 in the POM · the jar: 3 entries differ · the class path: +3 jars · 2 listeners"

# "Boot runs Docker's own command-line tool: its version, the file's config, then compose up, and waits. Compose creates the
# network, the volume and the container ... healthy ... the seven ... on the shutdown hook's thread, one more command: compose
# stop ... the container is exited, not removed; its network and its volume stay"
x lifecycle '^  \{"/var/lib/postgresql":\{\}\} null$'
x lifecycle '^  listens on: 127\.0\.0\.1:18880 · WARN lines 0 · ERROR lines 0$'
x lifecycle '^the compose project while TiffinBox runs: tiffinbox-dev-postgres-1 running 127\.0\.0\.1:18881->5432/tcp$'
x lifecycle "^  exit 0 · the seven responses: 7 lines · md5 $S115\$"
LG=$(blk lifecycle 'the log, start to exit: ' '  Running lines: ')
for l in "  [main] Running 'docker version --format {{.Client.Version}}'" "  [main] Running 'docker compose --file …/.harness/dev/compose.yaml --ansi never config --format=json'" "  [main] Running 'docker compose --file …/.harness/dev/compose.yaml --ansi never up --no-color --detach --wait'" '  Network tiffinbox-dev_default Created' '  Volume tiffinbox-dev_data Created' '  Container tiffinbox-dev-postgres-1 Created' '  Container tiffinbox-dev-postgres-1 Started' '  Container tiffinbox-dev-postgres-1 Waiting' '  Container tiffinbox-dev-postgres-1 Healthy' '  TiffinBox listening on http://127.0.0.1:18880' "  [ionShutdownHook] Running 'docker compose --file …/.harness/dev/compose.yaml --ansi never stop --timeout 10'"; do
  has1 "$LG" "$l" lifecycle; done
[ "$(printf '%s\n' "$LG" | grep -A1 'up --no-color --detach --wait' | tail -1)" = '  Network tiffinbox-dev_default Creating' ] || die "lifecycle: Compose's lines follow compose up"
[ "$(printf '%s\n' "$LG" | grep -c '^  \[ionShutdownHook\] Running ')" = 1 ] || die "lifecycle: one command on the shutdown hook's thread"
[ "$(printf '%s\n' "$LG" | tail -1 | grep -c 'stop --timeout 10')" = 1 ] || die "lifecycle: compose stop is the last command"
[ "$(printf '%s\n' "$LG" | grep -oE '(Network|Volume|Container) [^ ]+' | awk '{ print $2 }' | sort -u | grep -c '^tiffinbox-dev')" = 3 ] && [ "$(printf '%s\n' "$LG" | grep -oE '(Network|Volume|Container) [^ ]+' | awk '{ print $2 }' | sort -u | grep -c .)" = 3 ] || die "lifecycle: every name Compose made starts with the project's: 3 of 3"
x lifecycle '^  Running lines: 9 · on the main thread: 8 · lines that say Pulling: 0$'
x lifecycle '^  containers: tiffinbox-dev-postgres-1 exited \(exit code 0\)$'
x lifecycle '^  volumes: tiffinbox-dev_data$'
x lifecycle '^  networks: tiffinbox-dev_default$'
echo "  lifecycle: 8 docker commands on main (version ... config ... up --wait), Compose's Created/Started/Waiting/Healthy, 3 names of 3 the project's · $S115 · stop --timeout 10 on [ionShutdownHook] · exited (0), the volume and the network kept · Pulling 0"

# "the jar Boot ships holds none of this: zero entries of the module, zero of Jackson 3. Started with dev, beside compose.yaml,
# Boot runs no Docker command ... include optional, off, keeps the module and its Jackson out. Exclude docker compose, on,
# keeps the module out, but lets its Jackson in"
JA=$(blk jar 'A   ' 'B   '); JB=$(blk jar 'B   ' 'C   '); JC=$(blk jar 'C   ' 'D   '); JD=$(blk jar 'D   ' 'A′  '); JA2=$(blk jar 'A′  ' '')
has1 "$JA" '  BOOT-INF/lib/: 31 jars · spring-boot-docker-compose: 0 · Jackson 3, jackson-core-3 and jackson-databind-3: 0' jar
has1 "$JA" "  the jar: after/'s, the same bytes: yes · .harness/dev's, the same bytes: yes" jar
has1 "$JA" '  listens on: 127.0.0.1:18889 · WARN lines 0 · ERROR lines 0' jar
has1 "$JA" "  the log: The following 1 profile is active: \"dev\" · lines from Boot's Docker Compose support: 0" jar
has1 "$JA" "  exit 0 · the seven responses: 7 lines · md5 $S115" jar
has1 "$JA" '  the compose project now: containers, volumes and networks 0' jar
has1 "$JB" '  BOOT-INF/lib/: 31 jars · spring-boot-docker-compose: 0 · Jackson 3, jackson-core-3 and jackson-databind-3: 0' jar
has1 "$JC" '  exit 0 · tiffinbox-web/pom.xml against after/'"'"'s, lines that differ: 2' jar
has1 "$JC" '  BOOT-INF/lib/: 33 jars · spring-boot-docker-compose: 0 · Jackson 3, jackson-core-3 and jackson-databind-3: 2' jar
has1 "$JD" '  BOOT-INF/lib/: 34 jars · spring-boot-docker-compose: 1 · Jackson 3, jackson-core-3 and jackson-databind-3: 2' jar
has1 "$JA2" '  BOOT-INF/lib/: 31 jars · spring-boot-docker-compose: 0 · Jackson 3, jackson-core-3 and jackson-databind-3: 0' jar
has1 "$JA2" "  the jar: after/'s, the same bytes: yes" jar
[ "$(grep -c '^  exit 0 · offline: yes (-o) · BUILD SUCCESS lines: 1$' .r-jar.out)" = 5 ] || die "jar: five builds, each offline"
echo "  jar: A 31 · 0 · 0, after/'s bytes, run with dev: 0 Compose lines, $S115 · B excludeDockerCompose off: 31 · 0 · 0 · C includeOptional on: 33 · 0 · 2 · D both: 34 · 1 · 2 · A' = A"

# "A: the class path that holds the module, no profile, a folder with no compose file. It serves, the same hash. B deletes the
# switch's three lines ... no Docker Compose file found. A again: it serves"
GA=$(blk gate 'A   ' 'B   '); GB=$(blk gate 'B   ' 'A′  '); GA2=$(blk gate 'A′  ' '')
x gate '^every run starts in \.harness/plain: a config tree \(secrets/tiffinbox/shutdown-token\), and compose\.yaml: none$'
x gate "^the class path file, \.harness/dev's tiffinbox-web/target/classpath\.txt, names spring-boot-docker-compose: 1 jar\$"
has1 "$GA" "  lines from Boot's Docker Compose support: 0" gate; has1 "$GA" "  exit 0 · the seven responses: 7 lines · md5 $S115" gate
has1 "$GB" "  the module's own default for the key, from its metadata (META-INF/spring-configuration-metadata.json): spring.docker.compose.enabled = true" gate
has1 "$GB" '  application.yaml against after/'"'"'s, lines removed: 3' gate
has1 "$GB" '  exit 1 · lines 32 · listening lines 0 · WARN lines 0 · ERROR lines 1' gate
has1 "$GB" "  java.lang.IllegalStateException: No Docker Compose file found in directory '…/.harness/plain/.'" gate
[ "$GA" = "$(printf '%s\n' "$GA2")" ] || die "gate: A' is not A, line for line"
echo "  gate: A the module on the class path, the switch off, no compose.yaml: 0 Compose lines, $S115 · B 3 lines deleted: exit 1, No Docker Compose file found · A' = A"

# "without the profile, the earlier ways still run: the jar, the jar unpacked, and the image. Each one gives the same hash."
[ "$(grep -c "^  exit 0 · the seven responses: 7 lines · md5 $S115\$" .r-default.out)" = 2 ] && [ "$(grep -c "^  the seven responses: 7 lines · md5 $S115\$" .r-default.out)" = 1 ] || die "default: the jar, the extracted jar and the image, each $S115"
[ "$(grep -c "^  lines from Boot's Docker Compose support: 0\$" .r-default.out)" = 2 ] || die "default: no Compose line"
x default '^  exit 0 · lib/: 31 jars · spring-boot-docker-compose among them: 0$'
x default "^  the address in the listening line: 0\.0\.0\.0:18425 · WARN lines 0 · ERROR lines 0 · lines from Boot's Docker Compose support: 0\$"
DW=$(blk default '$ docker wait tiffinbox-nodev' '$ docker rm'); [ "$DW" = '  0' ] || die "default: the container exits 0"
x default '^  the compose project now: containers, volumes and networks 0$'
echo "  default: the jar, the extracted jar (31, no module) and the image: $S115 each, 0 Compose lines"

# "a harness adds Spring Boot's JDBC module and the Postgres driver, on its own class path only. With dev on, Boot registers
# connection details: a bean holding Postgres's address, port eighteen eight eight one, and its user. But the DataSource ... is
# an embedded H2. Boot's condition report says why ... TiffinBox ... refuses to start: a syntax error at AUTO_INCREMENT"
x details '^  jars it lists: 18 · not already on TiffinBox.s: 8$'
x details '^  checker-qual-3\.55\.1\.jar postgresql-42\.7\.13\.jar spring-boot-jdbc-4\.1\.1\.jar spring-boot-persistence-4\.1\.1\.jar spring-boot-sql-4\.1\.1\.jar spring-boot-transaction-4\.1\.1\.jar spring-jdbc-7\.0\.9\.jar spring-tx-7\.0\.9\.jar$'
x details '^spring-boot-jdbc-4\.1\.1\.jar, META-INF/spring\.factories: ConnectionDetailsFactory entries 8 · the ones that read Docker Compose: 7 · Postgres.s:$'
DA=$(blk details 'the harness, the dev profile on' 'TiffinBox itself'); DC=$(blk details 'TiffinBox itself' '')
for l in '  exit 0 · WARN lines 0 · ERROR lines 0' '  the log: Container tiffinbox-dev-postgres-1 Healthy' "  the log: Starting embedded database: url='jdbc:h2:mem:<a random name>;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=false', username='sa'" '  beans of type JdbcConnectionDetails: 1' '    jdbcConnectionDetailsForTiffinboxDevPostgres1 -> org.springframework.boot.jdbc.docker.compose.PostgresJdbcDockerComposeConnectionDetailsFactory$PostgresJdbcDockerComposeConnectionDetails' '      url=jdbc:postgresql://127.0.0.1:18881/tiffinbox user=tiffinbox password=(none)' '  beans of type DataSource: 1' '    dataSource -> org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseFactory$EmbeddedDataSourceProxy' '      connects to: H2 jdbc:h2:mem:<a random name>' '  the condition report: DataSourceAutoConfiguration$PooledDataSourceConfiguration -> did not match' '      NestedCondition on DataSourceAutoConfiguration.PooledDataSourceCondition.PooledDataSourceAvailable PooledDataSource did not find supported DataSource' '  the condition report: DataSourceAutoConfiguration$EmbeddedDatabaseConfiguration -> matched' '      EmbeddedDataSource found embedded database H2' '  containers: tiffinbox-dev-postgres-1 exited (exit code 0)'; do
  has1 "$DA" "$l" details; done
has1 "$DC" '  exit 1 · lines 97 · listening lines 0' details
has1 "$DC" '  the log: Container tiffinbox-dev-postgres-1 Healthy' details
has1 "$DC" '  the last Caused by: line, the root cause: Caused by: org.postgresql.util.PSQLException: ERROR: syntax error at or near "AUTO_INCREMENT"' details
[ "$(grep -c '18881' .r-details.out)" -ge 2 ] || die "details: port 18881"
echo "  details: +8 jars (jdbc, the driver) · jdbcConnectionDetailsForTiffinboxDevPostgres1 url=jdbc:postgresql://127.0.0.1:18881/tiffinbox user=tiffinbox · dataSource EmbeddedDataSourceProxy, H2 · pooled: did not match · TiffinBox on Postgres: exit 1, AUTO_INCREMENT"

# "A: Docker reachable, the dev profile. Healthy, and the same hash. B sets DOCKER_HOST ... for this one JVM ... a socket that
# doesn't exist ... TiffinBox refuses to start: docker version failed. C adds the switch, off, on the command line, and it
# serves. A again: healthy."
KA=$(blk docker 'A   ' 'B   '); KB=$(blk docker 'B   ' 'C   '); KC=$(blk docker 'C   ' 'A′  '); KA2=$(blk docker 'A′  ' '')
has1 "$KA" '  the log: Container tiffinbox-dev-postgres-1 Healthy' docker; has1 "$KA" "  exit 0 · the seven responses: 7 lines · md5 $S115" docker
has1 "$KB" '  exit 1 · lines 44 · listening lines 0 · WARN lines 0 · ERROR lines 1' docker
has1 "$KB" "  org.springframework.boot.docker.compose.core.ProcessExitException: 'docker version --format {{.Client.Version}}' failed with exit code 1." docker
has1 "$KB" '  failed to connect to the docker API at unix:///nonexistent/docker.sock; check if the path is correct and if the daemon is running: dial unix /nonexistent/docker.sock: connect: no such file or directory' docker
has1 "$KB" '  the compose project now: containers, volumes and networks 0' docker
has1 "$KC" "  lines from Boot's Docker Compose support: 0" docker; has1 "$KC" "  exit 0 · the seven responses: 7 lines · md5 $S115" docker
[ "$(printf '%s\n' "$KA" | sed '/^\$ docker compose -p tiffinbox-dev down -v$/,$d')" = "$KA2" ] || die "docker: A' is not A, line for line"
echo "  docker: A Healthy, $S115 · B DOCKER_HOST for the JVM: exit 1, docker version failed, failed to connect · C + enabled=false: 0 Compose lines, $S115 · A' = A"

# the volume: named, kept by down, deleted by down -v; without the line, a volume with no name that down leaves behind
VA=$(blk volume 'A   ' 'B   '); VB=$(blk volume 'B   ' 'A′  '); VA2=$(blk volume 'A′  ' '')
has1 "$VA" '  volume tiffinbox-dev_data -> /var/lib/postgresql' volume; has1 "$VA" '  volumes: tiffinbox-dev_data' volume
has1 "$VA" '  exit 0 · lines it printed: 2 · the last: Volume tiffinbox-dev_data Removed' volume
has1 "$VB" '  .harness/anon/compose.yaml against after/compose.yaml, lines removed: 7 · added: 0' volume
has1 "$VB" '  volume [a volume ID] -> /var/lib/postgresql' volume
has1 "$VB" "  the volume's name, recorded while its container runs: 64 characters" volume
has1 "$VB" '  exit 0 · {"com.docker.volume.anonymous":""}' volume
has1 "$VB" '  exit 0 · lines it printed: 0 · the last: (none)' volume
has1 "$VB" '  exit 0 · still there: yes' volume
[ "$VA" = "$VA2" ] || die "volume: A' is not A, line for line"
echo "  volume: A tiffinbox-dev_data, kept by down, removed by down -v · B no name (64 characters, anonymous), left by down and by down -v, removed by its ID · A' = A"

# the exercise's end state: exited after the lesson's stop; nothing after the answer's; the volume kept, then removed
EA=$(blk exercise "its second block - a second terminal" 'the measured answer'); EB=$(blk exercise 'its second block - the second terminal:' "exercise/README.md's last block")
has1 "$EA" '  tiffinbox-dev-postgres-1:exited' exercise
has1 "$EB" '  (nothing printed)' exercise; has1 "$EB" '  tiffinbox-dev_data' exercise
[ "$(grep -c '^  {"stopping":true} 200$' .r-exercise.out)" = 2 ] && [ "$(grep -c '^  (the first terminal, back at its prompt) exit 0$' .r-exercise.out)" = 2 ] || die "exercise: two stops, each 200 and exit 0"
x exercise '^  stderr: Volume tiffinbox-dev_data Removed$'
x exercise '^the compose project now: containers, volumes and networks 0 · \.harness/mine: gone$'
for l in 'tiffinbox-dev-postgres-1:exited' 'tiffinbox-dev_data'; do grep -qF -- "$l" exercise/README.md && grep -qF -- "$l" exercise/solution/SOLUTION.md || die "exercise: README and SOLUTION must name $l"; done
echo "  exercise: the lesson's stop -> tiffinbox-dev-postgres-1:exited · --spring.docker.compose.stop.command=down -> no container, tiffinbox-dev_data kept · down -v removed it"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit17: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens in every capture and shipped file; the compose project, the image and the container removed"
