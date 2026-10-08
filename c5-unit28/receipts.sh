#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · Boot 4 and Framework 7: What Changed - this unit's receipts. This course ran on Boot 4.1.1 and Framework 7.0.9. What
# did those versions change for TiffinBox, counted against the last Boot 3 (3.5.16) and the Framework it manages (6.2.19) - and
# which of the things called new were there before? No anchor change: this unit's after/ IS ../c5-unit27/after (a link), read and
# copied, never built in place. No native build, no Docker, no GraalVM. Ten captures, each run three times and hashed; cap() DIES
# when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo
# token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run, and in every file this
# unit ships.
#   modules   the auto-configuration list, counted: the last Boot 3's one autoconfigure jar against this course's; TiffinBox's jar,
#             each of its jars that holds the list; the modules each BOM manages
#   moved     Actuator's list split; the health package emptied; TiffinBox's own Boot imports looked up in the last Boot 3's jars;
#             the bridge's discoverer's constructors, both versions
#   jackson   Boot's own JSON bean, both versions (javap); the BOMs' Jackson; the Compose module's Jackson; Jackson 3's annotations;
#             what TiffinBox ships and writes with
#   swap      the break, Jackson 3: A after/ from its folders, the seven · B the code swapped to Jackson 3, the POM untouched: the
#             build fails · A' = A · C (labelled) the code swapped and Jackson 3 declared: the seven, compared line by line with A's
#   nulls     Framework 7's null-safety: Spring's own package annotation against JSpecify's, both versions; Spring's old Nullable,
#             deprecated; what TiffinBox annotates and checks; javac's deprecation warnings on TiffinBox, and on a planted use
#   notnew    what 3.5.16 already had: heapdump's default access, the deprecated key's metadata; the deprecated key on this course's
#             Boot - A / B (=false) / A'
#   counts    Course 4's nine-line Boot app, run as written, and its definitions split by package (the harness's BoxCount);
#             TiffinBox's, split the same way (the harness's Count)
#   versions  the parent's versions, BOM against BOM (one declared filter, the cut counted); Undertow; Framework 7's version
#             attribute on a request mapping, and whether TiffinBox has spring-web at all
#   migrator  Boot's properties migrator on TiffinBox's class path: A its own keys · B a Boot 3 key · A' = A · C (labelled) the
#             migrator without the metadata jar
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# The previous tree and after/ are the same tree: ../c5-unit27/after, the anchor as the command-line lesson left it (= ../c5-tiffinbox
# when this unit was made). The last Boot 3's files come from harness/jars/pom.xml - a POM that builds nothing and names every file by
# exact version, so Maven copies them out of .m2-demo (on a fresh clone, from Maven Central, once): $OLD = its target/old (Boot
# 3.5.16's autoconfigure, actuator and actuator-autoconfigure jars, its BOM and Compose POM, Framework 6.2.19's spring-context),
# $NEW = its target/new (Boot 4.1.1's BOM, Compose POM and Jackson module, Jackson 3's databind POM, spring-web 7.0.9, the migrator
# and its metadata jar). $LIB = TiffinBox's own jars: after/'s jar, built here and extracted (its lib/). $IMP = the auto-configuration
# list's path inside a jar. $CURLSET = ../c5-unit11/curlset.sh (the seven requests, POST /shutdown with the token's header read from
# the file). $M2 = this unit's own repository, .m2-demo. The harness (harness/probe/count/: Count, BoxCount; harness/jars.py; three
# patches) lives outside com.tiffinbox, and it is the course's, never TiffinBox's. No harness passes a bare word to the guarded tree
# (brief ⚑18): every run here passes options only.
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an artifact
# offline goes to Maven Central once, and says that ("offline: no - ..."). At run time nothing leaves 127.0.0.1.
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; this
# folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every line of every
# capture. No duration is captured.
# Ports (brief ⚑1, 19140-19149): swap A and A' 19140 · swap C 19141 · notnew 19142 · counts 19143 · migrator 19144 · the exercise
# 19145. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $fpid, a start expected to end by itself), if they still run, then sweep(): anything of this run still alive in its process group
# - a TiffinBox JVM (a jar, an extracted class path, a folder run), Course 4's app, the harness's BoxCount - is stopped. After an
# interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names.
pid=""; fpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "boot-in-ninety-seconds") || index($0, "probe.count.BoxCount") || index($0, "plexus-classworlds")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
trap 'trap "" INT TERM; for p in "$pid" "$fpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in javac javap python3 curl rsync unzip lsof patch md5; do command -v $t > /dev/null || die "$t is needed here"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the failure lesson's loop, verbatim: sed -E, a canary planted under every name first, and
# the run stops if one survives - RED C5-S4 #63).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L after ] && [ "$(readlink after)" = ../c5-unit27/after ] || die "after/ must be the link to ../c5-unit27/after - this unit changes nothing in the anchor"
[ -e after/secrets ] || [ -e after/tiffinbox-web/secrets ] || [ -e after/tiffinbox-local.yaml ] || [ -e after/target ] || [ -e after/tiffinbox-web/target ] || [ -e after/banner.txt ] && die "after/ (../c5-unit27/after) holds a secrets/, a tiffinbox-local.yaml, a banner.txt or a target/ - it is the anchor's frozen copy, never built in place; remove them"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
TOKEN=not-a-real-token-demo-only                     # FAKE, and meant to look it: written into .harness/*/secrets/, never printed
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f after/pom.xml ] && [ -f after/README.md ] || die "after/ (../c5-unit27/after) is missing"
for f in harness/jars/pom.xml harness/jars.py harness/probe/count/Count.java harness/probe/count/BoxCount.java harness/jackson3-code.patch harness/jackson3-pom.patch harness/old-nullable.patch harness/shutdown.sh ../c4-unit01/boot-in-ninety-seconds/pom.xml; do [ -f "$f" ] || die "missing: $f"; done
# On screen: $OLD, $NEW, $LIB, $IMP (defined above and in README.md) - absolute here, so a command run from any folder finds them
OLD="$U/.harness/jars/target/old"; NEW="$U/.harness/jars/target/new"; LIB="$U/.harness/serve/tiffinbox-web/target/extracted/lib"
IMP=META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19140 19141 19142 19143 19144 19145 19146 19147 19148 19149; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_CPB=$(readme 'mvn -B package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_DEV=$(readme 'java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.profiles.active=dev')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_HEALTH=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health")
R_KITCHEN=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/kitchen")
# The folder run: the README's "Postgres with TiffinBox" line WITHOUT its --spring.profiles.active=dev - the profile that switches
# Boot's Compose support on (application-dev.yaml). Without it nothing runs Docker: the same class path, TiffinBox's own database.
R_DIR=${R_DEV% --spring.profiles.active=dev}
[ "$R_DIR" = 'java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431' ] || die "the folder run, without the dev profile"
# off DIR 'README mvn LINE' [PHASE] ['EXTRA']: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's
# own repository, for a build phase clean and without tests, EXTRA after it. dev() takes those things back out, and must give the
# README's line again.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s%s\n' "$1" "$c" "${4:+ $4}"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; c=${c% -Dmaven.compiler.showDeprecation=true}; printf '%s\n' "$c"; }
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# hcp DIR PORT 'EXTRA' ['FLAGS']: the README's exploded run - the extracted jar on the class path, TiffinBox's own main - from DIR,
# its port made PORT, EXTRA added to the class path after lib/*, FLAGS after the port
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:$3\"}; printf '%s%s\n' "$c" "${4:+ $4}"; }
MIGJ='$NEW/spring-boot-properties-migrator-4.1.1.jar'; METAJ='$NEW/spring-boot-configuration-metadata-4.1.1.jar'
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
DEPR=-Dmaven.compiler.showDeprecation=true
for c in "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_CPB" package)" "$(off .harness/x "$R_PLAIN" package "$DEPR")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_CPB" ] || die "not a README line with the offline changes: $c"; done
[ "$(hcp .harness/x 19144 "$MIGJ:$METAJ" '--a=1')" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$NEW/spring-boot-properties-migrator-4.1.1.jar:$NEW/spring-boot-configuration-metadata-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19144 --a=1' ] || die "the exploded run with the migrator"
echo "  the commands: after/README.md gives all 9 lines this script runs or derives from"

# ---- build: before the captures - after/ with the README's class-path line, extracted ($LIB); the harness's jars ($OLD, $NEW);
# ---- Course 4's app; the harness compiled. On a fresh clone (.m2-demo empty: git ignores it) these builds fill .m2-demo, once.
rm -rf .harness; mkdir -p .harness
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only if
# the offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is never
# silent (inside a capture, "no" changes the capture's hash: cap() then dies). EXPECT=fail: a build that must fail (the break) - its
# exit is printed, never retried, and a resolution failure is still an error.
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  if [ "${EXPECT:-ok}" = fail ]; then echo "  built $3 · offline: $how · exit $ec"; return 0; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; tree "$2"; }
copy after .harness/serve
mbuild "$(off .harness/serve "$R_CPB" package)" .harness/build-serve.log ".harness/serve (after/, the README's class-path line)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
(cd .harness/serve && eval "$R_EXTRACT") > .harness/extract-serve.log 2>&1 || { cat .harness/extract-serve.log >&3; die "the README's extract command failed in .harness/serve"; }
rsync -a harness/jars/ .harness/jars/
mbuild 'cd .harness/jars && mvn -o -B -Dmaven.repo.local="$M2" validate' .harness/build-jars.log ".harness/jars (harness/jars/pom.xml: the old and new files into \$OLD and \$NEW)"
[ "$(ls "$OLD" | wc -l | tr -d ' ')" = 6 ] && [ "$(ls "$NEW" | wc -l | tr -d ' ')" = 7 ] || die "the harness's POM did not copy its 6 old and 7 new files"
rm -rf .harness/box0; rsync -a --exclude target --exclude .m2-demo ../c4-unit01/boot-in-ninety-seconds/ .harness/box0/
mbuild 'cd .harness/box0 && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package' .harness/build-box0.log ".harness/box0 (Course 4's app)"
javac -d .harness/hc -cp ".harness/serve/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:$LIB/*" harness/probe/count/*.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile"; }
echo "  the harness: harness/probe/count/ compiled into .harness/hc ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes) · \$LIB holds $(ls "$LIB" | wc -l | tr -d ' ') jars"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; FLOGS=0; LASTE=""
first() { grep -m1 ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//'; }
# run 'COMMAND': printed exactly as typed, run (eval, from this folder), what it printed indented
run() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | sed 's/^/  /'; }
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
listening() { local a="" i=0
  while [ $i -lt 240 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  echo "  listens on: $l"; echo "  Boot's first line: $(first .harness/run.out)"; }
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed - then the README's readiness line,
# printed and run once (brief S5.28)
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  ask "$R_READY" "$1"; }
# served PORT: for a run whose readiness cannot answer (health switched off): /kitchen asked until it answers 200, not printed - the
# kitchen answers once TiffinBox's server is up; the process is checked alive on every round, and the stop below runs on every path
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times"; }
served() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/kitchen" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before /kitchen answered"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "/kitchen never answered 200 on $1"; }
# seven PORT DIR [all] [SAVE]: the comparison set's seven requests, printed as run - every response line with "all", else the POST
# line; the process must leave within 15 s, the port must be free; then its log counted (logtok). SAVE keeps the seven lines.
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  [ -z "$4" ] || cp .harness/responses.txt "$4"
  if [ "$3" = all ]; then sed 's/^/  /' .harness/responses.txt; else grep '^POST ' .harness/responses.txt | sed 's/^/  /' || echo "  (no POST line)"; fi
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  logtok; }
stop() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | sed 's/^/  /'; ends "$1"; }
ends() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · listening on $1 now: 0"; logtok; }
# levels LOG: the run's WARN and ERROR lines, counted, and its lines that name KEY (the deprecated key), counted
levels() { echo "  its log: WARN lines $(grep -cE '^[0-9-]+T[^ ]+ +WARN ' "$1" || true) · ERROR lines $(grep -cE '^[0-9-]+T[^ ]+ +ERROR ' "$1" || true) · lines naming $2: $(grep -cF -- "$2" "$1" || true)"; }
# A failed start (the failure lesson's shape): read after it exited, never printed whole - frames and Caused by: counted; WARN and
# ERROR lines from their level on; the first line of each exception; the analysis, from "Description:" on
SHAPEAWK='
an { if (NF) ana[++na] = "  " $0; next }
/^Description:$/ { an = 1; ana[++na] = "  " $0; next }
/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ +[0-9]+ --- \[/ {
  lv = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
  i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
  if (lv == "WARN" || lv == "ERROR") ln[++nl] = "  " lv " " lg (msg == "" ? ":" : ": " msg)
  next }
/^\tat / { fr++; next }
/^\t\.\.\. [0-9]+ (common frames omitted|more)$/ { om += $2; next }
/^Caused by: / { cb++; ex[++ne] = "  " $0; next }
/^([a-z][a-z0-9_]*\.)+[A-Z][A-Za-z0-9_$]*(: .*)?$/ { ex[++ne] = "  " $0; next }
/^APPLICATION FAILED TO START$/ { ban++; next }
END {
  print "  its log, read after it exited: APPLICATION FAILED TO START " (ban + 0) " · stack frames " (fr + 0) " · Caused by: " (cb + 0) " · frames folded as common " (om + 0)
  for (i = 1; i <= nl; i++) print ln[i]
  for (i = 1; i <= ne; i++) print ex[i]
  for (i = 1; i <= na; i++) print ana[i] }'
fails() { local e=0 i=0 t
  echo "\$ $1"; (eval "$(exe "$1")") > .harness/fail.out 2> .harness/fail.err < /dev/null & fpid=$!
  while kill -0 "$fpid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$fpid" 2> /dev/null && { kill "$fpid"; die "a start expected to end still ran after 60 s: $1"; }
  wait "$fpid" || e=$?; fpid=""; LASTE=$e
  echo "  exit $e"
  t=$(raw "$TOKEN" .harness/fail.out .harness/fail.err); FLOGS=$((FLOGS + 1)); [ "$t" = 0 ] || die "a failed start's log held the demo token ($t)"
  awk "$SHAPEAWK" .harness/fail.out
  echo "  its log: TiffinBox listening $(grep -c 'TiffinBox listening on ' .harness/fail.out || true) · its standard error: $(wc -l < .harness/fail.err | tr -d ' ') lines · the demo token in its log: 0"; }
now() { local p o=""; for p in "$@"; do o="$o${o:+ · }$p $(listeners "$p")"; done; echo "  listening now: $o"; }
# mask: the demo token becomes a label naming its length; this folder's path "…", the folder above it "…/..", the home folder "~"
# (each also in its URL form, spaces as %20); the user name "<user>" - in every line (gsub)
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = lit(me) }
  { gsub(T, "[masked: the 26-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(M, "<user>"); print }'; }
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] && [ -z "$fpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
pbuild() { local c; c=$(off "$1" "${3:-$R_PLAIN}" package "$4"); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
extract() { echo "\$ cd $1 && $R_EXTRACT"
  (cd "$1" && eval "$R_EXTRACT") > "$1.extract.log" 2>&1 || { cat "$1.extract.log" >&3; die "the extract failed in $1"; }
  echo "  extracted: exit 0 · its lib/ holds $(ls "$1/tiffinbox-web/target/extracted/lib" | wc -l | tr -d ' ') jars"; }
# entries JAR-EXPRESSION: the auto-configuration list's entries in one jar - its lines that are neither comment nor blank
entries() { run "unzip -p $1 \"\$IMP\" | grep -cvE '^[[:space:]]*(#|\$)'"; }
# lists: every jar in $LIB that holds the list, with its entries; then the totals
lists() { local j n f=0 t=0
  echo "\$ for j in \"\$LIB\"/*.jar; do n=\$(unzip -p \"\$j\" \"\$IMP\" 2> /dev/null | grep -cvE '^[[:space:]]*(#|\$)'); [ \"\$n\" = 0 ] || echo \"\$(basename \"\$j\") \$n\"; done"
  for j in "$LIB"/*.jar; do n=$(unzip -p "$j" "$IMP" 2> /dev/null | grep -cvE '^[[:space:]]*(#|$)' || true); [ "$n" = 0 ] && continue
    echo "  $(basename "$j") $n"; f=$((f + 1)); t=$((t + n)); done
  echo "  the jars that hold the list: $f · its entries in all of them: $t · the jars in \$LIB: $(ls "$LIB" | wc -l | tr -d ' ')"; }
# compiled LOG: what javac said - its "Compiling" lines from "Compiling" on, its deprecation warnings (distinct; the path cut before
# tiffinbox-web/), counted
compiled() { grep -E 'Compiling [0-9]+ source files' "$1" | sed 's/^.*Compiling/  Compiling/; s/ to target\/classes$//'
  echo "  javac's warnings that say deprecated, distinct: $(grep -E '^\[WARNING\] .*has been deprecated' "$1" | sort -u | wc -l | tr -d ' ')"
  grep -E '^\[WARNING\] .*has been deprecated' "$1" | sort -u | sed 's|^\[WARNING\] .*/tiffinbox-web/|  [WARNING] tiffinbox-web/|'; }

