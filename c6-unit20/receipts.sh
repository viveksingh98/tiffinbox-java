#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · File Upload and Download - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit16/after, the tree
# the problem-detail lesson froze (= c6-tiffinbox at Section 3's end, the tree the viewer last saw). This script copies that tree under
# .harness/anchor, builds it and runs it - as its README runs it, and on its class path with the course's harness joined
# (harness/probe/web, outside com.tiffinbox) - and shows a file coming in (a multipart request, read by Spring MVC as a MultipartFile),
# the size where TiffinBox says no, and a customer's bill going out: streamed, row by row, and whole.
# Six captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run and in every file this unit ships.
#   limits     the anchor built and extracted; the harness compiled; the seven on the jar; the multipart keys Boot's own metadata
#              declares (their defaults); the MultipartConfigElement Boot built from them, read back off the running application
#   upload     a small menu (3 lines of CSV) sent as a multipart request: the part's name, size, lines - and its content type, once as
#              curl guessed it and once as curl was told
#   limit      A/B/A': A, Boot's limits - one mebibyte exactly, one byte more, one and a half million bytes, twelve million bytes; B,
#              spring.servlet.multipart.max-file-size=2MB for one run (an option), the limit read back and the 1,500,000 bytes again;
#              A', A again; C (labelled): B's key, twelve million bytes - the request's own limit
#   bill       a customer's bill (TiffinBox's own CustomerRepository, read by the harness), streamed: its headers, its body, the hooks -
#              which thread wrote it, and the dispatches Tomcat ran; a name nobody has
#   resource   the same bill whole (a Resource): its headers, a range of it; a customer whose name is not ASCII, added with the
#              anchor's own POST, and the two filenames Content-Disposition gives; curl -O -J saving both bills
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit16/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. The harness - harness/probe/web (compiled with -parameters): Files (the
# upload, the limits read back, the streamed bill and the whole one, from TiffinBox's own CustomerRepository), Dispatches (a filter
# registration for every dispatch type, on the bill paths), Refusals (a handler exception resolver that answers nothing and prints
# which of Tomcat's limits refused an upload), Trace (their lines) - is the course's, never TiffinBox's: outside com.tiffinbox, joined
# by --spring.main.sources on the extracted jar's class path, and named on every capture that uses it; harness/keys.py reads a jar's
# configuration metadata; harness/shutdown.sh is POST /shutdown with the token read from its file. Every run passes options only. The
# seven run first, on a fresh JVM of the jar. The test files are made here (head -c ... /dev/zero | tr), under .harness/, never shipped.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's, Jackson's and Tomcat's messages in
# the log and in the answers are written in the JVM's locale: so every JVM this script starts has its locale pinned on its run line
# (-Duser.language=en -Duser.country=US, before -jar or -cp: at() puts it there, README.md "The commands this unit adds"), and every
# harness JVM prints it (Files), and the checks assert en_US.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build, no Docker and no browser: this unit
# measures the JVM alone, with curl. At run time nothing leaves 127.0.0.1: TiffinBox listens there, every request goes there, and
# Logback writes to the terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. Spring's error timestamp becomes "…" (both forms) in the seven and wherever an answer is printed. An answer's
# Date header keeps its name, its value becomes "…"; a header line loses its carriage return and its trailing space. Tomcat's sentence
# for a request over the request limit keeps the limit and loses the request's own size (curl's multipart framing around the file, not
# the file): "its size (…)". A run's log lines are printed from their logger on (no time, no process id, no thread); Boot's first line is
# cut before " with PID". A WARN or ERROR record is printed as its level, logger and message, then the exception line under it; its
# stack frames are bounded ("over 40") and its other lines counted, never shown. The harness's lines are printed in the order they
# ran, numbered from 1 for each request (the JVM's running number is checked to rise, never shown); a thread's own number is "<n>"
# (the harness prints it so). A body curl saved is printed whole when it is the bill (32 lines), its lines and bytes counted; a test
# file is shown by its size alone. No duration is captured, and no count of the bytes curl sent before a refusal (it moves with timing).
# Ports (brief ⚑1, 19490-19499): limits - the seven 19490, the harness 19491 · upload 19492 · limit - A and A' 19493, B 19494, C 19495 ·
# bill 19496 · resource 19497 · the exercise 19499. Captures run one after another, each JVM stopped before the next starts on its port.
# 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it. The published captures were
# made with no locale set, which is the C locale. (The JVM ignores it on macOS: its locale is pinned per JVM, above.)
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $xpid, the exercise's shell, with every process under it - its Maven, its JVM, its curl), if they still run, then sweep(): anything
# of this run still alive in its process group - a TiffinBox JVM, a Maven - is stopped. After an interrupt, a capture's unfinished
# runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C,
# and nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an interrupt (README.md,
# "Interrupted"). $pid and $xpid are cleared whenever their process has been reaped. sweep() kills only processes of this run's own
# process group - start each run in a group of its own (README.md, "Interrupted"). No wait in this script is bare: each names its pid.
pid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 curl rsync lsof unzip javac mvn cmp; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A
# SPRING_SERVLET_MULTIPART_MAX_FILE_SIZE of yours would move the very limit this unit measures; a JAVA_TOOL_OPTIONS could set every
# JVM's locale.)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit16/after ] || die "anchor must be the link to ../c6-unit16/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/anchor/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-a-file-and-a-bill
[ ${#TOKEN} = 32 ] || die "the demo token must be 32 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/Dispatches.java harness/probe/web/Files.java harness/probe/web/Refusals.java harness/probe/web/Trace.java'
for f in harness/shutdown.sh harness/keys.py $HWS exercise/README.md exercise/MenuDesk.java exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Dispatches.java Files.java Refusals.java Trace.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
[ "$(ls exercise/solution | paste -sd' ' -)" = 'SOLUTION.md' ] || die "exercise/solution holds another file: the solution is a key, not a class"
cmp -s harness/probe/web/Trace.java ../c6-unit18/harness/probe/web/Trace.java || die "harness/probe/web/Trace.java must be the filters lesson's, byte for byte"
cmp -s harness/shutdown.sh ../c6-unit18/harness/shutdown.sh || die "harness/shutdown.sh must be the filters lesson's, byte for byte"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19490 19491 19492 19493 19494 19495 19496 19497 19498 19499; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole ---------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
CPL='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431'
ASHA='{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme "$J")
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme "java -cp $CPL")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_PD=$(readme "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/customers/Nobody")
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '$ASHA' http://127.0.0.1:18431/customers")
WT=" -w ' %{http_code} · Content-Type: [%{content_type}]\n'"; WU=" -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n'"
[ "${R_PD#curl -s}" = "$WT http://127.0.0.1:18431/customers/Nobody" ] || die "the anchor's Content-Type line"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the anchor's run and class-path
# lines with the JVM's locale pinned; the class-path line with Boot's file-size key; the harness's javac line; the metadata reader; a
# test file made; the anchor's Content-Type line with the Connection header printed and one file sent as a multipart part, at the
# harness's path; the same line with the headers and the body saved to files instead, at another; curl -O -J from a folder of its own;
# the anchor's POST with another name
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
SERVLETJAR=spring-boot-servlet-4.1.1.jar
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_MB=$(mine "$L_CPL --spring.servlet.multipart.max-file-size=2MB")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/tiffinbox-web/target/extracted/lib/*\" $HWS")
L_KEYS=$(mine "python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/$SERVLETJAR spring.servlet.multipart.")
L_MAKE=$(mine "head -c 1048577 /dev/zero | tr '\\0' 'm' > .harness/files/menu-1048577.txt")
L_UP=$(mine "curl -s$WU -F 'menu=@.harness/files/menu.csv' http://127.0.0.1:18431/probe/menu")
L_GET=$(mine "curl -s -D .harness/head.txt -o .harness/body.csv$WT http://127.0.0.1:18431/probe/bill/Ravi")
L_OJ=$(mine "cd .harness/dl && curl -s -O -J http://127.0.0.1:18431/probe/bill/Ravi")
L_RAW=$(mine "curl -s --raw -o .harness/raw.txt http://127.0.0.1:18431/probe/bill/Ravi")
ZOE='{"name":"Zoë K","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
L_ZOE=$(mine "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '$ZOE' http://127.0.0.1:18431/customers")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
O_MB=${L_MB#"$L_CPL "}; [ "$O_MB" = '--spring.servlet.multipart.max-file-size=2MB' ] || die "the B line must be the pinned class-path line with Boot's file-size key, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the four files in harness/probe/web, and nothing else"
r=${R_PD/"$WT"/$WU}; P_='/customers/Nobody'; Q_='/probe/menu'; r=${r/"$P_"/$Q_}; P_=" http://"; Q_=" -F 'menu=@.harness/files/menu.csv' http://"; r=${r/"$P_"/$Q_}
[ "$r" = "$L_UP" ] || die "the upload line must be the anchor's Content-Type line with Connection printed, one -F part and /probe/menu, and nothing else"
r=${R_PD/"$WT"/ -D .harness/head.txt -o .harness/body.csv$WT}; P_='/customers/Nobody'; Q_='/probe/bill/Ravi'; r=${r/"$P_"/$Q_}
[ "$r" = "$L_GET" ] || die "the saved-answer line must be the anchor's Content-Type line with -D and -o and /probe/bill/Ravi, and nothing else"
P_='"name":"Asha"'; Q_='"name":"Zoë K"'; r=${R_POST/"$P_"/$Q_}
[ "$r" = "$L_ZOE" ] || die "the second POST must be the anchor's POST with the name Zoë K, and nothing else"
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package) clean and without tests. dev() takes those four things back out, and must give the
# README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - and a java line with the JVM's locale pinned
# right after "java" (this unit's pinned lines show the form, and at() must give them back)
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java -Djarmode=tools '*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# hcp DIR PORT CLASSES ['OPTIONS']: the README's class-path line - the extracted jar, TiffinBox's own main - from DIR, its port made
# PORT, the harness's classes added to the class path (../hc) and CLASSES joined (--spring.main.sources=); OPTIONS after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
# url 'curl LINE' PORT: the line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# uq PORT FILE ['TYPE']: this unit's upload line - the body, the status, curl's Content-Type and the answer's Connection header - with
# the part's file FILE (under .harness/files/), and, when given, the content type curl is told to give the part
uq() { local c=${L_UP/:18431\//:$1/} P_="menu=@.harness/files/menu.csv" Q_="menu=@.harness/files/$2${3:+;type=$3}"; printf '%s\n' "${c/"$P_"/$Q_}"; }
# gq PORT PATH ['CURL OPTION']: this unit's saved-answer line, its port PORT and its path PATH, one more curl option before the URL
gq() { local c=${L_GET/:18431\//:$1/} P_=" http://" Q_=" ${3:-} http://"; c=${c/\/probe\/bill\/Ravi/$2}; [ -z "${3:-}" ] || c=${c/"$P_"/$Q_}; printf '%s\n' "$c"; }
# oj PORT PATH: this unit's curl -O -J line, its port and its path
oj() { local c=${L_OJ/:18431\//:$1/}; printf '%s\n' "${c/\/probe\/bill\/Ravi/$2}"; }
# rawq PORT: this unit's --raw line on PORT - the body as it came, chunk framing and all (RED S4 #344)
rawq() { printf '%s\n' "${L_RAW/:18431\//:$1/}"; }
# chunks FILE: a chunked body's framing, read - each chunk's size (the size lines, hex, read as decimal), in order; then its data
# joined, without the framing, in FILE.data
chunks() { python3 -c 'import sys
b = open(sys.argv[1], "rb").read(); i = 0; z = []; d = b""
while True:
    j = b.index(b"\r\n", i); n = int(b[i:j].split(b";")[0], 16); z.append(n); d += b[j + 2:j + 2 + n]; i = j + 2 + n + 2
    if n == 0: break
open(sys.argv[1] + ".data", "wb").write(d); print(", ".join(map(str, z)))' "$1"; }
# mk BYTES: this unit's file-making line for a test file of BYTES bytes
mk() { printf '%s\n' "${L_MAKE//1048577/$1}"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19490 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19490}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$R_EXTRACT")" = "cd .harness/x && $R_EXTRACT" ] || die "at(): the pinned lines are not README.md's"
[ "$(hcp .harness/x 19494 probe.web.Files "$O_MB")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19494 --spring.main.sources=probe.web.Files --spring.servlet.multipart.max-file-size=2MB' ] || die "hcp()"
[ "$(uq 18431 menu.csv)" = "$L_UP" ] && [ "$(uq 19492 menu.csv text/csv)" = "curl -s$WU -F 'menu=@.harness/files/menu.csv;type=text/csv' http://127.0.0.1:19492/probe/menu" ] && [ "$(gq 18431 /probe/bill/Ravi)" = "$L_GET" ] && [ "$(gq 19497 /probe/bill-whole/Ravi '-r 0-15')" = "curl -s -D .harness/head.txt -o .harness/body.csv$WT -r 0-15 http://127.0.0.1:19497/probe/bill-whole/Ravi" ] && [ "$(oj 18431 /probe/bill/Ravi)" = "$L_OJ" ] && [ "$(mk 1048577)" = "$L_MAKE" ] && [ "$(rawq 18431)" = "$L_RAW" ] || die "uq(), gq(), oj(), mk() or rawq()"
echo "  the commands: anchor/README.md gives the 7 lines this script runs or derives from; README.md the 10 this unit adds"

# ---- build: before the captures - the anchor built once (on a fresh clone this fills .m2-demo); what .m2-demo holds ---------------
rm -rf .harness; mkdir -p .harness
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only if the
# offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is never
# silent (inside a capture, "no" changes the capture's hash: cap() then dies).
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the demo token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
rsync -a --exclude target --exclude secrets anchor/ .harness/pre/
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (the anchor)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-webmvc/4.1.1/spring-boot-starter-webmvc-4.1.1.jar" ] || die "Spring MVC's starter is not in .m2-demo after the first build"
echo "  .m2-demo holds Spring MVC's starter"


# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; LASTE=""                                     # logs counted: served runs
first() { grep -m1 -E ' : Starting |^main Starting ' "$1" | sed 's/^.* : //; s/^main //; s/ with PID .*$//'; }
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# addrs: the addresses the process $pid listens on, read off the process (lsof, by pid - its command name is never printed)
addrs() { lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
# listening [PORT]: addrs, polled until the process listens (on PORT, when given) - every 0.25 s, up to 120 s
listening() { local a="" i=0
  while [ $i -lt 480 ]; do
    a=$(addrs); if [ -n "$1" ]; then case " $a " in *":$1 "*) break ;; esac; elif [ -n "$a" ]; then break; fi
    kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# lb ADDRESSES: yes when every one is 127.0.0.1:<port> - the check R.78 asks for, on the address read off the process
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
up() { local l; l=$(listening "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  case " $l " in *':8080 '*|*':35729 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080 or 35729 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (R.41, R.75). A JVM ($pid) that exits first stops the run.
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  local r; r=$(url "$R_READY" "$1"); echo "\$ $r"; (eval "$r") 2>&1 < /dev/null | sed 's/^/  /'; }
# logtok: the demo token 0 times in the last run's log, and the header's name 0 times
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token $h times"; }
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
# timestamp mask and how many lines the mask changed; the log counted (logtok) - the masked set kept as .harness/seven-PORT.txt
seven() { local m
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  gone "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  cp .harness/responses.m.txt ".harness/seven-$1.txt"
  logtok; }
# post PORT DIR: POST /shutdown with DIR's token (harness/shutdown.sh) - its answer, its Content-Length header, the timestamp masked
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | tsmask | sed 's/^/  /'; }
# stop PORT DIR: POST /shutdown with DIR's token; the JVM must leave, the port must be free; its exit code; its log counted (logtok)
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
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
pbuild() { local c; c=$(off "$1" "$R_PLAIN" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }
# settle: the log stops growing (the same length twice, 0.5 s apart; up to 15 s) - a request's last line is written just after
# its answer leaves
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
mark() { settle; wc -l < .harness/run.out | tr -d ' '; }
# logl FROM [LEVELS]: the run's lines after line FROM at those levels (WARN|ERROR unless named), from their level and logger on
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" 'NR > from && $0 ~ (" (" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); print "    " l " " lg ": " msg }' .harness/run.out; }
# recs FROM: each WARN or ERROR record the log gained after line FROM (the harness's lines skipped) - its level, its logger and its
# message; then the exception line under it (the first line after the record that is neither blank nor a stack frame); its stack
# frames, bounded ("over 40"), and its other lines, counted - none shown
recs() { awk -v from="$1" '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  NR <= from { next }
  /^HOOK [0-9]+ / { next }
  / [A-Z]+ [0-9]+ --- \[/ { out() }
  / (WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", m)
    print "    " $2 " " lg ": " m; inr = 1; ex = 1; next }
  inr && /^\tat / { fr++; next }
  inr && ex && NF > 0 { print "      " $0; ex = 0; next }
  inr { ot++ }
  END { out() }' .harness/run.out; }
# pagef: a curl answer through its filter - any HTML page as its <h1> and its length, never shown (none is expected here); curl's
# status line after it; a JSON answer - a problem detail too - as it came, its error timestamp masked
pagef() { python3 -c '
import re, sys
for l in sys.stdin.read().splitlines():
    if l.startswith("<html>") or l.lower().startswith("<!doctype html"):
        h = re.search(r"<h1>(.*?)</h1>", l)
        tail = l[l.index("</html>") + len("</html>"):] if "</html>" in l else ""
        print("  an HTML page - its <h1>: %s · %d characters, not shown%s" % (h.group(1) if h else "none", len(l) - len(tail), " · then curl'"'"'s:" + tail if tail else ""))
    else:
        print("  " + re.sub(r"\"timestamp\":[0-9]+", "\"timestamp\":…", re.sub(r"\"timestamp\":\"[^\"]*\"", "\"timestamp\":\"…\"", l)))'; }
WARNS() { settle; echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; }
# The answer filter and the record filter, checked on planted inputs before any capture (R.65)
PL=$(printf '%s\n' '<!doctype html><html lang="en"><head><title>HTTP Status 400 – Bad Request</title></head><body><h1>HTTP Status 400 – Bad Request</h1></body></html> 400 · Content-Type: [text/html]' '{"timestamp":"2026-10-18T07:04:55.123Z","status":500} 500' | pagef)
EXP=$(printf '%s\n' "  an HTML page - its <h1>: HTTP Status 400 – Bad Request · 146 characters, not shown · then curl's: 400 · Content-Type: [text/html]" '  {"timestamp":"…","status":500} 500')
[ "$PL" = "$EXP" ] || die "pagef: the planted pages do not come out as declared"
mkdir -p .harness
{ printf '%s\n' '2026-10-18T00:00:00.000Z  WARN 1 --- [planted] .m.m.a.ExceptionHandlerExceptionResolver : Failure in planted' '' 'org.example.PlantedException: planted reason'
  i=0; while [ $i -lt 45 ]; do printf '\tat planted.Frame%s(Planted.java)\n' $i; i=$((i + 1)); done
  printf '%s\n' '' '2026-10-18T00:00:00.001Z ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' '' 'org.example.Other: other reason' "$(printf '\tat a')" "$(printf '\tat b')" "$(printf '\tat c')"; } > .harness/run.out
PL=$(recs 0)
[ "$PL" = "$(printf '%s\n' '    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in planted' '      org.example.PlantedException: planted reason' '      its stack frames: over 40, its other lines: 2 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      org.example.Other: other reason' '      its stack frames: 3, its other lines: 1 - none shown')" ] || die "recs: the planted records do not come out as declared (.harness/run.out)"
rm -f .harness/run.out
# The harness's lines (Trace): HOOK, the JVM's running number, then what ran. hk FROM: the harness's lines the log gained after line
# FROM, in the order they printed, numbered from 1 - the running number must rise line by line (checked, never shown) - with Tomcat's
# request size masked (README.md, Masks)
hk() { local o; o=$(awk -v from="$1" 'NR > from && /^HOOK [0-9]+ / { n = $2 + 0; if (k && n <= last) bad = 1; last = n; s = $0; sub(/^HOOK [0-9]+ /, "", s); sub(/its size \([0-9]+\) exceeds/, "its size (…) exceeds", s); l[++k] = s }
    END { if (bad) exit 3; print "  the harness'"'"'s lines it printed, in order: " (k + 0); for (i = 1; i <= k; i++) printf "    %2d %s\n", i, l[i] }' .harness/run.out) || die "the harness's lines after line $1 are out of order"
  printf '%s\n' "$o"; }
# counted FROM: the WARN and ERROR lines the log gained after line FROM, as " · WARN lines it added: N · ERROR lines: M"
counted() { local w e; settle; w=$(logl "$1" WARN | grep -c . || true); e=$(logl "$1" ERROR | grep -c . || true); printf ' · WARN lines it added: %s · ERROR lines: %s' "$w" "$e"; }
# rq 'COMMAND': a curl line, printed and run, its answer through pagef, the WARN and ERROR lines the request added counted on its last
# line; then every harness line it printed (hk); then each WARN or ERROR record (recs)
rq() { local n0 c; n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | pagef > .harness/ask.txt
  c=$(counted "$n0"); awk -v c="$c" '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) print l[i] (i == NR ? c : "") }' .harness/ask.txt
  hk "$n0"; case "$c" in *': 0 · ERROR lines: 0') ;; *) recs "$n0" ;; esac; }
# hdrs FILE: the headers curl saved (-D), as they came - each line without its carriage return and trailing space, Date's value "…" -
# counted; then whether the answer had a Content-Length and a Transfer-Encoding
hdrs() { local n; n=$(tr -d '\r' < "$1" | grep -c . || true)
  echo "  the headers curl saved, as they came: $n lines, the status line first (Date's value masked):"
  tr -d '\r' < "$1" | grep . | sed -E 's/ +$//; s/^(Date|date): .*/\1: …/; s/^/    /'
  echo "  Content-Length: $(tr -d '\r' < "$1" | awk -F': ' 'tolower($1) == "content-length" { print $2; f = 1 } END { if (!f) print "none" }') · Transfer-Encoding: $(tr -d '\r' < "$1" | awk -F': ' 'tolower($1) == "transfer-encoding" { print $2; f = 1 } END { if (!f) print "none" }')"; }
# body FILE: what curl saved: its lines and its bytes, then every line ("|" first), whole; or "nothing"
body() { if [ ! -s "$1" ]; then echo "  the body curl saved: nothing"; return; fi
  echo "  the body curl saved: $(wc -l < "$1" | tr -d ' ') lines, $(wc -c < "$1" | tr -d ' ') bytes, $(tail -c 1 "$1" | od -An -c | tr -d ' ' | sed 's/^\\n$/the last one ended/; s/^[^t].*$/the last one cut/'):"
  awk '{ print "    | " $0 }' "$1"; }
# gt 'COMMAND': this unit's saved-answer line (or one built from it), printed and run - the files it writes removed first, so nothing
# read here is an earlier answer's (R.119) - curl's line and exit code; the headers (hdrs); the body (body), unless told "nobody";
# the WARN and ERROR lines it added; every harness line it printed
gt() { local n0 e=0 c; n0=$(mark); rm -f .harness/head.txt .harness/body.csv; echo "\$ $1"; (eval "$1") > .harness/gq.out 2>&1 < /dev/null || e=$?
  c=$(counted "$n0"); echo "  curl's line:$(cat .harness/gq.out) · curl's exit code: $e$c"; hdrs .harness/head.txt; [ "${2:-}" = nobody ] || body .harness/body.csv
  hk "$n0"; case "$c" in *': 0 · ERROR lines: 0') ;; *) recs "$n0" ;; esac; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# loc: the JVM's locale, as the harness's Files printed it when Spring made it
