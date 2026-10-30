#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · Web Layer Performance - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit28/after, the tree the
# web-layer testing lesson froze (= c6-tiffinbox at Section 5's end). This script copies that tree under .harness/anchor, builds it
# with its README's line and runs its jar with options only - two of Boot's switches, compression and HTTP/2 - and measures what
# crosses the wire: bytes (curl's %{size_download}) and connections (curl's own -v lines), never a time. The clients are curl, the
# JDK's HttpClient and Spring's RestClient - the last two in one small main class of the course's harness (harness/probe/web/Unzip.java,
# outside com.tiffinbox, compiled against the anchor's own jars and run on its class path). No stub, no native build, no Docker, no
# TLS and no browser. A labelled capture (aot, C) builds the anchor's AOT jar on a copy and runs it with the same two switches.
# Eight captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run and in every file this unit ships.
#   which     Boot's keys and their defaults, read off its own metadata (the 8 MIME types counted); the seven on the README's run
#             line, a fresh JVM; then the key off and the key on, one fresh JVM each, gzip asked and not: the page, the form page,
#             the customers' list, the stylesheet (its URL read off the page), health - each answer's bytes and its headers
#   switch    A compression on: the page gzip, its decoded md5 = the plain one; B no key, gzip asked all the same; A' = A
#   floor     the list under the floor, then grown by 30 POSTs past it (a fresh JVM, R.97): plain and gzip, three rounds, md5s
#   decode    who unzips: curl --compressed; the JDK's HttpClient, gzip set by hand; RestClient.create() - and Tomcat's access log
#             of the same requests (what each client asked for, what the server sent)
#   h2c       A HTTP/2 on: curl --http2 (the upgrade, -v), prior knowledge, the JDK's client; B the key off; A' = A
#   together  the page and its stylesheet at once (curl -Z, without --parallel-immediate): HTTP/1.1, then HTTP/2 - connections
#             counted off curl's own -v lines
#   aot       C (labelled): the anchor's AOT jar, built on a copy (-Pnative -DskipTests package, offline); the two switches on its
#             run line, then none
#   exercise  exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#             the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit28/after, COPIED under .harness/; this script never writes into another unit's folder
# and never builds a frozen tree in place. Every run of TiffinBox starts in a copy that holds a config tree with a fake token
# (secrets/), as the README asks - and before every start the script lists that secrets/ folder: the token's file, and nothing else (a
# file there is a key: R.158). Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since
# the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is
# this unit's own repository, .m2-demo. harness/keys.py reads a jar's configuration metadata (the upload lesson's, byte for byte);
# harness/shutdown.sh is POST /shutdown with the token read from its file (the filters lesson's, byte for byte). The seven run first,
# on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - so every JVM this script starts has its locale
# pinned on its run line (-Duser.language=en -Duser.country=US, right after java), and each one's locale is read off its pid (jcmd
# PID VM.system_properties) or printed by it (Unzip), and asserted: en_US.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin reads its metadata
# repository from .m2-demo (a file: URL) - a build whose log says it went to http(s) for it stops the run. At run time nothing leaves
# 127.0.0.1: TiffinBox listens there, every request goes there, Logback writes to the terminal and Tomcat's access log (a harness
# option, named on every line that sets it) to .harness/tomcat/logs.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its own
# length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every line
# of every capture. The JDK's version in Boot's first line becomes " using Java <version>" (printed once on the terminal, R.151);
# Tomcat's connector name with its port, "http-nio-127.0.0.1-<port>" (S6.22). Spring's error timestamp becomes "…" in the seven. A
# run's log lines are printed from their logger on; Boot's first line is cut before " with PID". An answer's headers are kept by a
# declared filter, the kept lines counted beside the total; curl's -v lines are written to a file, then read, kept by a declared
# filter and counted beside the total. No duration is captured: bytes and connections only.
# Ports (brief ⚑1, 19590-19599): TiffinBox 19590-19596 (one JVM at a time, each port asserted free before each start), 19599 never
# bound (asserted free). Captures run one after another, each JVM stopped before the next starts - by POST /shutdown, its pid waited
# for. 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it (the C locale).
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, TiffinBox or a
# Maven build; $xpid, the exercise's shell, with every process under it), if they still run, then sweep(): anything of this run still
# alive in its process group - a TiffinBox JVM, an Unzip JVM, a Maven - is stopped. After an interrupt, a capture's unfinished runs
# (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and
# nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an interrupt (README.md,
# "Interrupted"). sweep() kills only processes of this run's own process group - start each run in a group of its own. No wait in this
# script is bare: each names its pid.
pid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "probe.web.Unzip") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
# desc PID: every process under PID (ps, by parent); killtree PID: PID and all of them, TERM
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; [ -z "$xpid" ] || killtree "$xpid"; [ -z "$pid" ] || killtree "$pid"; for p in "$pid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | sed -n 1p)"
JV=$(java -version 2>&1 | sed -n '1s/.*version "\([^"]*\)".*/\1/p')
echo "  (terminal only) the JDK is $JV - Boot's first line names it; the captures say Java <version>"
for t in python3 curl rsync lsof unzip javac jcmd mvn cmp md5 gunzip; do command -v $t > /dev/null || die "$t is needed"; done
# curl must speak HTTP/2 (nghttp2) and decode gzip (libz): its features line, read once (the version printed on the terminal only)
CV=$(curl -V); CF=$(printf '%s\n' "$CV" | sed -n 's/^Features: //p')
case " $CF " in *' HTTP2 '*) ;; *) die "this curl has no HTTP2 feature - h2c and together need it" ;; esac
case " $CF " in *' libz '*) ;; *) die "this curl has no libz feature - --compressed needs it" ;; esac
echo "  (terminal only) $(printf '%s\n' "$CV" | sed -n 1p | cut -d' ' -f1-2)"
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG, the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are
# removed first (a canary planted under every name first, and the run stops if one survives). (A SERVER_COMPRESSION_ENABLED of yours
# would switch compression on in every run here; a JAVA_TOOL_OPTIONS could set every JVM's locale.) Curl reads ~/.curlrc unless -q
# comes first - CURL_HOME is pointed at an empty folder instead, so no option of yours reaches a request.
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit28/after ] || die "anchor must be the link to ../c6-unit28/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into each copy's secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-web-performance-ok
[ ${#TOKEN} = 33 ] || die "the demo token must be 33 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/Unzip.java'
for f in harness/shutdown.sh harness/keys.py $HWS exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Unzip.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
[ "$(ls harness | paste -sd' ' -)" = 'keys.py probe shutdown.sh' ] || die "harness/ holds another file"
[ "$(ls exercise/solution | paste -sd' ' -)" = 'SOLUTION.md' ] && [ "$(ls exercise | paste -sd' ' -)" = 'README.md solution' ] || die "exercise/ holds another file"
cmp -s harness/shutdown.sh ../c6-unit18/harness/shutdown.sh || die "harness/shutdown.sh must be the filters lesson's, byte for byte"
cmp -s harness/keys.py ../c6-unit20/harness/keys.py || die "harness/keys.py must be the upload lesson's, byte for byte"
mkdir -p .harness; rm -rf .harness/curlhome; mkdir -p .harness/curlhome; export CURL_HOME="$PWD/.harness/curlhome"

# The ports, BEFORE anything is wiped
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19590 19591 19592 19593 19594 19595 19596 19597 19598 19599; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole ---------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
R_PLAIN=$(readme 'mvn -B package')
R_NATIVE=$(readme 'mvn -B -Pnative package')
R_RUN=$(readme "$J")
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_CSS=$(readme "curl -s -H 'Accept: text/html' http://127.0.0.1:18431/dashboard | grep -o '/css/[^\"]*'")
R_AOTR=$(readme "java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.threads.virtual.enabled=false --logging.level.kitchen=debug --logging.pattern.console='%thread %msg%n'")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
LIBD=.harness/anchor/tiffinbox-web/target/extracted/lib
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_AOTL=$(mine "java $JL -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \"$LIBD/*\" $HWS")
L_UNZIP=$(mine "java $JL -cp \"$LIBD/*:.harness/hc\" probe.web.Unzip http://127.0.0.1:18431/customers")
L_KEYC=$(mine "python3 harness/keys.py $LIBD/spring-boot-web-server-4.1.1.jar server.compression")
L_KEYH=$(mine "python3 harness/keys.py $LIBD/spring-boot-web-server-4.1.1.jar server.http2")
L_KEYA=$(mine "python3 harness/keys.py $LIBD/spring-boot-tomcat-4.1.1.jar server.tomcat.accesslog")
L_FETCH=$(mine "curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:18431/customers")
L_VER=$(mine "curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' http://127.0.0.1:18431/customers")
L_VERB=$(mine "curl -s -v -o /dev/null http://127.0.0.1:18431/customers 2> .harness/v.txt")
L_PAR=$(mine "curl -s -v -Z -H 'Accept: text/html' -o /dev/null -o /dev/null -w '%{http_version} ' http://127.0.0.1:18431/dashboard http://127.0.0.1:18431/css/tiffinbox.css 2> .harness/v.txt")
L_POST=$(mine "curl -s -o /dev/null -w '%{http_code}' -H 'Content-Type: application/json' --data '{\"name\":\"Guest1\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_JCMD=$(mine 'jcmd "$pid" VM.system_properties')
L_YAML=$(mine "grep -n -A1 'virtual threads too. Under Spring.s AOT step' anchor/tiffinbox-web/src/main/resources/application.yaml")
L_JAVAP=$(mine "javap -cp $LIBD/spring-web-7.0.9.jar -p org.springframework.http.client.JdkClientHttpRequestFactory 'org.springframework.http.client.JdkClientHttpRequest\$DecompressingBodyHandler'")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] || die "the pinned run line must be the anchor's run line with $JL after java, and nothing else"
[ "${L_AOTL/ -Dspring.aot.enabled=true / }" = "$L_RUNL" ] || die "the AOT run line must be the pinned run line with -Dspring.aot.enabled=true, and nothing else"
r=${R_AOTR%% --spring.threads.virtual.enabled=*}; [ "${r/"$P_"/$Q_}" = "$L_AOTL" ] || die "the AOT run line must be the anchor's AOT line, its locale pinned, without that line's three options"
[ "${L_JAVAC##* }" = "$HWS" ] || die "the harness's javac line must compile harness/probe/web/Unzip.java, and nothing else"
# off DIR 'README mvn LINE' PHASE: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, clean and without tests. dev() takes those things back out, and must give the README's line again.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'LINE' ['OPTIONS']: the line run from DIR, its port 18431 made PORT, OPTIONS after it
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; printf 'cd %s && %s%s\n' "$1" "$l" "${4:+ $4}"; }
# url 'curl LINE' PORT: the line, its port 18431 made PORT
url() { printf '%s\n' "${1//:18431\//:$2/}"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package); C_PREA=$(off .harness/prea "$R_NATIVE" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] && [ "$(dev "$C_PREA")" = "$R_NATIVE" ] || die "not the README's build lines with the offline changes: $C_PRE / $C_PREA"
[ "$(exe "$(at .harness/x 19590 "$L_RUNL")")" = "cd .harness/x && exec ${L_RUNL/18431/19590}" ] || die "at()/exe(): not the pinned run line"
# The two switches and the access log - every key spelled from Boot's own metadata (which prints them; a last check refuses any
# server.* option in this unit's files that the metadata does not declare, R.138)
CZ='--server.compression.enabled=true'
H2='--server.http2.enabled=true'
FL='--server.compression.min-response-size=128'
AL="--server.tomcat.basedir=../tomcat --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false '--server.tomcat.accesslog.pattern=%m %U %H %s upgrade:%{Upgrade}i accept-encoding:%{Accept-Encoding}i content-encoding:%{Content-Encoding}o'"
GZ="-H 'Accept-Encoding: gzip'"; HT="-H 'Accept: text/html'"
echo "  the commands: anchor/README.md gives the 7 lines this script runs or derives from; README.md the 15 this unit adds"

# ---- build: before the captures - the anchor built once, plain and with the profile native (on a fresh clone these fill
# ---- .m2-demo); what .m2-demo holds ---------------------------------------------------------------------------------------------
rm -rf .harness/pre .harness/prea .harness/anchor .harness/aot .harness/mine .harness/hc .harness/tomcat
# ghub LOG: GraalVM's native plugin fetched its metadata repository over http(s) - never allowed
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
ZIP="$M2/org/graalvm/buildtools/graalvm-reachability-metadata/1.1.8/graalvm-reachability-metadata-1.1.8-repository.zip"
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval) as a job of its own ($pid, so Ctrl-C reaches the trap), its log kept
# in LOG; Maven Central only if the offline build could not resolve something - and the line says which (offline: yes / no)
mbuild() { local how=yes ec=0 c=$1
  case $c in *' -Pnative '*) [ -f "$ZIP" ] || { c=${c/mvn -o -B /mvn -B }; how="no - GraalVM's metadata repository was not in .m2-demo, so the configured repository was asked for it (Maven Central unless your settings name a mirror)"; } ;; esac
  (eval "$c") > "$2" 2>&1 < /dev/null & pid=$!; wait "$pid" || ec=$?; pid=""
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so the configured repository was asked (Maven Central unless your settings name a mirror)"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & pid=$!; wait "$pid" || ec=$?; pid=""; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $3"; }
  if ghub "$2"; then die "$3: GraalVM's native plugin went over the network for its metadata repository"; fi
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the demo token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2"; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
rsync -a --exclude target --exclude secrets anchor/ .harness/pre/
rsync -a --exclude target --exclude secrets anchor/ .harness/prea/
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (the anchor)"
mbuild "$C_PREA" .harness/build-prea.log ".harness/prea (the anchor, the profile native)"
for a in org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar org/springframework/boot/spring-boot-maven-plugin/4.1.1/spring-boot-maven-plugin-4.1.1.jar; do
  [ -f "$M2/$a" ] || die "$a is not in .m2-demo after the first builds"; done
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first builds"
echo "  .m2-demo holds Boot's plugin, GraalVM's native plugin 1.1.8 and its metadata repository"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; LASTE=""
first() { grep -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//'; }
# start 'COMMAND': the folder it starts in must hold, in secrets/, the token's file and nothing else (a file in TiffinBox's config
# tree is a key, R.158) - listed first; its port must be free; then the command, printed and run as a job ($pid)
start() { local p d s; p=$(printf '%s\n' "$1" | sed -n 's/.*--tiffinbox\.port=\([0-9]*\).*/\1/p'); [ -n "$p" ] && [ "$(listeners "$p")" = 0 ] || die "port ${p:-?} is not free before a start"
  d=$(printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'); s=$(cd "$d/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$d/secrets holds more than the token's file ($s) - every file there is a key (R.158)"
  echo "  secrets/ before the start: $s - the token's file, and nothing else"
  echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
listening() { local a="" i=0
  while [ $i -lt 480 ]; do
    a=$(addrs "$1"); if [ -n "$2" ]; then case " $a " in *":$2 "*) break ;; esac; elif [ -n "$a" ]; then break; fi
    kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
# loc: this unit's jcmd line - the JVM's locale, read off its pid ($pid): user.language and user.country, as one locale
loc() { local o; o=$(jcmd "$pid" VM.system_properties 2> /dev/null) || o=""
  echo "  the JVM's locale, read off its pid (this unit's jcmd line): $(printf '%s\n' "$o" | sed -n 's/^user\.language=//p')_$(printf '%s\n' "$o" | sed -n 's/^user\.country=//p')"; }
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  case " $l " in *':8080 '*|*':35729 '*|*':19599 '*|*':18425 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729, 18425 or 19599 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; loc; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's readiness line,
# printed and run once
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  local r; r=$(url "$R_READY" "$1"); echo "\$ $r"; (eval "$r") 2>&1 < /dev/null | sed 's/^/  /'; }
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token $h times"; }
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
# settle [FILE]: the file (the run's log unless named) stops growing (the same length twice, 0.5 s apart; up to 15 s)
settle() { local i=0 a b=-1 f=${1:-.harness/run.out}; while [ $i -lt 30 ]; do a=$(wc -l < "$f" | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "$f never settled"; }
# logl FROM [LEVELS]: the run's lines after line FROM at those levels (WARN|ERROR unless named), from their level and logger on
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" 'NR > from && $0 ~ (" (" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); print "    " l " " lg ": " msg }' "${3:-.harness/run.out}"; }
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
WARNS() { settle; echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; logl 0; }
# exited PORT: after a POST /shutdown - the JVM must leave within 15 s, the port must be free; its exit code
exited() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
# seven PORT DIR NAME: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), every line
# printed, the timestamp masked; the log's WARN and ERROR records during them; POST /shutdown must answer 2xx, the JVM must leave; the
# md5 of the seven; the log counted (logtok) - the masked set kept as .harness/seven-NAME.txt
seven() { local m n0
  settle; n0=$(wc -l < .harness/run.out | tr -d ' ')
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  sed 's/^/  /' .harness/responses.m.txt
  grep -qE '^POST +/shutdown +-> 2[0-9][0-9] ' .harness/responses.txt || die "POST /shutdown did not answer 2xx in the seven on $1"
  exited "$1"
  echo "  the log's WARN and ERROR records during the seven: $(logl "$n0" | grep -c . || true)"; logl "$n0"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  cp .harness/responses.m.txt ".harness/seven-$3.txt"
  logtok; }
# halt PORT DIR: POST /shutdown with DIR's token - it must answer 2xx; the JVM must leave within 15 s and free the port; its exit
# code; its WARN and ERROR counts; its log counted (logtok)
halt() { local o c
  WARNS
  echo "\$ harness/shutdown.sh $1 $2/$TF"; o=$(harness/shutdown.sh "$1" "$2/$TF" | tsmask); echo "  $o"; c=$(printf '%s\n' "$o" | awk '{ print $4 }')
  case $c in 2[0-9][0-9]) exited "$1"; echo "  exit $LASTE · listening on $1 now: 0" ;; *) die "POST /shutdown answered $c on $1" ;; esac
  logtok; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~");
    gsub(/ using Java [0-9][0-9.]*/, " using Java <version>")
    gsub(/http-nio-127\.0\.0\.1-[0-9]+/, "http-nio-127.0.0.1-<port>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
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
    die "$nm is not the published capture - suspect another JDK, Boot, Maven or curl, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
pbuild() { local c; c=$(off "$1" "$2" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$3"; }
extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# fetch PORT ['CURL OPTIONS'] [PATH]: this unit's fetch line (README.md) - its port made PORT, OPTIONS before the URL, /customers made
# PATH - printed and run; then what curl wrote: its status and %{size_download} (the bytes that crossed the wire), the md5 of the
# bytes it saved; the answer's header lines, counted (the status line among them), kept by the declared filter
# ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case); and, for an answer that says Content-Encoding:
# gzip and was saved as it came (no --compressed), the saved bytes unzipped (gunzip -c): their count and their md5. The saved bytes
# are kept as .harness/f-N.bin (N counts the fetches of a run), for a comparison the capture prints
HF='^(content-type|content-encoding|content-length|transfer-encoding|vary): '
FN=0
fetch() { local c r; c=$(url "$L_FETCH" "$1"); [ -z "$3" ] || c="${c%/customers}$3"; [ -z "$2" ] || c=${c/ http:\/\/127/ $2 http://127}
  rm -f .harness/body.bin .harness/head.txt; echo "\$ $c"; r=$(eval "$c" 2>&1 < /dev/null) || true
  tr -d '\r' < .harness/head.txt | grep . > .harness/head.n.txt || true
  FN=$((FN + 1)); cp .harness/body.bin ".harness/f-$FN.bin" 2> /dev/null || : > ".harness/f-$FN.bin"
  echo "  -> $r · md5 $(md5 -q ".harness/f-$FN.bin") · its header lines: $(wc -l < .harness/head.n.txt | tr -d ' ') · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): $(grep -ciE "$HF" .harness/head.n.txt || true)"
  grep -iE "$HF" .harness/head.n.txt | sed 's/^/    /' || true
  case $2 in *--compressed*) ;; *) if grep -qix 'content-encoding: gzip' .harness/head.n.txt; then
    echo "  gunzip -c, the saved bytes: $(gunzip -c < ".harness/f-$FN.bin" | wc -c | tr -d ' ') bytes · md5 $(gunzip -c < ".harness/f-$FN.bin" | md5 -q)"; fi ;; esac; }
# same A B: yes when fetch A's bytes (unzipped when it says gzip and it is the second argument's "gunzip") equal fetch B's
md5f() { md5 -q ".harness/f-$1.bin"; }
md5g() { gunzip -c < ".harness/f-$1.bin" | md5 -q; }
# ver PORT ['CURL OPTIONS']: this unit's version line (README.md) - curl's status, the HTTP version it used (%{http_version}: 0 when
# no answer came) and the bytes; the md5 of the bytes it saved, or "nothing saved"; curl's exit code (an answer that never came may
# still exit 0, or not: a check reads %{http_version}, never the exit)
ver() { local c r e=0; c=$(url "$L_VER" "$1"); [ -z "$2" ] || c=${c/ http:\/\/127/ $2 http://127}
  rm -f .harness/body.bin; echo "\$ $c"; r=$(eval "$c" 2>&1 < /dev/null) || e=$?
  echo "  -> $r · $( [ -s .harness/body.bin ] && echo "md5 $(md5 -q .harness/body.bin)" || echo "nothing saved") · curl exit $e"; }
# verb PORT 'CURL OPTIONS': this unit's -v line (README.md) - curl's -v lines written to .harness/v.txt, then read: counted, and kept
# by the declared filter ^(> GET |> Connection: |> Upgrade: |> HTTP2-Settings: |< HTTP/|< connection: |< upgrade: |\* Received 101)
# (curl's own lines: > what it sent, < what it got, * what it says; any case)
VF='^(> get |> connection: |> upgrade: |> http2-settings: |< http/|< connection: |< upgrade: |\* received 101)'
verb() { local c e=0; c=$(url "$L_VERB" "$1"); c=${c/ -o \/dev\/null / $2 -o \/dev\/null }
  rm -f .harness/v.txt; echo "\$ $c"; (eval "$c") < /dev/null || e=$?
  tr -d '\r' < .harness/v.txt > .harness/v.n.txt
  echo "  curl exit $e · its -v lines: $(wc -l < .harness/v.n.txt | tr -d ' ') · kept, by ^(> GET |> Connection: |> Upgrade: |> HTTP2-Settings: |< HTTP/|< Connection: |< Upgrade: |\\* Received 101) (any case): $(grep -ciE "$VF" .harness/v.n.txt || true)"
  grep -iE "$VF" .harness/v.n.txt | sed 's/^/    /' || true; }
# par PORT 'MODE' CSS: this unit's parallel line (README.md) - the page and its stylesheet (CSS, the URL read off the page), at once
# (-Z), in MODE (--http1.1 or --http2-prior-knowledge, after -Z); %{http_version} per transfer; curl's -v lines written to
# .harness/v.txt, then read, kept by the declared filter ^\* (Connected to |Multiplexed connection found|Re-using existing
# connection|Server doesn't support multiplex) and counted, line by line (sort | uniq -c: parallel transfers write in either order)
PF="^\\* (Connected to |Multiplexed connection found|Re-using existing connection|Server doesn't support multiplex)"
par() { local c r e=0; c=$(url "$L_PAR" "$1"); c=${c/ -Z / -Z $2 }; c=${c/\/css\/tiffinbox.css/$3}
  rm -f .harness/v.txt; echo "\$ $c"; r=$(eval "$c" < /dev/null) || e=$?
  tr -d '\r' < .harness/v.txt > .harness/v.n.txt
  echo "  -> %{http_version} per transfer: $r· curl exit $e · its -v lines kept, by ^\\* (Connected to |Multiplexed connection found|Re-using existing connection|Server doesn't support multiplex), counted: $(grep -cE "$PF" .harness/v.n.txt || true)"
  grep -E "$PF" .harness/v.n.txt | sed -E 's/ \(127\.0\.0\.1\) port [0-9]+$/ (127.0.0.1) port <port>/' | sort | uniq -c | sed -E 's/^ *([0-9]+) /    \1 × /' || true
  echo "  connections curl opened (its \"Connected to\" lines): $(grep -c '^\* Connected to ' .harness/v.n.txt || true)"; }
# css PORT: the anchor's README line that reads the stylesheet's URL off the page - printed, run; the URL it gives
css() { local c; c=$(url "$R_CSS" "$1"); echo "\$ $c"; CSS=$(eval "$c" < /dev/null | sed -n 1p); echo "  the stylesheet's URL, read off the page: $CSS"; }
# unz PORT [PATH]: this unit's Unzip line (README.md) - the JDK's HttpClient and RestClient on the anchor's class path, /customers
# (or PATH); its UNZIP lines, whole; its other lines counted
unz() { local c e=0; c=$(url "$L_UNZIP" "$1"); [ -z "$2" ] || c="${c%/customers}$2"
  echo "\$ $c"; (eval "$c") > .harness/unz.out 2>&1 < /dev/null || e=$?
  grep -q '^UNZIP done$' .harness/unz.out || { cat .harness/unz.out >&3; die "Unzip never printed done"; }
  echo "  exit $e · its UNZIP lines: $(grep -c '^UNZIP ' .harness/unz.out) · its other lines: $(grep -vc '^UNZIP ' .harness/unz.out || true)"
  grep '^UNZIP ' .harness/unz.out | grep -v '^UNZIP done$' | sed 's/^UNZIP /    /'; }
# posts PORT N: this unit's POST line (README.md) N times, the name Guest1 ... GuestN - the first printed whole; every status, counted
posts() { local c i=1 s=""; c=$(url "$L_POST" "$1"); echo "\$ $c   (then the same with Guest2 ... Guest$2)"
  while [ $i -le "$2" ]; do s="$s $(eval "${c/Guest1/Guest$i}" < /dev/null)"; i=$((i + 1)); done
  echo "  their statuses: $(printf '%s\n' $s | sort | uniq -c | awk '{ printf "%s%s ×%s", (NR > 1 ? " · " : ""), $2, $1 }')"; }
# The access log - Tomcat's, a harness option of the runs that name it ($AL): .harness/tomcat/logs/access_log.log. amark: settled,
# its line count now (after readiness); alog FROM: its lines after FROM - each GET whole, the POSTs counted
ALF=.harness/tomcat/logs/access_log.log
amark() { [ -f "$ALF" ] || die "no access log at $ALF"; settle "$ALF"; wc -l < "$ALF" | tr -d ' '; }
alog() { settle "$ALF"; echo "  Tomcat's access log since the mark (after readiness) (the harness's pattern - the method, the path, the protocol, the status, the request's Upgrade and Accept-Encoding, the answer's Content-Encoding; - for none): $(awk -v f="$1" 'NR > f' "$ALF" | grep -c . || true) lines, $(awk -v f="$1" 'NR > f' "$ALF" | grep -c '^POST ' || true) of them POSTs (not shown)"
  awk -v f="$1" 'NR > f && !/^POST / { print "    " $0 }' "$ALF"; }
# The filters and the masks, checked on planted inputs before any capture (R.65, R.120): a header block, a -v file of each kind, an
# access log, a level-count log, Boot's first line, a connector name, and the token
mkdir -p .harness
{ printf '%s\n' '2026-10-22T00:00:00.000+02:00  WARN 1 --- [planted] o.s.web.servlet.PageNotFound             : planted warning' '2026-10-22T00:00:00.001+02:00 ERROR 1 --- [planted] o.s.boot.SpringApplication               : planted error' 'UNZIP a line that says ERROR'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(lvl ERROR .harness/run.out)" = 1 ] && [ "$(grep -c ' ERROR' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR' gives 2)"
printf 'HTTP/1.1 200 \r\nvary: accept-encoding\r\nContent-Encoding: gzip\r\nContent-Type: text/html;charset=UTF-8\r\nTransfer-Encoding: chunked\r\nDate: x\r\n\r\n' > .harness/head.txt; tr -d '\r' < .harness/head.txt | grep . > .harness/head.n.txt
[ "$(grep -ciE "$HF" .harness/head.n.txt)" = 4 ] && [ "$(wc -l < .harness/head.n.txt | tr -d ' ')" = 6 ] && grep -qix 'content-encoding: gzip' .harness/head.n.txt || die "fetch: the planted headers must give 6 lines, 4 kept (any case), gzip seen"
printf '%s\n' '* Connected to 127.0.0.1 (127.0.0.1) port 19590' '> GET /customers HTTP/1.1' '> Host: 127.0.0.1:19590' '> Connection: Upgrade, HTTP2-Settings' '> Upgrade: h2c' '< HTTP/1.1 101 ' '< Connection: Upgrade' '< Upgrade: h2c' '* Received 101, Switching to HTTP/2' '< HTTP/2 200 ' '< content-type: application/json' > .harness/v.n.txt
[ "$(grep -ciE "$VF" .harness/v.n.txt)" = 8 ] || die "verb: the planted -v lines must keep 8 of 11"
printf '%s\n' '* Connected to 127.0.0.1 (127.0.0.1) port 19592' '* Connected to 127.0.0.1 (127.0.0.1) port 19592' '* Multiplexed connection found' '* Re-using existing connection with host 127.0.0.1' "* Server doesn't support multiplex yet, wait" '* Request completely sent off' > .harness/v.n.txt
[ "$(grep -cE "$PF" .harness/v.n.txt)" = 5 ] && [ "$(grep -c '^\* Connected to ' .harness/v.n.txt)" = 2 ] || die "par: the planted -v lines must keep 5 of 6, 2 connections"
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'Tomcat initialized: http-nio-127.0.0.1-19590' "$TOKEN" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'Tomcat initialized: http-nio-127.0.0.1-<port>' '[masked: the 33-character token]')" ] || die "mask: the planted JDK version, connector name and token must be masked"
printf '%s\n' '[INFO] Downloaded GraalVM reachability metadata repository from https://github.com/oracle/graalvm-reachability-metadata/releases/download/x.zip' > .harness/p2; ghub .harness/p2 || die "ghub: the planted http(s) fetch line must be seen"
printf '%s\n' '[INFO] Downloaded GraalVM reachability metadata repository from file:/x.zip' > .harness/p2; ! ghub .harness/p2 || die "ghub: a file: URL is no fetch"; rm -f .harness/p2
rm -f .harness/run.out .harness/p1 .harness/head.txt .harness/head.n.txt .harness/v.n.txt
echo "  the filters: the level counts, the header filter, the two -v filters, the GraalVM-fetch guard and the masks print their planted inputs as declared"

# ==== CAPTURES BEGIN ==============================================================================================================
# answers PORT: the five answers this unit measures, each asked twice - as curl asks (no Accept-Encoding) and with gzip asked: the
# page and the form page (Accept: text/html), the customers' list, the stylesheet (its URL read off the page), health
answers() { css "$1"
  echo "  the page - /dashboard, Accept: text/html:"; fetch "$1" "$HT" /dashboard; fetch "$1" "$HT $GZ" /dashboard
  echo "  the form page - /customers/new, Accept: text/html:"; fetch "$1" "$HT" /customers/new; fetch "$1" "$HT $GZ" /customers/new
  echo "  the customers' list - /customers:"; fetch "$1"; fetch "$1" "$GZ"
  echo "  the stylesheet:"; fetch "$1" "" "$CSS"; fetch "$1" "$GZ" "$CSS"
  echo "  health - /actuator/health:"; fetch "$1" "" /actuator/health; fetch "$1" "$GZ" /actuator/health; }
# ---- which: which answers shrink - Boot's keys from its metadata; the seven; the key off, the key on ---------------------------
which() { local j n
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):"
  copy anchor .harness/anchor; pbuild .harness/anchor "$R_PLAIN" "the anchor"; extract .harness/anchor
  echo "  the anchor's libraries (its extracted lib/): $(ls "$LIBD" | grep -c '\.jar$') · httpclient5, Jetty's or Reactor Netty's client among them: $(ls "$LIBD" | grep -cE '^(httpclient5|jetty-client|reactor-netty)' || true)"
  echo "Boot's keys - what spring-boot-web-server's own metadata declares under server.compression and server.http2 (this unit's lines):"
  echo "\$ $L_KEYC"; (eval "$L_KEYC") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  the default of server.compression.mime-types, entry by entry: $(python3 -c 'import json,sys,zipfile; m=json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json")); d=[p["defaultValue"] for p in m["properties"] if p["name"]=="server.compression.mime-types"][0]; print(str(len(d)) + " types - " + " · ".join(d))' "$LIBD/spring-boot-web-server-4.1.1.jar")"
  echo "\$ $L_KEYH"; (eval "$L_KEYH") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  the jars on the class path whose metadata declares server.compression.enabled: $(for j in "$LIBD"/*.jar; do unzip -p "$j" META-INF/spring-configuration-metadata.json 2> /dev/null | grep -qF '"server.compression.enabled"' && echo "${j##*/}"; done | paste -sd' ' -)"
  echo "the access log's keys - what spring-boot-tomcat's metadata declares under server.tomcat.accesslog (this unit's line; the harness's option for decode and h2c):"
  echo "\$ $L_KEYA"; (eval "$L_KEYA") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  server.tomcat.basedir in that metadata: $(unzip -p "$LIBD/spring-boot-tomcat-4.1.1.jar" META-INF/spring-configuration-metadata.json | grep -cF '"name": "server.tomcat.basedir"')"
  echo "the harness, compiled against the anchor's own jars (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jars"; }
  echo "  exit 0 · what javac printed: $(wc -l < .harness/javac.log | tr -d ' ') lines · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "  19599, never bound: listening $(listeners 19599) (lsof, by port)"
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19590, a fresh JVM:"
  start "$(at .harness/anchor 19590 "$L_RUNL")"; up 19590; ready 19590; seven 19590 .harness/anchor base
  echo "the key off - the README's run line, port 19591, a fresh JVM:"
  start "$(at .harness/anchor 19591 "$L_RUNL")"; up 19591; ready 19591; answers 19591; halt 19591 .harness/anchor
  echo "the key on - the README's run line and $CZ, port 19592, a fresh JVM - then the seven:"
  start "$(at .harness/anchor 19592 "$L_RUNL" "$CZ")"; up 19592; ready 19592; answers 19592; WARNS; seven 19592 .harness/anchor on; }
# ---- switch: A the key on, B no key, A' = A - the page, plain and gzip asked ---------------------------------------------------
sw() { local a b; start "$(at .harness/anchor "$1" "$L_RUNL" "$2")"; up "$1"; ready "$1"
  fetch "$1" "$HT" /dashboard; a=$FN; fetch "$1" "$HT $GZ" /dashboard; b=$FN
  if grep -qix 'content-encoding: gzip' .harness/head.n.txt; then echo "  the unzipped page against the plain one, md5 for md5: $( [ "$(md5g $b)" = "$(md5f $a)" ] && echo the same || echo they differ)"
  else echo "  no Content-Encoding: the bytes with gzip asked against the plain ones, md5 for md5: $( [ "$(md5f $b)" = "$(md5f $a)" ] && echo the same || echo they differ)"; fi
  halt "$1" .harness/anchor; }
switch() {
  echo "A - the key on: the README's run line and $CZ, port 19590, a fresh JVM:"; sw 19590 "$CZ"
  echo "B - no key: the README's run line alone, port 19591, a fresh JVM:"; sw 19591 ""
  echo "A' - A again, port 19590, a fresh JVM:"; sw 19590 "$CZ"
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"; }
# ---- floor: one list, under the floor and past it ---------------------------------------------------------------------------------
floor() { local k a b g1=""
  echo "the floor - the key on, port 19590, a fresh JVM (it is POSTed to: no other capture's JVM):"
  start "$(at .harness/anchor 19590 "$L_RUNL" "$CZ")"; up 19590; ready 19590
  echo "  the floor in force: server.compression.min-response-size $(printf '%s\n' "$(at .harness/anchor 19590 "$L_RUNL" "$CZ")" | grep -q 'min-response-size' && echo "on the run line" || echo "not on the run line - Boot's default, from its metadata (which)")"
  echo "  the list as TiffinBox starts, gzip asked:"; fetch 19590 "$GZ"
  echo "  grown - thirty customers added:"; posts 19590 30
  for k in 1 2 3; do echo "  round $k - plain, then gzip asked:"; fetch 19590; a=$FN; fetch 19590 "$GZ"; b=$FN
    echo "  round $k: the unzipped list against the plain one, md5 for md5: $( [ "$(md5g $b)" = "$(md5f $a)" ] && echo the same || echo they differ)"
    [ -n "$g1" ] || g1=$(md5f $b); echo "  round $k: the gzip bytes against round 1's, md5 for md5: $( [ "$(md5f $b)" = "$g1" ] && echo the same || echo they differ)"; done
  halt 19590 .harness/anchor; }
# ---- decode: who unzips - curl --compressed, the JDK's HttpClient, RestClient; the access log of the same requests -----------------
decode() { local m p g c
  echo "who unzips - the key on, Tomcat's access log on (the harness's options), port 19591, a fresh JVM, the list grown past the floor:"
  rm -rf .harness/tomcat; start "$(at .harness/anchor 19591 "$L_RUNL" "$CZ $AL")"; up 19591; ready 19591
  m=$(amark); posts 19591 30
  echo "  curl, plain:"; fetch 19591; p=$FN
  echo "  curl, gzip asked by hand:"; fetch 19591 "$GZ"; g=$FN
  echo "  curl --compressed (it asks, and unzips what it saves):"; fetch 19591 "--compressed"; c=$FN
  echo "  curl --compressed's saved bytes against the plain list, md5 for md5: $( [ "$(md5f $c)" = "$(md5f $p)" ] && echo the same || echo they differ) · against the gzip bytes: $( [ "$(md5f $c)" = "$(md5f $g)" ] && echo the same || echo they differ)"
  echo "  the md5s to compare the clients' lines with - the plain list: $(md5f $p) · the gzip bytes: $(md5f $g)"
  echo "  the JDK's HttpClient and Spring's RestClient - the harness's Unzip, on the anchor's class path (this unit's line):"; unz 19591
  alog "$m"; halt 19591 .harness/anchor
  # who unzips for RestClient: the owner read off the jar (R.134, RED S6 #510) - spring-web's JDK request factory and its body handler
  echo "  who unzips for RestClient - read off spring-web's jar (this unit's javap line), kept by the declared filter 'class |ompression|decompress':"
  echo "\$ $L_JAVAP"; (eval "$L_JAVAP") > .harness/javap.txt 2>&1 < /dev/null || { cat .harness/javap.txt >&3; die "javap could not read spring-web's jar"; }
  echo "  javap's lines: $(grep -c . .harness/javap.txt) · kept: $(grep -cE 'class |ompression|decompress' .harness/javap.txt)"
  grep -E 'class |ompression|decompress' .harness/javap.txt | sed 's/^ *//; s/^/    /'; }
# ---- h2c: HTTP/2 without TLS - A the key on, B the key off, A' = A ------------------------------------------------------------------
hrun() { local m; rm -rf .harness/tomcat; start "$(at .harness/anchor "$1" "$L_RUNL" "$2")"; up "$1"; ready "$1"; m=$(amark)
  verb "$1" --http2; ver "$1"; ver "$1" --http2; ver "$1" --http2-prior-knowledge; unz "$1"; alog "$m"; halt "$1" .harness/anchor; }
h2c() {
  echo "A - HTTP/2 on: the README's run line, $H2 and the access log (the harness's options), port 19590, a fresh JVM:"; hrun 19590 "$H2 $AL"
  echo "B - the key off: the README's run line and the access log, port 19591, a fresh JVM:"; hrun 19591 "$AL"
  echo "A' - A again, port 19590, a fresh JVM:"; hrun 19590 "$H2 $AL"
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"; }
# ---- together: the page and its stylesheet at once - connections counted off curl's lines ------------------------------------------
together() {
  echo "the page and its stylesheet at once - HTTP/2 on, port 19592, a fresh JVM; curl -Z (at once), without --parallel-immediate:"
  start "$(at .harness/anchor 19592 "$L_RUNL" "$H2")"; up 19592; ready 19592; css 19592
  echo "  HTTP/1.1:"; par 19592 --http1.1 "$CSS"
  echo "  HTTP/2:"; par 19592 --http2-prior-knowledge "$CSS"
  halt 19592 .harness/anchor; }
# ---- aot: C (labelled) - the anchor's AOT jar, built on a copy; the two switches on its run line, then none -------------------------
arun() { start "$(at .harness/aot "$1" "$L_AOTL" "$2")"; up "$1"; ready "$1"
  echo "  Boot's AOT line in its log: $(grep -c 'Starting AOT-processed ' .harness/run.out || true)"
  fetch "$1" "$HT" /dashboard; fetch "$1" "$HT $GZ" /dashboard; ver "$1" --http2-prior-knowledge; halt "$1" .harness/aot; }
aot() { local n0 n1
  echo "C (labelled) - ahead of time: the anchor copied to .harness/aot, a config tree, built with its README's native line (offline, -DskipTests: the copy's tests are the web-layer testing lesson's, and this build is the AOT jar's):"
  copy anchor .harness/aot; n0=$(find "$M2" -type f | wc -l | tr -d ' ')
  pbuild .harness/aot "$R_NATIVE" "the AOT jar (.harness/aot)"; n1=$(find "$M2" -type f | wc -l | tr -d ' ')
  echo "  files .m2-demo gained: $((n1 - n0)) · Spring's AOT step ran (process-aot): $(grep -c 'spring-boot:4.1.1:process-aot (process-aot)' .harness/aot.build.log) · GraalVM's metadata repository read from a file: URL: $(grep -c 'Downloaded GraalVM reachability metadata repository from file:' .harness/aot.build.log) · from http(s): 0"
  echo "  the generated bean definitions in the jar (BOOT-INF/classes, *__BeanDefinitions.class): $(unzip -l .harness/aot/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | grep -c '__BeanDefinitions\.class$')"
  echo "under Spring's AOT step, the anchor's own application.yaml says, threading is fixed when the jar is built (this unit's line):"
  echo "\$ $L_YAML"; (eval "$L_YAML") 2>&1 < /dev/null | sed 's/^ *//; s/^/  /'
  echo "the AOT jar with the two switches - this unit's AOT line, $CZ $H2, port 19593, a fresh JVM:"; arun 19593 "$CZ $H2"
  echo "the AOT jar with neither - this unit's AOT line, port 19594, a fresh JVM:"; arun 19594 ""; }
# ---- exercise ---------------------------------------------------------------------------------------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
VX="V=($CZ)"
VS="V=($CZ $FL)"
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2 tk
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 5 ] || die "SOLUTION.md's first bash block must be the README's two export lines, its S= line, the solution's V= line and the README's last line"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$sol" | sed -n 3p)" = "$(printf '%s\n' "$setup" | grep '^S=')" ] || die "SOLUTION.md's third line must be the README's S= line"
  printf '%s\n' "$sol" | sed -n 4p | grep -qxF -- "$VS" || die "SOLUTION.md's fourth line must lower the floor: $VS"
  printf '%s\n' "$setup" | grep -qxF -- "$VX" || die "exercise/README.md must ship the key alone: $VX"
  ! printf '%s\n' "$setup" | grep -qF 'min-response-size' || die "exercise/README.md must not name the floor's key: it is the exercise"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 5p)
  [ "$l1" = "$l2" ] || die "SOLUTION.md's last line must be the README's last line, unchanged: the fix is the key, not the command"
  rm -f .harness/ex-* .harness/exz-*
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/$2readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/$2readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/$2readme.log" 2> /dev/null
. "$1/.harness/ex-sol.sh" > "$1/.harness/$2sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/$2sol.st"
DRV
  # the same driver twice: /bin/bash, then /bin/zsh -f (the Mac's Terminal shell, which never splits an unquoted variable - RED S6 #527)
  env -i HOME="$HOME" PATH="$XPATH" CURL_HOME="$CURL_HOME" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" ex- > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$!
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's shell still ran after 600 s"; }
  wait "$xpid" || true; xpid=""
  cp .harness/mine/run.log .harness/ex-sol.log 2> /dev/null; i=0
  tk=$(head -1 .harness/mine/anchor/$TF 2> /dev/null)
  env -i HOME="$HOME" PATH="$XPATH" CURL_HOME="$CURL_HOME" /bin/zsh -f .harness/ex-drive.sh "$U" exz- > .harness/exz-shell.out 2>&1 < /dev/null & xpid=$!
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's zsh shell still ran after 600 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/exz-readme.st ] && [ -f .harness/exz-sol.st ] || { cat .harness/exz-shell.out .harness/exz-readme.out .harness/exz-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's zsh shell did not reach the end of both blocks"; }
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's shell did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  [ "$e1" = 0 ] || { tail -20 .harness/ex-readme.out >&3; die "the exercise's commands failed: exit $e1"; }
  [ "$e2" = 0 ] || { tail -20 .harness/ex-sol.out >&3; die "the solution's lines failed: exit $e2"; }
  echo "exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:"
  echo "the README's $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "  exit $e1 · what they printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$tk" .harness/ex-readme.log) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19596 now: $(listeners 19596)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$tk" .harness/ex-sol.log) times · WARN lines in its log: $(lvl WARN .harness/ex-sol.log) · ERROR lines: $(lvl ERROR .harness/ex-sol.log) · listening on 19596 now: $(listeners 19596)"
  read -r e1 d1 < .harness/exz-readme.st; read -r e2 d2 < .harness/exz-sol.st; tz=$(head -1 .harness/mine/anchor/$TF)
  echo "the same two blocks again, in ONE new shell - env -i, /bin/zsh -f (zsh, the Mac's Terminal shell; it never splits an unquoted variable):"
  echo "  the README's lines: exit $e1 · what they printed:"; sed 's/^/    /' .harness/exz-readme.out
  echo "  the solution's lines: exit $e2 · what they printed:"; sed 's/^/    /' .harness/exz-sol.out
  echo "  the shell is now in: $(where "$d2") · its copy's own token in its log: $(raw "$tz" .harness/mine/run.log) times · listening on 19596 now: $(listeners 19596)"; }

cap which which
cap switch switch
cap floor floor
cap decode decode
cap h2c h2c
cap together together
cap aot aot
cap exercise exercise
# ==== CAPTURES END ================================================================================================================
echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
blk() { A="$2" B="$3" awk 'index($0, ENVIRON["A"]) == 1 { f = 1; next } ENVIRON["B"] != "" && index($0, ENVIRON["B"]) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: did not expect the line: $2"; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (logtok()), nor
# anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
SHIP="README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/keys.py $HWS"
for f in .r-*.out $SHIP; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! grep -E 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" | grep -vxF '  $ S="$PWD/harness/shutdown.sh"' > /dev/null || die "$f holds a unit number"
  ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"
  ! grep -qE ' using Java [0-9]' "$f" || die "$f holds the JDK's version (R.151)"
  ! grep -qE 'http-nio-127\.0\.0\.1-[0-9]' "$f" || die "$f holds a connector name with its port (S6.22)"
  ! grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T' "$f" || die "$f holds a log line with its time"
  ! grep -qiE '^ *(< )?date: ' "$f" || die "$f holds a Date header"
  ! grep -qF "$(printf '\r')" "$f" || die "$f holds a carriage return"
  ! grep -qE '"timestamp":"[0-9]' "$f" || die "$f holds an unmasked timestamp"
  ! grep -qE '[0-9] ?(ms|milliseconds?|seconds?)\b|\b(faster|slower|latency)\b' "$f" || die "$f holds a duration (⚑10: bytes and connections only)"
  ! grep -qE 'https://|server\.ssl|keytool' "$f" || die "$f holds a TLS line - this unit runs no TLS (⚑3)"
  ! grep -qE ':8080|:35729|:18425/' "$f" || die "$f names 8080, 35729 or 18425"; done
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
for f in $HWS exercise/README.md exercise/solution/SOLUTION.md; do ! grep -qE 'https?://localhost|localhost:' "$f" || die "$f names localhost - every URL is 127.0.0.1's (R.82)"; done
# R.105: no wait is bare - each names its pid; R.79: nothing is stopped by name
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (R.105)"; done
PK='p''kill|kill''all'
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md README.md; do ! grep -nE "\\b($PK)\\b" "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f stops a process by name"; done
# R.96 / S6.8: no running step piped into head; curl -v always writes to a file first
! grep -nE '(eval|java |mvn |curl ).*\| *head' receipts.sh | grep -vE '^[0-9]+: *#' > /dev/null || die "receipts.sh pipes a running step into head (R.96)"
CB=$(awk '/^## The commands this unit adds/ { f = 1; next } f && /^## / { f = 0 } f' README.md)
[ "$(printf '%s\n' "$CB" | grep -c -- '^curl -s -v ')" = 2 ] && ! grep -hE -- '^(\$ )?curl -s -v ' README.md .r-*.out | grep -v ' 2> \.harness/v\.txt$' > /dev/null || die "every curl -v line writes its lines to .harness/v.txt (S6.8)"
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# R.138: every server.* key this unit's files name is one Boot's own metadata declares (spring-boot-web-server's and
# spring-boot-tomcat's, read off the anchor's jars) - a key spelled any other way is refused
for j in spring-boot-web-server-4.1.1.jar spring-boot-tomcat-4.1.1.jar; do unzip -p "$LIBD/$j" META-INF/spring-configuration-metadata.json; done | python3 -c 'import json,sys; t=sys.stdin.read(); d=json.JSONDecoder(); i=0; out=[]
while i < len(t):
    t2=t[i:].lstrip(); 
    if not t2: break
    o,n=d.raw_decode(t2); i=len(t)-len(t2)+n; out+= [p["name"] for p in o.get("properties",[])]
print("\n".join(sorted(set(out))))' > .harness/server-keys.txt
[ "$(grep -c '^server\.' .harness/server-keys.txt)" -gt 50 ] || die "R.138: the metadata's server.* keys could not be read"
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do
  for k in $(grep -oE -- '--server\.[a-z0-9.-]+[a-z0-9]' "$f" | sed 's/^--//' | sort -u); do grep -qxF "$k" .harness/server-keys.txt || die "$f names --$k, a key Boot's metadata does not declare (R.138)"; done
  for k in $(grep -oE 'server\.(compression|http2)\.[a-z0-9-]+[a-z0-9]' "$f" | sort -u); do grep -qxF "$k" .harness/server-keys.txt || die "$f names $k, a key Boot's metadata does not declare (R.138)"; done; done
# S6.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes)
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
for f in exercise/README.md exercise/solution/SOLUTION.md; do ! grep -oE '\{ java [^>]*' "$f" | grep -vF -- "{ java $JL " > /dev/null || die "$f: the exercise's java lines must pin the JVM's locale (S6.1)"; done
for f in .r-*.out; do ! grep -E "^  the JVM's locale, read off its pid|^    the JVM's locale: " "$f" | grep -vE ': en_US$' > /dev/null || die "$f: a JVM's locale is not en_US (S6.1)"; done
# R.158 / S6.29: before every start, secrets/ held the token's file alone - once per start, in every capture that starts TiffinBox
for f in .r-*.out; do [ "$(grep -c '^  secrets/ before the start: tiffinbox/shutdown-token - the token.s file, and nothing else$' "$f")" = "$(grep -E '^\$ cd \.harness/(anchor|aot) && java ' "$f" | grep -vc -- ' -Djarmode=tools ')" ] || die "$f: a start without its secrets/ listing (R.158)"; done
# R.114: no harness class reaches the anchor
for c in Unzip probe.web; do ! grep -rqwF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c"; done
# S2.16: the harness compiles with -parameters; R.135: the client sentence's class path - no other HTTP client library
[ "$(grep -c '^javac -parameters ' README.md)" = 1 ] || die "the harness must compile with -parameters (S2.16)"
[ -z "$(ls "$LIBD" | grep -E '^(httpclient5|jetty-client|reactor-netty)' || true)" ] || die "another HTTP client is on the class path - RestClient's factory would change (R.135)"
# R.115: no browser is used here
! grep -qi 'browser' $HWS exercise/solution/SOLUTION.md && [ "$(grep -oi 'browser' exercise/README.md | wc -l | tr -d ' ')" = 1 ] && grep -i 'browser' exercise/README.md | grep -qF 'no browser are needed' || die "a browser is named (R.115) - none is used"
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that ran ($LOGS here; the published captures' $NL) and in every file this unit ships; no absolute path, unit number, process line, JDK version, connector port, log time, Date header, duration or TLS line in any capture; every key from Boot's metadata (R.138)"

S466='466c20ed7e0d5439cb052f32ce09de1b'
LOC="  the JVM's locale, read off its pid (this unit's jcmd line): en_US"
SECR="  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else"
Z2="  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0"
FQ="\$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}'"
KEPT="its header lines"
P962='94eb3463816e1a310cbc1827ed825692'; G477='9f593240fa15ea6cef5fffe7f2f4f253'; L282='09cb28cd6fa1ad8b8fe4870ec8bbf0d0'
# line PREFIX: the line after the line that is exactly PREFIX (a $ line) in block B - the answer curl gave it
after() { printf '%s\n' "$1" | awk -v q="$2" 'f { print; exit } $0 == q { f = 1 }'; }
# kept B Q: the kept header lines under the $ line Q in block B (the lines after its "->" line that start with four spaces)
kept() { printf '%s\n' "$1" | awk -v q="$2" 'f == 2 && /^    / { print; next } f == 2 { exit } f == 1 { f = 2; next } $0 == q { f = 1 }'; }
size() { after "$1" "$2" | sed -n 's/^  -> [0-9]* \([0-9]*\) · .*/\1/p'; }

# "Boot's metadata: off by default, a floor of 2KB, eight types ... the page about half, the list and the stylesheet the same" - which
WO=$(cat .r-which.out); WOFF=$(blk which "the key off - " "the key on - "); WON=$(blk which "the key on - " "")
has "$WO" '  built the anchor · offline: yes · exit 0' "which: the anchor built offline"
has "$WO" "  the anchor's libraries (its extracted lib/): 61 · httpclient5, Jetty's or Reactor Netty's client among them: 0" "which: 61 libraries, no other client"
has "$WO" '  server.compression.enabled · default false · Boolean' "which: the switch is off by default"
has "$WO" '  server.compression.min-response-size · default 2KB · DataSize' "which: the floor, 2KB"
has "$WO" '  5 keys under server.compression' "which: five compression keys"
has "$WO" '  the default of server.compression.mime-types, entry by entry: 8 types - text/html · text/xml · text/plain · text/css · text/javascript · application/javascript · application/json · application/xml' "which: the eight types, counted"
has "$WO" '  server.http2.enabled · default false · Boolean' "which: HTTP/2 off by default"
has "$WO" '  the jars on the class path whose metadata declares server.compression.enabled: spring-boot-web-server-4.1.1.jar' "which: the owner, spring-boot-web-server (S6.17)"
for k in enabled rotate buffered pattern; do printf '%s\n' "$WO" | grep -qE "^  server\\.tomcat\\.accesslog\\.$k · default " || die "which: the access log key $k"; done
has "$WO" '  server.tomcat.basedir in that metadata: 1' "which: the basedir key"
has "$WO" '  exit 0 · what javac printed: 0 lines · its classes: probe/web/Unzip.class' "which: the harness compiled"
has "$WO" '  19599, never bound: listening 0 (lsof, by port)' "which: 19599 free"
[ "$(cnt "$WO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466")" = 2 ] || die "which: the seven $S466, on the README's run line and with the key on"
[ "$(cnt "$WO" "$LOC")" = 3 ] && [ "$(cnt "$WO" "  listens on: 127.0.0.1:19590 · loopback only: yes")" = 1 ] || die "which: three JVMs, en_US, loopback"
# the five answers, key off then key on: QP the page, QF the form page, QL the list, QS the stylesheet, QH health
CSSU=$(printf '%s\n' "$WO" | sed -n "s/^  the stylesheet's URL, read off the page: //p" | sort -u)
[ "$(printf '%s\n' "$CSSU" | grep -c .)" = 1 ] && case $CSSU in /css/tiffinbox-[0-9a-f]*.css) ;; *) false ;; esac || die "which: the stylesheet's URL, read off the page, one URL ($CSSU)"
for B in OFF ON; do p=19591; [ $B = ON ] && p=19592; eval "b=\$W$B"
  QP="$FQ -H 'Accept: text/html' http://127.0.0.1:$p/dashboard"; QPG="$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:$p/dashboard"
  QF="$FQ -H 'Accept: text/html' http://127.0.0.1:$p/customers/new"; QFG="$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:$p/customers/new"
  QL="$FQ http://127.0.0.1:$p/customers"; QLG="$FQ -H 'Accept-Encoding: gzip' http://127.0.0.1:$p/customers"
  QS="$FQ http://127.0.0.1:$p$CSSU"; QSG="$FQ -H 'Accept-Encoding: gzip' http://127.0.0.1:$p$CSSU"
  QH="$FQ http://127.0.0.1:$p/actuator/health"; QHG="$FQ -H 'Accept-Encoding: gzip' http://127.0.0.1:$p/actuator/health"
  for q in "$QP" "$QPG" "$QF" "$QFG" "$QL" "$QLG" "$QS" "$QSG" "$QH" "$QHG"; do has "$b" "$q" "which $B: the request $q"; done
  [ "$(size "$b" "$QP")" = 962 ] && [ "$(size "$b" "$QF")" = 839 ] && [ "$(size "$b" "$QL")" = 282 ] && [ "$(size "$b" "$QS")" = 200 ] && [ "$(size "$b" "$QH")" = 49 ] || die "which $B: the plain sizes 962 839 282 200 49"
  [ "$(size "$b" "$QLG")" = 282 ] && [ "$(size "$b" "$QSG")" = 200 ] && [ "$(size "$b" "$QHG")" = 49 ] || die "which $B: the list, the stylesheet and health the same with gzip asked"
  kept "$b" "$QLG" | grep -qxF '    Content-Length: 282' && ! kept "$b" "$QLG" | grep -qi 'content-encoding' || die "which $B: the list keeps its Content-Length: 282, no Content-Encoding (R.157)"
  kept "$b" "$QSG" | grep -qxF '    Content-Length: 200' && ! kept "$b" "$QSG" | grep -qi 'content-encoding' || die "which $B: the stylesheet keeps its Content-Length: 200, no Content-Encoding"
  ! kept "$b" "$QHG" | grep -qi 'content-encoding' && kept "$b" "$QHG" | grep -qxF '    Content-Type: application/vnd.spring-boot.actuator.v3+json' || die "which $B: health not compressed, its type not on the list"
  kept "$b" "$QHG" | grep -qxF '    Transfer-Encoding: chunked' && ! kept "$b" "$QHG" | grep -qi '^    content-length' || die "which $B: health is a chunked answer with no Content-Length - so the 2KB floor never judged it, and its type is the one reason it stays 49 (RED S6 #529)"
  kept "$b" "$QP" | grep -qxF '    Transfer-Encoding: chunked' && kept "$b" "$QF" | grep -qxF '    Transfer-Encoding: chunked' || die "which $B: the two pages are chunked answers - no Content-Length"
  ! kept "$b" "$QP" | grep -qi '^    content-length' || die "which $B: the page has no Content-Length"; done
QPG1="$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/dashboard"; QFG1="$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/customers/new"
QPG2="$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19592/dashboard"; QFG2="$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19592/customers/new"
[ "$(size "$WOFF" "$QPG1")" = 962 ] && [ "$(size "$WOFF" "$QFG1")" = 839 ] && ! printf '%s\n' "$WOFF" | grep -qi '^    content-encoding' && ! printf '%s\n' "$WOFF" | grep -qi '^    vary' || die "which: the key off - gzip asked, nothing compressed, no Vary"
[ "$(size "$WON" "$QPG2")" = 477 ] && [ "$(size "$WON" "$QFG2")" = 435 ] || die "which: the key on - the page 477, the form page 435"
for q in "$QPG2" "$QFG2"; do kept "$WON" "$q" | grep -qxF '    Content-Encoding: gzip' && kept "$WON" "$q" | grep -qxF '    Transfer-Encoding: chunked' && kept "$WON" "$q" | grep -qxF '    vary: accept-encoding' || die "which ON: $q - Content-Encoding: gzip beside Transfer-Encoding: chunked, vary (R.157)"; done
[ "$(printf '%s\n' "$WON" | grep -c '^    Content-Encoding: gzip$')" = 2 ] || die "which ON: two answers compressed - the two pages"
has "$WON" "  gunzip -c, the saved bytes: 962 bytes · md5 $P962" "which ON: the page unzipped = the plain page"
has "$WON" "  gunzip -c, the saved bytes: 839 bytes · md5 87df349ae83a86f946fe185e5931153f" "which ON: the form page unzipped = the plain form page"
[ "$(after "$WON" "$QPG2" | sed -n 's/.* · md5 \([0-9a-f]*\) · .*/\1/p')" = "$G477" ] || die "which ON: the page's gzip bytes"
[ "$(printf '%s\n' "$WON" | grep -ci '^    vary: accept-encoding$')" = 4 ] || die "which ON: vary on the four page answers, plain and gzip, and on no other"
echo "  which: off by default, floor 2KB, 8 types (spring-boot-web-server's metadata); key off: nothing compressed; key on: the page 962 -> 477, the form page 839 -> 435 (gzip, chunked, vary), the list 282 -> 282 (Content-Length: 282), the stylesheet 200 -> 200, health 49 -> 49 (its type not on the list); the seven $S466 both ways"

# "A: 477 gzip, unzipped = plain; B: 962, no Content-Encoding, gzip asked all the same; A' = A" - switch
TA=$(blk switch "A - " "B - "); TB=$(blk switch "B - " "A' - "); TA2=$(blk switch "A' - " "A' against A")
for b in "$TA" "$TA2"; do has "$b" "\$ cd .harness/anchor && ${L_RUNL/18431/19590} $CZ" "switch A: its \$ line (S6.2)"
  [ "$(size "$b" "$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19590/dashboard")" = 477 ] && [ "$(size "$b" "$FQ -H 'Accept: text/html' http://127.0.0.1:19590/dashboard")" = 962 ] || die "switch A: 962 plain, 477 gzip"
  has "$b" "    Content-Encoding: gzip" "switch A: Content-Encoding: gzip"; has "$b" "  gunzip -c, the saved bytes: 962 bytes · md5 $P962" "switch A: unzipped = plain, by md5"
  has "$b" "  the unzipped page against the plain one, md5 for md5: the same" "switch A: the comparison"; has "$b" "$LOC" "switch A: en_US"; has "$b" "$Z2" "switch A: 0/0"; done
has "$TB" "\$ cd .harness/anchor && ${L_RUNL/18431/19591}" "switch B: its \$ line, no key"
[ "$(size "$TB" "$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/dashboard")" = 962 ] || die "switch B: gzip asked, 962"
! printf '%s\n' "$TB" | grep -qi '^    content-encoding' || die "switch B: no Content-Encoding"
has "$TB" "  no Content-Encoding: the bytes with gzip asked against the plain ones, md5 for md5: the same" "switch B: the same bytes"
has "$(cat .r-switch.out)" "A' against A, its label aside, line for line the same: yes" "switch: A' = A"
echo "  switch: A (the key) -> 962 plain, 477 gzip, unzipped md5 = plain; B (no key, gzip asked) -> 962, no Content-Encoding; A' = A"

# "the list says Content-Length 282 ... thirty customers ... 2,403 bytes, zipped 229: about a tenth ... the same zipped bytes three times" - floor
FO=$(cat .r-floor.out); L2403='bc5535748533a4c827adf3935546b84b'; G229='557506580848e47c344634ee01314d0e'
has "$FO" "  the floor in force: server.compression.min-response-size not on the run line - Boot's default, from its metadata (which)" "floor: the floor in force named (R.157)"
QL0="$FQ -H 'Accept-Encoding: gzip' http://127.0.0.1:19590/customers"
[ "$(after "$FO" "$QL0" | sed -n 1p)" = "  -> 200 282 · md5 $L282 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2" ] && [ "$(kept "$FO" "$QL0")" = "$(printf '%s\n' '    Content-Type: application/json' '    Content-Length: 282')" ] || die "floor: the list under the floor - 282 B, Content-Length: 282, no Content-Encoding, gzip asked"
has "$FO" "  their statuses: 201 ×30" "floor: thirty POSTs, each 201"
has "$FO" "\$ cd .harness/anchor && ${L_RUNL/18431/19590} $CZ" "floor: its \$ line, the key on, no floor key"
[ "$(cnt "$FO" "  -> 200 2403 · md5 $L2403 · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3")" = 3 ] && [ "$(cnt "$FO" '    Content-Length: 2403')" = 3 ] || die "floor: the grown list plain - 2403 B with Content-Length: 2403, three rounds"
[ "$(cnt "$FO" "  -> 200 229 · md5 $G229 · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4")" = 3 ] || die "floor: the grown list gzip - 229 B, the same md5 three rounds"
[ "$(cnt "$FO" "  gunzip -c, the saved bytes: 2403 bytes · md5 $L2403")" = 3 ] && [ "$(cnt "$FO" '    Content-Encoding: gzip')" = 3 ] && [ "$(cnt "$FO" '    Transfer-Encoding: chunked')" = 3 ] || die "floor: Content-Encoding: gzip beside Transfer-Encoding: chunked, unzipped = plain, three rounds (R.157)"
for k in 1 2 3; do has "$FO" "  round $k: the unzipped list against the plain one, md5 for md5: the same" "floor: round $k unzipped = plain"; has "$FO" "  round $k: the gzip bytes against round 1's, md5 for md5: the same" "floor: round $k's gzip bytes = round 1's"; done
# the band: 229/2403 is "about a tenth" (0.05-0.15); 477/962 "about half" (0.4-0.6) - from the %{size_download} lines, one JVM each
awk 'BEGIN { r = 229 / 2403; exit !(r > 0.05 && r < 0.15) }' && awk 'BEGIN { r = 477 / 962; exit !(r > 0.4 && r < 0.6) }' && awk 'BEGIN { r = 435 / 839; exit !(r > 0.4 && r < 0.6) }' || die "floor/which: the bands - about a tenth, about half"
echo "  floor: 282 B with Content-Length: 282 under the 2KB floor, not compressed; 30 POSTs (201 ×30); 2403 B (Content-Length: 2403) -> 229 B gzip (chunked), about a tenth, the gzip bytes $G229 ×3, unzipped = plain ×3"

# "curl --compressed unzips ... the JDK's HttpClient does not unzip ... RestClient: 2,403 bytes, the plain md5, no Content-Encoding ... it asked gzip and deflate" - decode
DO=$(cat .r-decode.out)
has "$DO" "\$ cd .harness/anchor && ${L_RUNL/18431/19591} $CZ $AL" "decode: its \$ line - the key and the access log (the harness's options)"
has "$DO" "  their statuses: 201 ×30" "decode: thirty POSTs"
# RED S6 #510: who unzips for RestClient, read off spring-web 7.0.9 - Spring's JDK request factory has the switch, its request the handler
has "$DO" "\$ $L_JAVAP" "decode: the javap line"; has "$DO" "  javap's lines: 22 · kept: 5" "decode: javap, 5 of 22 lines kept"
for l in '    public class org.springframework.http.client.JdkClientHttpRequestFactory implements org.springframework.http.client.ClientHttpRequestFactory {' '    private boolean compression;' '    public void enableCompression(boolean);' '    final class org.springframework.http.client.JdkClientHttpRequest$DecompressingBodyHandler implements java.net.http.HttpResponse$BodyHandler<java.io.InputStream> {' '    private static java.io.InputStream decompressStream(java.io.InputStream, java.lang.String);'; do has "$DO" "$l" "decode: spring-web's own line: $l"; done
QDC="$FQ --compressed http://127.0.0.1:19591/customers"
[ "$(after "$DO" "$QDC" | sed -n 1p)" = "  -> 200 229 · md5 $L2403 · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4" ] || die "decode: curl --compressed - 229 B on the wire, the plain md5 saved"
has "$DO" "  curl --compressed's saved bytes against the plain list, md5 for md5: the same · against the gzip bytes: they differ" "decode: curl unzips"
has "$DO" "  the md5s to compare the clients' lines with - the plain list: $L2403 · the gzip bytes: $G229" "decode: the two md5s"
UZ="    the JDK's HttpClient, no header added -> 200 HTTP_1_1 | Content-Encoding: none | bytes handed back: 2403 | md5 $L2403"
UG="    the JDK's HttpClient, Accept-Encoding: gzip set by hand -> 200 HTTP_1_1 | Content-Encoding: gzip | bytes handed back: 229 | md5 $G229"
UR="    RestClient.create(), no header added -> 200 | Content-Encoding: none | bytes handed back: 2403 | md5 $L2403"
UF="    RestClient.create(): its request factory org.springframework.http.client.JdkClientHttpRequestFactory"
for l in "$UZ" "$UG" "$UR" "$UF" "    the JVM's locale: en_US"; do has "$DO" "$l" "decode: $l"; done
# the JDK's raw body is the gzip bytes - NOT the plain list (the decode md5 can tell them apart)
[ "$(printf '%s\n' "$DO" | sed -n 's/^    the JDK.s HttpClient, Accept-Encoding: gzip set by hand -> .* md5 \([0-9a-f]*\)$/\1/p')" != "$L2403" ] || die "decode: the JDK's HttpClient handed back the plain list - it would have unzipped"
has "$DO" "  exit 0 · its UNZIP lines: 7 · its other lines: 0" "decode: Unzip ran, nothing else printed"
for l in '    GET /customers HTTP/1.1 200 upgrade:- accept-encoding:- content-encoding:-' '    GET /customers HTTP/1.1 200 upgrade:- accept-encoding:gzip content-encoding:gzip' '    GET /customers HTTP/1.1 200 upgrade:- accept-encoding:deflate, gzip content-encoding:gzip' '    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:- content-encoding:-' '    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:gzip content-encoding:gzip' '    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:gzip,deflate content-encoding:gzip'; do has "$DO" "$l" "decode: the access log: $l"; done
printf '%s\n' "$DO" | grep -qE '^  Tomcat.s access log since the mark \(after readiness\).*: 36 lines, 30 of them POSTs \(not shown\)$' || die "decode: the access log, 36 lines, 30 POSTs"
echo "  decode: curl --compressed 229 B on the wire, the plain md5 saved; the JDK's HttpClient, gzip by hand -> 229 B, the gzip md5 (not unzipped); RestClient.create() (JdkClientHttpRequestFactory) -> 2403 B, the plain md5, no Content-Encoding; the access log: it asked gzip,deflate and was sent gzip"

# "the key on: 101, Upgrade h2c, switched to HTTP/2 ... prior knowledge 2 ... the JDK's offer accepted, HTTP_2 ... the key off: 1.1, prior knowledge no answer" - h2c
HA=$(blk h2c "A - " "B - "); HB=$(blk h2c "B - " "A' - "); HA2=$(blk h2c "A' - " "A' against A")
VQ="\$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}'"
for b in "$HA" "$HA2"; do has "$b" "\$ cd .harness/anchor && ${L_RUNL/18431/19590} $H2 $AL" "h2c A: its \$ line (S6.2)"
  for l in '    > Upgrade: h2c' '    < HTTP/1.1 101 ' '    < Upgrade: h2c' '    * Received 101, Switching to HTTP/2' '    < HTTP/2 200 '; do has "$b" "$l" "h2c A: curl's -v line $l"; done
  [ "$(after "$b" "$VQ --http2 http://127.0.0.1:19590/customers")" = "  -> 200 2 282 · md5 $L282 · curl exit 0" ] && [ "$(after "$b" "$VQ --http2-prior-knowledge http://127.0.0.1:19590/customers")" = "  -> 200 2 282 · md5 $L282 · curl exit 0" ] && [ "$(after "$b" "$VQ http://127.0.0.1:19590/customers")" = "  -> 200 1.1 282 · md5 $L282 · curl exit 0" ] || die "h2c A: %{http_version} 2 with --http2 and prior knowledge, 1.1 with neither, the same body"
  has "$b" "    the JDK's HttpClient, no header added -> 200 HTTP_2 | Content-Encoding: none | bytes handed back: 282 | md5 $L282" "h2c A: the JDK's client's own offer accepted - HTTP_2"
  has "$b" '    GET /customers HTTP/1.1 101 upgrade:h2c accept-encoding:- content-encoding:-' "h2c A: the access log's 101 for an h2c offer"
  [ "$(printf '%s\n' "$b" | grep -c '^    GET /customers HTTP/1.1 101 upgrade:h2c ')" = 4 ] || die "h2c A: four offers accepted - curl's two, the JDK client's, RestClient's"; done
has "$HB" "\$ cd .harness/anchor && ${L_RUNL/18431/19591} $AL" "h2c B: its \$ line, no key"
nhas "$HB" '    < HTTP/1.1 101 ' "h2c B: no 101"; has "$HB" '    > Upgrade: h2c' "h2c B: curl offered"; has "$HB" '    < HTTP/1.1 200 ' "h2c B: answered HTTP/1.1"
[ "$(after "$HB" "$VQ --http2 http://127.0.0.1:19591/customers")" = "  -> 200 1.1 282 · md5 $L282 · curl exit 0" ] || die "h2c B: --http2 -> 1.1, the offer ignored"
# prior knowledge with the key off: no answer - read off %{http_version} (0), never off the exit code
HV=$(after "$HB" "$VQ --http2-prior-knowledge http://127.0.0.1:19591/customers" | sed -n 's/^  -> \([0-9]*\) \([0-9.]*\) .*/\2/p'); [ "$HV" = 0 ] || die "h2c B: prior knowledge must get no answer - %{http_version} $HV"
has "$HB" "  -> 000 0 0 · nothing saved · curl exit 16" "h2c B: prior knowledge, 000"
has "$HB" "    the JDK's HttpClient, no header added -> 200 HTTP_1_1 | Content-Encoding: none | bytes handed back: 282 | md5 $L282" "h2c B: the JDK's offer ignored - HTTP_1_1"
[ "$(printf '%s\n' "$HB" | grep -c '^    GET /customers HTTP/1.1 101 ')" = 0 ] && [ "$(printf '%s\n' "$HB" | grep -c '^    GET /customers HTTP/1.1 200 upgrade:h2c ')" = 5 ] || die "h2c B: five offers, none accepted"
has "$(cat .r-h2c.out)" "A' against A, its label aside, line for line the same: yes" "h2c: A' = A"
echo "  h2c: the key on -> curl's 101 / Upgrade: h2c / Received 101, Switching to HTTP/2, %{http_version} 2 (--http2, prior knowledge), the JDK's offer -> HTTP_2; the key off -> 1.1, the offer ignored, prior knowledge 000 (%{http_version} 0, curl exit 16); A' = A"

# "over one point one, two connections; over HTTP/2, one - a multiplexed connection, reused" - together (curl's own lines)
TO=$(cat .r-together.out); T1=$(blk together "  HTTP/1.1:" "  HTTP/2:"); T2=$(blk together "  HTTP/2:" "")
has "$TO" "\$ cd .harness/anchor && ${L_RUNL/18431/19592} $H2" "together: its \$ line"
has "$T1" '  connections curl opened (its "Connected to" lines): 2' "together: HTTP/1.1 - two connections"
has "$T2" '  connections curl opened (its "Connected to" lines): 1' "together: HTTP/2 - one connection"
has "$T2" '    1 × * Multiplexed connection found' "together: HTTP/2 - multiplexed (curl's line)"; has "$T2" '    1 × * Re-using existing connection with host 127.0.0.1' "together: HTTP/2 - reused"
nhas "$T1" '    1 × * Multiplexed connection found' "together: HTTP/1.1 is not multiplexed"
has "$T1" "\$ curl -s -v -Z --http1.1 -H 'Accept: text/html' -o /dev/null -o /dev/null -w '%{http_version} ' http://127.0.0.1:19592/dashboard http://127.0.0.1:19592$CSSU 2> .harness/v.txt" "together: the HTTP/1.1 line, the stylesheet read off the page"
has "$T2" "\$ curl -s -v -Z --http2-prior-knowledge -H 'Accept: text/html' -o /dev/null -o /dev/null -w '%{http_version} ' http://127.0.0.1:19592/dashboard http://127.0.0.1:19592$CSSU 2> .harness/v.txt" "together: the HTTP/2 line"
printf '%s\n' "$T1" | grep -qF -- "-> %{http_version} per transfer: 1.1 1.1 · curl exit 0" && printf '%s\n' "$T2" | grep -qF -- "-> %{http_version} per transfer: 2 2 · curl exit 0" || die "together: the versions per transfer"
! grep -E '^\$ ' .r-together.out | grep -qF -- '--parallel-immediate' || die "together: --parallel-immediate opens a connection per transfer - never on these lines"
echo "  together: the page and its stylesheet at once - HTTP/1.1: 2 connections (curl's Connected to lines); HTTP/2: 1, Multiplexed connection found, re-used"
# "C, labelled: the AOT jar ... with the two switches, 477 zipped and HTTP/2 ... without them, 962 and no answer ... unlike virtual threads" - aot
AO=$(cat .r-aot.out); AW=$(blk aot "the AOT jar with the two switches - " "the AOT jar with neither - "); AN=$(blk aot "the AOT jar with neither - " "")
has "$AO" "\$ cd .harness/aot && mvn -o -B -Dmaven.repo.local=\"\$M2\" -Pnative -DskipTests clean package" "aot: the README's native line, offline, -DskipTests"
[ "$(dev "cd .harness/aot && mvn -o -B -Dmaven.repo.local=\"\$M2\" -Pnative -DskipTests clean package")" = "$R_NATIVE" ] || die "aot: the build line is not the README's native line with the offline changes"
has "$AO" '  built the AOT jar (.harness/aot) · offline: yes · exit 0' "aot: built offline"
has "$AO" "  files .m2-demo gained: 0 · Spring's AOT step ran (process-aot): 1 · GraalVM's metadata repository read from a file: URL: 1 · from http(s): 0" "aot: nothing downloaded, the AOT step ran, the metadata from a file"
printf '%s\n' "$AO" | grep -qE '^  the generated bean definitions in the jar \(BOOT-INF/classes, \*__BeanDefinitions\.class\): [1-9][0-9]+$' || die "aot: the generated bean definitions"
has "$AO" "  31:  # and Boot's task executor uses virtual threads too. Under Spring's AOT step, and so in the native binary, this is fixed" "aot: the anchor's own line - threading fixed at build"
has "$AO" "  32-  # when the jar is built: a run-time --spring.threads.virtual.enabled changes nothing there, either way." "aot: the anchor's own line, its second half"
for b in "$AW" "$AN"; do has "$b" "  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java <version>" "aot: the AOT-processed start"; has "$b" "  Boot's AOT line in its log: 1" "aot: one AOT line"; has "$b" "$LOC" "aot: en_US"; has "$b" "$Z2" "aot: 0/0"; done
has "$AW" "\$ cd .harness/aot && ${L_AOTL/18431/19593} $CZ $H2" "aot: the two switches on the AOT line (S6.2)"
has "$AN" "\$ cd .harness/aot && ${L_AOTL/18431/19594}" "aot: the AOT line, neither"
[ "$(size "$AW" "$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19593/dashboard")" = 477 ] && has "$AW" '    Content-Encoding: gzip' "aot: the page zipped" && has "$AW" "  gunzip -c, the saved bytes: 962 bytes · md5 $P962" "aot: unzipped = plain" || die "aot: with the switches - the page 477, gzip"
[ "$(size "$AN" "$FQ -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19594/dashboard")" = 962 ] && ! printf '%s\n' "$AN" | grep -qi '^    content-encoding' || die "aot: with neither - 962, no Content-Encoding"
[ "$(after "$AW" "$VQ --http2-prior-knowledge http://127.0.0.1:19593/customers")" = "  -> 200 2 282 · md5 $L282 · curl exit 0" ] || die "aot: with the switches - prior knowledge, HTTP/2"
[ "$(after "$AN" "$VQ --http2-prior-knowledge http://127.0.0.1:19594/customers" | sed -n 's/^  -> \([0-9]*\) \([0-9.]*\) .*/\2/p')" = 0 ] || die "aot: with neither - prior knowledge, no answer (%{http_version} 0)"
grep -q '^aot ' receipts.md5 && grep -q '^C (labelled) - ahead of time' .r-aot.out || die "aot: the capture must be labelled C"
echo "  aot (C): the AOT jar built offline on a copy (0 files gained, process-aot 1, the metadata from a file: URL); with $CZ $H2 -> the page 477 gzip, prior knowledge 2; with neither -> 962, no answer; the anchor's own yaml: threading fixed at build"

# the exercise's files as shipped (read again here, so a check that the exercise capture makes cannot be skipped)
XR=$(block exercise/README.md); XL=$(block exercise/solution/SOLUTION.md)
[ "$(printf '%s\n' "$XL" | grep -c .)" = 5 ] && [ "$(printf '%s\n' "$XL" | sed -n 1,2p)" = "$(printf '%s\n' "$XR" | sed -n 1,2p)" ] && [ "$(printf '%s\n' "$XL" | sed -n 4p)" = "$VS" ] && [ "$(printf '%s\n' "$XL" | sed -n 5p)" = "$(printf '%s\n' "$XR" | tail -1)" ] && printf '%s\n' "$XR" | grep -qxF -- "$VX" && ! printf '%s\n' "$XR" | grep -qF min-response-size || die "exercise: SOLUTION.md must be the README's two exports, its S= line, $VS and the README's last line; the README must ship $VX"
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" 'the same two blocks again'); XZ=$(blk exercise 'the same two blocks again' '')
l="/customers, gzip asked: 129 bytes · Content-Encoding: gzip · TiffinBox stopped by: POST /shutdown, 200"; l0="/customers, gzip asked: 282 bytes · Content-Encoding: none · TiffinBox stopped by: POST /shutdown, 200"
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
for b in "$XS" "$XE"; do has "$b" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19596 now: 0" "exercise: the shell back in this folder, nothing left"; done
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
# RED S6 #527: the same two blocks in zsh (the Mac's Terminal shell) print the same two lines - and no block passes an unquoted variable
# that could hold two options (zsh never splits one: the two would arrive as one word)
has "$XZ" "    $l0" "exercise (zsh): as shipped"; has "$XZ" "    $l" "exercise (zsh): the solution"
has "$XZ" "  the README's lines: exit 0 · what they printed:" "exercise (zsh): the README's commands, exit 0"; has "$XZ" "  the solution's lines: exit 0 · what they printed:" "exercise (zsh): the solution's lines, exit 0"
has "$XZ" "  the shell is now in: this unit's folder · its copy's own token in its log: 0 times · listening on 19596 now: 0" "exercise (zsh): nothing left"
[ "$(printf '%s\n' "$XZ" | grep -c '^    /customers, gzip asked: ')" = 2 ] || die "exercise (zsh): two lines printed, one per block"
for f in exercise/README.md exercise/solution/SOLUTION.md; do ! block "$f" | grep -qE '(^|[^"{])\$V([^A-Za-z0-9_{]|$)|^V="[^"]* ' || die "$f passes V unquoted or as one string - zsh would hand the options over as one word (RED S6 #527): V=( ... ) and \"\${V[@]}\""; done
[ "$(printf '%s\n' "$XR" | grep -c -- "-H 'Accept-Encoding: gzip' -w '%{size_download}' http://127.0.0.1:19596/customers")" = 1 ] || die "exercise: \"fetch again\" is the README's curl with gzip asked and %{size_download}"
! printf '%s\n' "$XR$XL" | grep -qE -- "--data|-X POST|-d '[{]" || die "exercise: no POST - a second run in one shell measures the same list (S6.4)"
EXQ="Your turn: the README switches compression on, yet the customer list still arrives unzipped. Find the setting that skips it, change it, and fetch again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (the switch alone) -> $l0; the solution (+ $FL) -> $l; the shell in this unit's folder after each, 19596 free; the same two lines again in one zsh shell; no block passes V unquoted (RED S6 #527)"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit30: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log"