# ---- modules: one jar became many ----------------------------------------------------------------------------------------------
modules() {
  echo "the auto-configuration list (\$IMP) in Boot's autoconfigure jar - the last Boot 3's, then this course's - its entries:"
  entries '"$OLD/spring-boot-autoconfigure-3.5.16.jar"'
  entries '"$LIB/spring-boot-autoconfigure-4.1.1.jar"'
  echo "where Boot's Jackson configuration is listed - in the old autoconfigure jar, then in a module of its own:"
  run "unzip -p \"\$OLD/spring-boot-autoconfigure-3.5.16.jar\" \"\$IMP\" | grep -F .JacksonAutoConfiguration"
  run "unzip -p \"\$NEW/spring-boot-jackson-4.1.1.jar\" \"\$IMP\" | grep -F .JacksonAutoConfiguration"
  echo "TiffinBox's jar - every jar it ships (\$LIB) that holds the list, and its entries:"
  lists
  echo "the modules each BOM manages - its dependencyManagement entries with groupId org.springframework.boot, the starters apart:"
  run 'python3 harness/jars.py bom "$OLD/spring-boot-dependencies-3.5.16.pom" "$NEW/spring-boot-dependencies-4.1.1.pom"'; }

# ---- moved: what TiffinBox felt -------------------------------------------------------------------------------------------------
moved() {
  echo "Actuator's auto-configuration list - the last Boot 3's actuator-autoconfigure jar, then this course's, its entries:"
  entries '"$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar"'
  entries '"$LIB/spring-boot-actuator-autoconfigure-4.1.1.jar"'
  echo "the package org.springframework.boot.actuate.health in Boot's actuator jar - its class files, both versions:"
  run "unzip -Z1 \"\$OLD/spring-boot-actuator-3.5.16.jar\" | grep -cE '^org/springframework/boot/actuate/health/[^/]+\\.class\$'"
  run "unzip -Z1 \"\$LIB/spring-boot-actuator-4.1.1.jar\" | grep -cE '^org/springframework/boot/actuate/health/[^/]+\\.class\$'"
  echo "TiffinBox's own imports from org.springframework.boot (after/'s sources, copied to .harness/serve), each looked up in the"
  echo "last Boot 3's three jars by package and name, then by name alone; the rest by the jar of TiffinBox's that holds it:"
  run 'python3 harness/jars.py imports .harness/serve "$OLD/spring-boot-actuator-3.5.16.jar:$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar:$OLD/spring-boot-autoconfigure-3.5.16.jar" "$(ls "$LIB"/*.jar | paste -sd: -)"'
  echo "the bridge's discoverer - WebEndpointDiscoverer's public constructors (javap), both versions:"
  run 'python3 harness/jars.py ctors org.springframework.boot.actuate.endpoint.web.annotation.WebEndpointDiscoverer "$OLD/spring-boot-actuator-3.5.16.jar" "$LIB/spring-boot-actuator-4.1.1.jar"'
  echo "  the bridge, ActuatorRoutes.java, calls it with: $(grep -cF 'new WebEndpointDiscoverer(' .harness/serve/tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java) constructor call(s)"; }