loc() { local l; l=$(grep -m1 -E "^HOOK [0-9]+ Files +the JVM's locale: " .harness/run.out | sed "s/^.*the JVM's locale: //"); echo "  the JVM's locale (the harness's Files): ${l:-not printed}"; }
ALL=probe.web.Files,probe.web.Dispatches,probe.web.Refusals
# The level counts, the record filter, the hook filter and the header filter, checked on planted inputs before any capture (R.65,
# R.120): a harness line that names the ERROR dispatch, one WARN and one ERROR record - each count must be 1 by the log's own line
# shape, where a bare ' ERROR ' counts 2; a falling running number stops the run; Tomcat's request size is masked, its limit kept;
# a header file's carriage returns, trailing spaces and Date come out as declared
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
{ printf '%s\n' 'HOOK 0001 Dispatches      in  ERROR /error' '2026-10-22T00:00:00.000+02:00  WARN 1 --- [planted] o.s.web.servlet.PageNotFound      : planted warning' '2026-10-22T00:00:00.001+02:00 ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' 'java.lang.IllegalStateException: planted' "$(printf '\tat a')" 'HOOK 0002 Refusals        MaxUploadSizeExceededException - under it, Tomcat'"'"'s SizeLimitExceededException: the request was rejected because its size (12000197) exceeds the configured maximum (10485760)'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(lvl ERROR .harness/run.out)" = 1 ] && [ "$(lvl WARN .harness/run.out)" = 1 ] && [ "$(grep -c ' ERROR ' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR ' gives 2)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.web.servlet.PageNotFound: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      java.lang.IllegalStateException: planted' '      its stack frames: 1, its other lines: 0 - none shown')" ] || die "recs: the planted log's harness lines must be skipped (.harness/run.out)"
PL=$(hk 0); [ "$PL" = "$(printf '%s\n' "  the harness's lines it printed, in order: 2" '     1 Dispatches      in  ERROR /error' "     2 Refusals        MaxUploadSizeExceededException - under it, Tomcat's SizeLimitExceededException: the request was rejected because its size (…) exceeds the configured maximum (10485760)")" ] || die "hk: the planted harness lines do not come out as declared"
printf '%s\n' 'HOOK 0007 Dispatches      in  REQUEST /x' 'HOOK 0006 Dispatches      out REQUEST /x status 200' > .harness/run.out
( hk 0 > /dev/null 2>&1 3> /dev/null ) && die "hk: a falling running number must stop the run"
printf 'HTTP/1.1 200 \r\nDate: Thu, 22 Oct 2026 07:12:44 GMT\r\nTransfer-Encoding: chunked\r\n\r\n' > .harness/p1
PL=$(hdrs .harness/p1); [ "$PL" = "$(printf '%s\n' '  the headers curl saved, as they came: 3 lines, the status line first (Date'"'"'s value masked):' '    HTTP/1.1 200' '    Date: …' '    Transfer-Encoding: chunked' '  Content-Length: none · Transfer-Encoding: chunked')" ] || die "hdrs: the planted headers do not come out as declared"
printf 'a\nb\n' > .harness/p1; printf 'a\nb' > .harness/p2; : > .harness/p3
PL=$(body .harness/p1; body .harness/p2; body .harness/p3); [ "$PL" = "$(printf '%s\n' '  the body curl saved: 2 lines, 4 bytes, the last one ended:' '    | a' '    | b' '  the body curl saved: 1 lines, 3 bytes, the last one cut:' '    | a' '    | b' '  the body curl saved: nothing')" ] || die "body: the planted bodies do not come out as declared"
rm -f .harness/run.out .harness/p1 .harness/p2 .harness/p3
echo "  the filters: the answer, record, harness-line, header and body filters print their planted inputs as declared; a harness line that says ERROR is no ERROR line; a falling running number stops the run"

# ---- limits: the anchor, the harness, the seven, Boot's metadata and the bean it built --------------------------------------------
limits() {
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"; extract .harness/anchor
  echo "the harness, compiled against the anchor's own jar - with -parameters (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jar"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19490, a fresh JVM:"
  start "$(at .harness/anchor 19490 "$R_RUN")"; up 19490; ready 19490; seven 19490 .harness/anchor; WARNS; logl 0 WARN
  echo "the keys - what Boot's own metadata declares under spring.servlet.multipart. (in $SERVLETJAR, from the anchor's extracted lib/; this unit's line):"
  echo "\$ $L_KEYS"; (eval "$L_KEYS") 2>&1 < /dev/null | sed 's/^/  /'
  echo "the bean - the anchor on its class path, the harness joined (Files, Dispatches, Refusals), port 19491: Boot's MultipartConfigElement, read back:"
  start "$(hcp .harness/anchor 19491 "$ALL")"; up 19491; ready 19491; loc
  rq "$(url "${R_READY/actuator\/health\/readiness/probe/multipart}" 19491)"
  WARNS; stop 19491 .harness/anchor; }

# ---- upload: a small file in -----------------------------------------------------------------------------------------------
upload() {
  echo "a small menu - three lines of CSV, made here (printf):"
  mkdir -p .harness/files
  c="printf 'day,lunch,dinner\\nMonday,lentil soup,rice and beans\\nTuesday,vegetable curry,flatbread\\n' > .harness/files/menu.csv"; echo "\$ $c"; (eval "$c")
  echo "  its size: $(wc -c < .harness/files/menu.csv | tr -d ' ') bytes · its lines: $(wc -l < .harness/files/menu.csv | tr -d ' ')"
  echo "sent - the anchor on its class path, the harness joined, port 19492: once as curl sends it, once with the part's type named:"
  start "$(hcp .harness/anchor 19492 "$ALL")"; up 19492; ready 19492; loc
  rq "$(uq 19492 menu.csv)"
  rq "$(uq 19492 menu.csv text/csv)"
  WARNS; stop 19492 .harness/anchor; }

# ---- limit: the line, A/B/A'; C labelled -------------------------------------------------------------------------------------
files() { local b; mkdir -p .harness/files
  for b in 1048576 1048577 1500000 12000000; do c=$(mk $b); echo "\$ $c"; (eval "$c"); echo "  its size: $(wc -c < .harness/files/menu-$b.txt | tr -d ' ') bytes"; done; }
# lrun PORT 'OPTION' SIZE...: the anchor on its class path, the harness joined, OPTION after it (none: ""); the limits read back; each
# test file of those SIZES sent as the menu part; the JVM left running for the caller to stop
lrun() { local f p=$1; start "$(hcp .harness/anchor "$1" "$ALL" "${2:-}")"; up "$1"; ready "$1"; loc
  rq "$(url "${R_READY/actuator\/health\/readiness/probe/multipart}" "$1")"
  shift 2; for f in "$@"; do rq "$(uq "$p" "menu-$f.txt")"; done; }
limit() {
  echo "the test files - made here, each of one byte repeated (this unit's line, with each size):"
  files
  echo "A - the anchor on its class path, the harness joined, Boot's limits, port 19493:"
  lrun 19493 "" 1048576 1048577 1500000 12000000; WARNS; stop 19493 .harness/anchor
  echo "B - the same, the file limit raised for this run (this unit's line: Boot's key, as an option), port 19494:"
  lrun 19494 "$O_MB" 1500000; WARNS; stop 19494 .harness/anchor
  echo "A' - A again, a fresh JVM, port 19493:"
  lrun 19493 "" 1048576 1048577 1500000 12000000; WARNS; stop 19493 .harness/anchor
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"
  echo "C (labelled) - B's key again, a fresh JVM, port 19495: twelve million bytes, over the request's own limit:"
  lrun 19495 "$O_MB" 12000000; WARNS; stop 19495 .harness/anchor; }

# ---- bill: a customer's bill, streamed ----------------------------------------------------------------------------------------
bill() {
  echo "a bill streamed - the anchor on its class path, the harness joined, port 19496: Ravi (a customer the anchor seeds), then a name nobody has:"
  start "$(hcp .harness/anchor 19496 "$ALL")"; up 19496; ready 19496; loc
  gt "$(gq 19496 /probe/bill/Ravi)"
  cp .harness/body.csv .harness/streamed-Ravi.csv
  echo "the same bill once more, its framing kept - curl --raw writes each chunk's size line too (this unit's line):"
  rm -f .harness/raw.txt .harness/raw.txt.data; c=$(rawq 19496); echo "\$ $c"; e=0; (eval "$c") < /dev/null || e=$?
  echo "  curl's exit code: $e · the chunks' sizes, in bytes, as they came: [$(chunks .harness/raw.txt)] · their data = the bill above, byte for byte: $(cmp -s .harness/raw.txt.data .harness/streamed-Ravi.csv && echo yes || echo no)"; settle
  gt "$(gq 19496 /probe/bill/Nobody)"
  WARNS; stop 19496 .harness/anchor; }

# ---- resource: the same bill whole; a name that is not ASCII; curl -O -J -----------------------------------------------------------
resource() {
  echo "the bill whole - the anchor on its class path, the harness joined, port 19497: Ravi's, as a Resource; then a range of it:"
  start "$(hcp .harness/anchor 19497 "$ALL")"; up 19497; ready 19497; loc
  gt "$(gq 19497 /probe/bill-whole/Ravi)"
  echo "  the same bytes as the streamed bill (bill, above): $(cmp -s .harness/body.csv .harness/streamed-Ravi.csv && echo yes || echo no)"
  gt "$(gq 19497 /probe/bill-whole/Ravi '-r 0-15')"
  echo "a name that is not ASCII - Zoë K, added with the anchor's own POST (this unit's line: another name), then the streamed bill's headers:"
  rq "$(url "$L_ZOE" 19497)"
  gt "$(gq 19497 /probe/bill/Zo%C3%AB%20K)" nobody
  echo "curl -O -J - each bill saved under the name the answer gives, in a folder of its own (this unit's line):"
  rm -rf .harness/dl; mkdir -p .harness/dl
  for p in /probe/bill/Ravi /probe/bill/Zo%C3%AB%20K; do c=$(oj 19497 "$p"); echo "\$ $c"; e=0; (eval "$c") > .harness/oj.out 2>&1 < /dev/null || e=$?; echo "  curl's exit code: $e · it printed: $(grep -c . .harness/oj.out || true) lines"; done
  echo "  the folder now holds: $(ls .harness/dl | wc -l | tr -d ' ') files"
  ls .harness/dl | while IFS= read -r f; do echo "    [$f] · $(wc -l < ".harness/dl/$f" | tr -d ' ') lines · its first: $(head -1 ".harness/dl/$f") · its last: $(tail -1 ".harness/dl/$f")"; done
  echo "  Ravi's saved bill is the streamed bill, byte for byte: $(cmp -s ".harness/dl/bill Ravi.csv" .harness/streamed-Ravi.csv && echo yes || echo no)"
  WARNS; stop 19497 .harness/anchor; }

# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy, CURL_HOME) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this
# folder. A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit
# code and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files),
# and the README's run log kept before the solution's run writes its own. Bounded (600 s); on the way out, or past the bound, the
# shell and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 4 ] || die "SOLUTION.md's first bash block must be the README's two export lines, the solution's key line and the README's last line"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  printf '%s\n' "$sol" | sed -n 3p | grep -qxF "printf 'spring.servlet.multipart.max-file-size: 2MB\\n' > .harness/mine/anchor/tiffinbox-local.yaml" || die "SOLUTION.md's third line must write the key into the copy's tiffinbox-local.yaml"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 4p)
  [ "$l1" = "$l2" ] || die "SOLUTION.md's last line must be the README's last line, unchanged: the fix is a key, not the command"
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
  echo "  the shell is now in: $(where "$d1") · the menu it sent: $(wc -c < .harness/mine/menu.txt | tr -d ' ') bytes · the JVM's locale in its log: $(grep -m1 "^MenuDesk: the JVM's locale: " .harness/ex-readme.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19499 now: $(listeners 19499)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the menu it sent: $(wc -c < .harness/mine/menu.txt | tr -d ' ') bytes · the JVM's locale in its log: $(grep -m1 "^MenuDesk: the JVM's locale: " .harness/mine/run.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19499 now: $(listeners 19499)"
  echo "  the file the solution wrote, .harness/mine/anchor/tiffinbox-local.yaml, whole: $(grep -c . .harness/mine/anchor/tiffinbox-local.yaml) line"
  sed 's/^/    /' .harness/mine/anchor/tiffinbox-local.yaml; }

cap limits limits
cap upload upload
cap limit limit
cap bill bill
cap resource resource
cap exercise exercise
echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: did not expect the line: $2"; }
# aft CMDLINE BLOCK: the line after the first line of BLOCK that is exactly CMDLINE (a command's first answer line) - the line is
# handed to awk through its environment, which keeps a backslash a backslash (-v would turn \n into a newline)
aft() { printf '%s\n' "$2" | C="$1" awk 'f { print; exit } $0 == ENVIRON["C"] { f = 1 }'; }
# seg BLOCK 'COMMAND': the lines a command printed in BLOCK - from the line after "$ COMMAND" up to the next "$ " line or label line
seg() { printf '%s\n' "$1" | C="\$ $2" awk 'f && (/^\$ / || /^[A-Za-z]/) { exit } f { print } $0 == ENVIRON["C"] { f = 1 }'; }
# hl SEGMENT: its harness lines, numbers and padding taken off ("Dispatches in REQUEST /probe/bill/Ravi"), one a line
hl() { printf '%s\n' "$1" | awk '/^ +[0-9]+ [A-Z][A-Za-z]+ +/ { $1 = ""; sub(/^ /, ""); gsub(/ +/, " "); print }'; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted when
# it was read: logtok()), nor anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
for f in .r-*.out README.md exercise/README.md exercise/MenuDesk.java exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/keys.py $HWS; do
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qiE '<html>|<!doctype' "$f" || die "$f shows an HTML page whole"; ! grep -qE 'its size \([0-9]' "$f" || die "$f shows Tomcat's request size unmasked"; ! grep -qiE 'size_upload|bytes sent' "$f" || die "$f counts bytes curl sent (R.121)"; done
for f in receipts.sh README.md exercise/README.md exercise/MenuDesk.java exercise/solution/SOLUTION.md harness/shutdown.sh harness/keys.py $HWS; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# S3.21 (R.99): Boot 4.1 reads only spring.web.error.*, and Boot 3's keys (server, then error) are ignored without a word - no file of
# this unit names one (the name is split here, so this line does not spell it)
K3='server'; K3="$K3.error."
for f in receipts.sh README.md exercise/README.md exercise/MenuDesk.java exercise/solution/SOLUTION.md harness/shutdown.sh harness/keys.py $HWS; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys - Boot 4.1 reads only spring.web.error.* (S3.21)"; done
# S3.18 (R.114): no harness class reaches the anchor - its tree names none of them (as whole words), and no capture runs one but on a
# class-path line that joins it by --spring.main.sources
for c in Files Dispatches Refusals MenuDesk probe.web; do ! grep -rqwF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c (a whole word) - the harness is shown on the harness, never in the anchor (S3.18)"; done
# S3.9 (R.105): no wait in this script, its checks or the exercise is bare - each names its pid ($! or a variable)
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
# no capture runs a command with a URL that is not 127.0.0.1's
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
# S4.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes)
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S4.1)"; done
# the exercise's java line pins the JVM's locale too (it starts with M=..., so the check above does not see it)
for f in exercise/README.md exercise/solution/SOLUTION.md; do [ "$(grep -c '{ java ' "$f")" = 1 ] && grep '{ java ' "$f" | grep -qF -- "{ java $JL -cp " || die "$f: the exercise's java line must pin the JVM's locale (S4.1)"; done
# no test file is shipped: none under this folder outside .harness/ (git ignores .harness/)
[ -z "$(find . -path ./.harness -prune -o -path ./.m2-demo -prune -o -type f \( -name 'menu-*.txt' -o -name 'menu.txt' -o -name 'menu.csv' -o -name 'bill *.csv' \) -print)" ] || die "a test file or a saved bill lies outside .harness/ - every one is made under .harness/, never shipped"
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the exercise and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no whole HTML page, no 8080 or 35729, no carriage return, no unmasked request size, no bytes-sent count in any capture; no Boot 3 error key; no harness class in the anchor; no bare wait; every java line's locale pinned; every URL a capture runs is 127.0.0.1's; no test file outside .harness/"

S466='466c20ed7e0d5439cb052f32ce09de1b'
LOC="  the JVM's locale (the harness's Files): en_US"
Z00=' · WARN lines it added: 0 · ERROR lines: 0'
P413='  {"detail":"Maximum upload size exceeded","instance":"/probe/menu","status":413,"title":"Content Too Large"} 413 · Content-Type: [application/problem+json] · Connection: [close]'
FSL="Refusals MaxUploadSizeExceededException - under it, Tomcat's FileSizeLimitExceededException: The field menu exceeds its maximum permitted size of 1048576 bytes."
RSL="Refusals MaxUploadSizeExceededException - under it, Tomcat's SizeLimitExceededException: the request was rejected because its size (…) exceeds the configured maximum (10485760)"
OKM() { printf '  {"file":"menu-%s.txt","bytes":%s,"type":"text/plain","lines":1} 200 · Content-Type: [application/json] · Connection: []' "$1" "$1"; }

# "Boot's own metadata ... one mebibyte a file, ten a request ... the bean Boot built: one million, forty-eight thousand, five hundred
# and seventy-six ... a threshold of zero" - limits
LO=$(cat .r-limits.out)
has "$LO" '  built the anchor · offline: yes · exit 0' "limits: the anchor built offline"
has "$LO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "limits: the seven $S466"
has "$LO" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported' "limits: the seven's one WARN, PageNotFound"
has "$LO" '  exit 0 · its classes: probe/web/Dispatches$Seen.class probe/web/Dispatches.class probe/web/Files.class probe/web/Refusals.class probe/web/Trace.class' "limits: the harness's classes"
has "$LO" '  spring.servlet.multipart.max-file-size · default 1MB · DataSize' "limits: the file key's default"
has "$LO" '  spring.servlet.multipart.max-request-size · default 10MB · DataSize' "limits: the request key's default"
has "$LO" '  spring.servlet.multipart.file-size-threshold · default 0B · DataSize' "limits: the threshold key's default"
has "$LO" '  7 keys under spring.servlet.multipart.' "limits: 7 keys"
has "$LO" "$LOC" "limits: the locale"
has "$LO" "  {\"maxFileSize\":1048576,\"maxRequestSize\":10485760,\"fileSizeThreshold\":0,\"location\":\"\"} 200$Z00" "limits: the bean, 1048576 / 10485760 / 0 / no location"
has "$LO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "limits: the harness run 0/0"
[ $((1024 * 1024)) = 1048576 ] && [ $((10 * 1024 * 1024)) = 10485760 ] || die "limits: a mebibyte"
echo "  limits: the seven $S466, 1 WARN (PageNotFound); Boot's metadata: 7 keys, max-file-size 1MB, max-request-size 10MB, threshold 0B; the bean: 1048576 / 10485760 / 0 / location empty; en_US, 0/0"

# "three lines ... two hundred: its name, its size, three lines ... the type: application octet-stream, curl's guess ... told text/csv,
# the server repeats it" - upload
UO=$(cat .r-upload.out)
has "$UO" '  its size: 85 bytes · its lines: 3' "upload: the menu's size and lines"
has "$UO" "$LOC" "upload: the locale"
S_U1=$(seg "$UO" "$(uq 19492 menu.csv)"); S_U2=$(seg "$UO" "$(uq 19492 menu.csv text/csv)")
has "$S_U1" '  {"file":"menu.csv","bytes":85,"type":"application/octet-stream","lines":3} 200 · Content-Type: [application/json] · Connection: []'"$Z00" "upload: curl's guess"
has "$S_U2" '  {"file":"menu.csv","bytes":85,"type":"text/csv","lines":3} 200 · Content-Type: [application/json] · Connection: []'"$Z00" "upload: the type curl was told"
hl "$S_U1" | grep -qxF 'Files menu: part menu, 85 bytes' || die "upload: the route read the part"
grep -qF '@RequestPart("menu") MultipartFile menu' harness/probe/web/Files.java || die "upload: the route takes @RequestPart(\"menu\")"
echo "  upload: 85 bytes, 3 lines -> 200 (menu.csv, application/octet-stream as curl sent it; text/csv when told), 0/0"

# "exactly one mebibyte: two hundred ... one byte more: four thirteen, a problem detail, Content Too Large, the connection closed, not
# one warning ... Tomcat's file limit ... twelve million bytes: the request's limit ... B: two mebibytes ... A again ... C: the request
# limit still says no" - limit
LM=$(cat .r-limit.out); LA=$(blk limit "A - " "B - "); LB=$(blk limit "B - " "A' - "); LA2=$(blk limit "A' - " "A' against A"); LC=$(blk limit "C (labelled)" '')
for b in 1048576 1048577 1500000 12000000; do has "$LM" "  its size: $b bytes" "limit: the $b-byte file"; done
[ "$(printf '%s\n' "$LM" | grep -c "^$LOC\$")" = 4 ] || die "limit: four JVMs, each en_US"
has "$(seg "$LA" "$(uq 19493 menu-1048576.txt)")" "$(OKM 1048576)$Z00" "limit A: 1048576 bytes -> 200"
for b in 1048577 1500000 12000000; do has "$(seg "$LA" "$(uq 19493 menu-$b.txt)")" "$P413$Z00" "limit A: $b bytes -> 413 problem detail, Connection: close, 0/0"; done
for b in 1048577 1500000; do hl "$(seg "$LA" "$(uq 19493 menu-$b.txt)")" | grep -qxF -- "$(printf '%s' "$FSL" | sed 's/  */ /g')" || die "limit A: $b bytes - Tomcat's file limit"; done
hl "$(seg "$LA" "$(uq 19493 menu-12000000.txt)")" | grep -qxF -- "$RSL" || die "limit A: 12000000 bytes - Tomcat's request limit"
! hl "$(seg "$LA" "$(uq 19493 menu-1048577.txt)")" | grep -q '^Files menu' || die "limit A: the route never ran for a refused upload"
has "$LA" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "limit A: the run 0/0"
has "$LB" "\$ $(hcp .harness/anchor 19494 "$ALL" "$O_MB")" "limit B: its line"
has "$LB" "  {\"maxFileSize\":2097152,\"maxRequestSize\":10485760,\"fileSizeThreshold\":0,\"location\":\"\"} 200$Z00" "limit B: 2MB read back as 2097152"
has "$(seg "$LB" "$(uq 19494 menu-1500000.txt)")" "$(OKM 1500000)$Z00" "limit B: 1500000 bytes -> 200"
[ $((2 * 1024 * 1024)) = 2097152 ] || die "limit B: two mebibytes"
has "$LM" "A' against A, its label aside, line for line the same: yes" "limit: A' = A"
has "$LC" "\$ $(hcp .harness/anchor 19495 "$ALL" "$O_MB")" "limit C: B's key"
has "$(seg "$LC" "$(uq 19495 menu-12000000.txt)")" "$P413$Z00" "limit C: 12000000 bytes under B -> 413"
hl "$(seg "$LC" "$(uq 19495 menu-12000000.txt)")" | grep -qxF -- "$RSL" || die "limit C: the request limit"
echo "  limit: A - 1048576 -> 200; 1048577, 1500000 -> 413 (Tomcat's file limit), 12000000 -> 413 (the request limit), problem detail, Connection: close, 0/0; B --spring.servlet.multipart.max-file-size=2MB -> 2097152, 1500000 -> 200; A' = A; C B's key, 12000000 -> 413, the request limit"

# "the handler returns before a byte is written ... another thread writes it ... chunked, no length ... Content-Disposition: attachment,
# a filename ... thirty days and the month: seven thousand two hundred ... an async dispatch ... nobody: four oh four, nothing written" - bill
BO=$(cat .r-bill.out)
has "$BO" "$LOC" "bill: the locale"
S_B=$(seg "$BO" "$(gq 19496 /probe/bill/Ravi)"); S_N=$(seg "$BO" "$(gq 19496 /probe/bill/Nobody)")
has "$S_B" "  curl's line: 200 · Content-Type: [text/csv;charset=UTF-8] · curl's exit code: 0$Z00" "bill: 200 text/csv"
has "$S_B" '  Content-Length: none · Transfer-Encoding: chunked' "bill: chunked, no Content-Length"
has "$S_B" "    Content-Disposition: attachment; filename=\"bill Ravi.csv\"; filename*=UTF-8''bill%20Ravi.csv" "bill: the disposition, both forms"
has "$S_B" '  the body curl saved: 32 lines, 595 bytes, the last one ended:' "bill: 32 lines"
has "$S_B" '    | day,customer,meals,price per meal,amount' "bill: the header row"
has "$S_B" '    | 1,Ravi,2,120,240' "bill: day 1"
has "$S_B" '    | 30,Ravi,2,120,240' "bill: day 30"
has "$S_B" '    | month,Ravi,60,120,7200' "bill: the month, 7200"
[ $((2 * 120 * 30)) = 7200 ] || die "bill: Ravi's month"
grep -qF '{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}' .harness/seven-19490.txt || die "bill: Ravi as the anchor serves him (the seven's list)"
W_B='Dispatches in REQUEST /probe/bill/Ravi|Files bill: the handler returns, nothing written yet, on tomcat-handler-<n> (virtual: true)|Files bill: the body written, 32 lines, on task-<n> (virtual: true), the handler'"'"'s thread: no|Dispatches in ASYNC /probe/bill/Ravi|Dispatches out ASYNC /probe/bill/Ravi status 200'
[ "$(hl "$S_B" | paste -sd'|' -)" = "$W_B" ] || die "bill: the harness's lines, in order - got: $(hl "$S_B" | paste -sd'|' -)"
has "$S_N" "  curl's line: 404 · Content-Type: [] · curl's exit code: 0$Z00" "bill: Nobody 404"
has "$S_N" '  the body curl saved: nothing' "bill: Nobody - nothing written"
has "$S_N" '  Content-Length: 0 · Transfer-Encoding: none' "bill: Nobody - Content-Length 0"
[ "$(hl "$S_N" | paste -sd'|' -)" = 'Dispatches in REQUEST /probe/bill/Nobody|Files bill: no customer Nobody - 404, nothing written|Dispatches out REQUEST /probe/bill/Nobody status 404' ] || die "bill: Nobody - one REQUEST dispatch"
# "here the whole bill fit in one chunk" (RED S4 #344): curl --raw's framing read - one chunk of 595 bytes, then the last, empty one
has "$BO" "\$ $(rawq 19496)" "bill: the --raw line"
has "$BO" "  curl's exit code: 0 · the chunks' sizes, in bytes, as they came: [595, 0] · their data = the bill above, byte for byte: yes" "bill: one chunk of 595 bytes, then the end"
has "$BO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "bill: the run 0/0"
grep -qF 'private final CustomerRepository customers;' harness/probe/web/Files.java && grep -qF 'customers.findByName(name)' harness/probe/web/Files.java || die "bill: the harness reads TiffinBox's own CustomerRepository"
grep -qF 'b.setDispatcherTypes(EnumSet.allOf(DispatcherType.class));' harness/probe/web/Dispatches.java && grep -qF 'b.addUrlPatterns("/probe/bill/*", "/probe/bill-whole/*");' harness/probe/web/Dispatches.java || die "bill: Dispatches is registered for every dispatch type, on the two bill paths"
echo "  bill: Ravi - 200 text/csv, chunked, no Content-Length, attachment filename + filename*, 32 lines, the month 7200; the handler returns on tomcat-handler, the body written on task (another thread), then the ASYNC dispatch; Nobody - 404, nothing written, one REQUEST dispatch; --raw: one chunk, 595 bytes, then the empty last; 0/0"

# "a Resource ... a length: five hundred and ninety-five ... Accept-Ranges ... the first sixteen bytes: two oh six ... the same bytes
# ... Zoë: filename Zoe K, and the encoded one ... curl -O -J saved bill Zoe K, the plain one" - resource
RO=$(cat .r-resource.out)
has "$RO" "$LOC" "resource: the locale"
S_W=$(seg "$RO" "$(gq 19497 /probe/bill-whole/Ravi)"); S_R=$(seg "$RO" "$(gq 19497 /probe/bill-whole/Ravi '-r 0-15')"); S_Z=$(seg "$RO" "$(url "$L_ZOE" 19497)"); S_ZB=$(seg "$RO" "$(gq 19497 /probe/bill/Zo%C3%AB%20K)")
has "$S_W" "  curl's line: 200 · Content-Type: [text/csv;charset=UTF-8] · curl's exit code: 0$Z00" "resource: 200"
has "$S_W" '  Content-Length: 595 · Transfer-Encoding: none' "resource: Content-Length 595, not chunked"
has "$S_W" '    Accept-Ranges: bytes' "resource: Accept-Ranges"
has "$S_W" '  the body curl saved: 32 lines, 595 bytes, the last one ended:' "resource: the whole bill"
[ "$(hl "$S_W" | paste -sd'|' -)" = 'Dispatches in REQUEST /probe/bill-whole/Ravi|Files bill-whole: the handler returns 595 bytes, whole, on tomcat-handler-<n> (virtual: true)|Dispatches out REQUEST /probe/bill-whole/Ravi status 200' ] || die "resource: one REQUEST dispatch, whole"
has "$RO" '  the same bytes as the streamed bill (bill, above): yes' "resource: the same bytes"
has "$S_R" "  curl's line: 206 · Content-Type: [text/csv;charset=UTF-8] · curl's exit code: 0$Z00" "resource: the range 206"
has "$S_R" '    Content-Range: bytes 0-15/595' "resource: Content-Range"
has "$S_R" '  the body curl saved: 0 lines, 16 bytes, the last one cut:' "resource: 16 bytes"
has "$S_Z" "  $ZOE 201$Z00" "resource: Zoë K added, 201"
has "$S_ZB" "    Content-Disposition: attachment; filename=\"bill Zoe K.csv\"; filename*=UTF-8''bill%20Zo%C3%AB%20K.csv" "resource: the ASCII fallback and the encoded name"
has "$RO" '  the folder now holds: 2 files' "resource: curl -O -J saved two files"
has "$RO" '    [bill Ravi.csv] · 32 lines · its first: day,customer,meals,price per meal,amount · its last: month,Ravi,60,120,7200' "resource: bill Ravi.csv"
has "$RO" '    [bill Zoe K.csv] · 32 lines · its first: day,customer,meals,price per meal,amount · its last: month,Zoë K,60,110,6600' "resource: bill Zoe K.csv, the ASCII name"
[ "$(printf '%s\n' "$RO" | grep -c "^  curl's exit code: 0 · it printed: 0 lines\$")" = 2 ] || die "resource: curl -O -J, exit 0 twice"
has "$RO" "  Ravi's saved bill is the streamed bill, byte for byte: yes" "resource: the saved file"
[ $((2 * 110 * 30)) = 6600 ] || die "resource: Zoë K's month"
has "$RO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "resource: the run 0/0"
echo "  resource: Ravi whole - 200, Content-Length 595, Accept-Ranges: bytes, the same bytes; -r 0-15 -> 206, Content-Range 0-15/595, 16 bytes; Zoë K 201, filename=\"bill Zoe K.csv\" + filename*=UTF-8''bill%20Zo%C3%AB%20K.csv; curl -O -J: bill Ravi.csv, bill Zoe K.csv; 0/0"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='the menu: 200 application/json'; l0='the menu: 413 application/problem+json'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the menu it sent: 1500000 bytes · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19499 now: 0" "exercise: as shipped, 0/0 in its log"
has "$XE" "  the shell is now in: this unit's folder · the menu it sent: 1500000 bytes · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19499 now: 0" "exercise: the solution, 0/0 in its log"
has "$XE" '    spring.servlet.multipart.max-file-size: 2MB' "exercise: the key the solution writes"
grep -qxF "printf 'spring.servlet.multipart.max-file-size: 2MB\\n' > .harness/mine/anchor/tiffinbox-local.yaml" exercise/solution/SOLUTION.md || die "SOLUTION.md: the key line the capture ran is not the one it ships"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
EXQ="Your turn: the README's menu upload answers four thirteen. Read the limit's key, raise it, and upload again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (1500000 bytes, Boot's limit) -> $l0; the solution (max-file-size: 2MB in the copy's tiffinbox-local.yaml) -> $l; the shell in this unit's folder after each"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit20: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log"
