#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): only the native build reads it. Without it, this script makes every
# capture that needs no GraalVM - the JVM's, and the exercise's - filling .m2-demo on the way, then stops before the native build.
# Course 5 · DevTools, Restart and Live Reload - this unit's receipts. DevTools restarts TiffinBox inside the same JVM when a class
# file changes: a new class loader for what sits in folders, a new context, the same process. This unit changes NOTHING in the
# anchor (brief ⚑7): DevTools lives in copies under .harness/, each one the anchor as the logging lesson left it plus one line in
# its web module's POM - spring-boot-devtools, optional. Eleven captures, each run three times and hashed; cap() DIES when a hash
# differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is
# masked (gsub), and the last checks count 0 raw copies of it in every capture, every file this unit ships, and both binaries.
#   added      the copy: its POM line, its jar against the anchor's (DevTools entries counted), the class path Maven lists for it - and
#              for the tree both Section 4 probes measured - and its class-path run: DevTools' log line, the thread TiffinBox starts
#              on, env's property source "devtools" (its keys, never a value), the seven
#   loaders    the same run asked by jcmd (VM.classloaders): the loader tree, the classes the restart loader defined, TiffinBox's
#              classes in the application loader
#   restart    one class file's time changed: DevTools' line, the same process listening again, TiffinBox's lines twice, health, the
#              seven
#   timing     harness/clock.py: cold starts and restarts timed from outside - six runs of three restarts, run 1 a warm-up: the cold
#              start against a floor, the restart as a ratio of it, the time DevTools takes to notice a change against the restart
#   identity   the break: Witness and Holder (harness/probe) - A Holder in a folder · B Holder in a jar · A' = A: what Holder keeps
#              across a restart, the two classes compared, the cast
#   which      tiffinbox-core as a jar: changed and rebuilt while TiffinBox runs - no restart; then a web class - one restart
#   livereload DevTools' metadata for Live Reload; off (the condition report, the addresses); on for one run, on 19049 (the
#              addresses, its script); stopped
#   ship       three guards, each built the plain way: optional, not optional, forced in (the forced jar's restart: off, then
#              switched on); C (labelled) Boot's plugin's includeOptional; then the native profile's build: Spring's AOT step on the
#              copy against the anchor, the filter Boot's AOT goal applies, the jar's DevTools entries
#   exits      how a DevTools run ends after POST /shutdown - A restart on · B off · A' = A · C (labelled) without DevTools' jar: the
#              threads before the stop (jcmd), the exit code; D (labelled) DevTools' own code (javap); E (labelled) the JVM's rule
#              (harness/probe/MainEnds.java)
#   native     two copies built natively (the README's two Maven lines) - without and with one exclusion in the native plugin - and
#              their binaries run
#   exercise   exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "The anchor" is anchor/, a link in this folder to ../c5-unit24/after (TiffinBox as the logging lesson left it; brief: built
# against ../c5-unit21/after first, the Actuator lesson's tree, then re-pointed here before RED - the link was the one place that
# changed, then the tree-dependent expectations at the top of the checks), read and COPIED under .harness/ - never built in place; this script never writes into another unit's folder. ../c5-unit20/after (the tree both Section 4 probes measured) is read once, for the class-path count the probes
# disagreed on. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token (secrets/),
# as the anchor's README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set
# since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file).
# "$M2" is this unit's own repository, .m2-demo. "$pid" is the process the script started.
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an artifact
# offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin, under the profile native, reads
# its metadata repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even under -o: so a
# native-profile build without the zip goes to Maven Central for it at once, never offline first, and every build's log is searched
# for the plugin's own download line - found, the run stops. At run time nothing leaves 127.0.0.1 but one server: Live Reload's,
# which listens on every interface - switched on in one run of one capture, on 19049 (never its default, 35729), stopped by the
# same run's POST /shutdown.
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name
# "<user>" - in every line of every capture. A class loader's address (" @45ff1ded") becomes " @<hash>", a lambda's or a proxy's
# generated number is cut ("$$Lambda", "$Proxy<n>"). A Boot log line is printed from its message on. Logs, jcmd's answers and env's
# answer are read, never printed whole: what a capture shows is named, and the rest counted. Never printed: an environment
# variable's or a system property's name, a value from env, a pid, a thread's stack. No duration is captured: each is judged
# against a floor or as a ratio; seconds go to the terminal.
# Ports (brief ⚑10, 19040-19049): added 19040 · loaders 19041 · restart 19042 · timing 19043 · identity 19044 · which 19045 ·
# livereload 19046, and Live Reload's own server on 19049 · ship 19047 · exits 19048 · native 19047 · exercise 19045. 18425
# (TiffinBox's default), 8080 and 35729 (Live Reload's default) are checked free too.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default): start()'s "&& exec " would become "&& && exec ". Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash
# (bash receipts.sh) run the same commands; 3.2 has no such option.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the process this script started in the background, if it still runs
# (a background job of a non-interactive shell ignores the terminal's Ctrl-C), then sweep(): anything of this run still alive in
# its process group - a TiffinBox JVM (a jar, a class-path run: DevTools restarts inside that same JVM, and Live Reload's server is
# one of its threads), a binary, native-image's driver or builder, the clock, the JVM-rule harness - is stopped. Then env's answer,
# if a run left it (it lists the names of your environment's variables). After an interrupt, a capture's unfinished runs
# (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and
# nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an interrupt (tested:
# README.md, "Interrupted"). $pid is cleared whenever the process has been reaped.
pid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "harness/clock.py") || index($0, "probe.MainEnds")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
envfiles() { rm -f .harness/*/env.json 2> /dev/null || true; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; envfiles; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in jcmd javap jar javac; do command -v "$t" > /dev/null || die "$t (the JDK's own) is needed"; done
for t in python3 curl unzip lsof perl rsync; do command -v "$t" > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag, a build setting or a native-image option: every TIFFINBOX_*,
# SPRING_*, MANAGEMENT_*, SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags,
# MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are removed first. GRAALVM_HOME stays: it says which GraalVM to use.
# The list is an extended regular expression (sed -E): /usr/bin/sed's basic ones have no alternation, so the \| this loop once
# used matched nothing and removed no variable at all (measured: RED C5-S4 #63). A canary is planted under every name first, and
# the run stops if one survives the loop.
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1. An HTTP proxy named in your environment (http_proxy and the rest) would carry
# curl's requests to that proxy instead of to TiffinBox: 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
# The GraalVM: named by GRAALVM_HOME, never guessed and never printed (its folder is masked). The captures were made with GraalVM CE
# 25.3.4.1 (native-image 25.0.4.1); another build would print other lines, so it is refused here, not minutes in. Not set at all:
# no native build - the run fills .m2-demo, makes every capture that needs no GraalVM, the exercise's included, and stops where the
# native build would start (GOK=no).
GOK=yes
if [ -z "${GRAALVM_HOME:-}" ]; then GOK=no; unset GRAALVM_HOME
  echo "  GRAALVM_HOME is not set: this run fills .m2-demo, makes the captures that need no GraalVM - the JVM's, and the exercise's - and stops before the native build (README.md, The GraalVM)"
else
  [ -x "$GRAALVM_HOME/bin/native-image" ] || die "GRAALVM_HOME must name a GraalVM JDK 25 (its bin/native-image) - README.md, The GraalVM"
  NIV=$("$GRAALVM_HOME/bin/native-image" --version 2>&1 || true)
  printf '%s\n' "$NIV" | grep -q '^native-image 25\.0\.4\.1 ' && printf '%s\n' "$NIV" | grep -q 'GraalVM CE 25\.3\.4\.1+1\.1' || die "the published captures were made with GraalVM CE 25.3.4.1 (native-image 25.0.4.1); GRAALVM_HOME gives: $(printf '%s\n' "$NIV" | head -1)"
  export GRAALVM_HOME; fi
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
BASE=anchor                                          # a link to the anchor this unit measures: read, copied, never built in place
PROBES=../c5-unit20/after                            # the tree both Section 4 probes measured: read once, for a count
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
ROUTE=tiffinbox-web/target/classes/com/tiffinbox/web/Route.class       # the class file whose time the restarts change
WEBPOM=tiffinbox-web/pom.xml
# The one line every DevTools copy gains, in its web module's POM - and its two variants (ship's guards)
DEVDEP='    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>'
DEVREQ='    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId></dependency>'
# The native plugin's exclusion (capture native), on one line, before its closing tag
NATX='            <exclusion><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId></exclusion>'
DTJ=$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar
BPJ=$M2/org/springframework/boot/spring-boot-maven-plugin/4.1.1/spring-boot-maven-plugin-4.1.1.jar
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -L "$BASE" ] && [ -f "$BASE/pom.xml" ] && [ -f "$BASE/README.md" ] && [ -f "$PROBES/pom.xml" ] || die "the link $BASE (to the anchor) or the probes' tree $PROBES is missing"
for f in clock.py shutdown.sh probe/Loaders.java probe/Witness.java probe/Holder.java probe/MainEnds.java; do [ -f "harness/$f" ] || die "harness/$f is missing"; done

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19040 19041 19042 19043 19044 19045 19046 19047 19048 19049; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from the anchor's README and asserted - each line must be there, whole ----------------------------
readme() { grep -m1 -xF -- "$1" "$BASE/README.md" > /dev/null || die "the anchor's README no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_CPB=$(readme 'mvn -B package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt')
R_CPR=$(readme 'java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.profiles.active=dev')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_PKG=$(readme 'mvn -B -Pnative package')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
R_HEALTH=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_ENVRUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,env')
ENVFLAG=${R_ENVRUN##* }                              # the README's flag that exposes env beside health
[ "$ENVFLAG" = "--management.endpoints.web.exposure.include=health,env" ] || die "the README's env flag"
# The module built alone: a row of the README's table ("Building part of it"), not a line of its own
grep -qF '| `mvn -B clean package -pl tiffinbox-core` |' "$BASE/README.md" || die "the anchor's README no longer gives the row mvn -B clean package -pl tiffinbox-core"
R_CORE='mvn -B package -pl tiffinbox-core'           # off() adds the README row's "clean" back, with -DskipTests and offline
# The DevTools run: the README's class-path line (the Compose lesson's: the classes folder in front, the class path Maven lists
# after it), without the profile dev - that profile is Docker's (Compose), and nothing here runs Docker
FR=${R_CPR% --spring.profiles.active=dev}
[ "$FR" != "$R_CPR" ] || die "the README's class-path line no longer ends with the profile dev"
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package, install) clean and without tests. dev() takes those four things back out, and must
# give the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# front 'COMMAND' 'ENTRIES': COMMAND's class path (-cp "...") with ENTRIES put in front of it
front() { printf '%s\n' "$1" | sed "s|-cp \"|-cp \"$2:|"; }
for c in "$(off .harness/x "$R_INSTALL" install)" "$(off .harness/x "$R_CPB" package)" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PKG" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_CPB" ] || [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PKG" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(off .harness/x "$R_CORE" package)" = 'cd .harness/x && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package -pl tiffinbox-core' ] || die "the core build line"
[ "$(at .harness/x 19040 "$FR")" = 'cd .harness/x && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19040' ] || die "the DevTools run's line"
[ "$(front "$(at .harness/x 19044 "$FR")" ../hc)" = 'cd .harness/x && java -cp "../hc:tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19044' ] || die "the harness's class path"
echo "  the commands: the anchor's README gives all 11 lines and the table row this script runs or derives from"

# ---- build: two builds before the captures - they fill .m2-demo; then the harness ---------------------------------------------
rm -rf .harness; mkdir -p .harness
# ZIP: GraalVM's reachability metadata repository, as Maven Central serves it - the native plugin reads it from .m2-demo
ZIP="$M2/org/graalvm/buildtools/graalvm-reachability-metadata/1.1.8/graalvm-reachability-metadata-1.1.8-repository.zip"
# ghub LOG: the native plugin went over the network for its metadata repository - downloaded it (from GitHub, when the zip is not
# in $M2), or tried to (its own two lines). Never allowed: the caller says "offline: no" and stops.
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only if
# the offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is never
# silent (inside a capture, "no" changes the capture's hash: cap() then dies). A native-profile build while the metadata repository
# is not in $M2 goes to Maven Central at once (offline, the plugin would fetch it from GitHub instead).
mbuild() { local how=yes ec=0 c=$1
  case $c in *' -Pnative '*) [ -f "$ZIP" ] || { c=${c/mvn -o -B /mvn -B }; how="no - GraalVM's metadata repository was not in .m2-demo, so Maven Central was asked for it"; } ;; esac
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && [ "$how" = yes ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  if ghub "$2"; then echo "  built $3 · offline: no - GraalVM's native plugin went to GitHub for its metadata repository · exit $ec"
    die "$3: GraalVM's native plugin went over the network for its metadata repository - $(grep -m1 -E 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$2" | sed 's/^\[[A-Z]*\] //') - README.md, The repository"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
# copy SRC DEST: a tree copied without its target/ and secrets/, then a config tree of its own
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
# The first build is the README's native install, on a DevTools copy with the native plugin's exclusion (capture native's): it needs
# nearly every artifact the captures' Maven lines need - the plain ones, the profile native's (process-aot, the native plugin, its
# metadata repository), install's, and DevTools itself - so on a fresh clone, whose .m2-demo is empty (git ignores it), this one
# build fills .m2-demo from Maven Central, once. The second, the README's class-path build on the same copy, adds what only it needs
# (the dependency plugin), so that every build inside a capture says "offline: yes".
copy "$BASE" .harness/fill
perl -0pi -e "s|\n  </dependencies>|\n$DEVDEP\n  </dependencies>|" .harness/fill/$WEBPOM
perl -0pi -e "s|\n          </exclusions>|\n$NATX\n          </exclusions>|" .harness/fill/$WEBPOM
[ "$(grep -c 'spring-boot-devtools' .harness/fill/$WEBPOM)" = 2 ] || die "the fill copy's POM did not get the dependency and the exclusion"
mbuild "$(off .harness/fill "$R_INSTALL" install)" .harness/build-fill.log ".harness/fill (a DevTools copy, the profile native, both modules into \$M2)"
mbuild "$(off .harness/fill "$R_CPB" package)" .harness/build-fill2.log ".harness/fill (the class path Maven lists)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$DTJ" ] || die "DevTools 4.1.1 is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
[ -f "$BPJ" ] || die "Boot's Maven plugin 4.1.1 is not in .m2-demo after the first build"
echo "  .m2-demo holds Boot's parent, DevTools 4.1.1, Boot's plugin, GraalVM's native plugin 1.1.8 and its metadata repository ($(wc -c < "$ZIP" | tr -d ' ') bytes)"
# The harness: Holder alone into .harness/hold (a folder) and into .harness/holder.jar (a jar); Loaders and Witness into .harness/hc
# against the fill copy's classes and Maven's class path (Holder from .harness/hold); MainEnds, which needs nothing, into .harness/me
mkdir -p .harness/hold .harness/hc .harness/me
HCP=".harness/fill/tiffinbox-web/target/classes:$(cat .harness/fill/tiffinbox-web/target/classpath.txt)"
{ javac -d .harness/hold harness/probe/Holder.java && javac -d .harness/hc -cp ".harness/hold:$HCP" harness/probe/Loaders.java harness/probe/Witness.java \
  && (cd .harness/hold && jar --create --file ../holder.jar probe/Holder.class) && javac -d .harness/me harness/probe/MainEnds.java; } > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile"; }
[ ! -e .harness/hc/probe/Holder.class ] && [ "$(unzip -Z1 .harness/holder.jar | grep -c '\.class$')" = 1 ] || die "Holder must live only in .harness/hold and .harness/holder.jar"
echo "  the harness compiled: Loaders and Witness into .harness/hc, Holder into .harness/hold and .harness/holder.jar, MainEnds into .harness/me"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
# msg: a Boot log line from its message on (the time, the level, the pid, the thread and the logger cut)
msg() { sed 's/^[^]]*\] [^ ]* *: //'; }
# thread PATTERN: the thread a Boot log line matching PATTERN ran on (the field in square brackets)
thread() { grep -m1 -E "$1" .harness/run.out | sed -n 's/^[^[]*\[ *\([^]]*\)\].*$/\1/p'; }
# start 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec, so $pid is the program's own
# pid), its standard output and standard error to .harness/run.out
start() { echo "\$ $1"; (eval "${1/&& /&& exec }") > .harness/run.out 2>&1 < /dev/null & pid=$!; }
# listening [N]: what the operating system says the process listens on (lsof), once it listens on N addresses (1 unless said) - or
# what it listened on when it exited ("nothing" if never)
listening() { local a="" i=0 n=${1:-1}
  while [ $i -lt 160 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && [ "$(printf '%s\n' "$a" | wc -w | tr -d ' ')" -ge "$n" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# up [N]: the line after a start - where it listens; dies if it never listened
up() { local l; l=$(listening "${1:-1}"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  echo "  listens on: $l"; }
# ask 'README curl LINE' PORT: the README's curl line, its port made PORT, printed and run; what it printed, indented
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# ready PORT [quiet]: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed - then (unless quiet) the README's
# readiness line, printed and run once. No assertion, and no file change for DevTools to see, before it (brief S4.15): TiffinBox
# answers before Boot calls it ready, and DevTools watches the class path only once the context is up.
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  [ "$2" = quiet ] || ask "$R_READY" "$1"; }
# lines N 'PATTERN': wait until the log holds N lines matching PATTERN - every 0.25 s, up to 40 s (DevTools notices a change by
# polling: a bounded wait, never a fixed sleep)
lines() { local i=0
  while [ $i -lt 160 ] && [ "$(grep -cE "$2" .harness/run.out || true)" -lt "$1" ]; do kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  [ "$(grep -cE "$2" .harness/run.out || true)" -ge "$1" ] || { tail -20 .harness/run.out >&3; die "the log never held $1 lines matching $2"; }; }
# settled: the first main thread is gone (jcmd Thread.print, every 0.25 s, up to 20 s, not printed). DevTools ends it once the
# restarted context is up; a POST /shutdown that arrives before that could race it - the stop is sent only after.
settled() { local i=0
  while [ $i -lt 80 ]; do [ "$(jcmd "$pid" Thread.print 2> /dev/null | grep -c '^"main" ' || true)" = 0 ] && return 0; sleep 0.25; i=$((i + 1)); done
  die "the first main thread never ended"; }
# seven PORT DIR [all]: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), printed
# as run - every response line with "all", else the POST line; the process must leave within 15 s of them, and the port must be
# free again. Never call it inside $(...): wait needs this shell.
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  if [ "$3" = all ]; then sed 's/^/  /' .harness/responses.txt; else grep '^POST ' .harness/responses.txt | sed 's/^/  /' || echo "  (no POST line)"; fi
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }
# mask: the demo token becomes a label naming its length; the GraalVM's folder "$GRAALVM_HOME"; this folder's path "…", the folder
# above it "…/..", the home folder "~" (each also in its URL form, spaces as %20); the user name "<user>" - in every line (gsub). The
# GraalVM's folder is masked before the home folder, which holds it (and not at all when GRAALVM_HOME is not set).
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = lit(me) }
  { gsub(T, "[masked: the 26-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(M, "<user>"); print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, GraalVM, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# cbuild DIR 'LABEL': the README's class-path build (the classes, the executable jar, target/classpath.txt), offline, from DIR
cbuild() { local c; c=$(off "$1" "$R_CPB" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
# pbuild DIR 'LABEL' ['README mvn LINE' [EXTRA]]: the README's Maven line (the plain build unless named), offline, from DIR, and
# EXTRA added at its end
pbuild() { local c; c=$(off "$1" "${3:-$R_PLAIN}" package)${4:+ $4}; echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
# ins 'LINE' FILE ['CLOSING TAG']: the perl that puts LINE, whole, before the line CLOSING TAG ('  </dependencies>' unless named) of
# FILE, printed as run; one line added
ins() { local c b a t=${3:-  </dependencies>}
  c="perl -0pi -e 's|\\n$t|\\n$1\\n$t|' $2"
  b=$(wc -l < "$2"); echo "\$ $c"; eval "$c"; a=$(wc -l < "$2"); echo "  lines added: $((a - b))"; }
# libs DIR: the names under BOOT-INF/lib/ of DIR's executable jar, one per line, sorted
libs() { unzip -Z1 "$1/$JAR" | sed -n 's|^BOOT-INF/lib/\(.*\.jar\)$|\1|p' | LC_ALL=C sort; }
# dtent DIR: the entries of DIR's executable jar whose name holds "devtools" (any case), counted - and listed when there are any
dtent() { local n; n=$(unzip -Z1 "$1/$JAR" | grep -ci devtools || true)
  if [ "$n" = 0 ]; then echo "  entries of its jar that name devtools: 0"; else echo "  entries of its jar that name devtools: $n -"; unzip -Z1 "$1/$JAR" | grep -i devtools | sed 's/^/    /'; fi; }
# report LOG 'NAMES': the condition report's header, then the blocks whose class is one of NAMES (a nested configuration's dotted
# name included), each whole, in the report's order - and before each, and after the last, how many of the report's lines are not
# shown
report() { awk -v want=" $2 " '
  /^CONDITIONS EVALUATION REPORT$/ { r = NR; p = NR; print "    " $0; next }
  !r { next }
  /^[0-9][0-9][0-9][0-9]-/ && NR > r + 5 { if (!end) end = NR; next }
  end { next }
  /^   [A-Za-z][A-Za-z0-9.#]*( matched)?:$/ { n = $1; sub(/:$/, "", n); b = index(want, " " n " ") ? 1 : 0 }
  /^   [A-Za-z]/ && !/^   [A-Za-z][A-Za-z0-9.#]*( matched)?:$/ { b = 0 }
  /^$/ { b = 0 }
  b { if (NR > p + 1) printf "    … %d line%s not shown …\n", NR - p - 1, (NR - p - 1 == 1) ? "" : "s"; print "    " $0; p = NR }
  END { if (!end) end = NR + 1; if (end - 1 > p) printf "    … %d line%s not shown …\n", end - 1 - p, (end - 1 - p == 1) ? "" : "s" }' "$1"; }
# classpath DIR: what DIR's target/classpath.txt (the web module's, as the README's build writes it) holds - its entries, how many are
# jars, DevTools' jar among them, and how tiffinbox-core comes (the end of its path)
classpath() { local f=$1/tiffinbox-web/target/classpath.txt
  echo "  target/classpath.txt: $(tr ':' '\n' < "$f" | grep -c .) entries · jars $(tr ':' '\n' < "$f" | grep -c '\.jar$') · $(basename "$DTJ") among them: $(tr ':' '\n' < "$f" | grep -c '/spring-boot-devtools-4\.1\.1\.jar$' || true) · tiffinbox-core as: $(tr ':' '\n' < "$f" | grep 'tiffinbox-core' | sed 's|^.*/\(tiffinbox-core/target/[^/]*\)$|\1|')"; }

# ---- added: DevTools in a copy ----------------------------------------------------------------------------------------------
added() {
  echo "the anchor as the logging lesson left it, copied twice: .harness/base as it is, .harness/dev with one line more in the web"
  echo "module's POM - DevTools, optional. The copy built as the README builds the class path Maven lists (the Compose lesson's), the"
  echo "anchor's copy the README's plain way - both offline:"
  copy "$BASE" .harness/base; copy "$BASE" .harness/dev
  ins "$DEVDEP" .harness/dev/$WEBPOM
  echo "\$ diff .harness/base/$WEBPOM .harness/dev/$WEBPOM"
  diff .harness/base/$WEBPOM .harness/dev/$WEBPOM | sed 's/^/  /' || true
  pbuild .harness/base "the anchor's copy"
  cbuild .harness/dev "the copy"
  libs .harness/base > .harness/base.lib; libs .harness/dev > .harness/dev.lib
  echo "the two executable jars:"
  echo "  jars under BOOT-INF/lib: $(wc -l < .harness/base.lib | tr -d ' ') and $(wc -l < .harness/dev.lib | tr -d ' ') · the same names: $(cmp -s .harness/base.lib .harness/dev.lib && echo yes || echo no)"
  dtent .harness/dev
  echo "the class path Maven lists for the copy's web module - the classes folder the README's java -cp line puts in front is not in it:"
  classpath .harness/dev
  echo "the same line in the tree both Section 4 probes measured (the hints lesson's - before Actuator), copied to .harness/probes:"
  copy "$PROBES" .harness/probes
  ins "$DEVDEP" .harness/probes/$WEBPOM
  cbuild .harness/probes "the probes' tree, with the same line"
  classpath .harness/probes
  echo "the copy's class-path run - the README's line without the profile dev - with the README's flag that exposes env (the Actuator"
  echo "lesson's), port 19040:"
  start "$(at .harness/dev 19040 "$FR") $ENVFLAG"; up; ready 19040
  echo "  DevTools' line in Boot's log: $(grep -m1 'Devtools property defaults active!' .harness/run.out | msg)"
  echo "  the thread TiffinBox's own lines ran on: $(thread 'TiffinBox listening on ') · lines on a thread named main: $(grep -cE '\[ *main\] ' .harness/run.out || true)"
  echo "\$ curl -s -o .harness/dev/env.json http://127.0.0.1:19040/actuator/env"
  curl -s -o .harness/dev/env.json http://127.0.0.1:19040/actuator/env
  python3 - .harness/dev/env.json <<'PY'
import json, sys
s = json.load(open(sys.argv[1]))["propertySources"]
def label(n):
    if n.startswith("Config tree "): return "the config tree"
    if n.startswith("Config resource ") and "application.yaml" in n: return "application.yaml"
    return n
print("  env's property sources, in order (the config tree's and application.yaml's by label): " + " · ".join(label(x["name"]) for x in s))
d = [x for x in s if x["name"] == "devtools"]
assert len(d) == 1, "no devtools property source"
p = d[0]["properties"]
print("  the source devtools: %d keys · values that are not ******: %d - its keys:" % (len(p), sum(v.get("value") != "******" for v in p.values())))
for k in sorted(p): print("    " + k)
PY
  rm -f .harness/dev/env.json
  settled; seven 19040 .harness/dev; }

# ---- loaders: jcmd's view ---------------------------------------------------------------------------------------------------
# loadertree FILE: jcmd's VM.classloaders answer, read - the tree of loaders (one line each), the classes the restart loader defined
# (a lambda's and a proxy's generated numbers cut; sorted by name: jcmd lists them in the order they were defined, and on the logging
# lesson's tree that order moved between runs - two of ActuatorRoutes' lambdas are made by the first request to an endpoint, here a
# readiness poll that can arrive mid-start, and KitchenMetrics' two when Micrometer binds it), TiffinBox's web classes in the
# application loader, how many of tiffinbox-core's classes each loader defined, and DevTools' own classes in the application loader
# (counted)
loadertree() { python3 - "$1" <<'PY'
import re, sys
tree, owner, classes = [], None, {}
for l in open(sys.argv[1]):
    l = l.rstrip("\n")
    m = re.search(r"\+-- (.*)$", l)
    if m:
        owner = m.group(1).strip(); tree.append((l.index("+--"), owner)); classes[owner] = []; continue
    if owner is None: continue
    m = re.match(r"^[ |]*(?:Classes: )?([A-Za-z_$\[][\w$.\[;/]*)\s*$", l)
    if m and not re.match(r"^\(\d+ classes\)$", m.group(1)): classes[owner].append(m.group(1))
def cut(n): return re.sub(r"jdk\.proxy\d+\.\$Proxy\d+", "jdk.proxy<n>.$Proxy<n>", re.sub(r"\$\$Lambda/0x[0-9a-f]+", "$$Lambda", n))
print("  the loaders, as jcmd draws them:")
base = min(i for i, _ in tree)
for i, o in tree: print("    " + " " * ((i - base) // 2) + "+-- " + o)
rcl = [o for o in classes if o.endswith(".RestartClassLoader")]
app = [o for o in classes if o.startswith('"app"')]
assert len(rcl) == 1 and len(app) == 1, (rcl, app)
r, a = [cut(c) for c in classes[rcl[0]]], classes[app[0]]
print("  the classes RestartClassLoader defined, sorted by name: %d -" % len(r))
for c in sorted(r): print("    " + c)
web = [c for c in a if c.startswith("com.tiffinbox.web.")]
print("  com.tiffinbox.web classes the application loader defined: %d - %s" % (len(web), " ".join(sorted(web))))
core = lambda cs: [c for c in cs if c.startswith("com.tiffinbox.") and not c.startswith("com.tiffinbox.web.")]
print("  tiffinbox-core classes (com.tiffinbox, outside .web) - defined by the application loader: %d · by RestartClassLoader: %d" % (len(core(a)), len(core(r))))
print("  DevTools' own classes (org.springframework.boot.devtools) - defined by the application loader: %s · by RestartClassLoader: %d"
      % ("some" if any(c.startswith("org.springframework.boot.devtools.") for c in a) else "none", sum(c.startswith("org.springframework.boot.devtools.") for c in r)))
PY
}
loaders() {
  echo "the copy's class-path run again, port 19041; once readiness answers 200, jcmd - the JDK's tool that asks a running JVM - lists"
  echo "its class loaders and the classes each one defined:"
  start "$(at .harness/dev 19041 "$FR")"; up; ready 19041
  echo "\$ jcmd \$pid VM.classloaders show-classes=true"
  jcmd "$pid" VM.classloaders show-classes=true > .harness/loaders.txt 2>&1 || die "jcmd could not ask the JVM"
  loadertree .harness/loaders.txt
  echo "  (jcmd's answer is read, never printed whole: its first line names the pid, and its length moves from run to run)"
  settled; seven 19041 .harness/dev; }

# ---- restart: one class file changes ------------------------------------------------------------------------------------------
restart() {
  echo "the copy's class-path run, port 19042; once readiness answers 200, one class file's time changed, as a compiler that rewrites"
  echo "it would change it:"
  start "$(at .harness/dev 19042 "$FR")"; up; ready 19042
  echo "\$ cd .harness/dev && touch $ROUTE"
  (cd .harness/dev && touch "$ROUTE")
  lines 2 'TiffinBox listening on '; ready 19042 quiet
  echo "  DevTools' line, on its thread $(thread 'Restarting due to '): $(grep -m1 'Restarting due to ' .harness/run.out | msg)"
  echo "  the process listening on 19042 now: the one this script started: $( [ "$(lsof -nP -iTCP:19042 -sTCP:LISTEN -t 2> /dev/null)" = "$pid" ] && echo yes || echo no)"
  echo "  in the log, once per start: Boot's banner $(grep -c '^ :: Spring Boot ::\|(v4\.1\.1)' .harness/run.out || true) · 'orders cooked' $(grep -c 'orders cooked:' .harness/run.out || true) · 'TiffinBox listening' $(grep -c 'TiffinBox listening on ' .harness/run.out || true) · Boot's 'Started TiffinBoxServer' $(grep -c ': Started TiffinBoxServer in ' .harness/run.out || true) · DevTools' 'Devtools property defaults active!' $(grep -c 'Devtools property defaults active!' .harness/run.out || true)"
  echo "  the new context's line about its conditions: $(grep -m1 'Condition evaluation ' .harness/run.out | msg)"
  echo "  the threads TiffinBox's lines ran on: $(grep 'TiffinBox listening on ' .harness/run.out | sed -n 's/^[^[]*\[ *\([^]]*\)\].*$/\1/p' | sort | uniq -c | awk '{ printf "%s%s x%s", (NR > 1 ? " · " : ""), $2, $1 }')"
  echo "after the restart, readiness answered 200 again (asked until it did); then:"
  ask "$R_HEALTH" 19042
  settled; seven 19042 .harness/dev all; }

# ---- timing: the cold start and the restart, from outside ------------------------------------------------------------------------
timing() { local r c s
  echo "the cold start and the restart, timed from outside: harness/clock.py forks the copy's class-path run, port 19043, and asks"
  echo "/kitchen until the first 200 - the cold start - then three times: waits until readiness answers 200, changes Route.class's"
  echo "time, notes when the port stops accepting connections and when /kitchen answers 200 again; then POST /shutdown with the"
  echo "token. 6 runs, run 1 a warm-up:"
  echo "  (terminal only) this Mac: $(sysctl -n machdep.cpu.brand_string) · $(sysctl -n hw.ncpu) cores · $(( $(sysctl -n hw.memsize) / 1073741824 )) GB · $(java -version 2>&1 | head -1) · load $(uptime | sed 's/.*load averages*: //')" >&3
  unzip -p "$DTJ" META-INF/spring-configuration-metadata.json | python3 -c '
import json, sys
p = {x["name"]: x for x in json.load(sys.stdin)["properties"]}
print("  how DevTools notices a change - its metadata'"'"'s defaults: " + " · ".join("%s %s" % (k, p[k].get("defaultValue")) for k in ("spring.devtools.restart.poll-interval", "spring.devtools.restart.quiet-period")))'
  c=$(at .harness/dev 19043 "$FR"); c="cd .harness/dev && python3 ../../harness/clock.py 19043 $TF ../clock.out $ROUTE 3 -- ${c#cd .harness/dev && }"
  echo "\$ $c"
  : > .harness/times.txt
  r=1; while [ $r -le 6 ]; do
    s=$(eval "$c"); printf '%s %s\n' "$r" "$s" >> .harness/times.txt
    [ "$(listeners 19043)" = 0 ] || die "a timed run left 19043 bound"; r=$((r + 1)); done
  echo "  every run: a cold start, three restarts, then exit 1 after POST /shutdown: $(grep -cE '^[0-9] cold [0-9.]+ · noticing [0-9.]+ restart [0-9.]+ · noticing [0-9.]+ restart [0-9.]+ · noticing [0-9.]+ restart [0-9.]+ · exit 1$' .harness/times.txt || true) of $(wc -l < .harness/times.txt | tr -d ' ')"
  echo "the medians - the middle of the counted runs - the cold start against a floor, the restart against the cold start, noticing"
  echo "against the restart (the seconds go to the terminal, never to this capture):"
  awk '
    function med(a, n,   i, j, x, v) { for (i = 1; i <= n; i++) { x = a[i]; j = i - 1; while (j > 0 && v[j] > x) { v[j + 1] = v[j]; j-- }; v[j + 1] = x }; lo = v[1]; hi = v[n]; return v[int((n + 1) / 2)] }
    { if ($1 == 1) next; nc++; cold[nc] = $3; for (k = 0; k < 3; k++) { nr++; note[nr] = $(6 + 5 * k); rest[nr] = $(8 + 5 * k) } }
    END { q = "\047"
      mc = med(cold, nc); cl = lo; ch = hi; mr = med(rest, nr); rl = lo; rh = hi; mn = med(note, nr); nl = lo; nh = hi
      printf "  counted: %d cold starts and %d restarts - run 1 left out\n", nc, nr
      printf "  the cold start%ss median over half a second: %s\n", q, (mc > 0.5) ? "yes" : "no"
      printf "  the restart%ss median, from the closed port to the first 200, under a quarter of the cold start%ss: %s\n", q, q, (mr < mc / 4) ? "yes" : "no"
      printf "  noticing%ss median, from the change to the closed port, over the restart%ss: %s\n", q, q, (mn > mr) ? "yes" : "no"
      printf "  (terminal only) cold start %.3f-%.3f s, median %.3f s · restart %.3f-%.3f s, median %.3f s - %.3f of the cold start%ss · noticing %.3f-%.3f s, median %.3f s\n", cl, ch, mc, rl, rh, mr, mr / mc, q, nl, nh, mn > "/dev/stderr" }' .harness/times.txt 2>&3; }

# ---- identity: the break - where the holder of an old object lives ---------------------------------------------------------------
# witness LABEL 'HOLDER ON THE CLASS PATH': one run of the copy with the harness in front of its class path (Witness from .harness/hc,
# Holder where named), port 19044; Route.class's time changed once, so the context starts twice; the witness's lines, a loader's
# address in them masked; the seven
witness() {
  echo "$1"
  start "$(front "$(at .harness/dev 19044 "$FR")" "../hc:$2") --spring.main.sources=probe.Witness"; up; ready 19044 quiet
  echo "\$ cd .harness/dev && touch $ROUTE"
  (cd .harness/dev && touch "$ROUTE")
  lines 1 '^WITNESS start 2 '; ready 19044 quiet
  grep '^WITNESS ' .harness/run.out | sed -E 's/ @[0-9a-f]+([;)])/ @<hash>\1/g' | sed 's/^/  /'
  settled; seven 19044 .harness/dev; }
identity() {
  echo "the break - where the holder of an old object lives. The copy's class-path run with the harness in front of its class path:"
  echo "Witness (harness/probe/Witness.java, compiled into the folder .harness/hc, joined with --spring.main.sources) asks Holder - one"
  echo "static field - at every start what it kept from the start before, then hands it this start's TiffinBoxServer. The flipped"
  echo "attribute: which loader defines Holder - a folder's classes are DevTools' to restart, a jar's are not."
  witness "A - Holder in a folder (.harness/hold), port 19044:" ../hold
  witness "B - Holder in a jar (.harness/holder.jar), port 19044:" ../holder.jar
  witness "A' - A again:" ../hold; }

# ---- which: what restarts ---------------------------------------------------------------------------------------------------------
whichcap() { local m1 m2 c
  echo "what restarts. A copy of the copy's kind (.harness/which: the anchor and the same line), built the same way; tiffinbox-core"
  echo "comes as a jar on its class path:"
  copy "$BASE" .harness/which
  ins "$DEVDEP" .harness/which/$WEBPOM
  cbuild .harness/which "the copy"
  classpath .harness/which
  echo "its class-path run with the harness's Loaders (harness/probe/Loaders.java, from .harness/hc), port 19045:"
  start "$(front "$(at .harness/which 19045 "$FR")" ../hc) --spring.main.sources=probe.Loaders"; up; ready 19045 quiet
  grep '^LOADERS start 1 ' .harness/run.out | sed 's/^/  /'
  echo "while it runs, a change in tiffinbox-core - one comment line under OrderQueue.java's package line, so every line of code after"
  echo "it moves down one and the class file changes - and the module rebuilt alone, as the README's table builds it, offline:"
  m1=$(md5 -q .harness/which/tiffinbox-core/target/tiffinbox-core-1.0.0.jar)
  c="cd .harness/which && perl -0pi -e 's|^(package com\\.tiffinbox;\\n)|\\1// changed while TiffinBox runs\\n|' tiffinbox-core/src/main/java/com/tiffinbox/OrderQueue.java"
  echo "\$ $c"; (eval "$c")
  c=$(off .harness/which "$R_CORE" package); echo "\$ $c"; mbuild "$c" .harness/which-core.build.log "tiffinbox-core alone"
  m2=$(md5 -q .harness/which/tiffinbox-core/target/tiffinbox-core-1.0.0.jar)
  echo "  the jar on the class path, rewritten: its md5 changed: $( [ "$m1" != "$m2" ] && echo yes || echo no) · DevTools' restart lines so far: $(grep -c 'Restarting due to ' .harness/run.out || true)"
  echo "then one class file of the web module, its time changed:"
  echo "\$ cd .harness/which && touch $ROUTE"
  (cd .harness/which && touch "$ROUTE")
  lines 1 '^LOADERS start 2 '; ready 19045 quiet
  echo "  DevTools' restart lines: $(grep -c 'Restarting due to ' .harness/run.out || true) - $(grep -m1 'Restarting due to ' .harness/run.out | msg)"
  grep '^LOADERS start 2 ' .harness/run.out | sed 's/^/  /'
  settled; seven 19045 .harness/which; }

# ---- livereload: deprecated, off, on for one run, stopped -----------------------------------------------------------------------
livereload() {
  echo "Live Reload in DevTools' own metadata (META-INF/spring-configuration-metadata.json in $(basename "$DTJ")):"
  unzip -p "$DTJ" META-INF/spring-configuration-metadata.json | python3 -c '
import json, sys
p = {x["name"]: x for x in json.load(sys.stdin)["properties"]}
for k in ("spring.devtools.livereload.enabled", "spring.devtools.livereload.port"):
    x = p[k]; d = x.get("deprecation") or {}
    print("  %s · default %s · deprecated: %s · since %s · reason: %s" % (k, json.dumps(x.get("defaultValue")), "yes" if x.get("deprecated") else "no", d.get("since"), d.get("reason")))'
  echo "off, as DevTools leaves it - the copy's class-path run with --debug, port 19046: the condition report's block for Live Reload,"
  echo "the rest of the report counted:"
  start "$(at .harness/dev 19046 "$FR") --debug"; up; ready 19046 quiet
  report .harness/run.out "LocalDevToolsAutoConfiguration.LiveReloadConfiguration"
  echo "  19049 listened on: $(listeners 19049) · 35729 (its default): $(listeners 35729)"
  settled; seven 19046 .harness/dev
  echo "on, for this one run - its port 19049, never its default - port 19046:"
  start "$(at .harness/dev 19046 "$FR") --spring.devtools.livereload.enabled=true --spring.devtools.livereload.port=19049"; up 2; ready 19046 quiet
  echo "  its line in Boot's log: $(grep -m1 'LiveReload server is running' .harness/run.out | msg)"
  echo "\$ curl -s -o .harness/livereload.js -w '%{http_code} %{content_type}\n' http://127.0.0.1:19049/livereload.js"
  curl -s -o .harness/livereload.js -w '%{http_code} %{content_type}\n' http://127.0.0.1:19049/livereload.js | sed 's/^/  /'
  echo "  the script it served is DevTools' own file (org/springframework/boot/devtools/livereload/livereload.js in its jar): $( [ "$(md5 -q .harness/livereload.js)" = "$(unzip -p "$DTJ" org/springframework/boot/devtools/livereload/livereload.js | md5 -q)" ] && echo yes || echo no)"
  echo "  lines in Boot's log that say deprecated (any case): $(grep -ci 'deprecat' .harness/run.out || true)"
  settled; seven 19046 .harness/dev
  echo "  19049 listened on now: $(listeners 19049)"; }

# ---- ship: why it must never ship ------------------------------------------------------------------------------------------------
ship() { local c
  echo "why it must never ship - three guards. 1 optional: the copy (capture added's):"
  dtent .harness/dev
  echo "2 not optional - .harness/ship-req, the anchor and the line without <optional>; built the README's plain way:"
  copy "$BASE" .harness/ship-req
  ins "$DEVREQ" .harness/ship-req/$WEBPOM
  pbuild .harness/ship-req "not optional"
  dtent .harness/ship-req
  unzip -p "$BPJ" META-INF/maven/plugin.xml | python3 -c '
import re, sys
x = sys.stdin.read()
for m in re.finditer(r"<mojo>(.*?)</mojo>", x, re.S):
    b = m.group(1)
    if re.search(r"<goal>repackage</goal>", b):
        d = re.search(r"<excludeDevtools implementation=\"[^\"]*\" default-value=\"([^\"]*)\">\$\{([^}]*)\}</excludeDevtools>", b)
        print("  Boot'"'"'s plugin, its repackage goal (META-INF/maven/plugin.xml): excludeDevtools default %s · its property %s" % d.groups())'
  echo "3 forced in - .harness/ship-forced, the same, built with that property false:"
  copy "$BASE" .harness/ship-forced
  ins "$DEVREQ" .harness/ship-forced/$WEBPOM
  pbuild .harness/ship-forced "forced in" "$R_PLAIN" "-Dspring-boot.repackage.excludeDevtools=false"
  dtent .harness/ship-forced
  echo "its jar run as the README runs it, with --debug, port 19047:"
  start "$(at .harness/ship-forced 19047 "$R_RUN") --debug"; up; ready 19047 quiet
  report .harness/run.out "LocalDevToolsAutoConfiguration"
  echo "  lines on restartedMain: $(grep -c '\[ *restartedMain\]' .harness/run.out || true) · DevTools' 'Devtools property defaults active!': $(grep -c 'Devtools property defaults active!' .harness/run.out || true)"
  seven 19047 .harness/ship-forced
  echo "the same jar, one system property more:"
  start "$(at .harness/ship-forced 19047 "${R_RUN/java -jar /java -Dspring.devtools.restart.enabled=true -jar }")"; up; ready 19047 quiet
  echo "  DevTools' line: $(grep -m1 'Restart enabled irrespective' .harness/run.out | sed 's/^.* -- //')"
  echo "  TiffinBox's own lines on restartedMain: $(grep 'TiffinBox listening on ' .harness/run.out | grep -c '\[ *restartedMain\]' || true) · 'Devtools property defaults active!': $(grep -c 'Devtools property defaults active!' .harness/run.out || true)"
  settled; seven 19047 .harness/ship-forced
  echo "C (labelled) - .harness/ship-opt, the copy's line (optional) with Boot's plugin told to take optional dependencies and DevTools"
  echo "(includeOptional true, excludeDevtools false - includeOptional has no property of its own), before the POM's first"
  echo "</configuration>, Boot's plugin's:"
  copy "$BASE" .harness/ship-opt
  ins "$DEVDEP" .harness/ship-opt/$WEBPOM
  ins '          <includeOptional>true</includeOptional><excludeDevtools>false</excludeDevtools>' .harness/ship-opt/$WEBPOM '        </configuration>'
  pbuild .harness/ship-opt "C"
  libs .harness/ship-opt > .harness/ship-opt.lib
  echo "  jars under BOOT-INF/lib against the anchor's: $(wc -l < .harness/ship-opt.lib | tr -d ' ') and $(wc -l < .harness/base.lib | tr -d ' ') · only in C's: $(LC_ALL=C comm -13 .harness/base.lib .harness/ship-opt.lib | paste -sd' ' -) · only in the anchor's: $(LC_ALL=C comm -23 .harness/base.lib .harness/ship-opt.lib | wc -l | tr -d ' ')"
  echo "the native profile's build - the README's AOT line, Spring's AOT step on the plain JDK - on the copy (.harness/aot-dev) and on"
  echo "the anchor (.harness/aot-base), offline:"
  copy "$BASE" .harness/aot-base; copy "$BASE" .harness/aot-dev
  ins "$DEVDEP" .harness/aot-dev/$WEBPOM
  pbuild .harness/aot-base "the anchor" "$R_PKG"
  pbuild .harness/aot-dev "the copy" "$R_PKG"
  echo "\$ diff -rq .harness/aot-base/tiffinbox-web/target/spring-aot/main .harness/aot-dev/tiffinbox-web/target/spring-aot/main"
  echo "  files Spring's AOT step wrote: $(find .harness/aot-base/tiffinbox-web/target/spring-aot/main -type f | wc -l | tr -d ' ') and $(find .harness/aot-dev/tiffinbox-web/target/spring-aot/main -type f | wc -l | tr -d ' ') · files that differ, or are in one only: $(diff -rq .harness/aot-base/tiffinbox-web/target/spring-aot/main .harness/aot-dev/tiffinbox-web/target/spring-aot/main | wc -l | tr -d ' ') · naming devtools: $(grep -rli devtools .harness/aot-dev/tiffinbox-web/target/spring-aot/main | wc -l | tr -d ' ')"
  c='javap -c -p -cp "$M2/org/springframework/boot/spring-boot-maven-plugin/4.1.1/spring-boot-maven-plugin-4.1.1.jar" org.springframework.boot.maven.ProcessAotMojo'
  echo "\$ $c"; (eval "$c") > .harness/javap-aot.txt 2>&1 || die "javap could not read ProcessAotMojo"
  c='javap -c -p -constants -cp "$M2/org/springframework/boot/spring-boot-maven-plugin/4.1.1/spring-boot-maven-plugin-4.1.1.jar" org.springframework.boot.maven.AbstractDependencyFilterMojo'
  echo "\$ $c"; (eval "$c") > .harness/javap-filter.txt 2>&1 || die "javap could not read AbstractDependencyFilterMojo"
  echo "  Boot's process-aot goal (ProcessAotMojo) reads DEVTOOLS_EXCLUDE_FILTER: $(grep -c 'Field .*DEVTOOLS_EXCLUDE_FILTER' .harness/javap-aot.txt || true) time(s) · the filter (AbstractDependencyFilterMojo, its static block): $(awk '/static \{\};/ { s = 1 } s && /ldc .*\/\/ String / { sub(/^.*\/\/ String /, ""); printf "%s%s", (n++ ? " " : ""), $0 } s && /DEVTOOLS_EXCLUDE_FILTER/ { exit }' .harness/javap-filter.txt)"
  echo "  each jar's entries that name devtools - the anchor's: $(unzip -Z1 .harness/aot-base/$JAR | grep -ci devtools || true) · the copy's: $(unzip -Z1 .harness/aot-dev/$JAR | grep -ci devtools || true) -"
  unzip -Z1 .harness/aot-dev/$JAR | grep -i devtools | sed 's/^/    /'
  echo "  the copy's build log, the native plugin's metadata step: $(grep -m1 'spring-boot-devtools:4.1.1\]: Configuration directory is ' .harness/aot-dev.build.log | sed 's/^\[INFO\] //')"; }

# ---- exits: how a DevTools run ends ---------------------------------------------------------------------------------------------
# threads: what jcmd Thread.print says of the process's threads - the threads named main and DestroyJavaVM, counted, and the Java
# threads that are not daemons, by name (no thread number, no stack)
threads() { jcmd "$pid" Thread.print > .harness/threads.txt 2>&1 || die "jcmd could not ask the JVM"
  echo "  its threads (jcmd \$pid Thread.print): named main $(grep -c '^"main" ' .harness/threads.txt || true) · named DestroyJavaVM $(grep -c '^"DestroyJavaVM" ' .harness/threads.txt || true) · Java threads that are not daemons: $(grep -E '^"[^"]+" #[0-9]+' .harness/threads.txt | grep -v ' daemon ' | sed 's/^"\([^"]*\)".*$/\1/' | LC_ALL=C sort | paste -sd' ' -)"; }
# exitrun LABEL 'COMMAND': one run of COMMAND from .harness/dev, port 19048: readiness, DevTools' restart line if it printed one, the
# threads once the first main thread has gone, the seven - and the exit code
exitrun() {
  echo "$1"
  start "$2"; up; ready 19048 quiet; settled
  echo "  DevTools' restart lines: $(grep -cE 'Restart (enabled|disabled)' .harness/run.out || true)$(grep -m1 -E 'Restart (enabled|disabled)' .harness/run.out | sed 's/^.* -- / - /')"
  threads
  seven 19048 .harness/dev; }
exits() { local c c2 e
  echo "how the copy's class-path run ends after a clean POST /shutdown - A the restart on (DevTools' default) · B off · A' = A ·"
  echo "C (labelled) the same class path without DevTools' jar; port 19048:"
  c=$(at .harness/dev 19048 "$FR")
  exitrun "A - the restart on:" "$c"
  exitrun "B - -Dspring.devtools.restart.enabled=false:" "${c/&& java -cp /&& java -Dspring.devtools.restart.enabled=false -cp }"
  exitrun "A' - A again:" "$c"
  c2="cd .harness/dev && tr ':' '\\n' < tiffinbox-web/target/classpath.txt | grep -v '/spring-boot-devtools-' | paste -sd: - > tiffinbox-web/target/classpath-nodevtools.txt"
  echo "\$ $c2"; (eval "$c2")
  echo "  entries: $(tr ':' '\n' < .harness/dev/tiffinbox-web/target/classpath.txt | grep -c .) and $(tr ':' '\n' < .harness/dev/tiffinbox-web/target/classpath-nodevtools.txt | grep -c .)"
  exitrun "C - without DevTools' jar:" "${c/classpath.txt/classpath-nodevtools.txt}"
  echo "D (labelled) - DevTools' own code, read with javap from $(basename "$DTJ"):"
  c2='javap -c -p -cp "$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar" org.springframework.boot.devtools.restart.Restarter'
  echo "\$ $c2"; (eval "$c2") > .harness/javap-restarter.txt 2>&1 || die "javap could not read Restarter"
  c2='javap -c -p -cp "$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar" org.springframework.boot.devtools.restart.SilentExitExceptionHandler'
  echo "\$ $c2"; (eval "$c2") > .harness/javap-silent.txt 2>&1 || die "javap could not read SilentExitExceptionHandler"
  echo "  Restarter.immediateRestart() ends by calling: $(awk '/ immediateRestart\(\);$/ { f = 1; next } f && /^  [a-z]/ { exit } f && /invokestatic/ { sub(/^.*\/\/ Method /, ""); m = $0 } END { print m }' .harness/javap-restarter.txt)"
  echo "  SilentExitExceptionHandler.exitCurrentThread(): $(awk '/ exitCurrentThread\(\);$/ { f = 1; next } f && /^  [a-z]/ { exit } f && /(new|athrow)/ { sub(/^ *[0-9]+: /, ""); sub(/ +#[0-9]+ +\/\/ class /, " "); printf "%s%s", (n++ ? " · " : ""), $0 }' .harness/javap-silent.txt)"
  echo "E (labelled) - the JVM's own rule, with nothing of Spring (harness/probe/MainEnds.java: its main thread starts a thread that is not"
  echo "a daemon, and hides its own uncaught exception):"
  for c in throw return; do
    echo "\$ java -cp .harness/me probe.MainEnds $c"
    e=0; java -cp .harness/me probe.MainEnds "$c" > .harness/me.out 2>&1 || e=$?
    echo "  printed: $(grep -c . .harness/me.out || true) lines · exit $e"; done; }

# ---- native: the binary, without and with the exclusion -----------------------------------------------------------------------
# nbuild DIR: the README's native install, then its native:compile-no-fork - both offline, from DIR; the native build's log kept in
# DIR.native.log (never printed whole), its seconds to the terminal
nbuild() { local ci cn s0 s1 cpl
  ci=$(off "$1" "$R_INSTALL" install); cn=$(off "$1" "$R_NATIVE")
  echo "\$ $ci"; mbuild "$ci" "$1.install.log" "$1 (both modules, into \$M2)"
  echo "\$ $cn"
  NB_E=0; s0=$(date +%s); (eval "$cn") > "$1.native.log" 2>&1 < /dev/null || NB_E=$?; s1=$(date +%s); NB_S=$((s1 - s0))
  echo "  (terminal only) the native build in $1 took $NB_S s" >&3
  if ghub "$1.native.log"; then echo "  offline: no - GraalVM's native plugin went to GitHub for its metadata repository"; die "the native build in $1: GraalVM's native plugin went over the network for its metadata repository - README.md, The repository"; fi
  echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1.native.log" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1.native.log" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1.native.log" | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $NB_S -ge 60 ] && echo '1 minute or more' || echo 'under 1 minute' ), $( [ $NB_S -lt 1200 ] && echo 'under 20 minutes' || echo '20 minutes or more' ) · offline: yes"
  cpl=$(grep -m1 '^\[INFO\] Executing: .*/native-image -cp ' "$1.native.log" || true)
  echo "  native-image's class path (the plugin's 'Executing:' line) - entries that are $(basename "$DTJ"): $( [ -n "$cpl" ] && { printf '%s\n' "$cpl" | grep -o 'spring-boot-devtools-4\.1\.1\.jar' | wc -l | tr -d ' '; } || echo 'no such line')"
  echo "  file: $(file -b "$1/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" "$1/$BIN") · strings naming org.springframework.boot.devtools in its bytes: $(LC_ALL=C grep -aoE 'org[./]springframework[./]boot[./]devtools[./][A-Za-z0-9_$./]*' "$1/$BIN" | wc -l | tr -d ' ')"; }
# crash: after a start that stops - the exception the JVM printed for the main thread and every 'Caused by: ' line under it, the log's
# lines between them counted, the exit code, and what it listened on
crash() { local e=0
  wait "$pid" || e=$?; pid=""
  awk '
    function show(l) { if (p) printf "    … %d line%s not shown …\n", NR - p - 1, (NR - p - 1 == 1) ? "" : "s"; print "    " l; p = NR }
    /^Exception in thread / && !s { s = 1; show($0); next }
    s && /^Caused by: / { show($0) }
    END { if (p && NR > p) printf "    … %d line%s not shown …\n", NR - p, (NR - p == 1) ? "" : "s" }' .harness/run.out
  echo "  exit $e · listened on 19047: $(grep -c 'TiffinBox listening on ' .harness/run.out || true) time(s)"; }
native() {
  echo "two copies of the copy (the anchor and DevTools' optional line), each built with the README's two Maven lines, offline;"
  echo "\$GRAALVM_HOME names the GraalVM. Without an exclusion - .harness/nat-b:"
  copy "$BASE" .harness/nat-b
  ins "$DEVDEP" .harness/nat-b/$WEBPOM
  nbuild .harness/nat-b
  echo "its binary, run from beside its config tree as the README runs it, port 19047:"
  start "$(at .harness/nat-b 19047 "$R_BIN")"
  crash
  echo "with one exclusion in the native plugin, beside the hints lesson's three - .harness/nat-a:"
  copy "$BASE" .harness/nat-a
  ins "$DEVDEP" .harness/nat-a/$WEBPOM
  ins "$NATX" .harness/nat-a/$WEBPOM '          </exclusions>'
  nbuild .harness/nat-a
  echo "its binary, port 19047:"
  start "$(at .harness/nat-a 19047 "$R_BIN")"; up; ready 19047
  ask "$R_HEALTH" 19047
  seven 19047 .harness/nat-a all; }

# ---- exercise: the README's commands, exactly as written, then the solution's ---------------------------------------------
# block FILE: the lines of FILE's first ```bash block
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
exercise() { local setup sol ec=0
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  echo "exercise/README.md's commands, run exactly as written from this folder - $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  (eval "$setup") > .harness/ex-setup.log 2>&1 < /dev/null || ec=$?
  [ $ec = 0 ] || { tail -20 .harness/ex-setup.log >&3; die "the exercise's setup failed"; }
  echo "  exit $ec · printed: $(grep -c . .harness/ex-setup.log || true) line(s)"
  echo "the solution's commands (exercise/solution/SOLUTION.md), run exactly as written, from this folder - $(printf '%s\n' "$sol" | grep -c .) lines:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  ec=0; (eval "$sol") 2>&1 < /dev/null | sed -E 's/ @[0-9a-f]+([;)])/ @<hash>\1/g' || ec=$?
  echo "  listening on 19045 now: $(listeners 19045)"; }

# ==== the captures ===============================================================================================================
cap added added
cap loaders loaders
cap restart restart
cap timing timing
cap identity identity
cap which whichcap
cap livereload livereload
cap ship ship
cap exits exits
# Without a GraalVM the run stops here, the exercise's capture made first (it needs none): .m2-demo is filled, and every capture so
# far matched receipts.md5 - or cap() would have stopped the run.
if [ $GOK = no ]; then cap exercise exercise
  die "GRAALVM_HOME is not set: .m2-demo is filled, and the captures that need no GraalVM matched receipts.md5, the exercise's included; the native build needs a GraalVM JDK 25 - README.md, The GraalVM"; fi
cap native native
cap exercise exercise

echo
# ==== the checks =================================================================================================================
# Every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published md5 pins them,
# and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }                                            # how many lines match
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
# has 'TEXT' 'LINE' MESSAGE: TEXT (a variable holding a capture's block) holds the line, whole
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
S115='115c36bac276128e245ca57df11c2891'
# THE ANCHOR'S NUMBERS - the only lines here that depend on the tree anchor/ points at (the brief's re-point changed them; each is read
# off its capture and asserted below, and the builder derives the spoken words from the captures, never from here). The values are
# the logging lesson's tree (../c5-unit24/after); the Actuator lesson's (../c5-unit21/after), which this unit was first built on, in
# brackets:
E_LIBS=46      # jars under the anchor's BOOT-INF/lib (a DevTools copy's: the same) [39]
E_CP=54        # entries of a DevTools copy's target/classpath.txt (all jars) [47]
E_RCL=16       # classes RestartClassLoader defined by the time readiness answered 200 (loaders) [10; 14 before the bridge fix of RED C5-S4 part A]
E_WEB="TiffinBoxServer TiffinBoxApp Route ActuatorRoutes KitchenHealthIndicator KitchenMetrics"   # the web module's own classes
               # among them, by name - the rest are 1 proxy and lambdas [the first four]
E_CORE=10      # tiffinbox-core classes the application loader defined by then [10]
E_AOT=149      # files Spring's AOT step wrote under target/spring-aot/main [144]
E_FS=" · "     # (a separator, not a number)

# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does anything this
# unit ships for reading, nor a binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/clock.py harness/shutdown.sh harness/probe/*.java .harness/nat-b/$BIN .harness/nat-a/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat-*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ $GOK = no ] || [ "$NBIN" = 2 ] || die "two binaries were built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' @[0-9a-f]{6,}' "$f" || die "$f holds a class loader's address"; done
[ -z "$(find .harness -name env.json | head -1)" ] || die "an env answer was left under .harness/"
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the harness, receipts.md5 and $NBIN binaries; no absolute path, no GraalVM folder, no unit number, no loader address in any capture; no env answer left"
# S4.16: no exposure list with a star anywhere in this unit - the one flag it passes exposes health and env
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md .r-*.out; do [ -f "$f" ] || continue
  ! grep -nE "exposure\.include='?\*" "$f" | grep -q . || die "$f: an exposure list with a star"; done
# S4.3: Live Reload is switched on in one run of one capture, on 19049 - never on its default port, 35729
[ "$(cat .r-*.out | grep -c -- '--spring.devtools.livereload.enabled=true')" = 1 ] && grep -q -- '--spring.devtools.livereload.enabled=true --spring.devtools.livereload.port=19049$' .r-livereload.out \
  && ! cat receipts.sh .r-*.out | grep -q -- 'livereload\.port=35729' || die "Live Reload: one run, on 19049"

# "Spring Boot's DevTools ... goes into a copy, never into TiffinBox: one optional dependency. The jar holds zero DevTools entries."
x added '^  lines added: 1$'
[ "$(n added '^  > ')" = 1 ] && [ "$(n added '^  < ')" = 0 ] || die "added: the POM's diff - one line added, none removed"
has "$(blk added '$ diff ' '$ cd .harness/base')" "  >$(printf '%s' "$DEVDEP" | sed 's/^/ /')" "added: the line added is the dependency"
x added '^  built the anchor.s copy · offline: yes · exit 0$'
x added '^  built the copy · offline: yes · exit 0$'
x added "^  jars under BOOT-INF/lib: $E_LIBS and $E_LIBS · the same names: yes\$"
[ "$(n added '^  entries of its jar that name devtools: 0$')" = 1 ] || die "added: the copy's jar, 0 DevTools entries"
# "It needs folders, so it runs on the class path Maven lists" - and RE-MEASURE 5: the probes' 37 jars and 36 entries
x added "^  target/classpath.txt: $E_CP entries · jars $E_CP · spring-boot-devtools-4\.1\.1\.jar among them: 1 · tiffinbox-core as: tiffinbox-core/target/tiffinbox-core-1\.0\.0\.jar\$"
x added '^  built the probes. tree, with the same line · offline: yes · exit 0$'
x added '^  target/classpath.txt: 37 entries · jars 37 · spring-boot-devtools-4\.1\.1\.jar among them: 1 · tiffinbox-core as: tiffinbox-core/target/tiffinbox-core-1\.0\.0\.jar$'
# "Its log says: Devtools property defaults active. And TiffinBox now starts on a thread called restartedMain."
x added "^  DevTools' line in Boot's log: Devtools property defaults active! Set 'spring\.devtools\.add-properties' to 'false' to disable\$"
x added '^  the thread TiffinBox.s own lines ran on: restartedMain · lines on a thread named main: 0$'
# "The log says Devtools property defaults active: seven defaults, six of them for a web layer TiffinBox doesn't have."
x added '^  env.s property sources, in order \(the config tree.s and application\.yaml.s by label\): commandLineArgs · systemProperties · systemEnvironment · the config tree · application\.yaml · devtools · applicationInfo$'
x added '^  the source devtools: 7 keys · values that are not \*\*\*\*\*\*: 0 - its keys:$'
DK=$(blk added '  the source devtools: ' '$ $CURLSET')
for k in spring.docker.compose.readiness.wait spring.template.provider.cache spring.web.error.include-binding-errors spring.web.error.include-message spring.web.error.include-stacktrace spring.web.resources.cache.period spring.web.resources.chain.cache; do has "$DK" "    $k" "added: the devtools source's key $k"; done
[ "$(printf '%s\n' "$DK" | grep -cE '^    spring\.(web|template)\.')" = 6 ] || die "added: six of the seven keys are a web layer's (spring.web.*, spring.template.*)"
x added "^  exit 1 · the seven responses: 7 lines · md5 $S115\$"
echo "  added: one optional line; jars $E_LIBS = $E_LIBS, 0 DevTools entries; class path $E_CP jars (the probes' tree: 37, all jars); restartedMain; 7 property defaults; the seven, exit 1"

# "A class loader ... jcmd shows two here: the application's loader, holding every jar, and DevTools' RestartClassLoader under it,
# holding only what sits in folders - TiffinBox's web module. TiffinBoxServer is in both."
LT=$(blk loaders '  the loaders, as jcmd draws them:' '  the classes RestartClassLoader')
has "$LT" '    +-- <bootstrap>' "loaders: the tree"; has "$LT" '       +-- "platform", jdk.internal.loader.ClassLoaders$PlatformClassLoader' "loaders: the tree"
has "$LT" '          +-- "app", jdk.internal.loader.ClassLoaders$AppClassLoader' "loaders: the tree"
has "$LT" '             +-- org.springframework.boot.devtools.restart.classloader.RestartClassLoader' "loaders: the tree"
x loaders "^  the classes RestartClassLoader defined, sorted by name: $E_RCL -\$"
RC=$(blk loaders '  the classes RestartClassLoader defined, sorted by name: ' '  com.tiffinbox.web classes the application')
[ "$(printf '%s\n' "$RC" | LC_ALL=C sort)" = "$RC" ] || die "loaders: the restart loader's classes, sorted by name"
NW=$(printf '%s\n' $E_WEB | grep -c .)
for c in $E_WEB; do has "$RC" "    com.tiffinbox.web.$c" "loaders: $c in the restart loader"; done
[ "$(printf '%s\n' "$RC" | grep -c '^    com\.tiffinbox\.web\.[A-Za-z]*$')" = "$NW" ] || die "loaders: $NW of TiffinBox's own classes in the restart loader"
[ "$(printf '%s\n' "$RC" | grep -c '^    jdk\.proxy<n>\.\$Proxy<n>$')" = 1 ] || die "loaders: one proxy"
[ "$(printf '%s\n' "$RC" | grep -c '^    com\.tiffinbox\.web\.[A-Za-z]*\$\$Lambda$')" = $((E_RCL - NW - 1)) ] || die "loaders: the lambdas"
x loaders '^  com\.tiffinbox\.web classes the application loader defined: 2 - com\.tiffinbox\.web\.TiffinBoxApp com\.tiffinbox\.web\.TiffinBoxServer$'
x loaders "^  tiffinbox-core classes \(com\.tiffinbox, outside \.web\) - defined by the application loader: $E_CORE · by RestartClassLoader: 0\$"
x loaders '^  DevTools. own classes \(org\.springframework\.boot\.devtools\) - defined by the application loader: some · by RestartClassLoader: 0$'
x loaders "^  exit 1 · the seven responses: 7 lines · md5 $S115\$"
echo "  loaders: app -> RestartClassLoader; $E_RCL classes there ($NW named, 1 proxy, $((E_RCL - NW - 1)) lambdas); TiffinBoxServer and TiffinBoxApp in app too; core $E_CORE in app, 0 restarted"

# "Now change one class file. DevTools sees it: restarting due to one class path change. ... in the same process. The kitchen cooks
# again, and the same seven responses come back."
x restart "^  DevTools' line, on its thread File Watcher: Restarting due to 1 class path change \(0 additions, 0 deletions, 1 modification\)\$"
x restart '^  the process listening on 19042 now: the one this script started: yes$'
x restart "^  in the log, once per start: Boot's banner 2 · 'orders cooked' 2 · 'TiffinBox listening' 2 · Boot's 'Started TiffinBoxServer' 2 · DevTools' 'Devtools property defaults active!' 1\$"
x restart "^  the new context's line about its conditions: Condition evaluation unchanged\$"
x restart '^  the threads TiffinBox.s lines ran on: restartedMain x2$'
x restart '^  \{"status":"UP","groups":\["liveness","readiness"\]\} 200$'
[ "$(n restart ' -> ')" = 7 ] || die "restart: the seven response lines"
x restart "^  exit 1 · the seven responses: 7 lines · md5 $S115\$"
echo "  restart: 1 change, the same process, every TiffinBox line twice, health with its groups, the seven"

# "the restart took under a quarter of a cold start, on this Mac. Noticing the change took longer than the restart itself: DevTools
# checks every second, then waits for four hundred milliseconds of quiet."
x timing '^  how DevTools notices a change - its metadata.s defaults: spring\.devtools\.restart\.poll-interval 1s · spring\.devtools\.restart\.quiet-period 400ms$'
x timing '^  every run: a cold start, three restarts, then exit 1 after POST /shutdown: 6 of 6$'
x timing '^  counted: 5 cold starts and 15 restarts - run 1 left out$'
x timing '^  the cold start.s median over half a second: yes$'
x timing '^  the restart.s median, from the closed port to the first 200, under a quarter of the cold start.s: yes$'
x timing '^  noticing.s median, from the change to the closed port, over the restart.s: yes$'
echo "  timing: 6 of 6; the cold start over half a second; the restart under a quarter of it; noticing over the restart"

# "A holder in a jar keeps the first start's TiffinBoxServer. After the restart: same name true, same class false, and a cast that
# fails ... A, the holder in a folder: it restarts too, keeps nothing old, nothing to cast. A again: the same."
IA=$(blk identity 'A - Holder in a folder' 'B - Holder in a jar'); IB=$(blk identity 'B - Holder in a jar' "A' - A again"); IA2=$(blk identity "A' - A again" '')
for b in "$IA" "$IA2"; do
  for st in 1 2; do has "$b" "  WITNESS start $st · Holder's loader RestartClassLoader · TiffinBoxServer's loader RestartClassLoader" "identity A: start $st's loaders"
    has "$b" "  WITNESS start $st · Holder keeps nothing from an earlier start" "identity A: start $st keeps nothing"; done
  [ "$(printf '%s\n' "$b" | grep -c '^  WITNESS ')" = 4 ] || die "identity A: four witness lines, no cast"
  has "$b" "  exit 1 · the seven responses: 7 lines · md5 $S115" "identity A"; done
[ "$(printf '%s\n' "$IA" | grep '^\$ cd ')" = "$(printf '%s\n' "$IA2" | grep '^\$ cd ')" ] || die "identity: A' is not A's command"
for st in 1 2; do has "$IB" "  WITNESS start $st · Holder's loader app · TiffinBoxServer's loader RestartClassLoader" "identity B: start $st's loaders"; done
has "$IB" "  WITNESS start 1 · Holder keeps nothing from an earlier start" "identity B: start 1"
has "$IB" "  WITNESS start 2 · Holder keeps the TiffinBoxServer of start 1" "identity B: start 2 keeps start 1's server"
has "$IB" "  WITNESS start 2 · same name true · same class false · same loader false" "identity B: name, class, loader"
has "$IB" "  WITNESS start 2 · cast java.lang.ClassCastException: class com.tiffinbox.web.TiffinBoxServer cannot be cast to class com.tiffinbox.web.TiffinBoxServer (com.tiffinbox.web.TiffinBoxServer is in unnamed module of loader org.springframework.boot.devtools.restart.classloader.RestartClassLoader @<hash>; com.tiffinbox.web.TiffinBoxServer is in unnamed module of loader org.springframework.boot.devtools.restart.classloader.RestartClassLoader @<hash>)" "identity B: the cast"
has "$IB" "  exit 1 · the seven responses: 7 lines · md5 $S115" "identity B"
echo "  identity: A - Holder restarted, nothing kept, no cast · B - Holder in app, start 1's server kept, same name true, same class false, ClassCastException across two RestartClassLoaders · A' = A"

# "What restarts is folders. TiffinBox's core module is a jar on this class path. Rebuild it while it runs: the jar changes, and
# nothing restarts. Change a web class: one restart, one change."
x which '^  target/classpath.txt: [0-9]+ entries · jars [0-9]+ · spring-boot-devtools-4\.1\.1\.jar among them: 1 · tiffinbox-core as: tiffinbox-core/target/tiffinbox-core-1\.0\.0\.jar$'
x which "^  LOADERS start 1 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader app\$"
x which '^  built tiffinbox-core alone · offline: yes · exit 0$'
x which "^  the jar on the class path, rewritten: its md5 changed: yes · DevTools' restart lines so far: 0\$"
x which "^  DevTools' restart lines: 1 - Restarting due to 1 class path change \(0 additions, 0 deletions, 1 modification\)\$"
x which "^  LOADERS start 2 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader app\$"
x which "^  exit 1 · the seven responses: 7 lines · md5 $S115\$"
echo "  which: core as a jar - rebuilt (md5 changed), 0 restarts; a web class - 1 restart, 1 change; OrderQueue in app both times"

# "Live Reload ... deprecated since four point one, with no replacement, and off by default, says DevTools' own metadata. Switched on
# for one run, its server listened on every interface ... and served its script. ... Stopped at once."
x livereload '^  spring\.devtools\.livereload\.enabled · default false · deprecated: yes · since 4\.1\.0 · reason: Deprecated with no replacement$'
x livereload '^  spring\.devtools\.livereload\.port · default 35729 · deprecated: yes · since 4\.1\.0 · reason: Deprecated with no replacement$'
LR=$(blk livereload 'off, as DevTools leaves it' 'on, for this one run')
has "$LR" "       LocalDevToolsAutoConfiguration.LiveReloadConfiguration:" "livereload: the report's block"
has "$LR" "             - @ConditionalOnBooleanProperty (spring.devtools.livereload.enabled=true) did not find property 'spring.devtools.livereload.enabled' (OnPropertyCondition)" "livereload: off by default"
has "$LR" "  19049 listened on: 0 · 35729 (its default): 0" "livereload: nothing on 19049 or 35729 while off"
LO=$(blk livereload 'on, for this one run' '')
has "$LO" "  listens on: *:19049 127.0.0.1:19046" "livereload: every interface, beside TiffinBox's 127.0.0.1"
has "$LO" "  its line in Boot's log: LiveReload server is running on port 19049" "livereload: its line"
has "$LO" "  200 text/javascript" "livereload: its script"
has "$LO" "  the script it served is DevTools' own file (org/springframework/boot/devtools/livereload/livereload.js in its jar): yes" "livereload: DevTools' own file"
has "$LO" "  lines in Boot's log that say deprecated (any case): 0" "livereload: no deprecation line in the log"
has "$LO" "  19049 listened on now: 0" "livereload: stopped"
[ "$(n livereload "^  exit 1 · the seven responses: 7 lines · md5 $S115\$")" = 2 ] || die "livereload: two runs, each stopped by the seven"
echo "  livereload: deprecated since 4.1.0, no replacement, default false; off (the report); on - *:19049 beside 127.0.0.1:19046, livereload.js 200 = DevTools' file, no deprecation line; stopped"

# "Why it must never ship. Optional: zero entries. Not optional: still zero, Boot's plugin drops DevTools by default. Forced in, the
# jar's DevTools switches its own restart off - but one system property turns it back on."
[ "$(n ship '^  entries of its jar that name devtools: 0$')" = 2 ] || die "ship: optional and not optional, 0 entries each"
x ship '^  built not optional · offline: yes · exit 0$'
x ship "^  Boot's plugin, its repackage goal \(META-INF/maven/plugin\.xml\): excludeDevtools default true · its property spring-boot\.repackage\.excludeDevtools\$"
x ship '^  built forced in · offline: yes · exit 0$'
SF=$(blk ship '3 forced in' 'the same jar, one system property more'); SR=$(blk ship 'the same jar, one system property more' 'C (labelled)')
has "$SF" "  entries of its jar that name devtools: 1 -" "ship: forced in, 1 entry"; has "$SF" "    BOOT-INF/lib/spring-boot-devtools-4.1.1.jar" "ship: DevTools' jar in the forced jar"
has "$SF" "       LocalDevToolsAutoConfiguration:" "ship: the report's block"
has "$SF" "             - Initialized Restarter Condition initialized without URLs (OnInitializedRestarterCondition)" "ship: the restart off in a packaged jar"
has "$SF" "  lines on restartedMain: 0 · DevTools' 'Devtools property defaults active!': 0" "ship: no restartedMain, no defaults"
has "$SF" "  exit 0 · the seven responses: 7 lines · md5 $S115" "ship: the forced jar exits 0"
has "$SR" "  DevTools' line: Restart enabled irrespective of application packaging due to System property 'spring.devtools.restart.enabled' being set to true" "ship: the switch"
has "$SR" "  TiffinBox's own lines on restartedMain: 1 · 'Devtools property defaults active!': 1" "ship: the restart back on"
has "$SR" "  exit 1 · the seven responses: 7 lines · md5 $S115" "ship: exit 1 with the restart on"
x ship "^  jars under BOOT-INF/lib against the anchor's: $((E_LIBS + 1)) and $E_LIBS · only in C's: spring-boot-devtools-4\.1\.1\.jar · only in the anchor's: 0\$"
# "Boot's AOT step leaves DevTools out on its own: its plugin filters it by name. The same files, byte for byte."
x ship '^  built the anchor · offline: yes · exit 0$'; x ship '^  built the copy · offline: yes · exit 0$'
x ship "^  files Spring's AOT step wrote: $E_AOT and $E_AOT · files that differ, or are in one only: 0 · naming devtools: 0\$"
x ship "^  Boot's process-aot goal \(ProcessAotMojo\) reads DEVTOOLS_EXCLUDE_FILTER: [1-9][0-9]* time\(s\) · the filter \(AbstractDependencyFilterMojo, its static block\): org\.springframework\.boot spring-boot-devtools\$"
x ship "^  each jar's entries that name devtools - the anchor's: 0 · the copy's: 3 -\$"
x ship '^    META-INF/native-image/org\.springframework\.boot/spring-boot-devtools/4\.1\.1/reachability-metadata\.json$'
x ship '^  the copy.s build log, the native plugin.s metadata step: \[graalvm reachability metadata repository for org\.springframework\.boot:spring-boot-devtools:4\.1\.1\]: Configuration directory is org\.springframework\.boot/spring-boot-devtools/4\.1\.0$'
echo "  ship: optional 0, not optional 0 (excludeDevtools true), forced in 1 - restart off, then on by one property (exit 1); C +1 jar; AOT step: $E_AOT = $E_AOT files, 0 differ (Boot's filter); the native-profile jar: DevTools' metadata file"

# "Stopped cleanly with POST shutdown, the DevTools run exits with one, not zero ... With the restart off: zero. DevTools ends Java's
# first main thread with an exception it hides, and Java counts a main that ended that way as a failure."
XA=$(blk exits 'A - the restart on:' 'B - -D'); XB=$(blk exits 'B - -D' "A' - A again:"); XA2=$(blk exits "A' - A again:" '$ cd .harness/dev && tr'); XC=$(blk exits "C - without DevTools' jar:" 'D (labelled)')
TH="  its threads (jcmd \$pid Thread.print): named main 0 · named DestroyJavaVM 1 · Java threads that are not daemons: DestroyJavaVM HTTP-Dispatcher"
for b in "$XA" "$XB" "$XA2" "$XC"; do has "$b" "$TH" "exits: the threads before the stop"; done
for b in "$XA" "$XA2"; do has "$b" "  exit 1 · the seven responses: 7 lines · md5 $S115" "exits A, A': exit 1"; done
[ "$(printf '%s\n' "$XA" | grep '^\$ cd ')" = "$(printf '%s\n' "$XA2" | grep '^\$ cd ')" ] || die "exits: A' is not A's command"
has "$XB" "  DevTools' restart lines: 1 - Restart disabled due to System property 'spring.devtools.restart.enabled' being set to false" "exits B: the restart off"
has "$XB" "  exit 0 · the seven responses: 7 lines · md5 $S115" "exits B: exit 0"
x exits "^  entries: $E_CP and $((E_CP - 1))\$"
has "$XC" "  exit 0 · the seven responses: 7 lines · md5 $S115" "exits C: exit 0"
x exits '^  Restarter\.immediateRestart\(\) ends by calling: org/springframework/boot/devtools/restart/SilentExitExceptionHandler\.exitCurrentThread:\(\)V$'
x exits '^  SilentExitExceptionHandler\.exitCurrentThread\(\): new org/springframework/boot/devtools/restart/SilentExitExceptionHandler\$SilentExitException · athrow$'
XE=$(blk exits 'E (labelled)' '')
has "$XE" "\$ java -cp .harness/me probe.MainEnds throw" "exits E"; has "$XE" "  printed: 0 lines · exit 1" "exits E: a main that ends with an exception - 1"
has "$XE" "  printed: 0 lines · exit 0" "exits E: a main that returns - 0"
echo "  exits: A 1 · B 0 · A' 1 · C 0, the same threads; D: immediateRestart -> exitCurrentThread -> throws SilentExitException; E: the JVM's rule, 1 and 0"

if [ $GOK = yes ]; then
NB=$(blk native '$GRAALVM_HOME names the GraalVM. Without an exclusion' 'with one exclusion'); NA=$(blk native 'with one exclusion' '')
# "The native binary is another story: the native plugin reads Maven's class path. Without an exclusion, the binary stops at start:
# RestartScopeInitializer, a DevTools class it can't find. With one exclusion, it serves the seven."
NR="  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes"
has "$NB" "  built .harness/nat-b (both modules, into \$M2) · offline: yes · exit 0" "native B: the install"; has "$NB" "$NR" "native B: the native build"
has "$NB" "  native-image's class path (the plugin's 'Executing:' line) - entries that are spring-boot-devtools-4.1.1.jar: 1" "native B: DevTools on native-image's class path"
printf '%s\n' "$NB" | grep -qE '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · strings naming org\.springframework\.boot\.devtools in its bytes: [1-9][0-9]*$' || die "native B: DevTools' names in the binary"
has "$NB" '    Exception in thread "main" java.lang.IllegalArgumentException: Unable to instantiate factory class [org.springframework.boot.devtools.restart.RestartScopeInitializer] for factory type [org.springframework.context.ApplicationContextInitializer]' "native B: the failure"
has "$NB" "    Caused by: java.lang.ClassNotFoundException: org.springframework.boot.devtools.restart.RestartScopeInitializer" "native B: its cause"
has "$NB" "  exit 1 · listened on 19047: 0 time(s)" "native B: exit 1, never listened"
has "$NA" "  lines added: 1" "native A: the exclusion, one line"
has "$NA" "  built .harness/nat-a (both modules, into \$M2) · offline: yes · exit 0" "native A: the install"; has "$NA" "$NR" "native A: the native build"
has "$NA" "  native-image's class path (the plugin's 'Executing:' line) - entries that are spring-boot-devtools-4.1.1.jar: 0" "native A: no DevTools on native-image's class path"
has "$NA" "  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · strings naming org.springframework.boot.devtools in its bytes: 0" "native A: no DevTools in the binary"
has "$NA" '  {"status":"UP","groups":["liveness","readiness"]} 200' "native A: health"
has "$NA" "  exit 0 · the seven responses: 7 lines · md5 $S115" "native A: the seven, exit 0"
[ "$(printf '%s\n' "$NA" | grep -c ' -> ')" = 7 ] || die "native A: the seven response lines"
echo "  native: without the exclusion - DevTools on native-image's class path, its names in the binary, RestartScopeInitializer, exit 1; with it - none, health, the seven, exit 0"
fi

# the exercise's end state: the two lines exercise/README.md calls "Done" are lines of this capture, after the solution's commands,
# and of SOLUTION.md's measured run
XS=$(blk exercise "the solution's commands" '')
for l in "Restarting due to 1 class path change (0 additions, 0 deletions, 1 modification)" "LOADERS start 2 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader RestartClassLoader"; do
  has "$XS" "$l" "exercise"
  awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line: $l"
  awk '/^## Measured/ { f = 1 } f' exercise/solution/SOLUTION.md | grep -qxF -- "$l" || die "SOLUTION.md: the measured run shows no such line: $l"; done
has "$XS" "LOADERS start 1 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader RestartClassLoader" "exercise: core, as a folder, in the restart loader from the first start"
x exercise '^  exit 0 · printed: 0 line\(s\)$'
x exercise '^POST /shutdown -> 200 · curl exit 0$'
x exercise "^TiffinBox's exit code: 1\$"
x exercise '^  listening on 19045 now: 0$'
echo "  exercise: the README as written, then the solution's commands -> OrderQueue's loader RestartClassLoader, one restart for one core change"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit25: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture"