# ---- jackson: what moved to Jackson 3 --------------------------------------------------------------------------------------------
jackson() {
  echo "Boot's own JSON bean - the method that declares it, read with javap - the last Boot 3's, then this course's:"
  run "javap -cp \"\$OLD/spring-boot-autoconfigure-3.5.16.jar\" 'org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration\$JacksonObjectMapperConfiguration' | grep -E ' jackson[A-Za-z]*Mapper\\('"
  run "javap -cp \"\$NEW/spring-boot-jackson-4.1.1.jar\" org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration | grep -E ' jackson[A-Za-z]*Mapper\\('"
  echo "the Jackson each BOM manages:"
  run 'python3 harness/jars.py props jackson-bom.version,jackson-2-bom.version "$OLD/spring-boot-dependencies-3.5.16.pom" "$NEW/spring-boot-dependencies-4.1.1.pom"'
  echo "the Compose module's own dependencies, both versions - and Jackson 3's databind's:"
  run 'python3 harness/jars.py deps "$OLD/spring-boot-docker-compose-3.5.16.pom" "$NEW/spring-boot-docker-compose-4.1.1.pom" "$NEW/jackson-databind-3.1.5.pom"'
  echo "Actuator's Jackson configurations - their class files in actuator-autoconfigure, both versions:"
  run "unzip -Z1 \"\$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar\" | grep -E 'endpoint/jackson/[A-Za-z0-9]+\\.class\$'"
  run "unzip -Z1 \"\$LIB/spring-boot-actuator-autoconfigure-4.1.1.jar\" | grep -E 'endpoint/jackson/[A-Za-z0-9]+\\.class\$'"
  echo "TiffinBox - the Jackson jars it ships, Jackson 3's classes in any of them, Boot's Jackson module, and the mappers it makes:"
  run 'ls "$LIB" | grep -i jackson'
  run "for j in \"\$LIB\"/*.jar; do unzip -Z1 \"\$j\"; done | grep -c '^tools/jackson/'"
  run "ls \"\$LIB\" | grep -c '^spring-boot-jackson'"
  run "grep -rn 'new ObjectMapper()' .harness/serve/tiffinbox-core/src .harness/serve/tiffinbox-web/src | sed 's/^.*\\/\\([A-Za-z]*\\.java\\):/\\1:/' | sort"; }

