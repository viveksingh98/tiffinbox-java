#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · /actuator/mappings: Every Route, Listed - this unit's receipts. The last course asked Boot for its routing table and
# got one context with nothing in it: TiffinBox's routes were its own. Since the anchor moved onto embedded Tomcat they are Spring
# MVC's rows, and this unit prints the table, reads its rows, and finds the two rows that catch every path. Six captures, each run
# three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by
# a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of
# every run, and in every file this unit ships.
#   table     the anchor on the plain JVM with mappings exposed by a flag, for one run: the table, read by harness/table.py - its
#             one context, its three kinds, the DispatcherServlet's rows, the filters and the servlet, counted; the check that
#             every TiffinBox row is named, shown failing first on a planted copy; then the seven (the comparison set, masked)
#   adapter   who answers /actuator: the previous tree (TiffinBox's own server and its bridge, ActuatorRoutes) against the anchor
#             (Boot's own adapter) - the routing table, health's and the scrape's content types, /actuator and its links, the
#             class Boot's rows name and the jar it lives in; the previous tree's seven
#   rows      what a row says: Actuator's health row and TiffinBox's /customers row, every key the table gives each; then a
#             wrong verb (DELETE) on each path - who answers it, and its Allow header
#   catchall  A/B/A': the two static rows, /webjars/** (one folder) and /** (every path) - A the anchor (Boot's web log group at
#             DEBUG): the table, GET /customers, GET /nowhere and its lines; B the same with spring.web.resources.add-mappings=false;
#             A' = A; D (labelled): A's line, started from a folder that holds a static/ folder - /** serves its file
#   exposure  C (labelled): the AOT jar - the anchor built with the profile native - with the same flag: mappings is not there
#   exercise  exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#             the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit04/after: the tree the embedded-Tomcat lesson froze (= ../c6-tiffinbox when this
# unit was made). "The previous tree" is ../c5-unit27/after: the anchor as Course 5 left it, TiffinBox's own server and its bridge.
# Both are COPIED under .harness/ (after, before, aot) - this script never writes into another unit's folder, and never builds a
# frozen tree in place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token
# (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison
# set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the
# file). "$M2" is this unit's own repository, .m2-demo. The harness - harness/table.py (it reads one Actuator answer from its
# standard input and prints it: the course's, never TiffinBox's) and harness/shutdown.sh (POST /shutdown, the token read from its
# file) - is named on every capture that uses it. Every run passes options only.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). The profile native's build (exposure) runs
# GraalVM's native plugin, which reads its metadata repository (a zip) from .m2-demo - and downloads it from GitHub when the zip is
# not there, even under -o: so a native-profile build without the zip goes to Maven Central for it at once, and every native-profile
# build's log is searched for the plugin's own download line - found, the run stops. No GraalVM is needed: nothing here is compiled
# to a binary. At run time nothing leaves 127.0.0.1: TiffinBox listens there, every request goes there, and Logback writes to the
# terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its own
# length); a GraalVM's folder, if GRAALVM_HOME is set, "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..",
# the home folder "~"; your user name "<user>" - in every line of every capture. Spring's error timestamp becomes "…" (both forms: an
# ISO-8601 string, epoch milliseconds) wherever Spring's error body is printed, and the seven are hashed after it; a JSON answer's
# keys are sorted; in a DEBUG line an identity hash after "@" becomes "…" and the date in an error map "…". harness/table.py cuts two
# things, and counts each: a "produces" list keeps its first type, and a Java class name before "#" keeps its last part. A run's log
# lines are printed from their message on (no time, no process id, no thread); Boot's first line is cut before " with PID". Long
# DEBUG output goes through a declared filter, and what it cuts is counted. No duration is captured.
# Ports (brief ⚑1, 19340-19349): table 19340 · the previous tree 19341 · adapter's anchor 19342 · rows 19343 · catchall 19344 (D too)
# · the AOT jar 19345 · the exercise 19349 (19346-19348 unused, checked free). 18425 (TiffinBox's default) and 8080 (Tomcat's) are
# checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it. The published captures were
# made with no locale set, which is the C locale.
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $xpid, the exercise's shell, with every process under it - its Maven, its JVM, its curl), if they still run, then sweep():
# anything of this run still alive in its process group - a TiffinBox JVM - is stopped. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay,
# for the diff the message names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always
# reaches the rmdir; the script still exits 130 after an interrupt (README.md, "Interrupted"). $pid and $xpid are cleared whenever
# their process has been reaped.
pid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
# desc PID: every process under PID - its children, theirs, and so on (ps, by parent); killtree PID: PID and all of them, TERM
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; [ -z "$xpid" ] || killtree "$xpid"; for p in "$pid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip openssl; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A MANAGEMENT_* of
# yours could widen or narrow the exposure list every capture here reads.)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit04/after ] || die "anchor must be the link to ../c6-unit04/after - this unit changes nothing in the anchor"
PREV=../c5-unit27/after                              # the previous tree: the anchor as Course 5 left it - read, copied
for t in anchor "$PREV"; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-local.yaml" ] && die "$t holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"; done
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
W=tiffinbox-web/src/main/java/com/tiffinbox/web     # TiffinBox's web classes, in a tree
YAML=tiffinbox-web/src/main/resources/application.yaml
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-only-not-a-real-token
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
for f in harness/table.py harness/shutdown.sh exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19340 19341 19342 19343 19344 19345 19346 19347 19348 19349; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md (the anchor's own) and from README.md (this unit's: the options it adds), and
# ---- asserted - each line must be there, whole ----------------------------------------------------------------------------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
R_PLAIN=$(readme 'mvn -B package')
R_PNAT=$(readme 'mvn -B -Pnative package')
R_RUN=$(readme "$J")
R_WEB=$(readme "$J --logging.level.web=debug")
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_GET=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
R_Q=$(readme "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/customers")
EXPO='--management.endpoints.web.exposure.include=health,prometheus,mappings'
WEBF=${R_WEB#"$J "}; NOSTATIC='--spring.web.resources.add-mappings=false'
[ "$WEBF" = '--logging.level.web=debug' ] || die "the anchor README's web logging option"
L_MAP=$(mine "$R_RUN $EXPO")
L_WEB=$(mine "$R_RUN $EXPO $WEBF")
L_WEBOFF=$(mine "$R_RUN $EXPO $WEBF $NOSTATIC")
L_AOT=$(mine "$R_AOTRUN $EXPO")
L_TABLE=$(mine 'curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py')
L_COUNT=$(mine 'curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py count')
L_ROW=$(mine 'curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py row /actuator/health /customers')
L_LINKS=$(mine 'curl -s http://127.0.0.1:18431/actuator | python3 harness/table.py links')
L_RAW=$(mine "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/mappings")
L_DEL=$(mine "curl -s -X DELETE -w ' %{http_code} allow=%header{allow}\n' http://127.0.0.1:18431/customers")
L_STATIC=$(mine "mkdir -p static && printf 'a file in static/, beside secrets/' > static/probe.txt")
# off DIR 'README mvn LINE' PHASE: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, clean and without tests. dev() takes those things back out, and must give the README's line again.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }; c=${c/ $3/ -DskipTests clean $3}; printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# qc PORT PATH: the anchor README's status-and-type line, its port made PORT and its path PATH
qc() { local c; c=$(url "$R_Q" "$1"); printf '%s\n' "${c%/customers}$2"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's own
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
for c in "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19340 "$L_MAP")")" = "cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19340 $EXPO" ] || die "exe()"
[ "$(url "$L_TABLE" 19340)" = 'curl -s http://127.0.0.1:19340/actuator/mappings | python3 harness/table.py' ] && [ "$(qc 19341 /actuator)" = "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19341/actuator" ] || die "url(), qc()"
echo "  the commands: anchor/README.md gives the 8 lines this script derives from, README.md the 11 it adds (the exposure flag, the table's reader, one wrong verb, a static/ folder)"

# ---- build: before the captures - the anchor with the profile native (it fills .m2-demo on a fresh clone, Spring's AOT step and
# ---- GraalVM's native plugin included), and the previous tree - copies under .harness/, never the frozen trees -------------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target --exclude secrets anchor/ .harness/pre/
rsync -a --exclude target --exclude secrets "$PREV/" .harness/pre0/
ZIP="$M2/org/graalvm/buildtools/graalvm-reachability-metadata/1.1.8/graalvm-reachability-metadata-1.1.8-repository.zip"
# ghub LOG: the native plugin went over the network for its metadata repository. Never allowed: the run stops.
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only
# if the offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is
# never silent (inside a capture, "no" changes the capture's hash: cap() then dies).
mbuild() { local how=yes ec=0 c=$1
  case $c in *' -Pnative '*) [ -f "$ZIP" ] || { c=${c/mvn -o -B /mvn -B }; how="no - GraalVM's metadata repository was not in .m2-demo, so Maven Central was asked for it"; } ;; esac
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && [ "$how" = yes ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  if ghub "$2"; then echo "  built $3 · offline: no - GraalVM's native plugin went to GitHub for its metadata repository · exit $ec"
    die "$3: GraalVM's native plugin went over the network for its metadata repository - README.md, The repository"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
mbuild "$(off .harness/pre "$R_PNAT" package)" .harness/build-pre.log ".harness/pre (the anchor, the profile native)"
mbuild "$(off .harness/pre0 "$R_PLAIN" package)" .harness/build-pre0.log ".harness/pre0 (the previous tree)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-webmvc/4.1.1/spring-boot-starter-webmvc-4.1.1.jar" ] || die "Spring MVC's starter is not in .m2-demo after the first build"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
echo "  .m2-demo holds Spring MVC's starter and GraalVM's metadata repository; no build here goes to the network again"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; LASTE=""                                     # logs counted: every JVM that served
first() { grep -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//'; }
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# addrs: the addresses the process $pid listens on, read off the process (lsof, by pid - its command name is never printed)
addrs() { lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
# listening PORT: addrs, polled until the process listens on PORT - every 0.25 s, up to 120 s
listening() { local a="" i=0
  while [ $i -lt 480 ]; do
    a=$(addrs); case " $a " in *":$1 "*) break ;; esac
    kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# lb ADDRESSES: yes when every one is 127.0.0.1:<port> - the check R.78 asks for, on the address read off the process
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
up() { local l; l=$(listening "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  case " $l " in *':8080 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, Tomcat's default - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
# tline: Boot's started line - logged by Boot's TomcatWebServer, not by Tomcat: its logger, then its message - polled until it is
# there (up to 30 s). It names the port, never the address (the embedded-Tomcat lesson, bind F: Tomcat's own connector line names
# both, at a level Boot's logging defaults hide).
tline() { local i=0; while ! grep -q 'Tomcat started on port ' .harness/run.out && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  echo "  Boot's started line - logger: message: $(grep -m1 ' : Tomcat started on port ' .harness/run.out | sed 's/^.*--- \[[^]]*\] //; s/ *: /: /')"; }
# sortj: lines that start with a JSON object - curl's status and anything after it kept - the object's keys sorted (Jackson 2
# and Jackson 3 order keys differently)
sortj() { python3 -c '
import json, re, sys
out = []
for l in sys.stdin.buffer.read().decode("utf-8").splitlines():
    m = re.match(r"^(\{.*\})( .*)?$", l)
    if not m: out.append("  " + l); continue
    try: o = json.dumps(json.loads(m.group(1)), sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    except ValueError: out.append("  " + l); continue
    out.append("  " + o + (m.group(2) or "") + ("    (keys sorted)" if o != m.group(1) else ""))
sys.stdout.buffer.write("".join(x + "\n" for x in out).encode("utf-8"))'; }
# ask 'README curl LINE' PORT: printed and run, Spring's error timestamp masked, a JSON answer's keys sorted
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sortj; }
# tab PORT 'README LINE': a curl line piped into harness/table.py, printed and run from this folder
tab() { local c; c=$(url "$2" "$1"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null; }
# q PORT PATH: the anchor README's status-and-type line, printed and run
q() { local c; c=$(qc "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (R.41, R.75). A JVM ($pid) that exits first stops the run.
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  ask "$R_READY" "$1"; }
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times"; }
# tsmask: Spring's error timestamp, both forms (an ISO-8601 string, epoch milliseconds), becomes "…" (README.md, Masks)
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
# gone PORT: after a POST /shutdown - the JVM must leave within 15 s, the port must be free; its exit code
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
# seven PORT DIR: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), the POST
# line printed; the JVM must leave within 15 s of them, the port must be free; its exit code; the md5 of the seven after the
# timestamp mask, and how many lines the mask changed; its log counted (logtok)
seven() { local m
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  gone "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  logtok; }
# stop PORT DIR: POST /shutdown with DIR's token (harness/shutdown.sh); the JVM must leave, the port must be free
stop() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | sed 's/^/  /'; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
# mask: every line of a capture - the token, a GraalVM's folder, this folder, the folder above, home, and your user name as a
# whole word (README.md, Masks)
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  function word(s, w, r,   o, i, a, z) { o = ""; if (w == "") return s
    while ((i = index(s, w)) > 0) { a = substr(s, i - 1, 1); z = substr(s, i + length(w), 1)
      if ((i == 1 || a !~ /[A-Za-z0-9_]/) && z !~ /[A-Za-z0-9_]/) { o = o substr(s, 1, i - 1) r } else { o = o substr(s, 1, i + length(w) - 1) }
      s = substr(s, i + length(w)) }
    return o s }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)) }
  { gsub(T, "[masked: the " tl "-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    print word($0, me, "<user>") }'; }
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] && [ -z "$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
pbuild() { local c; c=$(off "$1" "${3:-$R_PLAIN}" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
lines() { if [ -f "$1" ]; then echo "$(wc -l < "$1" | tr -d ' ') lines"; else echo "deleted"; fi; }
# injar JAR CLASS: the jars in JAR's BOOT-INF/lib that hold CLASS (a .class path), and how many jars it looked in
injar() { python3 - "$1" "$2" <<'PY'
import io, sys, zipfile
z = zipfile.ZipFile(sys.argv[1]); want = sys.argv[2]
libs = sorted(e for e in z.namelist() if e.startswith("BOOT-INF/lib/") and e.endswith(".jar"))
hit = [j.split("/")[-1] for j in libs if want in zipfile.ZipFile(io.BytesIO(z.read(j))).namelist()]
print("%s (of its %d jars)" % (", ".join(hit) if hit else "in none", len(libs)))
PY
}
# meta JAR NAME: Boot's own metadata for a setting - its default, and the jar inside JAR whose metadata declares it
meta() { python3 - "$1" "$2" <<'PY'
import io, json, sys, zipfile
z = zipfile.ZipFile(sys.argv[1]); want = sys.argv[2]; out = []
for j in sorted(e for e in z.namelist() if e.startswith("BOOT-INF/lib/") and e.endswith(".jar")):
    i = zipfile.ZipFile(io.BytesIO(z.read(j))); n = "META-INF/spring-configuration-metadata.json"
    if n in i.namelist():
        for p in json.loads(i.read(n)).get("properties", []):
            if p["name"] == want:
                d = p.get("defaultValue")
                out.append("%s %s (%s)" % (want, "no default" if d is None else "default " + (d if isinstance(d, str) else json.dumps(d)), j.split("/")[-1]))
print(" · ".join(out) if out else want + ": in no jar's metadata")
PY
}
# settle: the log stops growing (the same length twice, 0.5 s apart; up to 15 s) - a request's last DEBUG line is written just
# after its answer leaves
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
# dbg FROM: the run's DEBUG and WARN lines after line FROM, from their logger on (a WARN line says so), an identity hash after "@"
# and a date in an error map made "…" (README.md, Masks)
dbg() { awk -v from="$1" 'NR > from && / (DEBUG|WARN) [0-9]+ --- \[/ { lv = ($0 ~ / WARN [0-9]+ --- \[/) ? "WARN " : ""
    s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); sub(/^ +/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); gsub(/timestamp=[^,]*,/, "timestamp=…,", msg); print "    " lv lg ": " msg }' .harness/run.out; }
# expo YAML: the exposure list an application.yaml writes down - the "include:" line under "exposure:"
expo() { awk '/^ +exposure:$/ { f = 1; next } f && /^ +include: / { sub(/^ +/, ""); print; exit }' "$1"; }
# lv FROM: the request's lines - every DEBUG and WARN line after line FROM (dbg), counted, and the lines of any other level in the
# same stretch of the log counted too (not shown)
lv() { local a b; a=$(dbg "$1" | grep -c . || true); b=$(awk -v f="$1" 'NR > f' .harness/run.out | grep -c . || true)
  echo "  its lines at DEBUG and WARN - $a (its other lines: $((b - a))):"; dbg "$1"; }
# pats: the handler mappings that logged their patterns at start (Boot's web log group at DEBUG), from the message on
pats() { grep -E "(Patterns \[.*\]|[0-9]+ mappings) in '[A-Za-z]+'\$" .harness/run.out | sed 's/^.* : //'; }

# ---- table: the routing table, filled ---------------------------------------------------------------------------------------
table() {
  echo "the anchor, copied under .harness/ with a config tree, built with its README's line (offline):"
  copy anchor .harness/after; pbuild .harness/after "the anchor"
  echo "  the exposure list it was built with (application.yaml): $(expo .harness/after/$YAML)"
  echo "the anchor on the plain JVM, the exposure list given for this one run (this unit's line), port 19340:"
  start "$(at .harness/after 19340 "$L_MAP")"; up 19340; ready 19340; tline
  tab 19340 "$L_TABLE"
  curl -s http://127.0.0.1:19340/actuator/mappings > .harness/answer.json
  echo "the same check - every TiffinBox row named for its path, no lambda - run on a planted copy of this answer, /kitchen's handler given a lambda's name:"
  sed 's#"handler":"TiffinBox route /kitchen"#"handler":"com.tiffinbox.web.TiffinBoxServer$$Lambda/0x…@…"#' .harness/answer.json | python3 harness/table.py | grep "^  TiffinBox's rows" || echo "  (no line)"
  echo "the seven - the comparison set, with mappings exposed:"
  seven 19340 .harness/after; }

# ---- adapter: who answers /actuator - the bridge against Boot's own adapter ---------------------------------------------------
ADC=org/springframework/boot/webmvc/actuate/endpoint/web/WebMvcEndpointHandlerMapping.class
adapter() {
  echo "before - the previous tree: TiffinBox's own server, and its bridge (ActuatorRoutes), copied with a config tree, built with the README's line (offline):"
  copy "$PREV" .harness/before; pbuild .harness/before "the previous tree"
  echo "  ActuatorRoutes.java: $(lines .harness/before/$W/ActuatorRoutes.java) · Boot's adapter, WebMvcEndpointHandlerMapping, in its jar's libraries: $(injar .harness/before/$JARP $ADC)"
  echo "the previous tree, the same line, port 19341:"
  start "$(at .harness/before 19341 "$L_MAP")"; up 19341; ready 19341
  echo "  its own line: $(grep -m1 ' : TiffinBox listening on ' .harness/run.out | sed 's/^.* : //')"
  ask "$L_RAW" 19341
  q 19341 /actuator/health; q 19341 /actuator/prometheus; q 19341 /actuator
  seven 19341 .harness/before
  echo "after - the anchor (built in table): Tomcat, and Boot's own Actuator adapter:"
  echo "  ActuatorRoutes.java: $(lines .harness/after/$W/ActuatorRoutes.java) · Boot's adapter, WebMvcEndpointHandlerMapping, in its jar's libraries: $(injar .harness/after/$JARP $ADC)"
  echo "the anchor, the same line, port 19342:"
  start "$(at .harness/after 19342 "$L_MAP")"; up 19342; ready 19342; tline
  tab 19342 "$L_COUNT"
  q 19342 /actuator/health; q 19342 /actuator/prometheus; q 19342 /actuator
  tab 19342 "$L_LINKS"
  stop 19342 .harness/after; }

# ---- rows: what a row says ------------------------------------------------------------------------------------------------------
# del PORT PATH: this unit's DELETE line, its port and path changed - the body (Spring's timestamp masked, keys sorted), the status
# and the Allow header curl saw
del() { local c; c=$(url "$L_DEL" "$1"); c=${c%/customers}$2; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sortj; }
rows() {
  echo "the anchor on the plain JVM, the exposure list given for this one run (this unit's line), port 19343:"
  start "$(at .harness/after 19343 "$L_MAP")"; up 19343; ready 19343; tline
  tab 19343 "$L_ROW"
  echo "a wrong verb on each row's path - DELETE: the answer, its status, and the Allow header (empty when there is none):"
  del 19343 /actuator/health; del 19343 /customers
  stop 19343 .harness/after; }

# ---- catchall: the two static rows - /webjars/** for one folder, /** for every path (A/B/A', C) -------------------------------------
# web PORT 'LINE': the run - its handler mappings at start, the table, GET /customers and GET /nowhere, each with its lines
web() { local n0 c
  start "$(at .harness/after "$1" "$2")"; up "$1"; ready "$1"; tline
  echo "  at start, the handler mappings that logged their patterns: $(pats | paste -sd'|' -)"
  tab "$1" "$L_TABLE"
  settle; n0=$(wc -l < .harness/run.out | tr -d ' ')
  q "$1" /customers
  settle; lv "$n0"
  settle; n0=$(wc -l < .harness/run.out | tr -d ' ')
  c=$(url "$R_GET" "$1"); c=${c%/customers}/nowhere; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sortj
  settle; lv "$n0"
  stop "$1" .harness/after; }
catchall() {
  echo "Boot's own metadata, in the anchor's jar: $(meta .harness/after/$JARP spring.web.resources.add-mappings)"
  echo "A - the anchor on the plain JVM, the exposure list for this one run, Boot's web log group at DEBUG (this unit's line), port 19344:"
  web 19344 "$L_WEB"
  echo "B - the same, and the static-resource mappings off (this unit's line):"
  web 19344 "$L_WEBOFF"
  echo "A' - A again:"
  web 19344 "$L_WEB"
  echo "D (labelled) - A's line, started from a folder that holds a static/ folder with one file in it (README.md's line, run in the copy's folder): /** serves that file - the row's ServletContext [/] reads the static/ folder of the folder TiffinBox starts in - and neither that folder's own files nor secrets/:"
  local c n0; c="cd .harness/after && $L_STATIC"; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  start "$(at .harness/after 19344 "$L_WEB")"; up 19344; ready 19344; tline
  settle; n0=$(wc -l < .harness/run.out | tr -d ' ')
  q 19344 /probe.txt
  settle; lv "$n0"
  c=$(url "$R_GET" 19344); c=${c%/customers}/probe.txt; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  q 19344 /pom.xml; q 19344 /secrets/tiffinbox/shutdown-token
  stop 19344 .harness/after
  rm -rf .harness/after/static; }

# ---- exposure: C (labelled) - the AOT jar ------------------------------------------------------------------------------------------
exposure() {
  echo "C (labelled) - the AOT jar: the anchor built with the profile native (its README's line: Spring's AOT step, run at build), copied with a config tree:"
  copy anchor .harness/aot; pbuild .harness/aot "the anchor, the profile native" "$R_PNAT"
  echo "  the exposure list it was built with (application.yaml): $(expo .harness/aot/$YAML)"
  echo "the anchor README's AOT line, the same exposure list for this one run (this unit's line), port 19345:"
  start "$(at .harness/aot 19345 "$L_AOT")"; up 19345; ready 19345; tline
  q 19345 /actuator/mappings
  tab 19345 "$L_LINKS"
  stop 19345 .harness/aot; }

# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# xlog LOG: the exercise's own log, read after it exited - the copy's token in it (raw), Actuator's count of the endpoints it
# exposes (INFO, Boot's default level), the lines that name "mapping", WARN and ERROR lines
xlog() { echo "  the copy's own token in its log: $(raw "$(head -1 .harness/mine/tree/$TF)" "$1") times"
  echo "  its log, at INFO (Boot's default): $(grep -o "Exposing [0-9]* endpoints beneath base path '/actuator'" "$1" || echo 'no line that counts the endpoints') · lines that name mapping: $(grep -ci 'mapping' "$1" || true) · WARN: $(grep -c ' WARN ' "$1" || true) · ERROR: $(grep -c ' ERROR ' "$1" || true)"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this folder.
# A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit
# code and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files),
# and the README's run log kept before the solution's run writes its own. Bounded (600 s); on the way out, or past the bound, the
# shell and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exercise() { local setup sol i=0 e1 d1 e2 d2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 3 ] || die "SOLUTION.md's first bash block must be its two export lines and its one command"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  rm -f .harness/ex-*
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/ex-readme.log" 2> /dev/null
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$!
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's shell still ran after 600 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's shell did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  [ "$e1" = 0 ] || { tail -20 .harness/ex-readme.out >&3; die "the exercise's commands failed: exit $e1"; }
  [ "$e2" = 0 ] || { tail -20 .harness/ex-sol.out >&3; die "the solution's lines failed: exit $e2"; }
  echo "exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:"
  echo "the README's $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "  exit $e1 · what they printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"; xlog .harness/ex-readme.log
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · listening on 19349 now: $(listeners 19349)"; xlog .harness/mine/run.log; }

cap table table
cap adapter adapter
cap rows rows
cap catchall catchall
cap exposure exposure
cap exercise exercise

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
xf() { grep -qxF -- "$2" ".r-$1.out" || die "$1: expected the line: $2"; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted
# when it was read: logtok), nor anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/table.py harness/shutdown.sh; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|utility)-[0-9]' "$f" || die "$f holds a log line's time, a timestamp or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; ! grep -qE '@[0-9a-f]{6,}' "$f" || die "$f shows an identity hash"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
NL=$(cat .r-*.out | grep -cxF "  its log: the demo token 0 times · X-Shutdown-Token 0 times" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the exercise and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no thread number, no stack frame, no identity hash, no 8080 in any capture; no exposure of every endpoint"

S115='115c36bac276128e245ca57df11c2891'; S571='571faaea42e87e85add8c9548c64c961'
READY='  {"status":"UP"} 200'
STOPPED() { printf '  exit 0 · listening on %s now: 0\n' "$1"; }
LB() { printf '  listens on: 127.0.0.1:%s · loopback only: yes\n' "$1"; }
TC() { printf "  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port %s (http) with context path '/'\n" "$1"; }
PLAIN="  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1"
HEAD3='  contexts: 1 (application) · kinds: 3 (dispatcherServlets servletFilters servlets)'
for c in table adapter rows catchall; do x "$c" "^$PLAIN\$"; done
for c in table adapter rows catchall exposure; do [ "$(n "$c" '^  listens on: ')" = "$(n "$c" '^  listens on: 127\.0\.0\.1:[0-9]+ · loopback only: yes$')" ] || die "$c: a JVM listened beyond 127.0.0.1"; done

# "Ask again, with a flag for this one run, on the plain JVM: one context, three kinds. Fourteen rows, five filters, one servlet.
#  Five rows are TiffinBox's own."
x table '^  built the anchor · offline: yes · exit 0$'; x table '^  the exposure list it was built with \(application\.yaml\): include: health,prometheus$'
xf table "$(LB 19340)"; xf table "$(TC 19340)"; xf table "\$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19340 $EXPO"
xf table "$HEAD3"
xf table "  dispatcherServlets · dispatcherServlet: 14 rows, in the table's order - a run of rows with details sorted by pattern (produces lists cut: 5 · class names cut to their last part: 2)"
for i in 6 7 8 9 10; do x table "^ +$i  /[a-z]+ -> TiffinBox route /[a-z]+\$"; done
x table '^   13  /webjars/\*\* -> ResourceHttpRequestHandler '; x table '^   14  /\*\* -> ResourceHttpRequestHandler '
x table '^  rows with details: 7 · without: 7 · naming a verb: 5 \(GET 5\)$'
xf table "  TiffinBox's rows (a handler named \"TiffinBox route /…\"): 5 · each named for its own path: 5 · a lambda's name (\$\$Lambda): 0"
xf table "  TiffinBox's rows (a handler named \"TiffinBox route /…\"): 4 · each named for its own path: 4 · a lambda's name (\$\$Lambda): 1"
x table '^  servletFilters: 5, by name: characterEncodingFilter, formContentFilter, requestContextFilter, Tomcat WebSocket \(JSR356\) Filter, webMvcObservationFilter · on /\* : 5$'
x table '^  servlets: 1 · dispatcherServlet on /$'
x table "^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 $S571\$"
echo "  table: the plain JVM, the flag for one run; 1 context, 3 kinds; 14 rows (TiffinBox's 5, named; the planted lambda caught), 7 with details, 5 naming GET; 5 filters; 1 servlet; the seven 571faaea..."

# "The last course's bridge: mappings empty, health and the scrape answer, /actuator four oh four. Now: the same two types, /actuator
#  answers with its links, and the class is Boot's own, in its webmvc jar. The bridge is gone."
AB=$(blk adapter 'before - ' 'after - '); AA=$(blk adapter 'after - ' '')
has "$AB" '  built the previous tree · offline: yes · exit 0' "adapter before: built"; has "$AB" '  its own line: TiffinBox listening on http://127.0.0.1:19341' "adapter before: its own server"
printf '%s\n' "$AB" | grep -qE '^  ActuatorRoutes\.java: 196 lines · Boot.s adapter, WebMvcEndpointHandlerMapping, in its jar.s libraries: in none \(of its 46 jars\)$' || die "adapter before: the bridge and no adapter"
has "$AB" '  {"contexts":{"application":{"mappings":{},"parentId":null}}} 200' "adapter before: the empty table"
printf '%s\n' "$AA" | grep -qE '^  ActuatorRoutes\.java: deleted · Boot.s adapter, WebMvcEndpointHandlerMapping, in its jar.s libraries: spring-boot-webmvc-4\.1\.1\.jar \(of its 58 jars\)$' || die "adapter after: Boot's adapter, its jar"
has "$AA" "$HEAD3 · rows: dispatcherServlet 14, servletFilters 5, servlets 1" "adapter after: the table"
for b in "$AB" "$AA"; do has "$(printf '%s\n' "$b" | grep -A1 '/actuator/health$')" '  200 application/vnd.spring-boot.actuator.v3+json' "adapter: health's type"
  has "$(printf '%s\n' "$b" | grep -A1 '/actuator/prometheus$')" '  200 text/plain;version=0.0.4;charset=utf-8' "adapter: the scrape's type"; done
has "$(printf '%s\n' "$AB" | grep -A1 '/actuator$')" '  404 application/json' "adapter before: /actuator"; has "$(printf '%s\n' "$AA" | grep -A1 '/actuator$')" '  200 application/vnd.spring-boot.actuator.v3+json' "adapter after: /actuator"
has "$AA" '  the links: health health-path mappings prometheus self' "adapter after: the links"; has "$AA" "$(STOPPED 19342)" "adapter after: exit 0"
has "$AB" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S115" "adapter before: the seven"
echo "  adapter: before the bridge (196 lines), 0 kinds, health/scrape types, /actuator 404, 115c36ba...; after the bridge deleted, Boot's class in spring-boot-webmvc-4.1.1.jar, 14 rows, the same two types, /actuator 200, mappings among the links"

# "Health's row: a pattern, a verb - GET - the types it produces, the method that runs. TiffinBox's: two things, a path and a
#  handler's name. DELETE: Spring answers health itself, four oh five, Allow GET; TiffinBox's handler answers its own, no Allow."
x rows "^$(LB 19343)\$"; x rows '^  the row for /actuator/health: 1$'; x rows '^  the row for /customers: 1$'
x rows '^  /actuator/health - 3 keys: details handler predicate$'; x rows '^    details\.requestMappingConditions\.methods = \["GET"\]$'
x rows '^    details\.handlerMethod\.className = org\.springframework\.boot\.webmvc\.actuate\.endpoint\.web\.AbstractWebMvcEndpointHandlerMapping\.OperationHandler$'
x rows "^    handler = Actuator web endpoint 'health'\$"
[ "$(blk rows '  /customers - ' 'a wrong verb' | paste -sd'|' -)" = '    handler = TiffinBox route /customers|    predicate = /customers' ] || die "rows: TiffinBox's row, its two keys"
x rows '^  /customers - 2 keys: handler predicate$'
x rows '^  \{"error":"Method Not Allowed","path":"/actuator/health","status":405,"timestamp":"…"\} 405 allow=GET    \(keys sorted\)$'
x rows '^  \{"error":"method not allowed"\} 405 allow=$'
x rows "^$(STOPPED 19343)\$"
echo "  rows: health 3 keys, GET, Boot's OperationHandler; /customers 2 keys; DELETE: Spring's 405 Allow GET / TiffinBox's own 405, no Allow"

# "The last two rows are the static ones: /webjars/** for one folder, /** for every path - Spring's static-file handler, which Boot
#  maps there. /customers stops at TiffinBox's row; /nowhere falls to /**, no file, four oh four. B: twelve rows, neither static
#  row; no handler at all, a different exception, the same four oh four. A again: fourteen. D: a static/ folder where TiffinBox
#  starts - /** serves its file; not the folder's own files, not secrets/."
x catchall "^Boot's own metadata, in the anchor's jar: spring\.web\.resources\.add-mappings default true \(spring-boot-autoconfigure-4\.1\.1\.jar\)\$"
CA=$(blk catchall 'A - the anchor' 'B - the same'); CB=$(blk catchall 'B - the same' "A' - A again"); CA2=$(blk catchall "A' - A again" 'D (labelled)'); CD=$(blk catchall 'D (labelled)' '')
for b in "$CA" "$CA2"; do has "$b" "  dispatcherServlets · dispatcherServlet: 14 rows, in the table's order - a run of rows with details sorted by pattern (produces lists cut: 5 · class names cut to their last part: 2)" "catchall A/A': 14 rows"
  printf '%s\n' "$b" | grep -qF "Patterns [/webjars/**, /**] in 'resourceHandlerMapping'" || die "catchall A/A': the resource mapping at start"
  has "$b" '    o.s.w.s.handler.SimpleUrlHandlerMapping: Mapped to TiffinBox route /customers' "catchall A/A': /customers is TiffinBox's"
  printf '%s\n' "$b" | grep -qE '^    o\.s\.w\.s\.handler\.SimpleUrlHandlerMapping: Mapped to ResourceHttpRequestHandler \[classpath \[META-INF/resources/\]' || die "catchall A/A': /nowhere to the static-file handler"
  printf '%s\n' "$b" | grep -qF 'NoResourceFoundException' || die "catchall A/A': NoResourceFoundException"
  printf '%s\n' "$b" | grep -qE '^  its lines at DEBUG and WARN - [0-9]+ \(its other lines: 0\):$' && ! printf '%s\n' "$b" | grep -qE '\(its other lines: [1-9][0-9]*\):$' || die "catchall A/A': every line of each request shown"
  has "$b" "$(STOPPED 19344)" "catchall A/A': exit 0"; done
[ "$(printf '%s\n' "$CA" | grep '^\$ cd')" = "$(printf '%s\n' "$CA2" | grep '^\$ cd')" ] || die "catchall: A' is not A's command"
[ "$(printf '%s\n' "$CA" | grep -vE '^\$ cd')" = "$(printf '%s\n' "$CA2" | grep -vE '^\$ cd')" ] || die "catchall: A' differs from A"
has "$CB" "  dispatcherServlets · dispatcherServlet: 12 rows, in the table's order - a run of rows with details sorted by pattern (produces lists cut: 5 · class names cut to their last part: 2)" "catchall B: 12 rows"
! printf '%s\n' "$CB" | grep -qE '^ +[0-9]+  /(webjars/)?\*\* -> ' || die "catchall B: a catch-all row survived"
! printf '%s\n' "$CB" | grep -qF "in 'resourceHandlerMapping'" || die "catchall B: the resource mapping logged at start"
has "$CB" '    WARN o.s.web.servlet.PageNotFound: No mapping for GET /nowhere' "catchall B: no mapping"
printf '%s\n' "$CB" | grep -qF 'Resolved [org.springframework.web.servlet.NoHandlerFoundException: No endpoint GET /nowhere.]' || die "catchall B: NoHandlerFoundException"
printf '%s\n' "$CB" | grep -qE '^  its lines at DEBUG and WARN - [0-9]+ \(its other lines: 0\):$' && ! printf '%s\n' "$CB" | grep -qE '\(its other lines: [1-9][0-9]*\):$' || die "catchall B: every line of the request shown"; has "$CB" "$(STOPPED 19344)" "catchall B: exit 0"
NW='  {"error":"Not Found","path":"/nowhere","status":404,"timestamp":"…"} 404    (keys sorted)'
for b in "$CA" "$CB" "$CA2"; do has "$b" "$NW" "catchall: the same 404, masked"; done
# D: the static row's ServletContext [/] - a static/ folder where TiffinBox starts is served; the start folder's own files and the
# config tree are not
has "$CD" "\$ cd .harness/after && mkdir -p static && printf 'a file in static/, beside secrets/' > static/probe.txt" "catchall D: the static/ folder"
printf '%s\n' "$CD" | grep -q -- "--logging.level.web=debug\$" && [ "$(printf '%s\n' "$CD" | grep '^\$ cd .harness/after && java')" = "$(printf '%s\n' "$CA" | grep '^\$ cd .harness/after && java')" ] || die "catchall D: A's line"
# ans BLOCK 'COMMAND': the line after the command's own $ line in BLOCK - its answer
ans() { printf '%s\n' "$1" | grep -A1 -xF -- "\$ $2" | sed -n 2p; }
has "$(ans "$CD" "$(qc 19344 /probe.txt)")" '  200 text/plain' "catchall D: the file served"
has "$CD" '  a file in static/, beside secrets/ 200' "catchall D: its content"
printf '%s\n' "$CD" | grep -qE '^    o\.s\.w\.s\.handler\.SimpleUrlHandlerMapping: Mapped to ResourceHttpRequestHandler \[classpath \[META-INF/resources/\].*ServletContext \[/\]\]$' || die "catchall D: the /** row's handler"
has "$(ans "$CD" "$(qc 19344 /pom.xml)")" '  404 application/json' "catchall D: the start folder's own file not served"
has "$(ans "$CD" "$(qc 19344 /secrets/tiffinbox/shutdown-token)")" '  404 application/json' "catchall D: the config tree not served"
has "$CD" "$(STOPPED 19344)" "catchall D: exit 0"
echo "  catchall: A 14 rows, /webjars/** and /** last ('resourceHandlerMapping'), /customers TiffinBox's, /nowhere -> /** -> NoResourceFoundException -> 404; B 12 rows, No mapping, NoHandlerFoundException, the same 404; A' = A; D a static/ folder served by /**, pom.xml and secrets/ 404"

# "Spring's AOT step fixes the endpoint list at build: the AOT jar with the same flag - mappings four oh four, not among the links."
x exposure '^  built the anchor, the profile native · offline: yes · exit 0$'; x exposure "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$"
x exposure '^\$ cd \.harness/aot && java -Dspring\.aot\.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=19345 --management\.endpoints\.web\.exposure\.include=health,prometheus,mappings$'
[ "$(blk exposure '$ curl -s -o /dev/null' '' | head -1)" = '  404 application/json' ] || die "exposure C: mappings 404"
x exposure '^  the links: health health-path prometheus self$'; x exposure "^$(STOPPED 19345)\$"; x exposure "^$(LB 19345)\$"
echo "  exposure C: the AOT jar, the same flag - /actuator/mappings 404, the links without it"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder;
# the line exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run;
# the README's own last line, as shipped, finds no table
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l="TiffinBox's rows: 5 · the verbs the table gives them: none"
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    TiffinBox's rows: 0 · not a routing table: status 404" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder" "exercise: the README's commands leave the shell in this unit's folder"
has "$XE" "  the shell is now in: this unit's folder · listening on 19349 now: 0" "exercise: the solution's lines leave the shell in this unit's folder, nothing listening"
[ "$(n exercise '^  the copy.s own token in its log: 0 times$')" = 2 ] || die "exercise: the copy's token, in both logs"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
has "$XS" "  its log, at INFO (Boot's default): Exposing 2 endpoints beneath base path '/actuator' · lines that name mapping: 0 · WARN: 0 · ERROR: 0" "exercise: as shipped, silent - two endpoints"
has "$XE" "  its log, at INFO (Boot's default): Exposing 3 endpoints beneath base path '/actuator' · lines that name mapping: 0 · WARN: 0 · ERROR: 0" "exercise: the solution - three endpoints"
echo "  exercise: one env -i shell - the README as written (mapping) -> no table, 404; the solution's lines (mappings) -> 5 rows, no verbs; the shell in this unit's folder after each"

[ -z "$(diff -rq -x target -x .m2-demo anchor/ ../c6-tiffinbox/ 2> /dev/null)" ] || echo "  (anchor/ and ../c6-tiffinbox differ - the anchor has moved past the tree this unit reads)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit05: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log"
