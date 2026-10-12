#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · Servlets, Filters and the Container - this unit's receipts. Spring MVC is one servlet among others, run by a
# container: a raw servlet and a raw filter (the harness's, outside com.tiffinbox) sit beside the DispatcherServlet, the
# container decides which servlet takes each request and when each one starts and stops, and changing the container -
# Tomcat for Jetty: one exclusion, one dependency - changes the bottom of the stack and nothing above the servlet. This unit
# changes NOTHING in the anchor (brief ⚑10): the tree is ../c5-unit27/after, reached through the link anchor, read and copied
# under .harness/, never built in place; every copy runs TiffinBox's own server and Spring MVC's beside it, in one JVM. Eight
# captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the run's demo token is masked (gsub), and the checks count 0 raw copies of
# it in every capture, in the log of every run, and in every file this unit ships.
#   jars      the two copies, each built offline the README's plain way: the copy (harness/mvc.patch: Spring MVC's starter in,
#             the Boot plugin's two Jackson 3 excludes out) - Tomcat - and the same copy with one exclusion and one dependency
#             more (harness/jetty.patch) - Jetty; the jars under BOOT-INF/lib of each, the ones only one holds named; each
#             extracted (the anchor README's extract line); then Spring MVC's starter alone (harness/starter): its class path
#   servlet   the harness's raw servlet, no Spring MVC above it, on three kinds of pattern (/raw, /raw/*, *.tiff) beside the
#             DispatcherServlet (/): seven requests to Tomcat - the container's own answer to which servlet takes each, and
#             how; one to TiffinBox's own server
#   filter    the harness's raw filter on /*: its line for each of the same seven, the servlet that answered named by the
#             container; the container's table (/actuator/mappings, exposed by a flag for this one run): its servlets and its
#             filters; the filters one request passed, outermost first, read off the stack of the method it reached
#   life      the raw servlet's life on Tomcat: no line at startup; init at its first request, on a request thread; service
#             once per request; destroy when the JVM is stopped, on Spring's shutdown-hook thread
#   swap      the break, the container - A: Tomcat · B: Jetty, the same copy with one exclusion and one dependency · A' = A:
#             when the raw servlet's init ran; the harness's route - the thread, the context class loader, the stack above and
#             below the DispatcherServlet; the raw servlet's four answers, their bodies hashed, their content type
#   two       D (labelled): a second server keeps the JVM alive - the seven against TiffinBox's own server, POST /shutdown
#             last; 2 s later the JVM is still there, listening on Tomcat's port, and the threads that are not daemons named;
#             stopped by its pid · E (labelled): the same on Jetty
#   undertow  C (labelled): Undertow's starter asked for on Boot 4.1.1's parent, no version - exit 1; Boot's own two lists of
#             versions (its BOM, 3.5.16 and 4.1.1): the lines that mention Undertow
#   exercise  exercise/README.md's commands, run exactly as written (the registration shipped broken), then SOLUTION.md's line
# "The tree" is ../c5-unit27/after (the anchor as the command-line lesson left it; ../c5-tiffinbox holds the same files, checked
# below), COPIED under .harness/; this script never writes into another unit's folder. Every run of TiffinBox starts in a copy
# that holds a config tree with this run's demo token (secrets/), as the anchor README asks. Commands are printed exactly as
# they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson (../c5-unit11/curlset.sh: the
# seven requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's own repository, .m2-demo.
# "$pid" is the process id of the JVM a capture started. Harness classes (harness/web/harness/, package harness - never
# com.tiffinbox) join a run by --spring.main.sources; every run passes options only (the anchor refuses a bare argument).
# The class-path layout every run uses: the executable jar extracted (the anchor README's extract line) plus the harness's own
# folder, .harness/hc - never java -jar (brief, unit 02's hazards).
# Two servers in one JVM, always both on 127.0.0.1: TiffinBox's own (the JDK's HttpServer, --tiffinbox.port) and Spring MVC's
# container (--server.address=127.0.0.1 --server.port): Tomcat and Jetty listen on every interface unless told an address, so
# every run names one, and every capture asserts the addresses its JVM's process listens on - only 127.0.0.1:<its two ports>.
# Readiness is asked of TiffinBox's own server until it answers 200: it answers 200 only once the start has finished, after
# the container started - and each run checks that the container's own "started on port" line was already in the log then.
# No request reaches the container before that check, so the raw filter's lines and the container's first request are this
# capture's own (Jetty runs its first requests on a pool thread; later ones may run deeper, on a reserved thread - README.md).
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve
# an artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No build here uses the native profile,
# and every build's log is still searched for GraalVM's metadata download - found, the run stops. No Docker. At run time
# nothing leaves 127.0.0.1: both servers listen there, every request goes there, and Logback writes to the terminal only.
# Masks and filters (README.md declares each; sub/gsub only): this run's demo token becomes "[masked: the N-character token]",
# N its own length; this folder's absolute path "…", the folder above it "…/..", the home folder "~", your user name "<user>";
# Spring's error timestamp "<time>" (an ISO-8601 string) or "<epoch ms>" (a number); a request thread's number (exec-N,
# qtp<hash>-N), Jetty's scheduler's "Scheduler-<hash>-" and identity hashes "@<hash>" - in every line of every capture. A
# run's log is read through declared filters (the harness's own lines, Boot's started line for the container - its logger is
# Boot's class, and it names the port - and Boot's graceful-shutdown lines), the rest counted or not printed; Boot's first line (its process id, your user, this folder) is never printed. No
# duration is captured.
# Ports (brief ⚑1, 19310-19319): servlet, life, swap's A, B and A' 19310 (TiffinBox) and 19311 (the container) · filter 19312
# and 19313 · two's D 19314 and 19315, E 19316 and 19317 · the exercise 19318 and 19319. 18425 (TiffinBox's default) and 8080
# (Tomcat's and Jetty's) are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option. (exe() inserts its "exec" with sed, not with ${x/a/b}.)
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the process this script started in the background ($pid, a server)
# if it still runs, then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a Maven build, the
# exercise's runner - is stopped. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check
# they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so
# it always reaches the rmdir; the script still exits 130 after an interrupt (README.md, "Interrupted"). $pid is cleared
# whenever its process has been reaped.
pid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "-Djarmode=tools") || index($0, "exercise/try.sh")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v javac > /dev/null || die "javac is needed: the harness's classes are compiled here"
command -v python3 > /dev/null || die "python3 is needed: the stack, the class loader and the container's table are read through filters"
command -v curl > /dev/null || die "curl is needed: every request here is curl's"
command -v rsync > /dev/null || die "rsync is needed: every tree is copied with it"
command -v patch > /dev/null || die "patch is needed: each copy's POM is changed by a patch this unit ships"
command -v unzip > /dev/null || die "unzip is needed: the jars under BOOT-INF/lib are listed with it"
command -v lsof > /dev/null || die "lsof is needed: the addresses a JVM listens on are read with it"
# A variable of yours must not become a property source, a JVM flag, a build setting or a native-image option: every
# TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject
# JVM flags, MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are removed first. GRAALVM_HOME stays: it says which GraalVM to use.
# (A DEBUG of yours would print the condition report and the trace in every failed start a capture counts.)
# The list is an extended regular expression (sed -E): /usr/bin/sed's basic ones have no alternation, so the \| this loop once
# used matched nothing and removed no variable at all (measured: RED C5-S4 #63). A canary is planted under every name first, and
# the run stops if one survives the loop.
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1. An HTTP proxy named in your environment (http_proxy and the rest) would
# carry curl's requests to that proxy instead of to TiffinBox: 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
TREE=anchor                                          # the tree: a link to ../c5-unit27/after, the anchor as the command-line lesson left it - read, copied
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a copy under .harness/"
[ -f "$TREE/pom.xml" ] && [ -f "$TREE/README.md" ] && [ -f "$TREE/tiffinbox-web/pom.xml" ] || die "the tree $TREE (its pom.xml, README.md or tiffinbox-web/pom.xml) is missing"
[ -e "$TREE/secrets" ] || [ -e "$TREE/target" ] || [ -e "$TREE/tiffinbox-web/target" ] && die "$TREE holds a secrets/ or a target/ - it is a frozen copy, never built in place"
# Both trees are frozen, so they hold the same files (brief ⚑10): the anchor this unit reads is Course 5's last tree.
[ -z "$(diff -rq -x target -x secrets -x .m2-demo -x .harness "$TREE/" ../c5-tiffinbox/ 2>&1)" ] || die "$TREE and ../c5-tiffinbox differ - both are frozen, so one was changed: $(diff -rq -x target -x secrets -x .m2-demo -x .harness "$TREE/" ../c5-tiffinbox/ 2>&1 | head -3)"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar     # the executable jar, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
for f in harness/mvc.patch harness/jetty.patch harness/paths.sh harness/starter/pom.xml harness/undertow/pom.xml harness/boms/pom.xml harness/web/harness/RawServlet.java harness/web/harness/RawFilter.java harness/web/harness/RawServletConfig.java harness/web/harness/RawFilterConfig.java harness/web/harness/Where.java exercise/README.md exercise/RawServletConfig.java exercise/try.sh exercise/solution/RawServletConfig.java exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
# The demo token: FAKE, and new on every run - 26 random lowercase letters and digits, never in any file this unit ships,
# never on a command line, never printed. It is written into .harness/*/secrets/ (git-ignored), with no newline, readable by
# its owner alone; the seven read it from that file. Every capture is masked, and every check counts it raw: 0.
TOKEN=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26)
[ ${#TOKEN} = 26 ] || die "the demo token could not be made from /dev/urandom"

# The ports, BEFORE anything is wiped.
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19310 19311 19312 19313 19314 19315 19316 19317 19318 19319; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it"; done

# ---- the commands: read from the anchor's README.md and from this unit's own, and asserted - each line must be there, whole -
readme() { grep -m1 -xF -- "$1" "$TREE/README.md" > /dev/null || die "$TREE/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_TC=$(mine 'cd .harness/tc && patch -s -p1 < ../../harness/mvc.patch && diff -U0 ../../anchor/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d')
R_JT=$(mine 'cd .harness/jt && patch -s -p1 < ../../harness/mvc.patch && patch -s -p1 < ../../harness/jetty.patch && diff -U0 ../tc/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d')
R_HC=$(mine 'javac -d .harness/hc -cp ".harness/tc/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/tc/tiffinbox-web/target/extracted/lib/*" harness/web/harness/*.java')
R_STARTER=$(mine 'cd .harness/starter && mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=target/classpath.txt')
R_UNDERTOW=$(mine 'cd .harness/undertow && mvn -o -B -Dmaven.repo.local="$M2" validate')
R_BOMS=$(mine 'cd .harness/boms && mvn -o -B -Dmaven.repo.local="$M2" validate')
R_EXPO=$(mine '--management.endpoints.web.exposure.include=health,mappings')
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package) clean and without tests. dev() takes those four things back out, and must give
# the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's own
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# hcp DIR TB C SOURCES ['FLAGS']: the anchor README's exploded run - the extracted jar on the class path, TiffinBox's own main -
# from DIR, its port made TB; the harness's folder added to the class path (../hc), its classes joined (--spring.main.sources),
# the container told its address and its port (C); then FLAGS. unhcp() takes those changes back out, and must give the
# README's line again.
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s --server.address=127.0.0.1 --server.port=%s%s\n' "$c" "$4" "$3" "${5:+ $5}"; }
unhcp() { local c=${1#cd * && }; c=${c/:..\/hc\"/\"}; c=${c% --management.endpoints.web.exposure.include=health,mappings}; c=${c% --server.address=127.0.0.1 --server.port=*}; c=${c% --spring.main.sources=*}; printf '%s\n' "${c/--tiffinbox.port=193??/--tiffinbox.port=18431}"; }
[ "$(unhcp "$(hcp .harness/tc 19310 19311 harness.Where)")" = "$R_CP" ] || die "not the README's exploded run with the declared changes: $(hcp .harness/tc 19310 19311 harness.Where)"
[ "$(unhcp "$(hcp .harness/tc 19312 19313 harness.Where "$R_EXPO")")" = "$R_CP" ] || die "not the README's exploded run with the declared changes and the exposure flag"
[ "$(hcp .harness/tc 19310 19311 harness.Where)" = 'cd .harness/tc && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19310 --spring.main.sources=harness.Where --server.address=127.0.0.1 --server.port=19311' ] || die "hcp()"
[ "$(dev "$(off .harness/tc "$R_PLAIN" package)")" = "$R_PLAIN" ] || die "not the README's Maven line with the offline changes"
[ "$(exe "$(hcp .harness/tc 19310 19311 harness.Where)")" = 'cd .harness/tc && exec java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19310 --spring.main.sources=harness.Where --server.address=127.0.0.1 --server.port=19311' ] || die "exe()"
echo "  the commands: $TREE/README.md and README.md give all 11 lines this script runs or derives from"

# ---- build: the two copies and the three harness POMs before the captures, so that .m2-demo holds what every capture builds --
rm -rf .harness; mkdir -p .harness
# ghub LOG: GraalVM's native plugin went over the network for its metadata repository. No build here uses the native profile;
# the search runs on every build log all the same, and a hit stops the run.
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only
# if the offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is
# never silent (inside a capture, "no" changes the capture's hash: cap() then dies).
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  if ghub "$2"; then echo "  built $3 · offline: no - GraalVM's native plugin went to GitHub for its metadata repository · exit $ec"
    die "$3: GraalVM's native plugin went over the network for its metadata repository - README.md, The repository"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, this run's token with no newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
# copy SRC DST: SRC's files (no target/, no secrets/) into a fresh DST, with a config tree of its own
copy() { rm -rf "$2"; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
# The pre-capture builds fill .m2-demo on a fresh clone (git ignores it): the copy and its Jetty twin the README's plain way,
# the starter alone's class path, the BOMs' copy - every artifact a capture's build needs, so every capture's build says
# "offline: yes". On this Mac, .m2-demo is seeded from ../../spring-web-mvc/_research/m2-seed-s1/ (README.md).
copy "$TREE" .harness/pre-tc; (eval "${R_TC/.harness\/tc/.harness/pre-tc}") > /dev/null
copy "$TREE" .harness/pre-jt; (cd .harness/pre-jt && patch -s -p1 < ../../harness/mvc.patch && patch -s -p1 < ../../harness/jetty.patch)
mbuild "$(off .harness/pre-tc "$R_PLAIN" package)" .harness/build-pre-tc.log ".harness/pre-tc (the copy with Spring MVC's starter: Tomcat)"
mbuild "$(off .harness/pre-jt "$R_PLAIN" package)" .harness/build-pre-jt.log ".harness/pre-jt (the same, one exclusion and one dependency: Jetty)"
for d in starter boms undertow; do rsync -a "harness/$d/" ".harness/pre-$d/"; done
mbuild "${R_STARTER/.harness\/starter/.harness/pre-starter}" .harness/build-pre-starter.log ".harness/pre-starter (Spring MVC's starter alone: its class path)"
mbuild "${R_BOMS/.harness\/boms/.harness/pre-boms}" .harness/build-pre-boms.log ".harness/pre-boms (Boot's two BOMs, copied)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$M2/org/springframework/boot/spring-boot-starter-jetty/4.1.1/spring-boot-starter-jetty-4.1.1.pom" ] || die "Jetty's starter is not in .m2-demo after the builds"
[ -f "$M2/org/springframework/boot/spring-boot-dependencies/3.5.16/spring-boot-dependencies-3.5.16.pom" ] || die "Boot 3.5.16's BOM is not in .m2-demo after the builds"
echo "  .m2-demo holds Boot's parent, Jetty's starter, Boot 3.5.16's BOM and Maven's dependency plugin"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0                                               # logs counted: every JVM a capture started
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
# loopback ADDRS TB C: the addresses a JVM listens on must be exactly 127.0.0.1:TB and 127.0.0.1:C - a wildcard (*:C) or any
# other address stops the run (README.md, "Found on the way": shown failing on a planted wildcard line first)
loopback() { [ "$1" = "127.0.0.1:$2 127.0.0.1:$3" ] || die "the JVM listens on [$1], not on 127.0.0.1:$2 and 127.0.0.1:$3 alone"; }
# up TB C: readiness asked of TiffinBox's own server (TB) every 0.25 s, up to 60 s, until it answers 200 - the start has then
# finished, the container's included, and Boot's started line for the container must already be in the log; the addresses the JVM
# listens on (only 127.0.0.1:TB and 127.0.0.1:C); TiffinBox's own line, and Boot's started line with its logger (Boot's class:
# TomcatWebServer or JettyWebServer); then the README's readiness line, run once.
up() { local i=0 c="" cl lg
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  cl=$(grep -m1 -oE "(Tomcat|Jetty) started on port $2 \(http(/1\.1)?\) with context path .*\$" .harness/run.out || true)
  [ -n "$cl" ] || die "readiness answered 200 on $1 before Boot's started line for the container was logged"
  lg=$(grep -m1 -E "(Tomcat|Jetty) started on port $2 " .harness/run.out | sed 's/^.*--- \[[^]]*\] //; s/ *: .*$//')
  loopback "$(addrs)" "$1" "$2"
  echo "  listens on: $(addrs) - TiffinBox's own server, $1, and the container, $2"
  echo "  TiffinBox's own line: $(grep -m1 -oE 'TiffinBox listening on http://[0-9.]+:[0-9]+$' .harness/run.out || echo '(none)')"
  echo "  Boot's started line, in the log once readiness answered - logger: message: $lg: $cl"
  echo "\$ $(url "$R_READY" "$1")"; (eval "$(url "$R_READY" "$1")") 2>&1 < /dev/null | sed 's/^/  /'; }
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times"; }
# halt TB C: the JVM stopped by its pid (SIGTERM: Boot's shutdown hook closes the context, and the container with it), waited
# for (15 s at most); its exit code; both ports free; Boot's graceful-shutdown lines; its log counted (logtok)
halt() { local i=0 e=0
  echo "\$ kill \$pid"; kill "$pid" 2> /dev/null || true
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill -9 "$pid"; die "the JVM was still running 15 s after SIGTERM"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] && [ "$(listeners "$2")" = 0 ] || die "something still listens on $1 or $2"
  echo "  exit $e · listening on $1 and $2 now: 0 and 0"
  echo "  Boot's graceful-shutdown lines ($(grep -E ' : (Commencing graceful shutdown|Graceful shutdown complete)' .harness/run.out | sed 's/^.*--- \[[^]]*\] //; s/ *: .*$//' | sort -u | paste -sd' ' -)): $(grep -oE 'Commencing graceful shutdown\. Waiting for active requests to complete$|Graceful shutdown complete$' .harness/run.out | paste -sd'|' - | sed 's/|/ · /g')"
  logtok; }
ask() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | sed 's/^/  /'; }
# harn: the harness's own lines in this run's log (System.out: "harness: ..."), in the log's order
harn() { grep '^harness: ' .harness/run.out | sed 's/^/  /' || true; }
# whereview: GET /where's answer read through a declared filter - the thread, the context class loader (its class, every
# superclass up to ClassLoader, its parent), the harness class's own loader, whether the context loader hands back the same
# class; then the frames the stack walker showed, counted: from the method down to DispatcherServlet.doService (the top, its
# names hashed), and below it, by whose they are - the DispatcherServlet's servlet methods (FrameworkServlet, HttpServlet),
# Spring's filters, the harness's, the container's (org.apache: Tomcat; org.eclipse.jetty: Jetty), the JDK's
whereview() { python3 -c '
import hashlib, sys
L = sys.stdin.read().splitlines()
fr = [l[6:] for l in L if l.startswith("frame ")]
for l in L:
    if l.startswith("thread "): print("  " + l.replace(" - virtual ", " · virtual "))
    elif l.startswith("context class loader "): print("  context class loader: " + l[len("context class loader "):])
    elif l.startswith("its parent "): print("  its parent: " + l[len("its parent "):], end="")
    elif l.startswith("this class") : print(" · the harness class\x27s own loader: " + l.split(" loader ", 1)[1])
    elif l.startswith("the context loader hands back"): print("  " + l)
k = next(i for i, f in enumerate(fr) if f == "org.springframework.web.servlet.DispatcherServlet.doService")
top, below = fr[:k + 1], fr[k + 1:]
def owner(f):
    if f.startswith(("org.springframework.web.servlet.FrameworkServlet.", "jakarta.servlet.http.HttpServlet.")): return "the servlet\x27s own methods (FrameworkServlet, HttpServlet)"
    if f.startswith("org.springframework.web.filter."): return "Spring\x27s filters"
    if f.startswith("harness."): return "the harness\x27s filter"
    if f.startswith("org.apache."): return "Tomcat"
    if f.startswith("org.eclipse.jetty."): return "Jetty"
    if f.startswith(("java.", "jdk.")): return "the JDK"
    return "other"
cnt = {}
for f in below: cnt[owner(f)] = cnt.get(owner(f), 0) + 1
order = ["the servlet\x27s own methods (FrameworkServlet, HttpServlet)", "Spring\x27s filters", "the harness\x27s filter", "Tomcat", "Jetty", "the JDK", "other"]
print("  frames the stack walker shows: %d" % len(fr))
print("    from the method down to DispatcherServlet.doService: %d - %s · their names\x27 md5 %s" % (len(top), " ".join(f.rsplit(".", 2)[-2] + "." + f.rsplit(".", 1)[1] for f in top[:1]) + " … " + top[-1].rsplit(".", 2)[-2] + "." + top[-1].rsplit(".", 1)[1], hashlib.md5("\n".join(top).encode()).hexdigest()))
print("    below it: %d - %s" % (len(below), " · ".join("%s %d" % (o, cnt[o]) for o in order if o in cnt)))
print("    the last frame: %s" % fr[-1])
'; }
# threadsview: GET /threads's answer through a declared filter - each thread's name and the class of its Thread object, a pool
# thread's number and a hash masked (the masks below, applied here first so that equal lines can be counted); each distinct
# line once, in order, with its count when it is more than one
threadsview() { python3 -c '
import re, sys
L = sys.stdin.read().splitlines()
ms = []
for nm in L[1:]:
    nm = re.sub(r"exec-[0-9]+", "exec-N", nm); nm = re.sub(r"qtp[0-9]+-[0-9]+", "qtp<hash>-N", nm)
    nm = re.sub(r"Scheduler-[0-9]+-", "Scheduler-<hash>-", nm); nm = re.sub(r"@[0-9a-f]{4,}", "@<hash>", nm)
    ms.append(nm)
seen = []
for nm in sorted(ms):
    if nm not in seen: seen.append(nm)
print("  " + L[0] + ":")
for nm in seen: print("    " + nm + ("  x%d" % ms.count(nm) if ms.count(nm) > 1 else ""))
'; }
# filters: the filters one request passed, read off GET /where's frames - each filter's own doFilter or doFilterInternal frame,
# outermost first (the stack lists them innermost first)
filters() { python3 -c '
import sys
fr = [l[6:] for l in sys.stdin.read().splitlines() if l.startswith("frame ")]
chain = ("org.apache.catalina.core.ApplicationFilterChain.", "org.eclipse.jetty.", "org.springframework.web.filter.OncePerRequestFilter.")
fs = [f.rsplit(".", 1)[0] for f in fr if f.endswith((".doFilter", ".doFilterInternal")) and not f.startswith(chain)]
fs.reverse()
print("  the filters it passed, outermost first: %d - %s" % (len(fs), " · ".join(f.rsplit(".", 1)[1] for f in fs)))
'; }
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = lit(me); N = length(t) }
  { gsub(T, "[masked: the " N "-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(M, "<user>")
    gsub(/"timestamp":"[0-9][0-9][0-9][0-9]-[^"]*"/, "\"timestamp\":\"<time>\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":<epoch ms>")
    gsub(/exec-[0-9]+/, "exec-N"); gsub(/qtp[0-9]+-[0-9]+/, "qtp<hash>-N"); gsub(/Scheduler-[0-9]+-/, "Scheduler-<hash>-")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@<hash>"); print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
pbuild() { local c; c=$(off "$1" "$R_PLAIN" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
libs() { unzip -Z1 "$1/$JAR" | sed -n 's|^BOOT-INF/lib/\(.*\.jar\)$|\1|p' | LC_ALL=C sort; }
TC=harness.RawServletConfig,harness.RawFilterConfig  # the raw servlet and the raw filter
# ---- jars: the two copies, built and extracted; the starter alone ---------------------------------------------------------
jars() { local c
  echo "the copy - the anchor with Spring MVC's starter in, the Boot plugin's two Jackson 3 excludes out (harness/mvc.patch) - and"
  echo "its Jetty twin - the same, with one exclusion and one dependency (harness/jetty.patch); each built the anchor README's plain way:"
  copy "$TREE" .harness/tc; ask "$R_TC"; pbuild .harness/tc "the copy: Tomcat"
  copy "$TREE" .harness/jt; ask "$R_JT"; pbuild .harness/jt "its twin: Jetty"
  libs .harness/tc > .harness/tc.lib; libs .harness/jt > .harness/jt.lib
  echo "the two executable jars:"
  echo "  jars under BOOT-INF/lib: Tomcat's copy $(wc -l < .harness/tc.lib | tr -d ' ') · Jetty's $(wc -l < .harness/jt.lib | tr -d ' ')"
  echo "  only in Tomcat's: $(LC_ALL=C comm -23 .harness/tc.lib .harness/jt.lib | wc -l | tr -d ' ') - $(LC_ALL=C comm -23 .harness/tc.lib .harness/jt.lib | paste -sd' ' -)"
  echo "  only in Jetty's: $(LC_ALL=C comm -13 .harness/tc.lib .harness/jt.lib | wc -l | tr -d ' ') -"
  LC_ALL=C comm -13 .harness/tc.lib .harness/jt.lib | paste -sd' ' - | sed 's/^/    /'
  for c in tc jt; do
    echo "\$ cd .harness/$c && $R_EXTRACT"
    (cd .harness/$c && eval "$R_EXTRACT") > .harness/$c.extract.log 2>&1 < /dev/null || die "the README's extract failed in .harness/$c"
    echo "  exit 0 · lib/ holds $(ls .harness/$c/tiffinbox-web/target/extracted/lib | grep -c '\.jar$') jars"; done
  echo "  the servlet API's own jar (jakarta.servlet-api): Tomcat's $(grep -c '^jakarta\.servlet-api-' .harness/tc.lib || true) · Jetty's $(grep -c '^jakarta\.servlet-api-' .harness/jt.lib || true) - Tomcat carries the API's classes inside tomcat-embed-core: $(unzip -Z1 ".harness/tc/tiffinbox-web/target/extracted/lib/tomcat-embed-core-11.0.24.jar" 2> /dev/null | grep -c '^jakarta/servlet/http/HttpServlet\.class$' || true) HttpServlet.class"
  echo "Spring MVC's starter alone - harness/starter/pom.xml: one dependency, on Boot 4.1.1's parent - and the class path Maven"
  echo "builds for it:"
  rm -rf .harness/starter; rsync -a harness/starter/ .harness/starter/
  echo "\$ $R_STARTER"; mbuild "$R_STARTER" .harness/starter.log "the starter alone"
  tr ':' '\n' < .harness/starter/target/classpath.txt | sed 's|.*/||' | LC_ALL=C sort > .harness/starter.cp
  echo "  jars on its class path: $(grep -c '\.jar$' .harness/starter.cp)"
  echo "  among them: $(grep -E '^(spring-webmvc|tomcat-embed-core|jackson-databind|logback-classic)-' .harness/starter.cp | paste -sd' ' - | sed 's/ / · /g')"; }

# ---- servlet: the container's own rules ------------------------------------------------------------------------------------
servlet() {
  echo "the copy (built by capture jars), run exploded - the extracted jar and the harness's folder - with the raw servlet on /raw,"
  echo "/raw/* and *.tiff and the raw filter on /* joined (harness/web/harness/): TiffinBox's own server on 19310, Tomcat on 19311."
  echo "The registration, and the line where the servlet asks the container how it matched:"
  ask "grep -n 'bean.setUrlMappings\\|= req.getHttpServletMapping()' harness/web/harness/RawServletConfig.java harness/web/harness/RawServlet.java"
  start "$(hcp .harness/tc 19310 19311 "$TC")"; up 19310 19311
  echo "seven requests to Tomcat, 19311 - which servlet the container gave each, as the answer says (the raw servlet's names the"
  echo "pattern that matched, read from getHttpServletMapping(); a 404 is the DispatcherServlet's):"
  ask "harness/paths.sh 19311"
  echo "the same path asked of TiffinBox's own server, 19310 - the JDK's HttpServer, no servlet container (its answer cut):"
  echo "\$ harness/paths.sh 19310 /customers"
  harness/paths.sh 19310 /customers | awk '{ i = index($0, "[{"); if (i) { r = length($0) - i - 29; print "  " substr($0, 1, i + 29) " … (" r " characters more)" } else print "  " $0 }'
  halt 19310 19311; }

# ---- filter: what a filter sees; the container's table ---------------------------------------------------------------------
filter() { local f
  echo "the same copy, the raw servlet and the raw filter joined, and the harness's route too (GET /where); mappings exposed by a"
  echo "flag for this one run - TiffinBox's own server on 19312, Tomcat on 19313. The filter's registration, and its three steps:"
  ask "grep -n 'bean.addUrlPatterns\\|resp.setHeader\\|chain.doFilter(request\\|println(.harness: raw filter' harness/web/harness/RawFilterConfig.java harness/web/harness/RawFilter.java"
  start "$(hcp .harness/tc 19312 19313 "$TC,harness.Where" "$R_EXPO")"; up 19312 19313
  echo "\$ harness/paths.sh 19313"; harness/paths.sh 19313 > .harness/paths.out
  echo "  $(wc -l < .harness/paths.out | tr -d ' ') answers · with the raw filter's header X-Raw-Filter: seen - $(grep -c '  X-Raw-Filter: seen  ' .harness/paths.out || true)"
  echo "the raw filter's own lines, in the log's order - the seven, the first requests the container got; the servlet that"
  echo "answered, as the container names it:"
  grep '^harness: raw filter ' .harness/run.out | sed 's/^/  /' || true
  echo "the container's table - Boot's /actuator/mappings, its servlets and its filters, each with its patterns:"
  echo "\$ curl -s -o .harness/mappings.json http://127.0.0.1:19313/actuator/mappings"
  curl -s -o .harness/mappings.json http://127.0.0.1:19313/actuator/mappings
  python3 - .harness/mappings.json <<'PY'
import json, sys
m = json.load(open(sys.argv[1]))["contexts"]["application"]["mappings"]
sv = m["servletContext"]["servlets"] if "servletContext" in m else m["servlets"]
fl = m["servletContext"]["filters"] if "servletContext" in m else m["servletFilters"]
print("  servlets: %d" % len(sv))
for x in sorted(sv, key=lambda x: x["name"]): print("    %s %s - %s" % (x["name"], " ".join(sorted(x["mappings"])), x["className"]))
print("  filters: %d" % len(fl))
for x in sorted(fl, key=lambda x: x["name"].lower()): print("    %s %s - %s" % (x["name"], " ".join(sorted(x["urlPatternMappings"])), x["className"]))
PY
  echo "one request's path through them - GET /where, the harness's route, read off the stack of the method it reached:"
  echo "\$ curl -s http://127.0.0.1:19313/where"; curl -s http://127.0.0.1:19313/where > .harness/where.out
  filters < .harness/where.out
  halt 19312 19313; }

# ---- life: init, service, destroy ------------------------------------------------------------------------------------------
life() { local i
  echo "the raw servlet's life, on Tomcat - the copy with the raw servlet joined; TiffinBox on 19310, Tomcat on 19311:"
  start "$(hcp .harness/tc 19310 19311 harness.RawServletConfig)"; up 19310 19311
  echo "  the raw servlet's lines so far: init $(grep -c '^harness: raw servlet init ' .harness/run.out || true) · service $(grep -c '^harness: raw servlet service ' .harness/run.out || true) · destroy $(grep -c '^harness: raw servlet destroy ' .harness/run.out || true)"
  for i in 1 2 3; do ask "curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19311/raw"; done
  echo "  the raw servlet's lines so far: init $(grep -c '^harness: raw servlet init ' .harness/run.out || true) · service $(grep -c '^harness: raw servlet service ' .harness/run.out || true) · destroy $(grep -c '^harness: raw servlet destroy ' .harness/run.out || true)"
  halt 19310 19311
  echo "  the raw servlet's lines in all: init $(grep -c '^harness: raw servlet init ' .harness/run.out || true) · service $(grep -c '^harness: raw servlet service ' .harness/run.out || true) · destroy $(grep -c '^harness: raw servlet destroy ' .harness/run.out || true) - in the log's order:"
  grep '^harness: raw servlet ' .harness/run.out | sed 's/^/  /' || true; }

# ---- swap: A Tomcat, B Jetty, A' Tomcat ------------------------------------------------------------------------------------
# side DIR: one side of the break - the raw servlet and the harness's route joined, TiffinBox on 19310, the container on 19311:
# whether the raw servlet's init ran before any request; GET /where, the container's first request; the raw servlet's four
# answers, their bodies hashed; then stopped by its pid
side() {
  start "$(hcp "$1" 19310 19311 harness.RawServletConfig,harness.Where)"; up 19310 19311
  echo "  the raw servlet's init, before any request reached the container: $(grep -c '^harness: raw servlet init ' .harness/run.out || true) line(s)$(grep -m1 '^harness: raw servlet init ' .harness/run.out | sed 's/^harness: raw servlet init - / - /')"
  echo "\$ curl -s http://127.0.0.1:19311/where"; curl -s http://127.0.0.1:19311/where > .harness/where.out
  whereview < .harness/where.out
  echo "\$ harness/paths.sh 19311 /raw /raw/menu/today /lunch.tiff /raw/lunch.tiff"
  harness/paths.sh 19311 /raw /raw/menu/today /lunch.tiff /raw/lunch.tiff > .harness/four.out
  sed 's/^/  /' .harness/four.out
  echo "  the four answers' bodies: md5 $(sed 's/^.*  X-Raw-Filter: -  //' .harness/four.out | md5 -q) · their content type: $(awk '{ print $5 }' .harness/four.out | sort -u | paste -sd' ' -)"
  echo "  the raw servlet's init: $(grep -c '^harness: raw servlet init ' .harness/run.out || true) line$(grep -m1 '^harness: raw servlet init ' .harness/run.out | sed 's/^harness: raw servlet init - / - /')"
  halt 19310 19311; }
swap() {
  echo "A - Tomcat: the copy (capture jars built it):"; side .harness/tc
  echo "B - Jetty: its twin, one exclusion and one dependency more in tiffinbox-web/pom.xml, against the copy's (capture jars built it):"
  echo "\$ diff -U0 .harness/tc/tiffinbox-web/pom.xml .harness/jt/tiffinbox-web/pom.xml | sed 1,2d"
  diff -U0 .harness/tc/tiffinbox-web/pom.xml .harness/jt/tiffinbox-web/pom.xml | sed 1,2d | sed 's/^/  /' || true
  side .harness/jt
  echo "A' - A again:"; side .harness/tc; }

# ---- two: a second server keeps the JVM alive ------------------------------------------------------------------------------
# survive DIR TB C: the copy in DIR, the harness's route joined, TiffinBox on TB, the container on C; the threads that are not
# daemons; the seven against TiffinBox's own server, POST /shutdown last; 2 s later - is the JVM still there, and on which
# addresses; the threads again; then stopped by its pid
survive() { local e=0
  start "$(hcp "$1" "$2" "$3" harness.Where)"; up "$2" "$3"
  echo "\$ curl -s http://127.0.0.1:$3/threads"; curl -s "http://127.0.0.1:$3/threads" | threadsview
  echo "\$ \$CURLSET $2 $1/$TF"
  "$CURLSET" "$2" "$1/$TF" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt | sed 's/^/  /' || echo "  (no POST line)"
  echo "  the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  sleep 2
  echo "  2 s after POST /shutdown - still running: $(kill -0 "$pid" 2> /dev/null && echo yes || echo no) · listening on: $(addrs)"
  echo "\$ curl -s http://127.0.0.1:$3/threads"; curl -s "http://127.0.0.1:$3/threads" | threadsview
  halt "$2" "$3"; }
two() {
  echo "D (labelled) - two servers in one JVM: the copy, TiffinBox's own server on 19314, Tomcat on 19315; the harness's route joined"
  echo "(GET /threads: every live thread that is not a daemon - a JVM keeps running while one is left):"
  survive .harness/tc 19314 19315
  echo "E (labelled) - the same on Jetty: its twin, TiffinBox's own server on 19316, Jetty on 19317:"
  survive .harness/jt 19316 19317; }

# ---- undertow: the third server Boot 3 offered ------------------------------------------------------------------------------
undertow() { local e=0
  echo "C (labelled) - Undertow, asked for the way Boot 3's parent offered it: harness/undertow/pom.xml names its starter on Boot"
  echo "4.1.1's parent, the version left to the parent:"
  rm -rf .harness/undertow; rsync -a harness/undertow/ .harness/undertow/
  echo "\$ $R_UNDERTOW"
  (eval "$R_UNDERTOW") > .harness/undertow.log 2>&1 < /dev/null || e=$?
  ! grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' .harness/undertow.log || die "undertow: Maven could not resolve Boot's parent offline - run the pre-capture builds"
  echo "  exit $e"
  grep -m1 -E "^\[ERROR\] +'dependencies\.dependency\.version' " .harness/undertow.log | sed -E 's/^\[ERROR\] +/  [ERROR] /' || echo "  (no such line)"
  echo "Boot's own lists of the versions it manages - its BOM, spring-boot-dependencies - as Boot 3.5.16 ships it and as Boot"
  echo "4.1.1 ships it (harness/boms/pom.xml copies the two files into .harness/boms/target/boms):"
  rm -rf .harness/boms; rsync -a harness/boms/ .harness/boms/
  echo "\$ $R_BOMS"; mbuild "$R_BOMS" .harness/boms.log "the two BOMs' copy"
  for v in 3.5.16 4.1.1; do
    f=.harness/boms/target/boms/spring-boot-dependencies-$v.pom
    echo "  spring-boot-dependencies-$v.pom: lines that mention undertow, in any case: $(grep -ci undertow "$f" || true) · that name spring-boot-starter-undertow: $(grep -c '<artifactId>spring-boot-starter-undertow</artifactId>' "$f" || true) · that name spring-boot-starter-jetty: $(grep -c '<artifactId>spring-boot-starter-jetty</artifactId>' "$f" || true)"; done; }

# ---- exercise: the README's commands, then the solution's ---------------------------------------------------------------------
# blockn FILE N: the Nth bash block of FILE
blockn() { awk -v n="$2" '/^```bash$/ { k++; if (k == n) f = 1; next } f && /^```$/ { f = 0 } f' "$1"; }
exercise() { local setup try sol ec=0
  setup=$(blockn exercise/README.md 1); try=$(blockn exercise/README.md 2); sol=$(blockn exercise/solution/SOLUTION.md 1)
  [ -n "$setup" ] && [ -n "$try" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$try" | grep -c .)" = 1 ] && [ "$(printf '%s\n' "$sol" | grep -c .)" = 1 ] || die "the exercise's try line and the solution's must be one line each"
  echo "exercise/README.md's setup, run exactly as written from this folder - $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  (eval "$setup") > .harness/ex-setup.log 2>&1 < /dev/null || ec=$?
  [ $ec = 0 ] || { tail -20 .harness/ex-setup.log >&3; die "the exercise's setup failed"; }
  echo "  exit $ec · printed: $(grep -c . .harness/ex-setup.log || true) line(s) · the token file: $(wc -c < .harness/mine/$TF | tr -d ' ') characters, mode $(stat -f '%Lp' .harness/mine/$TF)"
  echo "its try line, as shipped - the registration lists /raw and /raw/* only:"
  echo "\$ $try"; ec=0; (eval "$try") 2>&1 < /dev/null | sed 's/^/  /' || ec=$?
  echo "  listening on 19318 and 19319 now: $(listeners 19318) and $(listeners 19319)"
  echo "the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:"
  echo "\$ $sol"; (eval "$sol") 2>&1 < /dev/null | sed 's/^/  /' || ec=$?
  echo "  listening on 19318 and 19319 now: $(listeners 19318) and $(listeners 19319)"
  XT=$(cat .harness/mine/$TF)
  [ "$(raw "$XT" .harness/mine/run.log)" = 0 ] && [ "$(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/mine/run.log | wc -l | tr -d ' ')" = 0 ] || die "the exercise's log held its token or the header's name"
  echo "  its log (.harness/mine/run.log, the last run's): the exercise's own token 0 times · X-Shutdown-Token 0 times"; }

cap jars jars
# The harness's classes, compiled once into .harness/hc against the copy's own extracted jars (the README's javac line); every
# run that joins them puts ../hc on its class path
(eval "$R_HC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile"; }
echo "  the harness's classes compiled into .harness/hc: $(find .harness/hc -name '*.class' | wc -l | tr -d ' ') class files"
cap servlet servlet
cap filter filter
cap life life
cap swap swap
cap two two
cap undertow undertow
cap exercise exercise

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
S115='115c36bac276128e245ca57df11c2891'
LOGOK="  its log: the demo token 0 times · X-Shutdown-Token 0 times"
GRACE="  Boot's graceful-shutdown lines (o.s.boot.tomcat.GracefulShutdown): Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete"
GRACEJ="  Boot's graceful-shutdown lines (o.s.boot.jetty.GracefulShutdown): Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete"
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted
# when it was read: logtok(), the exercise's), nor anything this unit ships
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md receipts.sh receipts.md5 exercise/README.md exercise/try.sh exercise/RawServletConfig.java exercise/solution/RawServletConfig.java exercise/solution/SOLUTION.md harness/paths.sh harness/mvc.patch harness/jetty.patch harness/starter/pom.xml harness/undertow/pom.xml harness/boms/pom.xml harness/web/harness/*.java; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|exec-[0-9]|qtp[0-9]|virtual-[0-9]' "$f" || die "$f holds a log line's time or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE '"timestamp":"?[0-9]' "$f" || die "$f holds Spring's error timestamp, unmasked"; done
# S4.16: no star in an exposure list anywhere in this unit - its scripts, its READMEs, its captures
for f in receipts.sh README.md exercise/README.md exercise/try.sh .r-*.out; do
  ! grep -nE "exposure\.include='?\*" "$f" | grep -vF 'grep -nE "exposure' | grep -q . || die "$f: a star in an exposure list"; done
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -E 'java ' | grep -vE -- '--server\.address=127\.0\.0\.1 ' | grep -E -- '--server\.port=' > /dev/null || die "$f starts a container without --server.address=127.0.0.1"; done
NL=$(cat .r-*.out | grep -cxF "$LOGOK" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every JVM that served ($LOGS here; the published captures' $NL) and the exercise's, in the READMEs, the harness, the exercise, receipts.sh and receipts.md5; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no thread number, no stack frame, no unmasked timestamp in any capture; no star exposure; every container told 127.0.0.1"

# "The copy: Spring MVC's starter. Its twin: one exclusion, one dependency. Three jars out, forty-two in. The starter alone:
# thirty-nine jars, on Boot four point one."
x jars '^  built the copy: Tomcat · offline: yes · exit 0$'; x jars '^  built its twin: Jetty · offline: yes · exit 0$'
x jars '^  jars under BOOT-INF/lib: Tomcat.s copy 58 · Jetty.s 97$'
x jars '^  only in Tomcat.s: 3 - spring-boot-tomcat-4\.1\.1\.jar tomcat-embed-core-11\.0\.24\.jar tomcat-embed-websocket-11\.0\.24\.jar$'
x jars '^  only in Jetty.s: 42 -$'
x jars '^  the servlet API.s own jar \(jakarta\.servlet-api\): Tomcat.s 0 · Jetty.s 1 - Tomcat carries the API.s classes inside tomcat-embed-core: 1 HttpServlet\.class$'
[ "$(n jars '^  exit 0 · lib/ holds (58|97) jars$')" = 2 ] || die "jars: both extracted"
x jars '^  built the starter alone · offline: yes · exit 0$'; x jars '^  jars on its class path: 39$'
x jars '^  among them: jackson-databind-3\.1\.5\.jar · logback-classic-1\.5\.38\.jar · spring-webmvc-7\.0\.9\.jar · tomcat-embed-core-11\.0\.24\.jar$'
echo "  jars: Tomcat 58, Jetty 97: 3 out, 42 in; the servlet API inside tomcat-embed-core; the starter alone 39 (Spring MVC, Tomcat, Jackson, Logback)"

# "The container decides. Exact path: exact. Under /raw/: path. .tiff: extension. /raw/lunch.tiff: path beats extension. Everything
# else: the default servlet, slash - that's the DispatcherServlet - and a four oh four."
SV=$(blk servlet 'seven requests to Tomcat' 'the same path asked')
# gl PATH STATUS TYPE FILTER BODY: one line of harness/paths.sh's, as it prints it (the same printf), indented as a capture shows it
gl() { printf '  GET %-16s -> %s %s  X-Raw-Filter: %s  %s' "$1" "$2" "$3" "$4" "$5"; }
TP='text/plain;charset=ISO-8859-1'
has "$SV" "$(gl /raw 200 "$TP" seen 'raw servlet: pattern=/raw match=EXACT')" "servlet /raw"
has "$SV" "$(gl /raw/menu/today 200 "$TP" seen 'raw servlet: pattern=/raw/* match=PATH')" "servlet /raw/menu/today"
has "$SV" "$(gl /lunch.tiff 200 "$TP" seen 'raw servlet: pattern=*.tiff match=EXTENSION')" "servlet /lunch.tiff"
has "$SV" "$(gl /raw/lunch.tiff 200 "$TP" seen 'raw servlet: pattern=/raw/* match=PATH')" "servlet: path beats extension"
for p in /customers /rawXYZ /nowhere; do has "$SV" "$(gl "$p" 404 application/json seen '{"timestamp":"<time>","status":404,"error":"Not Found","path":"'"$p"'"}')" "servlet $p"; done
[ "$(printf '%s\n' "$SV" | grep -c '^  GET ')" = 7 ] || die "servlet: seven answers"
x servlet "^$(gl /customers 200 application/json - '')\\[\\{"
x servlet '^  listens on: 127\.0\.0\.1:19310 127\.0\.0\.1:19311 - '; x servlet "^  Boot's started line, in the log once readiness answered - logger: message: o\.s\.boot\.tomcat\.TomcatWebServer: Tomcat started on port 19311 \(http\) with context path '/'\$"
x servlet '^  exit 143 · listening on 19310 and 19311 now: 0 and 0$'
echo "  servlet: EXACT, PATH, EXTENSION, PATH beats EXTENSION; 3 x 404 by the DispatcherServlet; text/plain;charset=ISO-8859-1; TiffinBox's own server: no filter header"

# "The filter saw all seven, whichever servlet answered. Besides yours, five more: four of Spring's, put there by Boot, and
# Tomcat's WebSocket filter."
FL=$(blk filter "the raw filter's own lines" "the container's table")
for l in '/raw -> servlet rawServlet (/raw, EXACT) - status 200' '/raw/menu/today -> servlet rawServlet (/raw/*, PATH) - status 200' '/lunch.tiff -> servlet rawServlet (*.tiff, EXTENSION) - status 200' '/raw/lunch.tiff -> servlet rawServlet (/raw/*, PATH) - status 200' '/customers -> servlet dispatcherServlet (/, DEFAULT) - status 404' '/rawXYZ -> servlet dispatcherServlet (/, DEFAULT) - status 404' '/nowhere -> servlet dispatcherServlet (/, DEFAULT) - status 404'; do has "$FL" "  harness: raw filter GET $l" "filter: $l"; done
[ "$(printf '%s\n' "$FL" | grep -c '^  harness: raw filter ')" = 7 ] || die "filter: the seven, and nothing before them"
x filter '^  7 answers · with the raw filter.s header X-Raw-Filter: seen - 7$'
TB=$(blk filter "  servlets: " "one request's path")
[ "$(printf '%s\n' "$TB" | paste -sd'|' -)" = '    dispatcherServlet / - org.springframework.web.servlet.DispatcherServlet|    rawServlet *.tiff /raw /raw/* - harness.RawServlet|  filters: 6|    characterEncodingFilter /* - org.springframework.boot.servlet.filter.OrderedCharacterEncodingFilter|    formContentFilter /* - org.springframework.boot.servlet.filter.OrderedFormContentFilter|    rawFilter /* - harness.RawFilter|    requestContextFilter /* - org.springframework.boot.servlet.filter.OrderedRequestContextFilter|    Tomcat WebSocket (JSR356) Filter /* - org.apache.tomcat.websocket.server.WsFilter|    webMvcObservationFilter /* - org.springframework.web.filter.ServerHttpObservationFilter' ] || die "filter: the container's table - 2 servlets, 6 filters"
x filter '^  servlets: 2$'
x filter '^  the filters it passed, outermost first: 6 - CharacterEncodingFilter · ServerHttpObservationFilter · FormContentFilter · RequestContextFilter · RawFilter · WsFilter$'
echo "  filter: 7 of 7 seen, the servlet named; the table: 2 servlets, 6 filters (4 Spring's + Tomcat's WebSocket filter + the raw one); the path: the same 6, outermost first"

# "Init: nothing at startup; once, at the first request, on a request thread. Service: once per request. Destroy: once, at shutdown,
# on Spring's shutdown-hook thread."
x life '^  the raw servlet.s lines so far: init 0 · service 0 · destroy 0$'
x life '^  the raw servlet.s lines so far: init 1 · service 3 · destroy 0$'
x life '^  the raw servlet.s lines in all: init 1 · service 3 · destroy 1 - in the log.s order:$'
LF=$(blk life "  the raw servlet's lines in all:" '')
[ "$(printf '%s\n' "$LF" | paste -sd'|' -)" = '  harness: raw servlet init - thread http-nio-127.0.0.1-19311-exec-N|  harness: raw servlet service GET /raw|  harness: raw servlet service GET /raw|  harness: raw servlet service GET /raw|  harness: raw servlet destroy - thread SpringApplicationShutdownHook' ] || die "life: init on a request thread, three services, destroy on the shutdown hook"
[ "$(n life '^  raw servlet: pattern=/raw match=EXACT 200 text/plain;charset=ISO-8859-1$')" = 3 ] || die "life: three answers"
grep -qxF -- "$GRACE" .r-life.out || die "life: Boot's graceful-shutdown lines"; x life '^  exit 143 · listening on 19310 and 19311 now: 0 and 0$'
echo "  life: init 0 at startup -> 1 at the first request (exec-N) · service 3 · destroy 1 on SpringApplicationShutdownHook · graceful lines"

# "A, Tomcat. B, Jetty: one exclusion, one dependency. The same four bodies; the same nine frames on top; below them, all different;
# Jetty runs the init at startup, on main. A again: A."
SA=$(blk swap 'A - Tomcat' 'B - Jetty'); SB=$(blk swap 'B - Jetty' "A' - A again"); SA2=$(blk swap "A' - A again" '')
[ "$SA" = "$SA2" ] || die "swap: A' is not A"
[ "$(printf '%s\n' "$SA" | grep '^\$ cd')" = "$(printf '%s\n' "$SA2" | grep '^\$ cd')" ] || die "swap: A' is not A's command"
[ "$(printf '%s\n' "$SA" | grep '^\$ cd' | sed 's|\.harness/tc|.harness/jt|')" = "$(printf '%s\n' "$SB" | grep '^\$ cd')" ] || die "swap: B's command is not A's on the twin"
has "$SA" "  Boot's started line, in the log once readiness answered - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19311 (http) with context path '/'" "swap A: Tomcat"
has "$SB" "  Boot's started line, in the log once readiness answered - logger: message: o.s.boot.jetty.JettyWebServer: Jetty started on port 19311 (http/1.1) with context path '/'" "swap B: Jetty"
has "$SA" '  the raw servlet'"'"'s init, before any request reached the container: 0 line(s)' "swap A: init not at startup"
has "$SB" '  the raw servlet'"'"'s init, before any request reached the container: 1 line(s) - thread main' "swap B: init at startup, on main"
has "$SA" '  the raw servlet'"'"'s init: 1 line - thread http-nio-127.0.0.1-19311-exec-N' "swap A: init on a request thread"
has "$SA" '  thread http-nio-127.0.0.1-19311-exec-N · virtual false' "swap A: the thread"; has "$SB" '  thread qtp<hash>-N · virtual false' "swap B: the thread"
has "$SA" '  context class loader: org.springframework.boot.tomcat.TomcatEmbeddedWebappClassLoader < org.apache.catalina.loader.ParallelWebappClassLoader < org.apache.catalina.loader.WebappClassLoaderBase < java.net.URLClassLoader < java.security.SecureClassLoader' "swap A: Boot's embedded web-app class loader, a Tomcat ParallelWebappClassLoader"
has "$SB" '  context class loader: org.eclipse.jetty.ee.webapp.WebAppClassLoader < java.net.URLClassLoader < java.security.SecureClassLoader' "swap B: Jetty's loader"
for s in "$SA" "$SB"; do has "$s" '  its parent: jdk.internal.loader.ClassLoaders$AppClassLoader · the harness class'"'"'s own loader: jdk.internal.loader.ClassLoaders$AppClassLoader' "swap: one loader under both"; has "$s" '  the context loader hands back this very class: true' "swap: the same class"; done
TA=$(printf '%s\n' "$SA" | sed -n 's/^    from the method down to DispatcherServlet\.doService: //p'); TB=$(printf '%s\n' "$SB" | sed -n 's/^    from the method down to DispatcherServlet\.doService: //p')
[ -n "$TA" ] && [ "$TA" = "$TB" ] || die "swap: the top is not the same nine on both"; case $TA in 9\ -\ *) ;; *) die "swap: the top is not nine frames: $TA" ;; esac
has "$SA" '  frames the stack walker shows: 45' "swap A: 45"; has "$SB" '  frames the stack walker shows: 54' "swap B: 54"
has "$SA" "    below it: 36 - the servlet's own methods (FrameworkServlet, HttpServlet) 5 · Spring's filters 8 · Tomcat 22 · the JDK 1" "swap A: 36 below"
has "$SB" "    below it: 45 - the servlet's own methods (FrameworkServlet, HttpServlet) 5 · Spring's filters 8 · Jetty 31 · the JDK 1" "swap B: 45 below"
BA=$(printf '%s\n' "$SA" | sed -n "s/^  the four answers' bodies: md5 \([0-9a-f]*\) · .*/\1/p"); BB=$(printf '%s\n' "$SB" | sed -n "s/^  the four answers' bodies: md5 \([0-9a-f]*\) · .*/\1/p")
[ -n "$BA" ] && [ "$BA" = "$BB" ] || die "swap: the four bodies differ between Tomcat and Jetty"
has "$SA" "  the four answers' bodies: md5 $BA · their content type: text/plain;charset=ISO-8859-1" "swap A: the content type"
has "$SB" "  the four answers' bodies: md5 $BA · their content type: text/plain;charset=iso-8859-1" "swap B: the same charset, in lower case"
echo "  swap: A' = A; Tomcat 45 = 9 + 36, Jetty 54 = 9 + 45, the same 9 on top; the same 4 bodies ($BA); ISO-8859-1 / iso-8859-1; init at the first request (exec-N) / at startup (main); TomcatEmbeddedWebappClassLoader / WebAppClassLoader, the same class"

# "With Tomcat beside it, POST shutdown stopped TiffinBox's server. Two seconds later the JVM was still there, on Tomcat's port:
# container-0 and two Catalina utility threads aren't daemons. On Jetty too."
TD=$(blk two 'D (labelled)' 'E (labelled)'); TE=$(blk two 'E (labelled)' '')
for s in "$TD" "$TE"; do has "$s" '  POST  /shutdown   -> 200 application/json  {"stopping":true}' "two: the reply"; has "$s" "  the seven responses: 7 lines · md5 $S115" "two: the seven"; done
has "$TD" '  2 s after POST /shutdown - still running: yes · listening on: 127.0.0.1:19315' "two D: the JVM lived, on Tomcat's port"
has "$TE" '  2 s after POST /shutdown - still running: yes · listening on: 127.0.0.1:19317' "two E: the JVM lived, on Jetty's port"
# thr 'TEXT' N: the thread list that follows the line "non-daemon threads N:" in TEXT, one line each, joined with |
thr() { printf '%s\n' "$1" | awk -v h="  non-daemon threads $2:" '$0 == h { f = 1; next } f && /^    / { print; next } f { exit }' | paste -sd'|' -; }
TA_='    Catalina-utility-1 - a org.apache.tomcat.util.threads.TaskThread|    Catalina-utility-2 - a org.apache.tomcat.util.threads.TaskThread|    DestroyJavaVM - a java.lang.Thread'
[ "$(thr "$TD" 5)" = "$TA_|    HTTP-Dispatcher - a java.lang.Thread|    container-0 - a org.springframework.boot.tomcat.TomcatWebServer\$1" ] || die "two D: before - five, TiffinBox's dispatcher among them"
[ "$(thr "$TD" 4)" = "$TA_|    container-0 - a org.springframework.boot.tomcat.TomcatWebServer\$1" ] || die "two D: after - the dispatcher gone; Boot's container-0 and Tomcat's two utility threads left"
JA_='    qtp<hash>-N - a java.lang.Thread  x7|    qtp<hash>-N-acceptor-0@<hash>-oejs.ServerConnector@<hash>{HTTP/1.1, (http/1.1)}{127.0.0.1:19317} - a java.lang.Thread'
[ "$(thr "$TE" 11)" = "    DestroyJavaVM - a java.lang.Thread|    HTTP-Dispatcher - a java.lang.Thread|    Scheduler-<hash>-1 - a java.lang.Thread|$JA_" ] || die "two E: before"
[ "$(thr "$TE" 10)" = "    DestroyJavaVM - a java.lang.Thread|    Scheduler-<hash>-1 - a java.lang.Thread|$JA_" ] || die "two E: after - Jetty's scheduler and its eight pool threads left"
has "$TD" "$GRACE" "two D: Boot's graceful-shutdown lines on SIGTERM"; has "$TE" "$GRACEJ" "two E: Boot's graceful-shutdown lines on SIGTERM, Jetty's"
has "$TD" '  exit 143 · listening on 19314 and 19315 now: 0 and 0' "two D: stopped by its pid"; has "$TE" '  exit 143 · listening on 19316 and 19317 now: 0 and 0' "two E: stopped by its pid"
echo "  two: D the seven 115c36ba..., alive 2 s later on 19315, Catalina-utility-1/2 + container-0 left, SIGTERM 143, graceful · E Jetty: alive on 19317, its scheduler and pool threads left, 143"

# "Undertow: Boot four point one's parent no longer lists it. Its starter, asked for: exit one. In Boot 3.5.16's list, eleven lines;
# in 4.1.1's, zero."
x undertow '^  exit 1$'
x undertow "^  \[ERROR\] 'dependencies\.dependency\.version' for org\.springframework\.boot:spring-boot-starter-undertow:jar is missing\. @ line [0-9]+, column [0-9]+\$"
x undertow '^  spring-boot-dependencies-3\.5\.16\.pom: lines that mention undertow, in any case: 11 · that name spring-boot-starter-undertow: 1 · that name spring-boot-starter-jetty: 1$'
x undertow '^  spring-boot-dependencies-4\.1\.1\.pom: lines that mention undertow, in any case: 0 · that name spring-boot-starter-undertow: 0 · that name spring-boot-starter-jetty: 1$'
x undertow '^  built the two BOMs. copy · offline: yes · exit 0$'
echo "  undertow: exit 1, the version missing; BOM 3.5.16 11 lines (1 starter), 4.1.1 0 (Jetty's starter in both)"

# the exercise's end state: the lines exercise/README.md calls "Done" are lines of this capture, after the solution's line - and
# of SOLUTION.md's measured run; the shipped registration's run gives the 404
XB=$(blk exercise 'its try line, as shipped' "the solution's line"); XS=$(blk exercise "the solution's line" '')
has "$XB" "$(gl /lunch.menu 404 application/json - '{"timestamp":"<time>","status":404,"error":"Not Found","path":"/lunch.menu"}')" "exercise: shipped broken"
has "$XB" "$(gl /raw/lunch.menu 200 "$TP" - 'raw servlet: pattern=/raw/* match=PATH')" "exercise: shipped, /raw/* already"
for l in "$(gl /lunch.menu 200 "$TP" - 'raw servlet: pattern=*.menu match=EXTENSION')" "$(gl /raw/lunch.menu 200 "$TP" - 'raw servlet: pattern=/raw/* match=PATH')"; do
  has "$XS" "$l" "exercise"
  awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "${l#  }" || die "exercise/README.md: Done names no such line: ${l#  }"
  grep -qxF -- "${l#  }" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line: ${l#  }"; done
[ "$(n exercise '^  listening on 19318 and 19319 now: 0 and 0$')" = 2 ] || die "exercise: both runs stopped"
echo "  exercise: as shipped /lunch.menu 404; the solution's line -> *.menu EXTENSION, /raw/* PATH"
cmp -s "$TREE/README.md" ../c5-tiffinbox/README.md || echo "  (the anchor has moved past ../c5-unit27/after: this unit's captures are of that tree)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit02: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log and every file this unit ships; nothing of this run left running"