# ---- swap: the break - Jackson 3 -----------------------------------------------------------------------------------------------
swap() {
  echo "A - after/, copied to .harness/a with a config tree, built with the README's class-path line; the README's folder run, port 19140:"
  copy after .harness/a
  pbuild .harness/a "after/" "$R_CPB"
  start "$(at .harness/a 19140 "$R_DIR")"; up; ready 19140
  seven 19140 .harness/a all .harness/seven-a.txt
  echo "B - after/, copied to .harness/b; the code swapped to Jackson 3 (harness/jackson3-code.patch), the POM untouched:"
  copy after .harness/b
  run 'cd .harness/b && patch -s -p1 < ../../harness/jackson3-code.patch && diff -U0 ../../after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java | sed 1,2d'
  local c; c=$(off .harness/b "$R_CPB" package); echo "\$ $c"
  EXPECT=fail mbuild "$c" .harness/b.build.log "the code swapped"
  echo "  javac's errors (distinct; the path cut before tiffinbox-web/):"
  grep -E '^\[ERROR\] .*\.java:\[' .harness/b.build.log | sort -u | sed 's|^\[ERROR\] .*/tiffinbox-web/|    tiffinbox-web/|'
  echo "  tiffinbox-web/target/classes/com/tiffinbox/web/TiffinBoxServer.class: $([ -e .harness/b/tiffinbox-web/target/classes/com/tiffinbox/web/TiffinBoxServer.class ] && echo exists || echo 'does not exist')"
  echo "  the class path Maven lists for the run (A's, .harness/a/tiffinbox-web/target/classpath.txt) - Jackson 3's databind: $(tr ':' '\n' < .harness/a/tiffinbox-web/target/classpath.txt | grep -c '/tools/jackson/core/jackson-databind/')"
  echo "A' - A again:"
  start "$(at .harness/a 19140 "$R_DIR")"; up; ready 19140
  seven 19140 .harness/a all
  echo "C (labelled) - after/, copied to .harness/c; the code swapped, and Jackson 3 declared in the POM (harness/jackson3-pom.patch):"
  copy after .harness/c
  run 'cd .harness/c && patch -s -p1 < ../../harness/jackson3-code.patch && patch -s -p1 < ../../harness/jackson3-pom.patch && diff -U0 ../../after/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d'
  pbuild .harness/c "the code swapped, Jackson 3 declared" "$R_CPB"
  echo "  the executable jar's BOOT-INF/lib - Jackson 3's databind: $(unzip -Z1 .harness/c/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | grep -c '^BOOT-INF/lib/jackson-databind-3') (the plugin's excludes keep it out) - so C runs from the folders, as A did"
  tr ':' '\n' < .harness/a/tiffinbox-web/target/classpath.txt | sed 's|.*/||' | sort > .harness/cp-a.txt; tr ':' '\n' < .harness/c/tiffinbox-web/target/classpath.txt | sed 's|.*/||' | sort > .harness/cp-c.txt
  echo "  the class path Maven lists, against A's - its jars' names, sorted: $(cmp -s .harness/cp-a.txt .harness/cp-c.txt && echo the same jars || echo different) ($(wc -l < .harness/cp-c.txt | tr -d ' ') jars; in another order: $(cmp -s .harness/a/tiffinbox-web/target/classpath.txt .harness/c/tiffinbox-web/target/classpath.txt && echo no || echo yes))"
  start "$(at .harness/c 19141 "$R_DIR")"; up; ready 19141
  seven 19141 .harness/c all .harness/seven-c.txt
  echo "\$ diff .harness/seven-a.txt .harness/seven-c.txt | grep -c '^[<>]'"
  echo "  $(diff .harness/seven-a.txt .harness/seven-c.txt | grep -c '^[<>]' || true)"; }

# ---- nulls: Framework 7's null-safety -----------------------------------------------------------------------------------------
nulls() {
  echo "Spring's packages and the annotation that says \"not null unless marked\" - spring-context, the Framework the last Boot 3 manages, then this course's:"
  run "python3 harness/jars.py annos \"\$OLD/spring-context-6.2.19.jar\" 'Lorg/springframework/lang/NonNullApi;' 'Lorg/jspecify/annotations/NullMarked;'"
  run "python3 harness/jars.py annos \"\$LIB/spring-context-7.0.9.jar\" 'Lorg/springframework/lang/NonNullApi;' 'Lorg/jspecify/annotations/NullMarked;'"
  echo "Spring's own Nullable, in this course's spring-core - its annotations (javap -v):"
  run "javap -v -cp \"\$LIB/spring-core-7.0.9.jar\" org.springframework.lang.Nullable | grep -E '^ *(java\\.lang\\.Deprecated\\(|since=)'"
  echo "TiffinBox - the JSpecify jar it ships, its sources' nullability annotations, a null checker in its three POMs:"
  run 'ls "$LIB" | grep jspecify'
  run "grep -rlE '@(Nullable|NonNull|NullMarked|NonNullApi|NullUnmarked)\\b' .harness/serve/tiffinbox-core/src .harness/serve/tiffinbox-web/src | wc -l | tr -d ' '"
  run "cat .harness/serve/pom.xml .harness/serve/tiffinbox-core/pom.xml .harness/serve/tiffinbox-web/pom.xml | grep -ciE 'nullaway|errorprone|error_prone'"
  echo "TiffinBox's code on this course's Boot and Framework - after/, copied to .harness/lint, the README's plain line with javac's"
  echo "deprecation warnings on:"
  copy after .harness/lint
  pbuild .harness/lint "after/, deprecation warnings on" "$R_PLAIN" "$DEPR"
  compiled .harness/lint.build.log
  echo "the same build on a copy with one planted use of Spring's old Nullable (harness/old-nullable.patch) - so the count can move:"
  copy after .harness/lintp
  run 'cd .harness/lintp && patch -s -p1 < ../../harness/old-nullable.patch && diff -U0 ../../after/tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java | sed 1,2d'
  pbuild .harness/lintp "the planted copy, deprecation warnings on" "$R_PLAIN" "$DEPR"
  compiled .harness/lintp.build.log; }

