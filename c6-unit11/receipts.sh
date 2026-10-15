#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · Content Negotiation - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit10/after, the tree the
# responses lesson froze, which answers in JSON alone. This script copies that tree twice under .harness/ - once as it is (the
# anchor), once with one dependency line added to its web module's POM (the copy: harness/xml.patch, Jackson's XML module, no
# version) - and asks both for their answers with the request's Accept header, the header that names the formats a client takes.
# Eight captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run and in every file this unit ships.
#   anchor     the anchor: the seven; then one customer asked for as JSON, as XML and as HTML, a name nobody has asked for as XML, a
#              customer sent as XML, and the last course's scrape asked for in its two formats
#   xml        the copy: the patch and its one-line diff, the build, the executable jar's libraries against the anchor's; the harness's
#              Formats joined to each tree - Spring MVC's message converters in order, which of them can write a Customer for five
#              media types, and Boot's condition report for the configurations whose name holds Xml
#   accept     the copy: the seven (curl asks for */*); then the customers asked for as XML, as JSON, with a weighted list and as text
#   shapes     the copy: one customer, the month's revenue and two error bodies, asked for as XML; a customer sent as XML and asked
#              back as XML, its Location followed as XML; another sent as XML with no Accept header; the first name again; a body cut
#              short
#   browser    C (labelled): a browser's Accept header, sent by curl - to the anchor, then to the copy; D (labelled): the copy with Boot's
#              default-content-types key and the harness joined - Boot's metadata for the key, the content negotiation manager's
#              strategies, the browser's header again; E (labelled): the copy with the harness joined and no key - the strategies, then
#              the harness's two routes, one that produces JSON, one that produces JSON or XML
#   actuator   health, asked for as XML, as JSON and with a browser's Accept header - the anchor, then the copy
#   param      A/B/A': ?format=xml on the copy as Boot sets it up (A); with favor-parameter on (B); A again (A'); Boot's metadata; then
#              C (labelled): the copy with the harness joined and favor-parameter on - the content negotiation manager's strategies
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit10/after (the responses lesson's frozen tree), COPIED under .harness/anchor; "the
# copy" is the same tree COPIED under .harness/xml with harness/xml.patch applied. This script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree
# with a fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. The harness - harness/probe/web/Formats.java (compiled with
# -parameters), the course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
# path; harness/shutdown.sh (POST /shutdown, the token read from its file); harness/xml.patch (the copy's one line) - is named on every
# capture that uses it. Every run passes options only. The seven always run on a fresh JVM, before any POST: a POST stores a
# customer, and three of the seven list customers; and every POST of one run names a customer no earlier POST of that run named,
# unless the capture says it posts a name again.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build and no Docker: this unit measures
# the JVM jar alone. At run time nothing leaves 127.0.0.1: TiffinBox listens there, every request goes there, and Logback writes to
# the terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. Spring's error timestamp becomes "…" - in JSON both forms (an ISO-8601 string, epoch milliseconds), in XML
# the text of a <timestamp> element - in the seven and wherever an answer is printed; the date and time on Boot's HTML error page
# (its <div id='created'>) becomes "…". A run's log lines are printed from their logger on (no time, no process id, no thread);
# Boot's first line is cut before " with PID". Long answers go through a declared filter, and what it cuts is counted. No duration is
# captured.
# Ports (brief ⚑1, 19400-19409): the anchor 19400 · the copy 19401 · the copy with the harness joined 19402 · the anchor with the
# harness joined 19403 · the copy with favor-parameter (B, and C with the harness) 19404 · the copy with default-content-types and the
# harness 19405 · the exercise 19409 (19406, 19407 and 19408 are never bound). 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too, and never bound.
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
# $xpid, the exercise's shell, with every process under it - its Maven, its JVM, its curl), if they still run, then sweep(): anything
# of this run still alive in its process group - a TiffinBox JVM - is stopped. After an interrupt, a capture's unfinished runs
# (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and
# nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an interrupt (README.md,
# "Interrupted"). $pid and $xpid are cleared whenever their process has been reaped. sweep() kills only processes of this run's own
# process group - start each run in a group of its own (README.md, "Interrupted").
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
for t in python3 curl rsync lsof unzip javac patch openssl mvn; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A SPRING_MVC_* of yours
# could switch on the format parameter, or a default content type, in every capture here.)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit10/after ] || die "anchor must be the link to ../c6-unit10/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=a-fake-demo-token-for-xml1
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HW=harness/probe/web/Formats.java
for f in harness/shutdown.sh harness/xml.patch $HW exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Formats.java' ] || die "harness/probe/web holds another file: javac compiles all of it"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19400 19401 19402 19403 19404 19405 19406 19407 19408 19409; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole ---------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme "$J")
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
# the responses lesson's POST, its answer's Location printed; the last course's scrape - curl's own Accept, then OpenMetrics asked for
R_LOC=$(readme "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_SCR0=$(readme "curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/actuator/prometheus")
R_SCR1=$(readme "curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' -H 'Accept: application/openmetrics-text; version=1.0.0' http://127.0.0.1:18431/actuator/prometheus")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the copy's patch and its diff
# (xml); a GET that prints its answer, the answer's status and its Content-Type - with an XML Accept header, with a browser's, and with
# none and a format parameter; a POST of an XML body that asks for XML back, and the same with no Accept header; the harness's question;
# the run line with favor-parameter on; the run line with a default content type
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_PATCH=$(mine 'cd .harness/xml && patch -s -p1 < ../../harness/xml.patch && diff -U0 ../../anchor/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d')
L_AX=$(mine "curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:18431/customers/Ravi")
BR='text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
L_BR=$(mine "curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: $BR' http://127.0.0.1:18431/customers/Ravi")
L_FMT=$(mine "curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' 'http://127.0.0.1:18431/customers/Ravi?format=xml'")
XASHA='<Customer><name>Asha</name><mealsPerDay>2</mealsPerDay><pricePerMeal>110</pricePerMeal><mealType>VEG</mealType></Customer>'
L_XPOST=$(mine "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Accept: application/xml' -H 'Content-Type: application/xml' --data '$XASHA' http://127.0.0.1:18431/customers")
L_XPOST0=$(mine "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/xml' --data '$XASHA' http://127.0.0.1:18431/customers")
L_PROBE=$(mine 'curl -s http://127.0.0.1:18431/probe/formats')
L_STRAT=$(mine 'curl -s http://127.0.0.1:18431/probe/formats/strategies')
L_CV=$(mine "curl -s -o /dev/null -v http://127.0.0.1:18431/customers 2>&1 | grep '^> Accept' | tr -d '\\r'")
L_FAV=$(mine "$J --spring.mvc.contentnegotiation.favor-parameter=true")
L_DCT=$(mine "$J --spring.mvc.contentnegotiation.default-content-types=application/json")
# The derivations, each asserted: the browser's and the format parameter's lines are the XML line with only the Accept header's value,
# or the header itself, and the path changed; the XML POST without an Accept header is the one with it, that header out; and that is
# the responses lesson's Location line with its JSON Content-Type made XML's and its body Asha's as XML elements - nothing else
TQW=${L_AX% -H *}                                    # the line's curl and its -w, before the Accept header
# (the pattern and the replacement are variables, and each result an assignment: /bin/bash 3.2 ends a pattern at a slash even inside
# quotes, and keeps a quoted replacement's quotes inside a quoted expansion)
XA=" -H 'Accept: application/xml'"
CTJ="-H 'Content-Type: application/json'"; CTX="-H 'Content-Type: application/xml'"
ADATA='{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
r=${L_XPOST/"$XA"/}; [ "$r" = "$L_XPOST0" ] || die "the XML POST without Accept must be the one with it, its Accept header out, and nothing else"
r=${R_LOC/"$CTJ"/$CTX}; r=${r/"$ADATA"/$XASHA}; [ "$r" = "$L_XPOST0" ] || die "the XML POST must be the responses lesson's Location line with an XML Content-Type and Asha's body as XML, and nothing else"
O_FAV=${L_FAV#"$R_RUN "}; O_DCT=${L_DCT#"$R_RUN "}     # the two options, as this unit's run lines give them
[ "$O_FAV" = '--spring.mvc.contentnegotiation.favor-parameter=true' ] && [ "$O_DCT" = '--spring.mvc.contentnegotiation.default-content-types=application/json' ] || die "the run lines must be the anchor's run line with one option each"
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package) clean and without tests. dev() takes those four things back out, and must give the
# README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# hcp DIR PORT CLASSES ['OPTION']: the README's class-path line - the extracted jar, TiffinBox's own main - from DIR, its port made
# PORT, the harness's classes added to the class path (../hc) and CLASSES joined (--spring.main.sources=); OPTION after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# qurl PORT PATH: the URL; one that holds a character the shell reads (; ? & * { } or a space) is single-quoted, so eval hands it to
# curl whole
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}\ ]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
# tq PORT PATH [ACCEPT]: this unit's GET line - its port and its path swapped, its Accept header's value made ACCEPT (with no ACCEPT,
# no Accept header at all: curl then sends its own, */*)
tq() { if [ -n "${3:-}" ]; then printf "%s -H 'Accept: %s' %s\n" "$TQW" "$3" "$(qurl "$1" "$2")"; else printf '%s %s\n' "$TQW" "$(qurl "$1" "$2")"; fi; }
# xpc PORT 'BODY' / xpc0 PORT 'BODY': this unit's XML POST, with and without its Accept header - the port and the body swapped, the
# body single-quoted as the README writes it
XPRE=${L_XPOST% --data *}; XPRE0=${L_XPOST0% --data *}
xpc() { printf "%s --data '%s' %s\n" "$XPRE" "$2" "$(qurl "$1" /customers)"; }
xpc0() { printf "%s --data '%s' %s\n" "$XPRE0" "$2" "$(qurl "$1" /customers)"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19400 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19400' ] || die "exe()"
[ "$(hcp .harness/x 19402 probe.web.Formats)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19402 --spring.main.sources=probe.web.Formats' ] && [ "$(hcp .harness/x 19405 probe.web.Formats "$O_DCT")" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19405 --spring.main.sources=probe.web.Formats --spring.mvc.contentnegotiation.default-content-types=application/json' ] || die "hcp()"
[ "$(tq 18431 /customers/Ravi application/xml)" = "$L_AX" ] && [ "$(tq 18431 /customers/Ravi "$BR")" = "$L_BR" ] && [ "$(tq 18431 '/customers/Ravi?format=xml')" = "$L_FMT" ] || die "tq(): not the README's GET lines"
[ "$(xpc 18431 "$XASHA")" = "$L_XPOST" ] && [ "$(xpc0 18431 "$XASHA")" = "$L_XPOST0" ] || die "xpc(), xpc0(): not the README's POST lines"
echo "  the commands: anchor/README.md gives the 9 lines this script runs or derives from; README.md the 11 this unit adds"

# ---- build: before the captures - the anchor and the copy, each built once (on a fresh clone the first fills .m2-demo, the second
# ---- adds the XML module's artifacts); the harness compiled against the anchor's own jar; what .m2-demo holds ------------------
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
# tree FOLDER [TOKEN]: a config tree in FOLDER/secrets holding one file, the token (the demo token unless named) and a newline,
# readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "${2:-$TOKEN}" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
rsync -a --exclude target --exclude secrets anchor/ .harness/pre/
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (the anchor)"
rsync -a --exclude target --exclude secrets anchor/ .harness/prex/
(cd .harness/prex && patch -s -p1 < ../../harness/xml.patch) || die "harness/xml.patch did not apply to the anchor's web POM"
mbuild "$(off .harness/prex "$R_PLAIN" package)" .harness/build-prex.log ".harness/prex (the copy)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-webmvc/4.1.1/spring-boot-starter-webmvc-4.1.1.jar" ] || die "Spring MVC's starter is not in .m2-demo after the first build"
[ -f "$M2/tools/jackson/dataformat/jackson-dataformat-xml/3.1.5/jackson-dataformat-xml-3.1.5.jar" ] || die "Jackson's XML module 3.1.5 is not in .m2-demo after the copy's build"
(cd .harness/pre && eval "$R_EXTRACT") > .harness/extract-pre.log 2>&1 || die "the README's extract line failed on .harness/pre"
javac -parameters -d .harness/hc -cp ".harness/pre/tiffinbox-web/target/extracted/lib/*" $HW > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jar"; }
echo "  .m2-demo holds Spring MVC's starter and Jackson's XML module 3.1.5; the harness compiled against the anchor's jar"

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
  case " $l " in *':8080 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, Tomcat's default - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
# sortj: a JSON answer followed by curl's status (" 200"), its keys sorted, its error timestamp masked
sortj() { python3 -c '
import json, re, sys
for l in sys.stdin.read().splitlines():
    b, _, s = l.rpartition(" ")
    try: o = json.dumps(json.loads(b), sort_keys=True, separators=(",", ":"))
    except ValueError: print("  " + l); continue
    o = re.sub(r"\"timestamp\":(\"[^\"]*\"|[0-9]+)", "\"timestamp\":\"…\"", o)
    print("  " + o + " " + s + ("    (keys sorted)" if o != re.sub(r"\"timestamp\":(\"[^\"]*\"|[0-9]+)", "\"timestamp\":\"…\"", b) else ""))'; }
askj() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sortj; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (R.41, R.75). A JVM ($pid) that exits first stops the run.
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  askj "$R_READY" "$1"; }
# logtok: the demo token 0 times in the last run's log, and the header's name 0 times
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token $h times"; }
# tsmask: Spring's error timestamp - in JSON both forms (an ISO-8601 string, epoch milliseconds), in XML a <timestamp> element's text
# - and the date and time on Boot's HTML error page (its <div id='created'>) become "…" (README.md, Masks)
tsmask() { awk -v q="'" '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…")
  gsub(/<timestamp>[^<]*<\/timestamp>/, "<timestamp>…</timestamp>"); gsub("<div id=" q "created" q ">[^<]*</div>", "<div id=" q "created" q ">…</div>"); print }'; }
# tsform FILE...: the error timestamps in the files - unmasked answers - each made a form: every digit of its date and time becomes d,
# its zone kept (README.md, Masks); each distinct form, and how many times it appears
tsform() { cat "$@" | grep -o '"timestamp":"[^"]*"' | python3 -c 'import re, sys
for l in sys.stdin: print(re.sub(r"^(\"timestamp\":\")([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?)", lambda m: m.group(1) + re.sub(r"[0-9]", "d", m.group(2)), l.rstrip("\n")))' | sort | uniq -c | awk '{ c = $1; $1 = ""; sub(/^ /, ""); printf "%s%s ×%d", (NR > 1 ? " · " : ""), $0, c } END { if (NR == 0) printf "none" }'; }
# gone PORT: after a POST /shutdown - the JVM must leave within 15 s, the port must be free; its exit code
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
# seven PORT DIR: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), the POST
# line printed; the JVM must leave within 15 s of them, the port must be free; its exit code; the md5 of the seven after the
# timestamp mask, how many lines the mask changed, and the form of the timestamps it hid; the log counted (logtok)
seven() { local m
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  gone "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  echo "  the timestamps the mask hid, their form: $(tsform .harness/responses.txt)"
  logtok; }
# post PORT DIR: POST /shutdown with DIR's token (harness/shutdown.sh) - its answer, its Content-Length header, the timestamp masked
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | tsmask | sed 's/^/  /'; }
# stop PORT DIR: POST /shutdown with DIR's token; the JVM must leave, the port must be free; its log counted (logtok)
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
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
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
pbuild() { local c; c=$(off "$1" "$R_PLAIN" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
libs() { unzip -Z1 "$1" | grep -E '^BOOT-INF/lib/.*\.jar$' | sed 's#^BOOT-INF/lib/##' | sort; }
extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }
# settle: the log stops growing (the same length twice, 0.5 s apart; up to 15 s) - a request's last line is written just after
# its answer leaves
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
mark() { settle; wc -l < .harness/run.out | tr -d ' '; }
# logl FROM [LEVELS]: the run's lines after line FROM at those levels (an extended regular expression; WARN|ERROR unless named), from
# their level and logger on - an identity hash after "@" made "…" (README.md, Masks)
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" 'NR > from && $0 ~ (" (" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); print "    " l " " lg ": " msg }' .harness/run.out; }
# wans FROM FILE: an answer (FILE) and the WARN lines its request added after line FROM, at the level the run was started with:
# the answer's last line ends with their count, each one follows
wans() { local w; settle; w=$(logl "$1" WARN | grep -c . || true)
  awk -v w="$w" '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) print "  " l[i] (i == NR ? " · WARN lines it added: " w : "") }' "$2"
  [ "$w" = 0 ] || logl "$1" WARN; }
# tql PORT PATH [ACCEPT]: this unit's GET line (tq), printed and run, the answer's timestamps masked; then the WARN lines it added
tql() { local c n0; n0=$(mark); c=$(tq "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# locof FILE: the Location an answer printed by a Location line holds - between "Location: [" and the line's last "]"
locof() { sed -n 's/^.* · Location: \[\(.*\)\]$/\1/p' "$1" | tail -1; }
# xpl PORT 'BODY' / xpl0 PORT 'BODY': this unit's XML POST (xpc, xpc0), printed and run, the answer's timestamps masked, the Location it
# printed kept in .harness/loc.txt; then the WARN lines it added
xpl() { local c n0; n0=$(mark); c=$(xpc "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; locof .harness/ask.txt > .harness/loc.txt; wans "$n0" .harness/ask.txt; }
xpl0() { local c n0; n0=$(mark); c=$(xpc0 "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; locof .harness/ask.txt > .harness/loc.txt; wans "$n0" .harness/ask.txt; }
# xfol ACCEPT: the Location the last POST printed, asked for with this unit's GET line and that Accept header - the URL must be on
# 127.0.0.1 (never another host's); printed and run, then the WARN lines it added
xfol() { local c n0 l; l=$(cat .harness/loc.txt 2> /dev/null); case $l in http://127.0.0.1:*) ;; *) die "no Location on 127.0.0.1 to follow: [$l]" ;; esac
  n0=$(mark); c=$(printf "%s -H 'Accept: %s' %s\n" "$TQW" "$1" "$l"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# rp 'COMMAND': a curl line, printed and run, the answer indented, the timestamps masked
rp() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
# warns: the run's WARN and ERROR lines so far, counted
warns() { echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# bmeta JAR KEY: Boot's own metadata for a key - its type, its default and its description - read from JAR in the copy's extracted lib
bmeta() { python3 - ".harness/xml/tiffinbox-web/target/extracted/lib/$1" "$2" <<'PY'
import json, os, sys, zipfile
d = json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json"))
p = {x["name"]: x for x in d.get("properties", [])}; j = os.path.basename(sys.argv[1]); k = sys.argv[2]; e = p.get(k)
if not e: print("  Boot's metadata (%s): %s - in none of its entries" % (j, k))
else:
    dv = e.get("defaultValue")
    print("  Boot's metadata (%s) - %s · its type: %s · its default: %s · its description: %s" % (j, k, e.get("type", "none").rsplit(".", 1)[-1].rstrip(">"), "none" if dv is None else json.dumps(dv), e.get("description", "none")))
PY
}

# ---- anchor: today's answer to XML - 406 ------------------------------------------------------------------------------------
XIRA='<Customer><name>Ira</name><mealsPerDay>1</mealsPerDay><pricePerMeal>130</pricePerMeal><mealType>VEG</mealType></Customer>'
XCUT='<Customer><name>Kiran</name><mealsPerDay>2'
anchor() {
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"
  echo "  and its jar extracted (the README's line) - the class path the harness runs on:"
  extract .harness/anchor
  echo "the seven - the anchor, the README's run line, port 19400, a fresh JVM (curl asks for */*):"
  start "$(at .harness/anchor 19400 "$R_RUN")"; up 19400; ready 19400; seven 19400 .harness/anchor
  echo "the anchor again, a fresh JVM, port 19400 - one customer, asked for as JSON, as XML and as HTML (this unit's GET line, its Accept header's value swapped):"
  start "$(at .harness/anchor 19400 "$R_RUN")"; up 19400; ready 19400
  tql 19400 /customers/Ravi application/json; tql 19400 /customers/Ravi application/xml; tql 19400 /customers/Ravi text/html
  echo "  a name nobody has, asked for as XML:"
  tql 19400 /customers/Nobody application/xml
  echo "  a customer sent as XML (this unit's XML POST):"
  xpl 19400 "$XIRA"
  echo "  the last course's scrape, asked for as curl asks, then for OpenMetrics (the anchor README's two lines; the page itself stays in .harness/anchor/scrape.txt, unread):"
  rp "cd .harness/anchor && $(url "$R_SCR0" 19400)"; rp "cd .harness/anchor && $(url "$R_SCR1" 19400)"
  warns
  stop 19400 .harness/anchor; }

# ---- xml: one dependency - the copy, its jar, its converters --------------------------------------------------------------
xml() { local c f n m
  echo "the copy - anchor/ copied to .harness/xml with a config tree, then this unit's patch (harness/xml.patch) and the copy's web POM against the anchor's (this unit's line):"
  copy anchor .harness/xml
  echo "\$ $L_PATCH"; (eval "$L_PATCH") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ diff -rq -x target -x secrets anchor .harness/xml"
  diff -rq -x target -x secrets anchor .harness/xml | sed 's/^/  /' || true
  (cd anchor && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; while IFS= read -r f; do m=$((m + 1)); cmp -s "anchor/$f" ".harness/xml/$f" && n=$((n + 1)); done < .harness/files.txt
  echo "  the anchor's files: $m · byte for byte the copy's: $n · the copy's files: $(cd .harness/xml && find . -type f ! -path './secrets/*' | grep -c .)"
  pbuild .harness/xml "the copy"
  libs .harness/anchor/$JARP > .harness/lb.txt; libs .harness/xml/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: the anchor's $(wc -l < .harness/lb.txt | tr -d ' ') jars -> the copy's $(wc -l < .harness/la.txt | tr -d ' ') · only in the copy's: $(comm -13 .harness/lb.txt .harness/la.txt | grep -c . || true) - $(comm -13 .harness/lb.txt .harness/la.txt | paste -sd' ' -) · only in the anchor's: $(comm -23 .harness/lb.txt .harness/la.txt | grep -c . || true)"
  echo "  the copy's jar extracted (the README's line):"
  extract .harness/xml
  echo "the harness, compiled against the anchor's own jar - with -parameters:"
  c="javac -parameters -d .harness/hc -cp \".harness/anchor/tiffinbox-web/target/extracted/lib/*\" $HW"
  echo "\$ $c"; rm -rf .harness/hc; (eval "$c") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jar"; }
  echo "  exit 0"
  echo "the anchor with the harness's Formats joined, port 19403 - its converters and Boot's conditions (this unit's line):"
  start "$(hcp .harness/anchor 19403 probe.web.Formats)"; up 19403; ready 19403
  rp "$(url "$L_PROBE" 19403)"; stop 19403 .harness/anchor
  echo "the copy, the same, port 19402:"
  start "$(hcp .harness/xml 19402 probe.web.Formats)"; up 19402; ready 19402
  rp "$(url "$L_PROBE" 19402)"; stop 19402 .harness/xml; }

# ---- accept: the same routes, by the Accept header ----------------------------------------------------------------------------
accept() {
  echo "the seven - the copy, the README's run line, port 19401, a fresh JVM (curl asks for */*):"
  start "$(at .harness/xml 19401 "$R_RUN")"; up 19401; ready 19401; seven 19401 .harness/xml
  echo "the copy again, a fresh JVM, port 19401 - the customers, asked for as XML, as JSON, with XML weighted below JSON, and as plain text (this unit's GET line):"
  start "$(at .harness/xml 19401 "$R_RUN")"; up 19401; ready 19401
  echo "  the Accept header curl sends when the command names none (curl's own request, verbose - this unit's line):"
  rp "$(url "$L_CV" 19401)"
  tql 19401 /customers application/xml; tql 19401 /customers application/json; tql 19401 /customers 'application/xml;q=0.5,application/json'; tql 19401 /customers text/plain
  warns
  stop 19401 .harness/xml; }

# ---- shapes: what XML looks like, both ways ---------------------------------------------------------------------------------
shapes() {
  echo "the copy, the README's run line, port 19401 - one customer and the month's revenue, asked for as XML (this unit's GET line):"
  start "$(at .harness/xml 19401 "$R_RUN")"; up 19401; ready 19401
  tql 19401 /customers/Ravi application/xml; tql 19401 /revenue application/xml
  echo "  error bodies - a name nobody has, a meal type nobody serves - asked for as XML:"
  tql 19401 /customers/Nobody application/xml; tql 19401 '/customers?mealType=veg' application/xml
  echo "  a customer sent as XML, asked back as XML (this unit's XML POST), then its Location, asked for as XML:"
  xpl 19401 "$XASHA"; xfol application/xml
  echo "  another, sent as XML with no Accept header (this unit's XML POST without it):"
  xpl0 19401 "$XIRA"
  echo "  the first name again, then a body cut short:"
  xpl 19401 "$XASHA"; xpl 19401 "$XCUT"
  warns
  stop 19401 .harness/xml; }

# ---- browser: C, D, E - the client that never asked for XML -------------------------------------------------------------------
browser() {
  echo "C (labelled) - a browser's Accept header, sent by curl (this unit's line):"
  echo "  the anchor, the README's run line, port 19400:"
  start "$(at .harness/anchor 19400 "$R_RUN")"; up 19400; ready 19400
  tql 19400 /customers/Ravi "$BR"; stop 19400 .harness/anchor
  echo "  the copy, the same line, port 19401:"
  start "$(at .harness/xml 19401 "$R_RUN")"; up 19401; ready 19401
  tql 19401 /customers/Ravi "$BR"; stop 19401 .harness/xml
  echo "D (labelled) - the copy with a default content type, application/json (this unit's run line's option), the harness joined, port 19405 - the strategies Spring MVC's content negotiation manager asks (this unit's line), then the browser's header again:"
  bmeta spring-boot-webmvc-4.1.1.jar spring.mvc.contentnegotiation.default-content-types
  start "$(hcp .harness/xml 19405 probe.web.Formats "$O_DCT")"; up 19405; ready 19405
  rp "$(url "$L_STRAT" 19405)"
  tql 19405 /customers/Ravi "$BR"
  stop 19405 .harness/xml
  echo "E (labelled) - the copy with the harness joined and no key, port 19402 - the strategies; then the harness's two routes: one that produces JSON, one that produces JSON or XML:"
  start "$(hcp .harness/xml 19402 probe.web.Formats)"; up 19402; ready 19402
  rp "$(url "$L_STRAT" 19402)"
  tql 19402 /probe/formats/json "$BR"; tql 19402 /probe/formats/both "$BR"; tql 19402 /probe/formats/json application/xml
  warns
  stop 19402 .harness/xml; }

# ---- actuator: health, asked for as XML ------------------------------------------------------------------------------------
actuator() {
  echo "the anchor, the README's run line, port 19400 - health, asked for as XML, as JSON and with a browser's Accept header (this unit's GET line):"
  start "$(at .harness/anchor 19400 "$R_RUN")"; up 19400; ready 19400
  tql 19400 /actuator/health application/xml; tql 19400 /actuator/health application/json; tql 19400 /actuator/health "$BR"
  stop 19400 .harness/anchor
  echo "the copy, the same three, port 19401:"
  start "$(at .harness/xml 19401 "$R_RUN")"; up 19401; ready 19401
  tql 19401 /actuator/health application/xml; tql 19401 /actuator/health application/json; tql 19401 /actuator/health "$BR"
  stop 19401 .harness/xml; }

# ---- param: A/B/A' - ?format=xml -------------------------------------------------------------------------------------------
param() {
  bmeta spring-boot-webmvc-4.1.1.jar spring.mvc.contentnegotiation.favor-parameter
  bmeta spring-boot-webmvc-4.1.1.jar spring.mvc.contentnegotiation.parameter-name
  echo "A - the copy, the README's run line, port 19401 - ?format=xml, no Accept header (this unit's line):"
  parama
  echo "B - the copy with favor-parameter on (this unit's run line), port 19404 - ?format=xml, ?format=json, ?format=xml beside an Accept header that asks for JSON, and no parameter:"
  start "$(at .harness/xml 19404 "$L_FAV")"; up 19404; ready 19404
  tql 19404 '/customers/Ravi?format=xml'; tql 19404 '/customers/Ravi?format=json'; tql 19404 '/customers/Ravi?format=xml' application/json; tql 19404 /customers/Ravi
  stop 19404 .harness/xml
  echo "A' - A again, on a fresh JVM:"
  parama
  echo "A' against A, its label aside, line for line the same: $(asame 'A - the copy' 'B - the copy' "A' - A again" '')"
  echo "C (labelled) - the copy with favor-parameter on (B's option) and the harness joined, port 19404 - the strategies Spring MVC's content negotiation manager asks (this unit's line):"
  start "$(hcp .harness/xml 19404 probe.web.Formats "$O_FAV")"; up 19404; ready 19404
  rp "$(url "$L_STRAT" 19404)"
  stop 19404 .harness/xml; }
parama() { start "$(at .harness/xml 19401 "$R_RUN")"; up 19401; ready 19401
  tql 19401 '/customers/Ravi?format=xml'
  stop 19401 .harness/xml; }

# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this folder.
# A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit code
# and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files), and the
# README's run log kept before the solution's run writes its own. Bounded (600 s); on the way out, or past the bound, the shell and
# every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exercise() { local setup sol i=0 e1 d1 e2 d2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 3 ] || die "SOLUTION.md's first bash block must be its two export lines and its one command"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/xml/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/ex-readme.log || true) · listening on 19409 now: $(listeners 19409)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/xml/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · listening on 19409 now: $(listeners 19409)"; }


cap anchor anchor
cap xml xml
cap accept accept
cap shapes shapes
cap browser browser
cap actuator actuator
cap param param
cap exercise exercise
echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: did not expect the line: $2"; }
# aft CMDLINE BLOCK: the line after the first line of BLOCK that is exactly CMDLINE (a command's first answer line) - the line is
# handed to awk through its environment, which keeps a backslash a backslash (-v would turn \n into a newline); aft2: the line after that
aft() { printf '%s\n' "$2" | C="$1" awk 'f { print; exit } $0 == ENVIRON["C"] { f = 1 }'; }
aft2() { printf '%s\n' "$2" | C="$1" awk 'f == 2 { print; exit } f == 1 { f = 2; next } $0 == ENVIRON["C"] { f = 1 }'; }
# aftn N CMDLINE BLOCK: the line after the Nth line of BLOCK that is exactly CMDLINE
aftn() { printf '%s\n' "$3" | C="$2" N="$1" awk 'f { print; exit } $0 == ENVIRON["C"] && ++k == ENVIRON["N"] { f = 1 }'; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted
# when it was read: logtok()), nor anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/xml.patch $HW; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|\"timestamp\":\"?[0-9]|timestamp=[A-Z0-9]|<timestamp>[0-9]|id='created'>[A-Za-z0-9]|(exec|handler|task|utility)-[0-9]|GMT| CES?T " "$f" || die "$f holds a log line's time, a timestamp, a date, a time zone or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; ! grep -E 'server\.error\.' "$f" | grep -vE '^ *#' > /dev/null || die "$f names one of Boot 3's error keys (server, then error) - Boot 4.1 reads only spring.web.error.* (S2.13)"; done
# Every command a capture runs asks 127.0.0.1
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the patch, the exercise and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no date, no time zone, no thread number, no stack frame, no 8080, no carriage return in any capture; every command a capture runs asks 127.0.0.1"

S87C='87ca7efc8584dcccd40e6b956db1de9b'
SEVEN1="  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C"
WA() { printf '%s · WARN lines it added: %s' "$1" "$2"; }
TQ() { printf '$ %s' "$(tq "$@")"; }                 # this unit's GET line, as a capture shows it
XQ() { printf '$ %s' "$(xpc "$@")"; }; XQ0() { printf '$ %s' "$(xpc0 "$@")"; }
[ "$(TQ 19400 /customers/Ravi application/xml)" = "\$ $(url "$L_AX" 19400)" ] && [ "$(TQ 19401 /customers/Ravi "$BR")" = "\$ $(url "$L_BR" 19401)" ] && [ "$(TQ 19404 '/customers/Ravi?format=xml')" = "\$ $(url "$L_FMT" 19404)" ] && [ "$(XQ 19401 "$XASHA")" = "\$ $(url "$L_XPOST" 19401)" ] || die "the checks' own command lines are not the README's"
RAVIJ='{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}'
RAVIX='<Customer><name>Ravi</name><mealsPerDay>2</mealsPerDay><pricePerMeal>120</pricePerMeal><mealType>VEG</mealType></Customer>'
ASHAX=$XASHA
CTXML='Content-Type: [application/xml;charset=UTF-8]'
W406='    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]'
EX() { printf '  <Map><timestamp>…</timestamp><status>%s</status><error>%s</error><path>%s</path></Map>' "$1" "$2" "$3"; }
ALL4='[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]'

# "Ask TiffinBox for Ravi in XML, and the answer is four oh six, not acceptable, with an empty body ... Ask for a web page, and Boot
#  sends the four oh six as its own HTML error page. Send XML in a body: four fifteen ... the scrape answered curl in plain text, and
#  OpenMetrics to a client that asked"
AN=$(cat .r-anchor.out); A2=$(blk anchor 'the anchor again' '')
x anchor '^  built the anchor · offline: yes · exit 0$'
has "$AN" "$SEVEN1" "anchor: the seven"
[ "$(aft "$(TQ 19400 /customers/Ravi application/json)" "$A2")" = "$(WA "  $RAVIJ · 200 · Content-Type: [application/json]" 0)" ] || die "anchor: JSON asked for, JSON"
[ "$(aft "$(TQ 19400 /customers/Ravi application/xml)" "$A2")" = "$(WA '   · 406 · Content-Type: []' 1)" ] && [ "$(aft2 "$(TQ 19400 /customers/Ravi application/xml)" "$A2")" = "$W406" ] || die "anchor: XML asked for, 406, an empty body, one WARN"
WL=$(aft "$(TQ 19400 /customers/Ravi text/html)" "$A2")
[ "$WL" = "$(WA "  <html><body><h1>Whitelabel Error Page</h1><p>This application has no explicit mapping for /error, so you are seeing this as a fallback.</p><div id='created'>…</div><div>There was an unexpected error (type=Not Acceptable, status=406).</div></body></html> · 406 · Content-Type: [text/html;charset=UTF-8]" 1)" ] || die "anchor: HTML asked for, Boot's HTML error page with the 406"
[ "$(aft "$(TQ 19400 /customers/Nobody application/xml)" "$A2")" = "$(WA '   · 404 · Content-Type: []' 0)" ] || die "anchor: a name nobody has, as XML - 404, an empty body"
[ "$(aft "$(XQ 19400 "$XIRA")" "$A2")" = "$(WA '   415 · Location: []' 1)" ] && has "$A2" "    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotSupportedException: Content-Type 'application/xml;charset=UTF-8' is not supported]" "anchor: the 415's WARN" || die "anchor: an XML body, 415"
[ "$(aft "\$ cd .harness/anchor && $(url "$R_SCR0" 19400)" "$A2")" = '  200 text/plain;version=0.0.4;charset=utf-8' ] && [ "$(aft "\$ cd .harness/anchor && $(url "$R_SCR1" 19400)" "$A2")" = '  200 application/openmetrics-text;version=1.0.0;charset=utf-8' ] || die "anchor: the scrape's two formats, by Accept"
has "$A2" "  WARN lines in this run's log, at Boot's default level: 3 · ERROR lines: 0" "anchor: 3 WARN lines - the 406s and the 415"
echo "  anchor: the seven $S87C; Ravi as JSON 200; as XML 406, empty, 1 WARN; as HTML 406 and Boot's HTML error page; Nobody as XML 404, empty; an XML body 415; the scrape text/plain for curl, OpenMetrics when asked; 3 WARN"

# "add one line to the web module's POM ... no version ... Here, fifty-six libraries become fifty-nine ... the configuration for an XML
#  converter needed a class ... and now it finds one ... from six to seven. The new one, Jackson's XML converter, joins last, after
#  JSON, and claims three media types ... application slash xml, text slash xml, and anything ending in plus xml"
XM=$(cat .r-xml.out); XP=$(blk xml "\$ $L_PATCH" '$ diff -rq'); XHA=$(blk xml 'the anchor with the harness' 'the copy, the same'); XHC=$(blk xml 'the copy, the same' '')
[ "$(printf '%s\n' "$XP" | grep -c '^  +')" = 1 ] && [ "$(printf '%s\n' "$XP" | grep -c '^  -')" = 0 ] && [ "$(printf '%s\n' "$XP" | grep -c '^  @@ ')" = 1 ] || die "xml: the copy's diff - one hunk, one line in, none out"
has "$XP" '  +    <dependency><groupId>tools.jackson.dataformat</groupId><artifactId>jackson-dataformat-xml</artifactId></dependency>' "xml: the one line, no version"
nhas "$XP" '  +    <version>' "xml: no version"
[ "$(n xml '^  Files ')" = 1 ] && [ "$(n xml '^  Only in ')" = 0 ] && x xml '^  Files anchor/tiffinbox-web/pom\.xml and \.harness/xml/tiffinbox-web/pom\.xml differ$' || die "xml: one file differs, the web POM"
x xml "^  the anchor's files: 25 · byte for byte the copy's: 24 · the copy's files: 25\$"
x xml '^  built the copy · offline: yes · exit 0$'
has "$XM" "the executable jar's BOOT-INF/lib: the anchor's 56 jars -> the copy's 59 · only in the copy's: 3 - jackson-dataformat-xml-3.1.5.jar stax2-api-4.2.2.jar woodstox-core-7.1.1.jar · only in the anchor's: 0" "xml: 56 -> 59, three in, none out"
has "$XHA" '  message converters: 6 - RequestMappingHandlerAdapter'"'"'s, in the order it asks them' "xml: the anchor's 6 converters"
has "$XHC" '  message converters: 7 - RequestMappingHandlerAdapter'"'"'s, in the order it asks them' "xml: the copy's 7"
for b in "$XHA" "$XHC"; do has "$b" '    6 JacksonJsonHttpMessageConverter [application/json, application/*+json]' "xml: JSON sixth on both"; done
has "$XHC" '    7 JacksonXmlHttpMessageConverter [application/xml;charset=UTF-8, text/xml;charset=UTF-8, application/*+xml;charset=UTF-8]' "xml: the seventh, Jackson's XML converter, three media types"
nhas "$XHA" '    7 JacksonXmlHttpMessageConverter [application/xml;charset=UTF-8, text/xml;charset=UTF-8, application/*+xml;charset=UTF-8]' "xml: the anchor has no seventh"
has "$XHA" '    application/xml: 0 of 6' "xml: the anchor - no converter writes a Customer as XML"; has "$XHA" '    application/json: 1 of 6 - 6 JacksonJsonHttpMessageConverter' "xml: the anchor - JSON's"
has "$XHC" '    application/xml: 1 of 7 - 7 JacksonXmlHttpMessageConverter' "xml: the copy - XML's"; has "$XHC" '    application/xhtml+xml: 1 of 7 - 7 JacksonXmlHttpMessageConverter' "xml: the copy - XHTML is XML's too"
for b in "$XHA" "$XHC"; do has "$b" '    text/html: 0 of '"$( [ "$b" = "$XHA" ] && echo 6 || echo 7)" "xml: no HTML writer"; done
# the XML converter's configuration, row and outcomes tied together (each row's outcomes are the lines right after it)
CFG='    org.springframework.boot.http.converter.autoconfigure.JacksonHttpMessageConvertersConfiguration$JacksonXmlHttpMessageConverterConfiguration: '
has "$XHA" "${CFG}did not match" "xml: the anchor - the XML converter's configuration did not match"
[ "$(aft "${CFG}did not match" "$XHA")" = "      - @ConditionalOnClass did not find required class 'tools.jackson.dataformat.xml.XmlMapper'" ] || die "xml: the anchor - the class the XML converter's configuration needs, not found"
has "$XHC" "${CFG}matched" "xml: the copy - matched"
[ "$(aft "${CFG}matched" "$XHC")" = "      + @ConditionalOnClass found required class 'tools.jackson.dataformat.xml.XmlMapper'" ] && [ "$(aft2 "${CFG}matched" "$XHC")" = "      + @ConditionalOnBean (types: tools.jackson.dataformat.xml.XmlMapper; SearchStrategy: all) found bean 'xmlMapper'" ] || die "xml: the copy - the class found, and the bean xmlMapper"
has "$XHC" '  the XML converter'"'"'s mapper (7): tools.jackson.dataformat.xml.XmlMapper · beans of that class: 1 - xmlMapper' "xml: its mapper, Boot's bean xmlMapper"
has "$XHA" "  Boot's condition report - the configurations whose name holds Xml: 3" "xml: 3 on the anchor"; has "$XHC" "  Boot's condition report - the configurations whose name holds Xml: 8" "xml: 8 on the copy"
echo "  xml: one line in, no version; one file differs; 56 -> 59 jars (3 in, 0 out); converters 6 -> 7, the seventh JacksonXmlHttpMessageConverter after JSON, application/xml, text/xml, application/*+xml; a Customer as XML 0 of 6 -> 1 of 7, as XHTML too; Boot's XML converter configuration did not match -> matched (XmlMapper found), its mapper the bean xmlMapper"

# "Curl's own header accepts anything, and still gets JSON: the seven hash exactly as before. Ask for application slash xml and the
#  customers come back as XML ... Weight XML at a half ... and JSON wins. Ask for plain text: four oh six"
AC=$(cat .r-accept.out); AC2=$(blk accept 'the copy again' '')
has "$AC" "$SEVEN1" "accept: the seven on the copy, unchanged"
[ "$(aft "\$ $(url "$L_CV" 19401)" "$AC2")" = '  > Accept: */*' ] || die "accept: curl's own Accept header, */*"
XL=$(aft "$(TQ 19401 /customers application/xml)" "$AC2")
case $XL in '  <List><item><name>Meera</name>'*'</item></List> · 200 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 0') ;; *) die "accept: XML asked for, a List of items: $XL" ;; esac
[ "$(printf '%s\n' "$XL" | grep -o '<item>' | wc -l | tr -d ' ')" = 4 ] || die "accept: four items"
[ "$(aft "$(TQ 19401 /customers application/json)" "$AC2")" = "$(WA "  $ALL4 · 200 · Content-Type: [application/json]" 0)" ] || die "accept: JSON asked for, JSON"
[ "$(aft "$(TQ 19401 /customers 'application/xml;q=0.5,application/json')" "$AC2")" = "$(WA "  $ALL4 · 200 · Content-Type: [application/json]" 0)" ] || die "accept: XML weighted 0.5 - JSON wins"
[ "$(aft "$(TQ 19401 /customers text/plain)" "$AC2")" = "$(WA '   · 406 · Content-Type: []' 1)" ] || die "accept: text, 406"
echo "  accept: the seven $S87C on the copy; curl's own Accept */*; XML -> <List>, 4 items; JSON -> JSON; xml;q=0.5 beside json -> JSON; text/plain -> 406, 1 WARN"

# "a root element ... named after the type the route returns: Customer for Ravi, Map for the month's revenue. Error bodies follow ...
#  Post Asha as XML, asking for XML: two oh one, the same Location, and Asha in XML. Leave the Accept header out, and the answer is
#  JSON ... the same name again, four oh nine ... A body cut short is a four hundred, and its WARN line says JSON parse error"
SH=$(cat .r-shapes.out)
[ "$(aft "$(TQ 19401 /customers/Ravi application/xml)" "$SH")" = "$(WA "  $RAVIX · 200 · $CTXML" 0)" ] || die "shapes: Ravi, <Customer>"
[ "$(aft "$(TQ 19401 /revenue application/xml)" "$SH")" = "$(WA "  <Map><monthRevenue>24300</monthRevenue></Map> · 200 · $CTXML" 0)" ] || die "shapes: the revenue, <Map>"
[ "$(aft "$(TQ 19401 /customers/Nobody application/xml)" "$SH")" = "$(WA "$(EX 404 'Not Found' /customers/Nobody) · 404 · $CTXML" 0)" ] || die "shapes: a name nobody has, 404 with an XML body"
[ "$(aft "$(TQ 19401 '/customers?mealType=veg' application/xml)" "$SH")" = "$(WA "$(EX 400 'Bad Request' /customers) · 400 · $CTXML" 1)" ] || die "shapes: a meal type nobody serves, 400 with an XML body"
[ "$(aft "$(XQ 19401 "$XASHA")" "$SH")" = "$(WA "  $ASHAX 201 · Location: [http://127.0.0.1:19401/customers/Asha]" 0)" ] || die "shapes: Asha posted as XML - 201, a Location, XML back"
[ "$(aft "\$ $TQW -H 'Accept: application/xml' http://127.0.0.1:19401/customers/Asha" "$SH")" = "$(WA "  $ASHAX · 200 · $CTXML" 0)" ] || die "shapes: the Location followed as XML"
[ "$(aft "$(XQ0 19401 "$XIRA")" "$SH")" = "$(WA '  {"name":"Ira","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19401/customers/Ira]' 0)" ] || die "shapes: Ira posted as XML with no Accept - JSON back"
[ "$(aftn 2 "$(XQ 19401 "$XASHA")" "$SH")" = "$(WA '   409 · Location: []' 0)" ] || die "shapes: Asha again, 409 and no body"
[ "$(aft "$(XQ 19401 "$XCUT")" "$SH")" = "$(WA "$(EX 400 'Bad Request' /customers) 400 · Location: []" 1)" ] || die "shapes: a body cut short, 400"
x shapes '^    WARN \.w\.s\.m\.s\.DefaultHandlerExceptionResolver: Resolved \[org\.springframework\.http\.converter\.HttpMessageNotReadableException: JSON parse error: Unexpected EOF; was expecting a close tag for element <mealsPerDay>'
has "$SH" "  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 0" "shapes: 2 WARN - the 400s"
echo "  shapes: <Customer>, <Map>; 404 and 400 with XML bodies; Asha as XML -> 201 + Location + XML, followed as XML 200; Ira with no Accept -> 201 + JSON; Asha again 409; cut short 400, 'JSON parse error' in the WARN"

# "a browser's Accept header, sent by curl ... The anchor answers it with JSON. The copy answers with XML, labelled XHTML ... Boot's
#  default content types key doesn't change that ... a route that says what it produces. JSON only, and the browser gets JSON. JSON
#  or XML, and it gets XML under its real name"
BC=$(blk browser 'C (labelled)' 'D (labelled)'); BD=$(blk browser 'D (labelled)' 'E (labelled)'); BE=$(blk browser 'E (labelled)' '')
[ "$(aft "$(TQ 19400 /customers/Ravi "$BR")" "$BC")" = "$(WA "  $RAVIJ · 200 · Content-Type: [application/json]" 0)" ] || die "browser C: the anchor - JSON"
[ "$(aft "$(TQ 19401 /customers/Ravi "$BR")" "$BC")" = "$(WA "  $RAVIX · 200 · Content-Type: [application/xhtml+xml]" 0)" ] || die "browser C: the copy - XML, labelled application/xhtml+xml"
has "$BD" "  Boot's metadata (spring-boot-webmvc-4.1.1.jar) - spring.mvc.contentnegotiation.default-content-types · its type: MediaType · its default: none · its description: List of default content types to be used when no specific content type is requested." "browser D: Boot's metadata"
ST2="  the content negotiation manager's strategies, in the order it asks them: 2"; ST1="  the content negotiation manager's strategies, in the order it asks them: 1"
[ "$(aft "$ST2" "$BD")" = '    1 HeaderContentNegotiationStrategy' ] && [ "$(aft2 "$ST2" "$BD")" = '    2 FixedContentNegotiationStrategy - its content types: [application/json]' ] || die "browser D: the key is read - a fixed default, asked after the Accept header"
[ "$(aft "$(TQ 19405 /customers/Ravi "$BR")" "$BD")" = "$(WA "  $RAVIX · 200 · Content-Type: [application/xhtml+xml]" 0)" ] || die "browser D: the default content type changes nothing for a browser"
[ "$(aft "$ST1" "$BE")" = '    1 HeaderContentNegotiationStrategy' ] && nhas "$BE" '    2 FixedContentNegotiationStrategy - its content types: [application/json]' "browser E: no fixed default without the key" || die "browser E: the Accept header's strategy alone"
[ "$(aft "$(TQ 19402 /probe/formats/json "$BR")" "$BE")" = "$(WA "  $RAVIJ · 200 · Content-Type: [application/json]" 0)" ] || die "browser E: produces JSON - JSON"
[ "$(aft "$(TQ 19402 /probe/formats/both "$BR")" "$BE")" = "$(WA "  $RAVIX · 200 · Content-Type: [application/xml]" 0)" ] || die "browser E: produces JSON or XML - XML, labelled application/xml"
[ "$(aft "$(TQ 19402 /probe/formats/json application/xml)" "$BE")" = "$(WA "$(EX 406 'Not Acceptable' /probe/formats/json) · 406 · $CTXML" 1)" ] || die "browser E: JSON only, asked for XML - 406"
echo "  browser: C the anchor JSON, the copy XML as application/xhtml+xml; D default-content-types=application/json - read (a fixed default after the Accept header), still application/xhtml+xml; E the header's strategy alone, produces JSON - JSON, produces JSON or XML - XML as application/xml, JSON only asked for XML - 406"

# "Ask health for XML and it's four oh six on both trees; the copy even explains, in XML. A browser gets JSON from it either way."
AA=$(blk actuator 'the anchor' 'the copy, the same three'); AB=$(blk actuator 'the copy, the same three' '')
HJ='{"groups":["liveness","readiness"],"status":"UP"}'
[ "$(aft "$(TQ 19400 /actuator/health application/xml)" "$AA")" = "$(WA '   · 406 · Content-Type: []' 1)" ] || die "actuator: the anchor, XML - 406, empty"
[ "$(aft "$(TQ 19401 /actuator/health application/xml)" "$AB")" = "$(WA "$(EX 406 'Not Acceptable' /actuator/health) · 406 · $CTXML" 1)" ] || die "actuator: the copy, XML - 406, an XML body"
for b in "$AA:19400" "$AB:19401"; do bb=${b%:*}; p_=${b##*:}
  [ "$(aft "$(TQ "$p_" /actuator/health application/json)" "$bb")" = "$(WA "  $HJ · 200 · Content-Type: [application/json]" 0)" ] || die "actuator: JSON, 200 ($p_)"
  [ "$(aft "$(TQ "$p_" /actuator/health "$BR")" "$bb")" = "$(WA "  $HJ · 200 · Content-Type: [application/vnd.spring-boot.actuator.v3+json]" 0)" ] || die "actuator: a browser's Accept, Actuator's JSON ($p_)"; done
echo "  actuator: health as XML - the anchor 406 empty, the copy 406 with an XML body; as JSON 200 on both; a browser's Accept - application/vnd.spring-boot.actuator.v3+json on both"

# "A: question mark format equals xml is ignored: JSON. B: switch on favor parameter, and the same URL answers XML, even beside an
#  Accept header that asks for JSON. A again: JSON."
PA=$(blk param 'A - the copy' 'B - the copy'); PB=$(blk param 'B - the copy' "A' - A again"); PA2=$(blk param "A' - A again" "A' against A")
x param '^  Boot.s metadata \(spring-boot-webmvc-4\.1\.1\.jar\) - spring\.mvc\.contentnegotiation\.favor-parameter · its type: Boolean · its default: false · its description: Whether a request parameter \("format" by default\) should be used to determine the requested media type\.$'
for b in "$PA" "$PA2"; do [ "$(aft "$(TQ 19401 '/customers/Ravi?format=xml')" "$b")" = "$(WA "  $RAVIJ · 200 · Content-Type: [application/json]" 0)" ] || die "param A/A': the parameter ignored - JSON"; done
[ "$(aft "$(TQ 19404 '/customers/Ravi?format=xml')" "$PB")" = "$(WA "  $RAVIX · 200 · $CTXML" 0)" ] || die "param B: ?format=xml - XML"
[ "$(aft "$(TQ 19404 '/customers/Ravi?format=json')" "$PB")" = "$(WA "  $RAVIJ · 200 · Content-Type: [application/json]" 0)" ] || die "param B: ?format=json - JSON"
[ "$(aft "$(TQ 19404 '/customers/Ravi?format=xml' application/json)" "$PB")" = "$(WA "  $RAVIX · 200 · $CTXML" 0)" ] || die "param B: the parameter beats the Accept header"
[ "$(aft "$(TQ 19404 /customers/Ravi)" "$PB")" = "$(WA "  $RAVIJ · 200 · Content-Type: [application/json]" 0)" ] || die "param B: no parameter - JSON"
x param "^A' against A, its label aside, line for line the same: yes\$"
PC=$(blk param 'C (labelled)' '')
[ "$(aft "  the content negotiation manager's strategies, in the order it asks them: 2" "$PC")" = '    1 ParameterContentNegotiationStrategy - its parameter: format' ] && [ "$(aft2 "  the content negotiation manager's strategies, in the order it asks them: 2" "$PC")" = '    2 HeaderContentNegotiationStrategy' ] || die "param C: with the key on, the parameter's strategy is asked first, the Accept header's second"
has "$PC" '  the format values it maps: json -> application/json · xml -> application/xml' "param C: the format values json and xml"
echo "  param: Boot's metadata favor-parameter false, \"format\"; A ?format=xml -> JSON; B -> XML, ?format=json -> JSON, ?format=xml beside Accept json -> XML, no parameter -> JSON; A' = A; C the parameter's strategy first, then the header's; format values json, xml"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder; the
# line exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='GET /customers/Ravi: 200 · application/xml;charset=UTF-8 · root element: Customer'; l0='GET /customers/Ravi: 200 · application/json · root element: none'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19409 now: 0" "exercise: the README's commands leave the shell in this unit's folder"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19409 now: 0" "exercise: the solution's lines leave the shell in this unit's folder"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
r=$(printf '%s\n' "$XS" | grep '^  \$ (cd \.harness/mine/xml && ' | sed 's/^  \$ //'); r2=$(printf '%s\n' "$XE" | grep '^  \$ (cd \.harness/mine/xml && ' | sed 's/^  \$ //')
F1="-H 'Accept: application/xml'"; F2="-H 'Content-Type: application/xml'"; t=${r2/"$F1"/$F2}
[ "$t" = "$r" ] && [ "$r2" != "$r" ] || die "exercise: the solution's last line is the README's with its header made Accept's, and nothing else"
echo "  exercise: one env -i shell - the README as written (Content-Type on a GET) -> 200, application/json, no root element; the solution (Accept) -> application/xml;charset=UTF-8, root element Customer; the shell in this unit's folder after each"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit11: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log"