# ---- notnew: what the last Boot 3 already had ------------------------------------------------------------------------------------
notnew() {
  echo "heapdump - the class's endpoint annotation (javap -v), both versions:"
  run "javap -v -cp \"\$OLD/spring-boot-actuator-3.5.16.jar\" org.springframework.boot.actuate.management.HeapDumpWebEndpoint | grep -E '^ +(org\\.springframework\\.boot\\.actuate\\.endpoint\\.web\\.annotation\\.WebEndpoint\\(|id=|defaultAccess=)'"
  run "javap -v -cp \"\$LIB/spring-boot-actuator-4.1.1.jar\" org.springframework.boot.actuate.management.HeapDumpWebEndpoint | grep -E '^ +(org\\.springframework\\.boot\\.actuate\\.endpoint\\.web\\.annotation\\.WebEndpoint\\(|id=|defaultAccess=)'"
  echo "the endpoint access model - the old switch and its replacement, in each version's own metadata:"
  run 'python3 harness/jars.py meta management.endpoints.enabled-by-default "$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar" "$LIB/spring-boot-actuator-autoconfigure-4.1.1.jar"'
  run 'python3 harness/jars.py meta management.endpoints.access.default "$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar" "$LIB/spring-boot-actuator-autoconfigure-4.1.1.jar"'
  echo "A - the deprecated switch on this course's Boot: not given. The README's run line, from .harness/serve, port 19142:"
  start "$(at .harness/serve 19142 "$R_RUN")"; up; ready 19142
  ask "$R_HEALTH" 19142; ask "$R_KITCHEN" 19142
  stop 19142 .harness/serve; levels .harness/run.out management.endpoints.enabled-by-default
  echo "B - the same line, the old switch off: --management.endpoints.enabled-by-default=false (readiness cannot answer; /kitchen waited for):"
  start "$(at .harness/serve 19142 "$R_RUN") --management.endpoints.enabled-by-default=false"; up; served 19142
  ask "$R_READY" 19142; ask "$R_HEALTH" 19142; ask "$R_KITCHEN" 19142
  stop 19142 .harness/serve; levels .harness/run.out management.endpoints.enabled-by-default
  echo "A' - A again:"
  start "$(at .harness/serve 19142 "$R_RUN")"; up; ready 19142
  ask "$R_HEALTH" 19142; ask "$R_KITCHEN" 19142
  stop 19142 .harness/serve; levels .harness/run.out management.endpoints.enabled-by-default; }

# ---- counts: a count belongs to a version -------------------------------------------------------------------------------------------
counts() {
  echo "Course 4's nine-line Boot app (boot-in-ninety-seconds/, from Course 4's first lesson), copied to .harness/box - the copy, its parent, its count:"
  rm -rf .harness/box; rsync -a --exclude target --exclude .m2-demo ../c4-unit01/boot-in-ninety-seconds/ .harness/box/
  echo "  the copy against Course 4's own folder (diff -rq, without target/ and .m2-demo/): $(diff -rq -x target -x .m2-demo ../c4-unit01/boot-in-ninety-seconds .harness/box | wc -l | tr -d ' ') files differ"
  echo "  its parent: $(grep -A2 '<artifactId>spring-boot-starter-parent</artifactId>' .harness/box/pom.xml | grep -m1 -o '<version>[^<]*</version>')"
  grep -E 'SpringApplication\.run|"bean definitions|getBeanDefinitionCount' .harness/box/src/main/java/com/tiffinbox/boot/BoxApp.java | sed 's/^ */  BoxApp.java: /'
  local c='cd .harness/box && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package'; echo "\$ $c"; mbuild "$c" .harness/box.build.log "Course 4's app"
  echo "\$ cd .harness/box && java -jar target/boot-in-ninety-seconds-1.0.0.jar"
  (cd .harness/box && java -jar target/boot-in-ninety-seconds-1.0.0.jar) > .harness/box.out 2>&1 < /dev/null || die "Course 4's app did not run"
  grep '^bean definitions' .harness/box.out | sed 's/^/  /'
  echo "  its log: Boot's Started line $(grep -c ' : Started BoxApp in ' .harness/box.out || true) · the demo token 0"
  echo "\$ cd .harness/box && java -Djarmode=tools -jar target/boot-in-ninety-seconds-1.0.0.jar extract --destination target/extracted"
  (cd .harness/box && java -Djarmode=tools -jar target/boot-in-ninety-seconds-1.0.0.jar extract --destination target/extracted) > .harness/box.extract.log 2>&1 || die "Course 4's jar did not extract"
  echo "  extracted: exit 0 · its lib/ holds $(ls .harness/box/target/extracted/lib | wc -l | tr -d ' ') jars"
  echo "the same start, split by package - the harness's BoxCount (SpringApplication.run on BoxApp, then the split):"
  echo "\$ cd .harness/box && java -cp \"target/extracted/boot-in-ninety-seconds-1.0.0.jar:target/extracted/lib/*:../hc\" probe.count.BoxCount"
  (cd .harness/box && java -cp "target/extracted/boot-in-ninety-seconds-1.0.0.jar:target/extracted/lib/*:../hc" probe.count.BoxCount) > .harness/boxcount.out 2>&1 < /dev/null || die "BoxCount did not run"
  sed -n 's/^harness: /  harness: /p' .harness/boxcount.out
  [ "$(raw "$TOKEN" .harness/box.out .harness/boxcount.out)" = 0 ] || die "Course 4's app printed the demo token"
  echo "TiffinBox - the harness's Count joined to the README's exploded run (\$LIB's jars), port 19143:"
  start "$(hcp .harness/serve 19143 ../hc '--spring.main.sources=probe.count.Count')"; up; ready 19143
  stop 19143 .harness/serve
  sed -n 's/^harness: /  harness: /p' .harness/run.out; }

# ---- versions: the parent's versions; Framework 7's version attribute -------------------------------------------------------------
versions() {
  echo "the versions the parent manages, BOM against BOM - nine properties of each BOM, the rest counted:"
  run 'python3 harness/jars.py props spring-framework.version,jackson-bom.version,micrometer.version,tomcat.version,jetty.version,jakarta-servlet.version,hibernate.version,junit-jupiter.version,undertow.version "$OLD/spring-boot-dependencies-3.5.16.pom" "$NEW/spring-boot-dependencies-4.1.1.pom"'
  run 'python3 harness/jars.py mentions undertow "$OLD/spring-boot-dependencies-3.5.16.pom" "$NEW/spring-boot-dependencies-4.1.1.pom"'
  echo "Framework 7's request mappings - spring-web 7.0.9 (javap), and whether TiffinBox ships spring-web at all:"
  run "javap -cp \"\$NEW/spring-web-7.0.9.jar\" org.springframework.web.bind.annotation.RequestMapping | grep -F ' version()'"
  run "javap -cp \"\$NEW/spring-web-7.0.9.jar\" org.springframework.web.bind.annotation.GetMapping | grep -F ' version()'"
  run "ls \"\$LIB\" | grep -c '^spring-web'"; }

# ---- migrator: Boot's properties migrator ---------------------------------------------------------------------------------------------
# report LOG: the migrator's report - from its ERROR line (the logger's name) to "Please refer", tabs and blank lines left out
report() { awk '/ ERROR .*PropertiesMigrationListener/ { f = 1; print "  ERROR o.s.b.c.p.m.PropertiesMigrationListener:"; next } f && NF { s = $0; gsub(/\t/, "  ", s); print "  " s } f && /^Please refer/ { f = 0 }' "$1"; }
migrator() {
  echo "A - the README's exploded run from .harness/serve, the migrator and its metadata jar added (\$NEW), port 19144:"
  start "$(hcp .harness/serve 19144 "$MIGJ:$METAJ")"; up; ready 19144
  seven 19144 .harness/serve
  echo "  its log: lines from PropertiesMigrationListener $(grep -c 'PropertiesMigrationListener' .harness/run.out || true) · WARN lines $(grep -cE '^[0-9-]+T[^ ]+ +WARN ' .harness/run.out || true) · ERROR lines $(grep -cE '^[0-9-]+T[^ ]+ +ERROR ' .harness/run.out || true)"
  echo "B - the same, and a Boot 3 key: --management.endpoints.enabled-by-default=true:"
  start "$(hcp .harness/serve 19144 "$MIGJ:$METAJ" '--management.endpoints.enabled-by-default=true')"; up; ready 19144
  seven 19144 .harness/serve
  echo "  its log: lines from PropertiesMigrationListener $(grep -c 'PropertiesMigrationListener' .harness/run.out || true) · its report:"
  report .harness/run.out
  echo "A' - A again:"
  start "$(hcp .harness/serve 19144 "$MIGJ:$METAJ")"; up; ready 19144
  seven 19144 .harness/serve
  echo "  its log: lines from PropertiesMigrationListener $(grep -c 'PropertiesMigrationListener' .harness/run.out || true) · WARN lines $(grep -cE '^[0-9-]+T[^ ]+ +WARN ' .harness/run.out || true) · ERROR lines $(grep -cE '^[0-9-]+T[^ ]+ +ERROR ' .harness/run.out || true)"
  echo "C (labelled) - the migrator alone, without its metadata jar:"
  fails "$(hcp .harness/serve 19144 "$MIGJ")"
  now 19144; }

# ---- exercise: the README's commands, exactly as written, then the solution's ---------------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
exercise() { local setup sol ec=0 tok
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 1 ] || die "SOLUTION.md's first bash block must be its one line"
  echo "exercise/README.md's commands, run exactly as written from this folder - $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  (eval "$setup") > .harness/ex-setup.log 2>&1 < /dev/null || ec=$?
  [ $ec = 0 ] || { tail -20 .harness/ex-setup.log >&3; die "the exercise's setup failed"; }
  echo "  exit $ec · printed: $(grep -c . .harness/ex-setup.log || true) line(s)"
  echo "the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:"
  echo "\$ $sol"
  ec=0; (eval "$sol") 2>&1 < /dev/null || ec=$?
  echo "  exit $ec · listening on 19145 now: $(listeners 19145)"
  tok=$(head -1 .harness/mine/after/$TF)
  echo "  its log (.harness/mine/after/run.log): its own token $(raw "$tok" .harness/mine/after/run.log) times · X-Shutdown-Token $(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/mine/after/run.log | wc -l | tr -d ' ') times"; }

cap modules modules
cap moved moved
cap jackson jackson
cap swap swap
cap nulls nulls
cap notnew notnew
cap counts counts
cap versions versions
cap migrator migrator
cap exercise exercise

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
# after1 'TEXT' 'COMMAND LINE': the line printed right after the command line - its output's first line
after1() { printf '%s\n' "$1" | C1="$2" awk 'p { print; exit } $0 == ENVIRON["C1"] { p = 1 }'; }   # ENVIRON: awk -v would eat the backslashes
S115='115c36bac276128e245ca57df11c2891'
SEVEN="  exit 0 · the seven responses: 7 lines · md5 $S115"
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/jars/pom.xml harness/jars.py harness/probe/count/*.java harness/*.patch harness/shutdown.sh; do
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|virtual-[0-9]' "$f" || die "$f holds a log line's time or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -q 'offline: no' "$f" || die "$f: a build went online"; done
NL=$(cat .r-*.out | grep -cxF "  its log: the demo token 0 times · X-Shutdown-Token 0 times" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every run that served ($LOGS counted here, the published captures' $NL each with 0) and every start that failed ($FLOGS), the READMEs, the harness, the exercise and receipts.md5; no absolute path, no unit number, no process line, no log time, no stack frame, no build that went online in any capture"

# "The last Boot three kept a hundred and fifty-six auto-configurations in one list, in one jar. On Boot four point one, that jar
# lists twelve. TiffinBox's own jar holds six lists, seventy-four entries. The modules the parent manages: eighteen, then a hundred
# and forty-one."
M=$(cat .r-modules.out)
[ "$(after1 "$M" "\$ unzip -p \"\$OLD/spring-boot-autoconfigure-3.5.16.jar\" \"\$IMP\" | grep -cvE '^[[:space:]]*(#|\$)'")" = "  156" ] || die "modules: 156"
[ "$(after1 "$M" "\$ unzip -p \"\$LIB/spring-boot-autoconfigure-4.1.1.jar\" \"\$IMP\" | grep -cvE '^[[:space:]]*(#|\$)'")" = "  12" ] || die "modules: 12"
has "$M" "  the jars that hold the list: 6 · its entries in all of them: 74 · the jars in \$LIB: 46" "modules: 6 lists, 74 entries"
has "$M" "  org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration" "modules: Jackson's in the old jar"
has "$M" "  org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration" "modules: Jackson's in its own module"
has "$M" "  spring-boot-dependencies-3.5.16.pom: entries 411 · org.springframework.boot 73 · starters 55 · the rest, modules 18" "modules: 18"
has "$M" "  spring-boot-dependencies-4.1.1.pom: entries 652 · org.springframework.boot 311 · starters 170 · the rest, modules 141" "modules: 141"
[ "$(printf '%s\n' "$M" | grep -cE '^  spring-boot-[a-z-]+-4\.1\.1\.jar [0-9]+$')" = 6 ] || die "modules: six jars listed"
echo "  modules: 156 -> 12 · TiffinBox 6 lists, 74 entries, 46 jars · BOM modules 18 -> 141 (starters 55 -> 170)"

# "Actuator's list went from a hundred and twenty-three to twenty-four. The health package: fifty class files, then none. Seven of
# TiffinBox's imports name the new packages. The bridge's eight-argument constructor: the same signature in both."
V=$(cat .r-moved.out)
[ "$(after1 "$V" "\$ unzip -p \"\$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar\" \"\$IMP\" | grep -cvE '^[[:space:]]*(#|\$)'")" = "  123" ] || die "moved: 123"
[ "$(after1 "$V" "\$ unzip -p \"\$LIB/spring-boot-actuator-autoconfigure-4.1.1.jar\" \"\$IMP\" | grep -cvE '^[[:space:]]*(#|\$)'")" = "  24" ] || die "moved: 24"
[ "$(after1 "$V" "\$ unzip -Z1 \"\$OLD/spring-boot-actuator-3.5.16.jar\" | grep -cE '^org/springframework/boot/actuate/health/[^/]+\\.class\$'")" = "  50" ] || die "moved: 50"
[ "$(after1 "$V" "\$ unzip -Z1 \"\$LIB/spring-boot-actuator-4.1.1.jar\" | grep -cE '^org/springframework/boot/actuate/health/[^/]+\\.class\$'")" = "  0" ] || die "moved: 0"
has "$V" "  source files 16 · org.springframework.boot imports, one per class: 34" "moved: 34 imports"
has "$V" "  moved - the same name, another package in 3.5.16's jars: 7" "moved: 7"
[ "$(printf '%s\n' "$V" | grep -cE '^    org\.springframework\.boot\.health\.[a-z.]+\.[A-Za-z]+  \(in (ActuatorRoutes|KitchenHealthIndicator)\.java\) - 3\.5\.16: org\.springframework\.boot\.actuate\.health\.[A-Za-z]+$')" = 7 ] || die "moved: each of the 7 from actuate.health"
[ "$(printf '%s\n' "$V" | grep -c '(in ActuatorRoutes.java)')" = 5 ] && [ "$(printf '%s\n' "$V" | grep -c '(in KitchenHealthIndicator.java)')" = 2 ] || die "moved: the bridge's 5, the indicator's 2"
has "$V" "  the same package and name in 3.5.16's jars: 19" "moved: 19 the same"
has "$V" "    spring-boot-4.1.1.jar: 8 - DefaultApplicationArguments ExitCodeGenerator SpringApplication ApplicationEnvironmentPreparedEvent ConfigurationProperties EnableConfigurationProperties AbstractFailureAnalyzer FailureAnalysis" "moved: the core's 8, not compared"
has "$V" "  spring-boot-actuator-3.5.16.jar: public constructors 2 · their arguments: 6, 8" "moved: 3.5.16 two"
has "$V" "  spring-boot-actuator-4.1.1.jar: public constructors 1 · their arguments: 8" "moved: 4.1.1 one"
has "$V" "  the 8-argument constructor, in every jar above: the same signature" "moved: identical"
has "$V" "  the bridge, ActuatorRoutes.java, calls it with: 1 constructor call(s)" "moved: the bridge's one call"
echo "  moved: Actuator 123 -> 24 · actuate.health 50 -> 0 · 34 imports: 19 the same, 7 moved (5 + 2), 8 core · the 8-argument constructor the same, the 6 gone"

# "Boot's own JSON bean: Jackson two's ObjectMapper on the last Boot three, Jackson three's JsonMapper here. The Compose module moved
# too. The annotations are still one shared jar. TiffinBox ships Jackson two and writes with its own mapper."
J=$(cat .r-jackson.out)
has "$J" "    com.fasterxml.jackson.databind.ObjectMapper jacksonObjectMapper(org.springframework.http.converter.json.Jackson2ObjectMapperBuilder);" "jackson: 3.5.16's bean"
has "$J" "    tools.jackson.databind.json.JsonMapper jacksonJsonMapper(tools.jackson.databind.json.JsonMapper\$Builder);" "jackson: 4.1.1's bean"
x jackson '^  jackson-bom\.version +2\.21\.4 +3\.1\.5$'
has "$J" "  spring-boot-docker-compose-3.5.16.pom: org.springframework.boot:spring-boot · com.fasterxml.jackson.core:jackson-databind · com.fasterxml.jackson.module:jackson-module-parameter-names" "jackson: Compose on Jackson 2"
has "$J" "  spring-boot-docker-compose-4.1.1.pom: org.springframework.boot:spring-boot-autoconfigure · tools.jackson.core:jackson-databind" "jackson: Compose on Jackson 3"
has "$J" "  jackson-databind-3.1.5.pom: com.fasterxml.jackson.core:jackson-annotations · tools.jackson.core:jackson-core" "jackson: one annotations jar"
has "$J" "  jackson-databind-2.22.2.jar" "jackson: TiffinBox ships Jackson 2"
[ "$(after1 "$J" "\$ for j in \"\$LIB\"/*.jar; do unzip -Z1 \"\$j\"; done | grep -c '^tools/jackson/'")" = "  0" ] || die "jackson: no Jackson 3 class in TiffinBox's jars"
[ "$(after1 "$J" "\$ ls \"\$LIB\" | grep -c '^spring-boot-jackson'")" = "  0" ] || die "jackson: no Boot Jackson module in TiffinBox's jars"
[ "$(printf '%s\n' "$J" | grep -cE '^  (TiffinBoxServer|ActuatorRoutes)\.java:[0-9]+: .*new ObjectMapper\(\);$')" = 2 ] || die "jackson: two mappers of its own"
echo "  jackson: ObjectMapper (3.5.16) -> JsonMapper (4.1.1) · jackson-bom 2.21.4 -> 3.1.5 · Compose 2 -> 3 · annotations shared · TiffinBox: Jackson 2, 0 Jackson 3 classes, 2 own mappers"

# "A: the anchor, the seven. B: swap the code to Jackson three and the build fails - package tools jackson does not exist. A again.
# C: declare Jackson three, and the seven come out the same, zero lines different."
SA=$(blk swap 'A - after/' 'B - after/'); SB=$(blk swap 'B - after/' "A' - A again"); SA2=$(blk swap "A' - A again" 'C (labelled)'); SC=$(blk swap 'C (labelled)' '')
has "$SA" "$SEVEN" "swap A: the seven"; has "$SA2" "$SEVEN" "swap A': the seven"; has "$SC" "$SEVEN" "swap C: the seven"
[ "$(printf '%s\n' "$SA" | grep '^\$ cd .harness/a && java')" = "$(printf '%s\n' "$SA2" | grep '^\$ cd .harness/a && java')" ] || die "swap: A' is not A's command"
printf '%s\n' "$SA" | grep -q 'profiles.active' && die "swap A: the dev profile (Docker) must not run"
has "$SB" "  built the code swapped · offline: yes · exit 1" "swap B: the build fails"
has "$SB" "    tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java:[3,35] package tools.jackson.databind.json does not exist" "swap B: the package"
has "$SB" "  tiffinbox-web/target/classes/com/tiffinbox/web/TiffinBoxServer.class: does not exist" "swap B: no class"
has "$SB" "  the class path Maven lists for the run (A's, .harness/a/tiffinbox-web/target/classpath.txt) - Jackson 3's databind: 1" "swap B: Jackson 3 on the run's class path all along"
printf '%s\n' "$SC" | grep -q "^  the class path Maven lists, against A's - its jars' names, sorted: the same jars (" || die "swap C: the same jars"
[ "$(after1 "$SC" "\$ diff .harness/seven-a.txt .harness/seven-c.txt | grep -c '^[<>]'")" = "  0" ] || die "swap C: 0 lines differ"
[ "$(printf '%s\n' "$SC" | grep -c '^  +.*tools\.jackson\.core')" = 1 ] || die "swap C: the POM's new dependency"
echo "  swap: A 115c36ba... · B exit 1, package tools.jackson.databind.json does not exist · A' 115c36ba... · C 115c36ba..., 0 lines differ, the same class path"

# "Framework six point two marked fifty-eight of fifty-eight packages with Spring's own annotation; seven marks fifty-five of
# fifty-nine with JSpecify's. Spring's old Nullable: deprecated since seven. TiffinBox ships the jar and annotates nothing - zero
# warnings; one planted use, one warning."
NU=$(cat .r-nulls.out)
has "$NU" "  spring-context-6.2.19.jar: package-info classes 58 · NonNullApi 58 · NullMarked 0" "nulls: 6.2.19 58 of 58"
has "$NU" "  spring-context-7.0.9.jar: package-info classes 59 · NonNullApi 0 · NullMarked 55" "nulls: 7.0.9 55 of 59"
has "$NU" '        since="7.0"' "nulls: deprecated since 7.0"; x nulls '^  +java\.lang\.Deprecated\($'
has "$NU" "  jspecify-1.0.1.jar" "nulls: TiffinBox ships JSpecify"
NL1=$(blk nulls 'TiffinBox - the JSpecify jar' "TiffinBox's code on"); [ "$(printf '%s\n' "$NL1" | grep -cx '  0')" = 2 ] || die "nulls: 0 annotations, 0 checkers"
NA=$(blk nulls "TiffinBox's code on" 'the same build on a copy'); NB=$(blk nulls 'the same build on a copy' '')
has "$NA" "  Compiling 7 source files with javac [debug deprecation parameters release 25]" "nulls: core's 7"; has "$NA" "  Compiling 9 source files with javac [debug deprecation parameters release 25]" "nulls: web's 9"
has "$NA" "  javac's warnings that say deprecated, distinct: 0" "nulls: 0 warnings"
has "$NB" "  javac's warnings that say deprecated, distinct: 1" "nulls: the planted one counted"
has "$NB" "  [WARNING] tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java:[13,40] org.springframework.lang.Nullable in org.springframework.lang has been deprecated" "nulls: the planted warning"
echo "  nulls: 58/58 NonNullApi -> 55/59 NullMarked · Nullable deprecated since 7.0 · TiffinBox: jspecify shipped, 0 annotations, 0 checkers, 16 files 0 warnings; planted 1"

# "Heapdump was already locked by default in the last Boot three. The old switch was deprecated in three point four, and on this
# Boot it still works: health off, a not found, no warning."
NN=$(cat .r-notnew.out)
[ "$(printf '%s\n' "$NN" | grep -cE '^  +defaultAccess=Lorg/springframework/boot/actuate/endpoint/Access;\.NONE$')" = 2 ] || die "notnew: NONE in both"
has "$NN" "  spring-boot-actuator-autoconfigure-3.5.16.jar: management.endpoints.enabled-by-default · type java.lang.Boolean · deprecated · level warning · replacement management.endpoints.access.default · since 3.4.0" "notnew: 3.5.16 deprecated since 3.4.0"
has "$NN" "  spring-boot-actuator-autoconfigure-4.1.1.jar: management.endpoints.enabled-by-default · type java.lang.Boolean · deprecated · level warning · replacement management.endpoints.access.default · since 3.4.0" "notnew: 4.1.1 the same"
has "$NN" "  spring-boot-actuator-autoconfigure-3.5.16.jar: management.endpoints.access.default · type org.springframework.boot.actuate.endpoint.Access · not deprecated" "notnew: 3.5.16 has the access model"
NA_=$(blk notnew 'A - the deprecated' 'B - the same line'); NB_=$(blk notnew 'B - the same line' "A' - A again"); NA2=$(blk notnew "A' - A again" '')
for b in "$NA_" "$NA2"; do has "$b" '  {"status":"UP"} 200' "notnew A: health 200"; has "$b" '  {"ordersCooked":120,"ordersValue":24300} 200' "notnew A: the kitchen"; has "$b" "  exit 0 · listening on 19142 now: 0" "notnew A: exit 0"; done
[ "$(printf '%s\n' "$NB_" | grep -cxF '  {"error":"not found"} 404')" = 2 ] || die "notnew B: readiness and health 404"
has "$NB_" '  {"ordersCooked":120,"ordersValue":24300} 200' "notnew B: the kitchen 200"
has "$NB_" "  its log: WARN lines 0 · ERROR lines 0 · lines naming management.endpoints.enabled-by-default: 0" "notnew B: silent"
has "$NB_" "  exit 0 · listening on 19142 now: 0" "notnew B: exit 0"
echo "  notnew: heapdump NONE in both · enabled-by-default deprecated since 3.4.0 in both · B: health 404, kitchen 200, 0 WARN, 0 naming it"

# "Course four's fifty still reads fifty on Boot four point one: one is the app's, eleven Spring's, thirty-eight Boot's. TiffinBox:
# a hundred and forty-three, eleven its own."
C=$(cat .r-counts.out)
has "$C" "  the copy against Course 4's own folder (diff -rq, without target/ and .m2-demo/): 0 files differ" "counts: Course 4's app as written"
has "$C" "  its parent: <version>4.1.1</version>" "counts: on Boot 4.1.1"
has "$C" "  bean definitions in a Boot context nobody in this file asked for: 50" "counts: fifty"
has "$C" "  harness: BoxApp · bean definitions 50 · com.tiffinbox 1 · org.springframework (not boot) 11 · org.springframework.boot 38" "counts: 1 + 11 + 38"
has "$C" "  harness: TiffinBox · bean definitions 144 · com.tiffinbox 11 · io.micrometer and io.prometheus 16 · org.springframework (not boot) 12 · org.springframework.boot 104 · the harness 1" "counts: TiffinBox 143, 11"
printf '%s\n' "$C" | grep -q 'other: ' && die "counts: a definition outside the named groups"
echo "  counts: BoxApp 50 = 1 + 11 + 38 · TiffinBox 144 - the harness's 1 = 143, com.tiffinbox 11"

# chips: the parent's versions; Undertow; the version attribute
VE=$(cat .r-versions.out)
for t in '  spring-framework.version  6.2.19                               7.0.9' '  tomcat.version            10.1.55                              11.0.24' '  jakarta-servlet.version   6.0.0                                6.1.0' '  junit-jupiter.version     5.12.2                               6.0.3' '  undertow.version          2.3.24.Final                         -'; do has "$VE" "$t" "versions"; done
has "$VE" "  spring-boot-dependencies-3.5.16.pom: lines that mention undertow, in any case: 11" "versions: undertow 11"; has "$VE" "  spring-boot-dependencies-4.1.1.pom: lines that mention undertow, in any case: 0" "versions: undertow 0"
[ "$(n versions '^    public abstract java\.lang\.String version\(\);$')" = 2 ] || die "versions: version() on both mappings"
[ "$(after1 "$VE" "\$ ls \"\$LIB\" | grep -c '^spring-web'")" = "  0" ] || die "versions: no spring-web in TiffinBox"
echo "  versions: Framework 6.2.19 -> 7.0.9, Tomcat 10.1 -> 11.0, Servlet 6.0 -> 6.1, JUnit 5.12 -> 6.0; Undertow 11 -> 0 · version() on @RequestMapping, @GetMapping; spring-web 0 in TiffinBox"

# "Boot's properties migrator finds nothing to migrate in TiffinBox's keys. Given a Boot three key, it names it."
MA=$(blk migrator 'A - the README' 'B - the same'); MB=$(blk migrator 'B - the same' "A' - A again"); MA2=$(blk migrator "A' - A again" 'C (labelled)'); MC=$(blk migrator 'C (labelled)' '')
for b in "$MA" "$MA2"; do has "$b" "$SEVEN" "migrator A: the seven"; has "$b" "  its log: lines from PropertiesMigrationListener 0 · WARN lines 0 · ERROR lines 0" "migrator A: nothing reported"; done
has "$MB" "$SEVEN" "migrator B: the seven"; has "$MB" "  ERROR o.s.b.c.p.m.PropertiesMigrationListener:" "migrator B: its report"
has "$MB" "    Key: management.endpoints.enabled-by-default" "migrator B: the key"; has "$MB" "      Reason: Replacement key 'management.endpoints.access.default' uses an incompatible target type" "migrator B: the reason"
has "$MC" "  exit 1" "migrator C: exit 1"; printf '%s\n' "$MC" | grep -q 'NoClassDefFoundError: org/springframework/boot/configurationmetadata/' || die "migrator C: the metadata classes"
echo "  migrator: A nothing reported, 115c36ba... · B names management.endpoints.enabled-by-default · A' = A · C without the metadata jar: exit 1"

# the exercise's end state
XE=$(blk exercise "the solution's line" '')
l="Key: management.endpoints.enabled-by-default"
has "$XE" "$l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: 0 line\(s\)$'; x exercise '^  exit 0 · listening on 19145 now: 0$'
x exercise '^  its log \(\.harness/mine/after/run\.log\): its own token 0 times · X-Shutdown-Token 0 times$'
echo "  exercise: the README as written, then the solution's line -> Key: management.endpoints.enabled-by-default"

cmp -s after/README.md ../c5-tiffinbox/README.md || echo "  (after/README.md and ../c5-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit28: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every run's log"
