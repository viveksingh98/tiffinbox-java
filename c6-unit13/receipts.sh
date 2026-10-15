#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · Binding, Converters and Formatters - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit12/after,
# the tree the validation lesson froze (= c6-tiffinbox, Section 2's end). This script copies that tree under .harness/anchor, builds it
# and runs it - as its README runs it, and on its class path with the course's harness joined (harness/probe/web, outside
# com.tiffinbox) - and asks how the text of a request becomes a method's values: by Spring's own rules, by a Converter bean for the
# whole application, by a format on one parameter, by one controller's binder, into a record, and by the locale.
# Seven captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run and in every file this unit ships.
#   default    the anchor built and extracted; the harness compiled; the seven; a meal type asked for as VEG, veg and empty, who binds
#              it (the harness's Who: the argument resolver, the converter Spring MVC's conversion service uses, the service itself),
#              and the same word in a JSON body - TiffinBox's own POST
#   converter  the harness's MealTypeConverter, its source; the seven with it joined; who binds a meal type now; veg, Veg, empty and
#              lunch; the converter on the harness's routes (a request parameter, a record's component); JSON bodies - TiffinBox's
#              own POST, and the harness's order, whose meal type is a MealType
#   format     A/B/A': Boot's metadata for its date format key; the harness's date routes; A - the formatter each route's date gets,
#              and the formatter the default one holds, then dates with no format and with @DateTimeFormat; B - Boot's key set to iso,
#              the formatter it holds now, the same dates; A' - A again
#   binder     Binder (an @InitBinder method: Strings trimmed, blank made null, its own MealType codes) and its twin Plain, the
#              converter joined: names with spaces, blank names, meal types
#   record     a record from a query string: who binds it (no annotation, @ModelAttribute); bound, a component missing, two values
#              that cannot be their types; @BindParam; a record with a rule and a BindingResult - a rule broken, a value that cannot
#              be its type beside it
#   locale     A/B/A': a date with no format - the short date pattern and two dates under U.S. English (A), U.K. English (B), U.S.
#              English again (A'); C (labelled): U.K. English, the route that names its pattern; D (labelled): U.S. English, the
#              request's own language U.K. English
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit12/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. The harness - harness/probe/web (compiled with -parameters): Who,
# MealTypeConverter, Plain, Binder, Queries, Dates - is the course's, never TiffinBox's: outside com.tiffinbox, joined by
# --spring.main.sources on the extracted jar's class path, and named on every capture that uses it; harness/shutdown.sh is POST
# /shutdown with the token read from its file. Every run passes options only. The seven always run on a fresh JVM, before any POST.
# The locale: a JVM whose answers can follow its locale - a date read with no format, a validation message, the harness's Who, which
# prints the JVM's locale - starts with -Duser.language and -Duser.country (before -cp, JVM options), so no capture depends on yours.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build and no Docker: this unit measures
# the JVM alone. At run time nothing leaves 127.0.0.1: TiffinBox listens there, every request goes there, and Logback writes to the
# terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. Spring's error timestamp becomes "…" (both JSON forms), in the seven and wherever an answer is printed. An
# identity hash - the "@" and hexadecimal digits Java prints after a class name - becomes "@…", in the harness's answers and in log
# lines. A run's log lines are printed from their logger on (no time, no process id, no thread); Boot's first line is cut before
# " with PID". A WARN line that lists field errors is cut after "with N errors", and its field errors follow, sorted. No duration is
# captured.
# Ports (brief ⚑1, 19420-19429): the seven on the jar 19420 · default's class path 19421 · converter 19422 · format A and A' 19423, B
# 19424 · binder 19425 · record 19426 · locale A, A' and D 19427, B and C 19428 · the exercise 19429. 18425 (TiffinBox's default) and
# 8080 (Tomcat's) are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it. The published captures were
# made with no locale set, which is the C locale. (Java's own locale is not this: it is pinned per JVM, above.)
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
for t in python3 curl rsync lsof unzip javac openssl mvn; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A SPRING_MVC_* of yours
# could set Boot's date format in every capture here; a JAVA_TOOL_OPTIONS could set every JVM's locale.)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit12/after ] || die "anchor must be the link to ../c6-unit12/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/anchor/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=a-fake-demo-token-for-bind
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='Binder.java Dates.java MealTypeConverter.java Plain.java Queries.java Who.java'
for f in harness/shutdown.sh exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = "$HWS" ] || die "harness/probe/web must hold exactly $HWS: javac compiles all of it"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19420 19421 19422 19423 19424 19425 19426 19427 19428 19429; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole ---------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
CPL='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431'
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme "$J")
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme "java -cp $CPL")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
# the binding lesson's GET with a meal type, and the request-body lesson's POST - the anchor README's lines every request here is made from
R_GQ=$(readme "curl -s -w ' %{http_code}\n' 'http://127.0.0.1:18431/customers?mealType=VEGAN'")
ASHA='{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '$ASHA' http://127.0.0.1:18431/customers")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the harness's compile line; the
# class-path run line with a locale - U.S. English, U.K. English - and with Boot's date format; the harness's question; the GET line
# with a language header; and the four lines that print the harness's source
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_JAVAC=$(mine 'javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/*.java')
L_CPUS=$(mine "java -Duser.language=en -Duser.country=US -cp $CPL")
L_CPGB=$(mine "java -Duser.language=en -Duser.country=GB -cp $CPL")
L_ISO=$(mine "java -Duser.language=en -Duser.country=US -cp $CPL --spring.mvc.format.date=iso")
L_WHO=$(mine "curl -s 'http://127.0.0.1:18431/probe/who/binds?route=/customers'")
L_AL=$(mine "curl -s -w ' %{http_code}\n' -H 'Accept-Language: en-GB' 'http://127.0.0.1:18431/probe/date?on=14/10/26'")
L_SRCC=$(mine "sed -n '/^@Component/,/^}/p' harness/probe/web/MealTypeConverter.java")
L_SRCB=$(mine "sed -n '/^    @InitBinder/,/^    }/p' harness/probe/web/Binder.java")
L_SRCD=$(mine "grep -n 'LocalDate on)' harness/probe/web/Dates.java")
L_SRCQ=$(mine "grep -n '^    record ' harness/probe/web/Queries.java")
# The derivations, each asserted: the locale lines are the anchor's class-path line with two JVM options before -cp (S2.14: after the
# main class the anchor's guard refuses them), and nothing else; the iso line is the U.S. one with one option at its end; the language
# line is the anchor's GET line with one header and its path changed
P_="java -cp "; R_="java -Duser.language=en -Duser.country=US -cp "; r=${R_CP/"$P_"/$R_}; [ "$r" = "$L_CPUS" ] || die "the U.S. English line must be the anchor's class-path line with -Duser.language=en -Duser.country=US before -cp, and nothing else"
R_="java -Duser.language=en -Duser.country=GB -cp "; r=${R_CP/"$P_"/$R_}; [ "$r" = "$L_CPGB" ] || die "the U.K. English line must be the anchor's class-path line with -Duser.language=en -Duser.country=GB before -cp, and nothing else"
[ "$L_ISO" = "$L_CPUS --spring.mvc.format.date=iso" ] || die "the iso line must be the U.S. English line with one option, and nothing else"
GQW=${R_GQ% *}                                       # the GET line's curl and its -w, before the URL
AH=" -H 'Accept-Language: en-GB'"; r=${L_AL/"$AH"/}; [ "$r" = "$GQW 'http://127.0.0.1:18431/probe/date?on=14/10/26'" ] || die "the language line must be the anchor's GET line with one header and another path, and nothing else"
WQW=${L_WHO% *}                                      # the harness's question, before its URL
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package) clean and without tests. dev() takes those four things back out, and must give the
# README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# hcp 'RUN LINE' DIR PORT CLASSES: a class-path run line (the anchor's, or one of this unit's with a locale) from DIR, its port made
# PORT, the harness's classes added to the class path (../hc) and CLASSES joined (--spring.main.sources=), after the line's own options
hcp() { local c; c=$(at "$2" "$3" "$1"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s\n' "$c" "$4"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# qurl PORT PATH: the URL; one that holds a character the shell reads (; ? & * { } or a space) is single-quoted, so eval hands it to
# curl whole
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}\ ]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
# gq PORT PATH: the anchor's GET line, its port and path swapped; pq PORT PATH 'BODY': its POST line, port, path and body swapped (the
# body single-quoted, as the README writes it); wq PORT ROUTE: this unit's question to the harness, for ROUTE; aq PORT PATH: the GET
# line with this unit's language header
PQW=${R_POST% --data *}
gq() { printf '%s %s\n' "$GQW" "$(qurl "$1" "$2")"; }
pq() { printf "%s --data '%s' %s\n" "$PQW" "$3" "$(qurl "$1" "$2")"; }
wq() { printf "%s 'http://127.0.0.1:%s/probe/who/binds?route=%s'\n" "$WQW" "$1" "$2"; }
aq() { printf '%s%s %s\n' "$GQW" "$AH" "$(qurl "$1" "$2")"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19420 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19420' ] || die "exe()"
[ "$(hcp "$L_CPGB" .harness/x 19428 probe.web.Dates)" = 'cd .harness/x && java -Duser.language=en -Duser.country=GB -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19428 --spring.main.sources=probe.web.Dates' ] || die "hcp()"
[ "$(gq 18431 '/customers?mealType=VEGAN')" = "$R_GQ" ] && [ "$(pq 18431 /customers "$ASHA")" = "$R_POST" ] && [ "$(wq 18431 /customers)" = "$L_WHO" ] && [ "$(aq 18431 '/probe/date?on=14/10/26')" = "$L_AL" ] || die "gq(), pq(), wq(), aq(): not the README's lines"
echo "  the commands: anchor/README.md gives the 8 lines this script runs or derives from; README.md the 10 this unit adds"

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
# tree FOLDER [TOKEN]: a config tree in FOLDER/secrets holding one file, the token (the demo token unless named) and a newline,
# readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "${2:-$TOKEN}" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
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
# tsmask: Spring's error timestamp - both JSON forms, an ISO-8601 string and epoch milliseconds - becomes "…" (README.md, Masks)
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
# tsform FILE...: the error timestamps in the files - unmasked answers - each made a form: every digit of its date and time becomes d,
# its zone kept (README.md, Masks); each distinct form, and how many times it appears
tsform() { cat "$@" | grep -o '"timestamp":"[^"]*"' | python3 -c 'import re, sys
for l in sys.stdin: print(re.sub(r"^(\"timestamp\":\")([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?)", lambda m: m.group(1) + re.sub(r"[0-9]", "d", m.group(2)), l.rstrip("\n")))' | sort | uniq -c | awk '{ c = $1; $1 = ""; sub(/^ /, ""); printf "%s%s ×%d", (NR > 1 ? " · " : ""), $0, c } END { if (NR == 0) printf "none" }'; }
# ihm: an identity hash - "@" and hexadecimal digits right after a class's name (a name that starts with a capital letter), as Java
# prints an object with no toString of its own - becomes "@…" (README.md, Masks)
ihm() { awk '{ s = $0; o = ""; while (match(s, /[A-Z][A-Za-z0-9_$]*@[0-9a-f]+/)) { m = substr(s, RSTART, RLENGTH); k = index(m, "@"); o = o substr(s, 1, RSTART - 1) substr(m, 1, k) "…"; s = substr(s, RSTART + RLENGTH) } print o s }'; }
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
extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }
# settle: the log stops growing (the same length twice, 0.5 s apart; up to 15 s) - a request's last line is written just after
# its answer leaves
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
mark() { settle; wc -l < .harness/run.out | tr -d ' '; }
# logl FROM [LEVELS]: the run's lines after line FROM at those levels (an extended regular expression; WARN|ERROR unless named), from
# their level and logger on - identity hashes masked (ihm)
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" 'NR > from && $0 ~ (" (" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3); print "    " l " " lg ": " msg }' .harness/run.out | ihm; }
# fwarn FROM: the WARN lines after line FROM, as logl prints them - but a line that lists field errors (Spring MVC's
# MethodArgumentNotValidException) is cut after "with N errors", and the field errors it lists follow, one a line, sorted by field:
# the field, the value it was given, its code - the last of its codes, the most general; the other codes, its arguments and its
# default message are counted out, not shown (README.md, Masks)
fwarn() { python3 - .harness/run.out "$1" <<'PY'
import re, sys
lines = open(sys.argv[1], encoding="utf-8", errors="replace").read().splitlines()[int(sys.argv[2]):]
for l in lines:
    m = re.search(r" (WARN) [0-9]+ --- \[[^]]*\] (.*?) +: (.*)$", l)
    if not m: continue
    lv, lg, msg = m.group(1), m.group(2).strip(), m.group(3)
    msg = re.sub(r"([A-Z][A-Za-z0-9_$]*)@[0-9a-f]+", r"\1@…", msg)
    k = re.search(r" with (\d+) errors?: \[", msg)
    if not k: print("    %s %s: %s" % (lv, lg, msg)); continue
    print("    %s %s: %s: …" % (lv, lg, msg[:k.end() - 3]))
    rows = []
    for p in msg[k.end() - 1:].split("[Field error in object '")[1:]:
        f = re.search(r"on field '([^']*)': rejected value \[(.*?)\]; codes \[([^]]*)\]", p)
        rows.append((f.group(1), f.group(2), f.group(3).split(",")[-1]))
    print("      the field errors it lists: %d, sorted by field - each: its field, the value it was given, its code (the last of its codes); the other codes, its arguments and its default message not shown:" % len(rows))
    for f, v, c in sorted(rows): print("        %s [%s]: %s" % (f, v, c))
PY
}
# wans FROM FILE: an answer (FILE) and the WARN lines its request added after line FROM, at the level the run was started with:
# the answer's last line ends with their count, each one follows (fwarn)
wans() { local w; settle; w=$(logl "$1" WARN | grep -c . || true)
  awk -v w="$w" '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) print "  " l[i] (i == NR ? " · WARN lines it added: " w : "") }' "$2"
  [ "$w" = 0 ] || fwarn "$1"; }
# ask PORT PATH: the anchor's GET line (gq), printed and run, the answer's timestamp masked; then the WARN lines it added. askp PORT
# PATH 'BODY': the anchor's POST line (pq), the same way. aska PORT PATH: the GET line with this unit's language header (aq)
ask() { local c n0; n0=$(mark); c=$(gq "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
askp() { local c n0; n0=$(mark); c=$(pq "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
aska() { local c n0; n0=$(mark); c=$(aq "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# who PORT ROUTE: this unit's question to the harness (wq) for ROUTE, printed and run, its answer indented, identity hashes masked
who() { local c; c=$(wq "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | ihm | sed 's/^/  /'; }
# rp 'COMMAND': a command, printed and run, its output indented, the timestamps masked
rp() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
# warns: the run's WARN and ERROR lines so far, counted
warns() { settle; echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# bmeta JAR KEY: Boot's own metadata for a key - its type, its default, its description and the values its hint names - read from JAR
# in the anchor's extracted lib
bmeta() { python3 - ".harness/anchor/tiffinbox-web/target/extracted/lib/$1" "$2" <<'PY'
import json, os, sys, zipfile
d = json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json"))
p = {x["name"]: x for x in d.get("properties", [])}; j = os.path.basename(sys.argv[1]); k = sys.argv[2]; e = p.get(k)
if not e: print("  Boot's metadata (%s): %s - in none of its entries" % (j, k))
else:
    dv = e.get("defaultValue")
    print("  Boot's metadata (%s) - %s · its type: %s · its default: %s · its description: %s" % (j, k, e.get("type", "none").rsplit(".", 1)[-1], "none" if dv is None else json.dumps(dv), e.get("description", "none")))
    hv = [v for x in d.get("hints", []) if x["name"] == k for v in x.get("values", [])]
    print("    the values its hint names: %d%s" % (len(hv), "".join(" · %s - %s" % (v["value"], v.get("description", "none")) for v in hv)))
PY
}

# ---- default: TiffinBox's own rule - a meal type by its exact name ------------------------------------------------------------
BVEG='{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"veg"}'
OVEG='{"mealType":"veg"}'; OVEGU='{"mealType":"VEG"}'
default() {
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"
  echo "  and its jar extracted (the README's line) - the class path the harness runs on:"
  extract .harness/anchor
  echo "the harness, compiled against the anchor's own jar - with -parameters (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jar"; }
  echo "  exit 0 · its classes: $(cd .harness/hc/probe/web && ls *.class | grep -vc '\$' || true) top-level - $(cd .harness/hc/probe/web && ls *.class | grep -v '\$' | sed 's/\.class$//' | paste -sd' ' -)"
  echo "the seven - the anchor, the README's run line, port 19420, a fresh JVM:"
  start "$(at .harness/anchor 19420 "$R_RUN")"; up 19420; ready 19420; seven 19420 .harness/anchor
  echo "the anchor on its class path, U.S. English (this unit's run line), the harness's Who joined, port 19421, a fresh JVM - the meal type asked for as VEG, veg and empty (the anchor README's GET line, its value swapped), then who binds it (this unit's line):"
  start "$(hcp "$L_CPUS" .harness/anchor 19421 probe.web.Who)"; up 19421; ready 19421
  ask 19421 '/customers?mealType=VEG'; ask 19421 '/customers?mealType=veg'; ask 19421 '/customers?mealType='
  who 19421 /customers
  echo "  the same word in a JSON body - TiffinBox's own POST (the anchor README's line, its meal type veg):"
  askp 19421 /customers "$BVEG"
  warns
  stop 19421 .harness/anchor; }

# ---- converter: one Converter bean, for every route - and never a JSON body ----------------------------------------------------
converter() {
  echo "the harness's converter, from its annotation on (this unit's line):"
  rp "$L_SRCC"
  echo "the seven - the anchor on its class path, U.S. English, the converter joined, port 19422, a fresh JVM:"
  start "$(hcp "$L_CPUS" .harness/anchor 19422 probe.web.MealTypeConverter)"; up 19422; ready 19422; seven 19422 .harness/anchor
  echo "the same, a fresh JVM, the converter, Who, Plain and Queries joined, port 19422 - who binds a meal type now, then the meal type asked for as veg, Veg, empty and lunch:"
  start "$(hcp "$L_CPUS" .harness/anchor 19422 probe.web.MealTypeConverter,probe.web.Who,probe.web.Plain,probe.web.Queries)"; up 19422; ready 19422
  who 19422 /customers
  ask 19422 '/customers?mealType=veg'; ask 19422 '/customers?mealType=Veg'; ask 19422 '/customers?mealType='; ask 19422 '/customers?mealType=lunch'
  echo "  the same converter on the harness's routes - a request parameter (Plain), a record's component (Queries):"
  ask 19422 '/probe/plain/meal?type=veg'; ask 19422 '/probe/query?mealType=veg&maxPrice=130'
  echo "  JSON bodies - TiffinBox's own POST (its meal type a String, which the record checks), then Plain's order (its meal type a MealType), as veg and as VEG:"
  askp 19422 /customers "$BVEG"; askp 19422 /probe/plain/order "$OVEG"; askp 19422 /probe/plain/order "$OVEGU"
  warns
  stop 19422 .harness/anchor; }

# ---- format: a format on one parameter, and Boot's for every date (A/B/A') ------------------------------------------------------
formatq() { ask "$1" '/probe/date?on=10/14/26'; ask "$1" '/probe/date?on=2026-10-14'
  ask "$1" '/probe/date/fmt?on=14/10/2026'; ask "$1" '/probe/date/fmt?on=2026-10-14'; ask "$1" '/probe/date/fmt?on=10/14/26'; }
formata() { start "$(hcp "$L_CPUS" .harness/anchor 19423 probe.web.Dates,probe.web.Who)"; up 19423; ready 19423
  who 19423 /probe/date; who 19423 /probe/date/fmt; formatq 19423; warns; stop 19423 .harness/anchor; }
format() {
  bmeta spring-boot-webmvc-4.1.1.jar spring.mvc.format.date
  echo "the harness's three date routes (this unit's line):"
  rp "$L_SRCD"
  echo "A - the anchor on its class path, U.S. English (this unit's run line), Dates and Who joined, port 19423 - what reads each route's date, then dates with no format, then with @DateTimeFormat(pattern = \"dd/MM/yyyy\"):"
  formata
  echo "B - the same with Boot's date format set to iso (this unit's run line), Dates and Who joined, port 19424 - what reads a date with no format, then the same dates:"
  start "$(hcp "$L_ISO" .harness/anchor 19424 probe.web.Dates,probe.web.Who)"; up 19424; ready 19424
  who 19424 /probe/date; formatq 19424; warns; stop 19424 .harness/anchor
  echo "A' - A again, a fresh JVM, port 19423:"
  formata
  echo "A' against A, its label aside, line for line the same: $(asame 'A - the anchor' 'B - the same' "A' - A again" "A' against A")"; }

# ---- binder: one controller's own rules (@InitBinder), and its twin without them ------------------------------------------------
binder() {
  echo "the harness's binder - its @InitBinder method (this unit's line):"
  rp "$L_SRCB"
  echo "Binder and its twin Plain, the converter joined too, the anchor on its class path (its README's line), port 19425, a fresh JVM - a name with two spaces either side, a blank name, then meal types:"
  start "$(hcp "$R_CP" .harness/anchor 19425 probe.web.Binder,probe.web.Plain,probe.web.MealTypeConverter)"; up 19425; ready 19425
  ask 19425 '/probe/binder/name?name=%20%20Ravi%20%20'; ask 19425 '/probe/plain/name?name=%20%20Ravi%20%20'
  ask 19425 '/probe/binder/name?name=%20%20'; ask 19425 '/probe/plain/name?name=%20%20'
  ask 19425 '/probe/binder/meal?type=v'; ask 19425 '/probe/binder/meal?type=VEG'; ask 19425 '/probe/plain/meal?type=veg'; ask 19425 '/probe/plain/meal?type=v'
  warns
  stop 19425 .harness/anchor; }

# ---- record: a record from a query string ---------------------------------------------------------------------------------
record() {
  echo "the harness's three records (this unit's line):"
  rp "$L_SRCQ"
  echo "Queries and Who joined, the anchor on its class path, U.S. English, port 19426, a fresh JVM - who binds a record, with no annotation and with @ModelAttribute:"
  start "$(hcp "$L_CPUS" .harness/anchor 19426 probe.web.Queries,probe.web.Who)"; up 19426; ready 19426
  who 19426 /probe/query; who 19426 /probe/query/model
  echo "  a record bound - both components, one missing, the same with @ModelAttribute, then two values that cannot become their types:"
  ask 19426 '/probe/query?mealType=VEG&maxPrice=130'; ask 19426 '/probe/query?maxPrice=130'; ask 19426 '/probe/query/model?mealType=VEG&maxPrice=130'; ask 19426 '/probe/query?mealType=veg&maxPrice=abc'
  echo "  @BindParam - a component bound from a parameter of another name:"
  ask 19426 '/probe/query/named?type=VEG&maxPrice=130'; ask 19426 '/probe/query/named?mealType=VEG&maxPrice=130'
  echo "  a record with a rule, @Min(1) on maxPrice, and a BindingResult beside it - the rule broken, then a meal type that cannot become its type beside the same broken rule:"
  ask 19426 '/probe/query/checked?mealType=VEG&maxPrice=0'; ask 19426 '/probe/query/checked?mealType=veg&maxPrice=0'
  warns
  stop 19426 .harness/anchor; }

# ---- locale: A/B/A' - the JVM's locale, for a date with no format; C and D, labelled -------------------------------------------
localeq() { ask "$1" /probe/date/pattern; ask "$1" '/probe/date?on=10/14/26'; ask "$1" '/probe/date?on=14/10/26'; }
locala() { start "$(hcp "$L_CPUS" .harness/anchor 19427 probe.web.Dates)"; up 19427; ready 19427; localeq 19427; warns; stop 19427 .harness/anchor; }
locale() {
  echo "A - the anchor on its class path, U.S. English (this unit's run line), Dates joined, port 19427 - the short date pattern, then two dates with no format:"
  locala
  echo "B - the same, U.K. English (this unit's run line), port 19428:"
  start "$(hcp "$L_CPGB" .harness/anchor 19428 probe.web.Dates)"; up 19428; ready 19428; localeq 19428; warns; stop 19428 .harness/anchor
  echo "A' - A again, a fresh JVM, port 19427:"
  locala
  echo "A' against A, its label aside, line for line the same: $(asame 'A - the anchor' 'B - the same' "A' - A again" "A' against A")"
  echo "C (labelled) - U.K. English, port 19428, a fresh JVM - the route that names its pattern, dd/MM/yy:"
  start "$(hcp "$L_CPGB" .harness/anchor 19428 probe.web.Dates)"; up 19428; ready 19428; ask 19428 '/probe/date/yy?on=14/10/26'; warns; stop 19428 .harness/anchor
  echo "D (labelled) - U.S. English, port 19427, a fresh JVM - the request itself in U.K. English, by its Accept-Language header (this unit's line):"
  start "$(hcp "$L_CPUS" .harness/anchor 19427 probe.web.Dates)"; up 19427; ready 19427; aska 19427 /probe/date/pattern; aska 19427 '/probe/date?on=14/10/26'; warns; stop 19427 .harness/anchor; }

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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/ex-readme.log || true) · listening on 19429 now: $(listeners 19429)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · listening on 19429 now: $(listeners 19429)"; }


cap default default
cap converter converter
cap format format
cap binder binder
cap record record
cap locale locale
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
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/probe/web/*.java; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|\"timestamp\":\"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]|GMT| CES?T " "$f" || die "$f holds a log line's time, a timestamp, a time zone or a thread's number"; ! grep -qE '[A-Z][A-Za-z0-9_$]*@[0-9a-f]' "$f" || die "$f holds an identity hash"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; ! grep -E 'server\.error\.' "$f" | grep -vE '^ *#' > /dev/null || die "$f names one of Boot 3's error keys (server, then error) - Boot 4.1 reads only spring.web.error.* (S2.13)"; done
# Every command a capture runs asks 127.0.0.1
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the exercise and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no time zone, no thread number, no identity hash, no stack frame, no 8080, no carriage return in any capture; every command a capture runs asks 127.0.0.1"

S87C='87ca7efc8584dcccd40e6b956db1de9b'
SEVEN1="  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C"
WA() { printf '%s · WARN lines it added: %s' "$1" "$2"; }
GQ() { printf '$ %s' "$(gq "$@")"; }; PQ() { printf '$ %s' "$(pq "$@")"; }; WQ() { printf '$ %s' "$(wq "$@")"; }; AQ() { printf '$ %s' "$(aq "$@")"; }
# (the pattern and the replacement are variables, and each result an assignment: /bin/bash 3.2 ends a pattern at a slash even inside
# quotes, and keeps a quoted replacement's quotes inside a quoted expansion)
P_='=VEGAN'; R_='=veg'; r1=${R_GQ/"$P_"/$R_}; P_='"mealType":"VEG"'; R_='"mealType":"veg"'; r2=${R_POST/"$P_"/$R_}
[ "$(GQ 19421 '/customers?mealType=veg')" = "\$ $(url "$r1" 19421)" ] && [ "$(PQ 19421 /customers "$BVEG")" = "\$ $(url "$r2" 19421)" ] && [ "$(WQ 19421 /customers)" = "\$ $(url "$L_WHO" 19421)" ] && [ "$(AQ 19427 '/probe/date?on=14/10/26')" = "\$ $(url "$L_AL" 19427)" ] || die "the checks' own command lines are not the README's"
VS='[{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]'
ALL4='[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]'
E400() { printf '  {"timestamp":"…","status":400,"error":"Bad Request","path":"%s"} 400' "$1"; }
WMM() { printf "    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter '%s': Failed to convert value of type 'java.lang.String' to required type '%s'; %s]" "$1" "$2" "$3"; }
FC() { printf 'Failed to convert from type [java.lang.String] to type [%s] for value [%s]' "$1" "$2"; }
RPM='@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType'
RPD='@org.springframework.web.bind.annotation.RequestParam java.time.LocalDate'; RPDF='@org.springframework.web.bind.annotation.RequestParam @org.springframework.format.annotation.DateTimeFormat java.time.LocalDate'
SVC="  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object"
VMSG='  {"mealType":"must match \"VEG|NON_VEG|VEGAN\""} 400'
LUS="  the JVM's locale: en_US"

# "Ask for the vegetarian customers with VEG in capitals: Ravi and Sunil. Type veg, and it's a four hundred, bad request ... read off
#  the running app ... the conversion service ... Spring's own converter, for every enum ... the same word in a JSON body ... validation's
#  message, and no warning line"
D0=$(blk default 'the anchor - anchor/' 'the seven - the anchor'); D7=$(blk default 'the seven - the anchor' 'the anchor on its class path'); D2=$(blk default 'the anchor on its class path' '')
has "$D0" '  built the anchor · offline: yes · exit 0' "default: the anchor built offline"
has "$D0" '  exit 0 · its classes: 6 top-level - Binder Dates MealTypeConverter Plain Queries Who' "default: the harness's six classes compiled"
has "$D7" "$SEVEN1" "default: the seven"
[ "$(aft "$(GQ 19421 '/customers?mealType=VEG')" "$D2")" = "$(WA "  $VS 200" 0)" ] || die "default: VEG - Ravi and Sunil"
[ "$(aft "$(GQ 19421 '/customers?mealType=veg')" "$D2")" = "$(WA "$(E400 /customers)" 1)" ] && [ "$(aft2 "$(GQ 19421 '/customers?mealType=veg')" "$D2")" = "$(WMM mealType com.tiffinbox.MealType "$(FC "$RPM" veg)")" ] || die "default: veg - 400, Boot's body, one WARN, the conversion that failed"
[ "$(aft "$(GQ 19421 '/customers?mealType=')" "$D2")" = "$(WA "  $ALL4 200" 0)" ] || die "default: an empty meal type - no filter, all four"
has "$D2" '  GET /customers - TiffinBoxServer#customers, 1 parameter' "default: Who reads TiffinBox's route"
has "$D2" '    @RequestParam MealType mealType - its argument resolver: 1 of 28, RequestParamMethodArgumentResolver' "default: the meal type's resolver"
has "$D2" '      from a String, the conversion service uses: java.lang.String -> java.lang.Enum : org.springframework.core.convert.support.StringToEnumConverterFactory@…' "default: Spring's own converter, for every enum"
has "$D2" "$SVC" "default: the conversion service, Boot's WebConversionService, the data binders' own"
has "$D2" "$LUS" "default: the JVM's locale pinned"
[ "$(aft "$(PQ 19421 /customers "$BVEG")" "$D2")" = "$(WA "$VMSG" 0)" ] || die "default: veg in a JSON body - validation's message, no WARN"
has "$D2" "  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0" "default: one WARN in all"
echo "  default: the seven $S87C; VEG -> Ravi, Sunil; veg -> 400, 1 WARN (MethodArgumentTypeMismatchException); empty -> all four; Who: resolver 1 of 28, StringToEnumConverterFactory, mvcConversionService = Boot's WebConversionService = the data binders'; locale en_US; veg in a JSON body -> validation's field message, 0 WARN"

# "the harness's MealTypeConverter ... trim, upper-case, look it up ... The seven hash as before ... veg and Veg: Ravi and Sunil ... blank
#  stays no filter ... lunch is still a four hundred ... the harness's own parameter, even a record's component ... TiffinBox's POST still
#  gets its validation message ... the harness's order ... four hundred: Jackson reads JSON bodies"
CV=$(cat .r-converter.out); C7=$(blk converter 'the seven - the anchor' 'the same, a fresh JVM'); C2=$(blk converter 'the same, a fresh JVM' '')
for l in '  @Component' '  public class MealTypeConverter implements Converter<String, MealType> {' '      public MealType convert(String source) {' '          String s = source.trim();' '          return s.isEmpty() ? null : MealType.valueOf(s.toUpperCase(Locale.ROOT));'; do has "$CV" "$l" "converter: its source"; done
has "$C7" "$SEVEN1" "converter: the seven, the converter joined, as before"
has "$C2" '      from a String, the conversion service uses: java.lang.String -> com.tiffinbox.MealType : probe.web.MealTypeConverter@…' "converter: the service picks ours"
has "$C2" "$SVC" "converter: the same service"
for v in veg Veg; do [ "$(aft "$(GQ 19422 "/customers?mealType=$v")" "$C2")" = "$(WA "  $VS 200" 0)" ] || die "converter: $v - Ravi and Sunil"; done
[ "$(aft "$(GQ 19422 '/customers?mealType=')" "$C2")" = "$(WA "  $ALL4 200" 0)" ] || die "converter: blank - still no filter"
[ "$(aft "$(GQ 19422 '/customers?mealType=lunch')" "$C2")" = "$(WA "$(E400 /customers)" 1)" ] && [ "$(aft2 "$(GQ 19422 '/customers?mealType=lunch')" "$C2")" = "$(WMM mealType com.tiffinbox.MealType "$(FC "$RPM" lunch)")" ] || die "converter: lunch - 400, one WARN"
[ "$(aft "$(GQ 19422 '/probe/plain/meal?type=veg')" "$C2")" = "$(WA '  type=VEG 200' 0)" ] || die "converter: Plain's parameter - VEG"
[ "$(aft "$(GQ 19422 '/probe/query?mealType=veg&maxPrice=130')" "$C2")" = "$(WA '  query=CustomerQuery[mealType=VEG, maxPrice=130] 200' 0)" ] || die "converter: a record's component - VEG"
[ "$(aft "$(PQ 19422 /customers "$BVEG")" "$C2")" = "$(WA "$VMSG" 0)" ] || die "converter: TiffinBox's POST - still validation's message"
[ "$(aft "$(PQ 19422 /probe/plain/order "$OVEG")" "$C2")" = "$(WA "$(E400 /probe/plain/order)" 1)" ] && [ "$(aft2 "$(PQ 19422 /probe/plain/order "$OVEG")" "$C2")" = '    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot deserialize value of type `com.tiffinbox.MealType` from String "veg": not one of the values accepted for Enum class: [VEG, VEGAN, NON_VEG]]' ] || die "converter: Plain's order, veg in JSON - Jackson's 400"
[ "$(aft "$(PQ 19422 /probe/plain/order "$OVEGU")" "$C2")" = "$(WA '  order=Order[mealType=VEG] 200' 0)" ] || die "converter: Plain's order, VEG in JSON - 200"
has "$C2" "  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 0" "converter: two WARN in all"
echo "  converter: its source; the seven $S87C with it; the service uses probe.web.MealTypeConverter; veg, Veg -> Ravi, Sunil; blank -> all four; lunch -> 400, 1 WARN; Plain's type=veg -> VEG; a record's component -> VEG; TiffinBox's POST -> validation's message; Plain's order veg -> Jackson's 400, VEG -> 200; 2 WARN"

# "With no format named, a date gets Spring's default formatter: A, in U.S. English, ten fourteen twenty-six is October the fourteenth,
#  and so is the ISO form ... DateTimeFormat with a pattern ... fourteen ten twenty twenty-six works there; ISO still does; the U.S. form
#  doesn't. B: Boot's key ... set to iso ... now only the year-first form. The parameter with its own pattern doesn't care. A again"
FA=$(blk format 'A - the anchor' 'B - the same'); FB=$(blk format 'B - the same' "A' - A again"); FA2=$(blk format "A' - A again" "A' against A")
x format "^  Boot's metadata \(spring-boot-webmvc-4\.1\.1\.jar\) - spring\.mvc\.format\.date · its type: String · its default: none · its description: Date format to use, for example 'dd/MM/yyyy'\. Used for formatting of java\.util\.Date and java\.time\.LocalDate\.\$"
x format '^    the values its hint names: 2 · dd/MM/yyyy - Example date format\. Any format supported by DateTimeFormatter\.parse can be used\. · iso - ISO-8601 extended local date format\.$'
x format '^  30:    String fmt\(@RequestParam @DateTimeFormat\(pattern = "dd/MM/yyyy"\) LocalDate on\) \{$'
for b in "$FA" "$FA2"; do
  has "$b" '      from a String, the conversion service uses: java.lang.String -> java.time.LocalDate: org.springframework.format.datetime.standard.TemporalAccessorParser@…' "format A/A': the default formatter's parser"
  has "$b" '      from a String, the conversion service uses: java.lang.String -> @org.springframework.format.annotation.DateTimeFormat java.time.LocalDate: org.springframework.format.datetime.standard.Jsr310DateTimeFormatAnnotationFormatterFactory@…' "format A/A': the annotation's formatter"
  has "$b" "$LUS" "format A/A': U.S. English"
  has "$b" "        its parser's formatter: Localized(SHORT,)" "format A/A': the default formatter holds the locale's short date style"
  [ "$(aft "$(GQ 19423 '/probe/date?on=10/14/26')" "$b")" = "$(WA "  on=2026-10-14 · the JVM's locale: en_US 200" 0)" ] || die "format A/A': 10/14/26 - 2026-10-14"
  [ "$(aft "$(GQ 19423 '/probe/date?on=2026-10-14')" "$b")" = "$(WA "  on=2026-10-14 · the JVM's locale: en_US 200" 0)" ] || die "format A/A': ISO - 2026-10-14"
  [ "$(aft "$(GQ 19423 '/probe/date/fmt?on=14/10/2026')" "$b")" = "$(WA '  on=2026-10-14 200' 0)" ] && [ "$(aft "$(GQ 19423 '/probe/date/fmt?on=2026-10-14')" "$b")" = "$(WA '  on=2026-10-14 200' 0)" ] || die "format A/A': the pattern, and ISO still"
  [ "$(aft "$(GQ 19423 '/probe/date/fmt?on=10/14/26')" "$b")" = "$(WA "$(E400 /probe/date/fmt)" 1)" ] && [ "$(aft2 "$(GQ 19423 '/probe/date/fmt?on=10/14/26')" "$b")" = "$(WMM on java.time.LocalDate "$(FC "$RPDF" 10/14/26)")" ] || die "format A/A': the U.S. form refused where the pattern is named"; done
x format "^A' against A, its label aside, line for line the same: yes\$"
has "$FB" '$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19424 --spring.mvc.format.date=iso --spring.main.sources=probe.web.Dates,probe.web.Who' "format B: the key on its run line"
has "$FB" "        its parser's formatter: Value(Year,4,10,EXCEEDS_PAD)'-'Value(MonthOfYear,2)'-'Value(DayOfMonth,2)" "format B: Boot's key - the parser holds ISO's year-month-day now"
[ "$(aft "$(GQ 19424 '/probe/date?on=10/14/26')" "$FB")" = "$(WA "$(E400 /probe/date)" 1)" ] && [ "$(aft2 "$(GQ 19424 '/probe/date?on=10/14/26')" "$FB")" = "$(WMM on java.time.LocalDate "$(FC "$RPD" 10/14/26)")" ] || die "format B: the U.S. form refused"
[ "$(aft "$(GQ 19424 '/probe/date?on=2026-10-14')" "$FB")" = "$(WA "  on=2026-10-14 · the JVM's locale: en_US 200" 0)" ] || die "format B: ISO only"
[ "$(aft "$(GQ 19424 '/probe/date/fmt?on=14/10/2026')" "$FB")" = "$(WA '  on=2026-10-14 200' 0)" ] || die "format B: the parameter's own pattern unchanged"
echo "  format: Boot's metadata, the hint iso; A en_US: the default parser TemporalAccessorParser holding Localized(SHORT,), the annotation's Jsr310DateTimeFormatAnnotationFormatterFactory; 10/14/26 and ISO -> 2026-10-14; dd/MM/yyyy: 14/10/2026 and ISO -> 2026-10-14, 10/14/26 -> 400; B iso: the parser holds year-month-day, 10/14/26 -> 400, ISO ok, the pattern's 14/10/2026 ok; A' = A"

# "an InitBinder method ... trim every string and make a blank one null, and read meal types as short codes. Two spaces round Ravi come
#  back trimmed; on its twin they stay. A blank name is a four hundred here, a pair of spaces there ... the binder's code v is VEG, and VEG
#  itself is refused, though our converter is right there. Next door, the converter still reads veg"
BI=$(cat .r-binder.out)
for l in '      @InitBinder' '      void rules(WebDataBinder binder) {' '          binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));' '          binder.registerCustomEditor(MealType.class, new ShortMealCodes());'; do has "$BI" "$l" "binder: its @InitBinder method"; done
[ "$(blk binder "\$ $L_SRCB" 'Binder and its twin' | grep -c .)" = 5 ] || die "binder: the source printed is the method's five lines"
[ "$(aft "$(GQ 19425 '/probe/binder/name?name=%20%20Ravi%20%20')" "$BI")" = "$(WA '  name=[Ravi] 200' 0)" ] && [ "$(aft "$(GQ 19425 '/probe/plain/name?name=%20%20Ravi%20%20')" "$BI")" = "$(WA '  name=[  Ravi  ] 200' 0)" ] || die "binder: trimmed in Binder, not in Plain"
[ "$(aft "$(GQ 19425 '/probe/binder/name?name=%20%20')" "$BI")" = "$(WA "$(E400 /probe/binder/name)" 1)" ] && [ "$(aft2 "$(GQ 19425 '/probe/binder/name?name=%20%20')" "$BI")" = "    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MissingServletRequestParameterException: Required request parameter 'name' for method parameter type String is present but converted to null]" ] || die "binder: a blank name - null, 400"
[ "$(aft "$(GQ 19425 '/probe/plain/name?name=%20%20')" "$BI")" = "$(WA '  name=[  ] 200' 0)" ] || die "binder: Plain keeps the spaces"
[ "$(aft "$(GQ 19425 '/probe/binder/meal?type=v')" "$BI")" = "$(WA '  type=VEG 200' 0)" ] || die "binder: v -> VEG"
[ "$(aft "$(GQ 19425 '/probe/binder/meal?type=VEG')" "$BI")" = "$(WA "$(E400 /probe/binder/meal)" 1)" ] && [ "$(aft2 "$(GQ 19425 '/probe/binder/meal?type=VEG')" "$BI")" = "$(WMM type com.tiffinbox.MealType 'not a short meal code: VEG')" ] || die "binder: VEG refused by the binder's editor, the converter present"
[ "$(aft "$(GQ 19425 '/probe/plain/meal?type=veg')" "$BI")" = "$(WA '  type=VEG 200' 0)" ] || die "binder: Plain - the converter's veg"
[ "$(aft "$(GQ 19425 '/probe/plain/meal?type=v')" "$BI")" = "$(WA "$(E400 /probe/plain/meal)" 1)" ] || die "binder: Plain - no short codes"
x binder ' --spring\.main\.sources=probe\.web\.Binder,probe\.web\.Plain,probe\.web\.MealTypeConverter$'
has "$BI" "  WARN lines in this run's log, at Boot's default level: 3 · ERROR lines: 0" "binder: three WARN"
echo "  binder: the @InitBinder method, 4 lines and its brace; Binder [Ravi], Plain [  Ravi  ]; blank: Binder 400 (converted to null), Plain [  ]; Binder v -> VEG, VEG -> 400 (not a short meal code), the converter joined; Plain veg -> VEG, v -> 400; 3 WARN"

# "a model attribute ... the same resolver ModelAttribute names, the last of its twenty-eight ... a component per parameter. A missing one
#  is null. BindParam renames one ... Two values that can't convert: four hundred, and the warning says method argument not valid ... both
#  binding failures, coded type mismatch ... max price zero breaks the rule. Add a bad meal type, and only the type mismatch comes back"
RE=$(cat .r-record.out)
has "$RE" '  26:    record CustomerQuery(MealType mealType, Integer maxPrice) {}' "record: CustomerQuery"
has "$RE" '  28:    record NamedQuery(@BindParam("type") MealType mealType, Integer maxPrice) {}' "record: @BindParam"
has "$RE" '  30:    record CheckedQuery(MealType mealType, @Min(1) Integer maxPrice) {}' "record: @Min(1)"
[ "$(aft "$(WQ 19426 /probe/query)" "$RE")" = '  GET /probe/query - Queries#query, 1 parameter' ] && [ "$(aft2 "$(WQ 19426 /probe/query)" "$RE")" = '    CustomerQuery q - its argument resolver: 28 of 28, ServletModelAttributeMethodProcessor' ] || die "record: no annotation - the last of 28, ServletModelAttributeMethodProcessor"
[ "$(aft2 "$(WQ 19426 /probe/query/model)" "$RE")" = '    @ModelAttribute CustomerQuery q - its argument resolver: 7 of 28, ServletModelAttributeMethodProcessor' ] || die "record: @ModelAttribute - the same class, 7 of 28"
[ "$(aft "$(GQ 19426 '/probe/query?mealType=VEG&maxPrice=130')" "$RE")" = "$(WA '  query=CustomerQuery[mealType=VEG, maxPrice=130] 200' 0)" ] && [ "$(aft "$(GQ 19426 '/probe/query/model?mealType=VEG&maxPrice=130')" "$RE")" = "$(WA '  query=CustomerQuery[mealType=VEG, maxPrice=130] 200' 0)" ] || die "record: bound, with and without @ModelAttribute"
[ "$(aft "$(GQ 19426 '/probe/query?maxPrice=130')" "$RE")" = "$(WA '  query=CustomerQuery[mealType=null, maxPrice=130] 200' 0)" ] || die "record: a missing component - null"
[ "$(aft "$(GQ 19426 '/probe/query?mealType=veg&maxPrice=abc')" "$RE")" = "$(WA "$(E400 /probe/query)" 1)" ] || die "record: two values that cannot convert - 400"
has "$RE" '    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MethodArgumentNotValidException: Validation failed for argument [0] in java.lang.String probe.web.Queries.query(probe.web.Queries$CustomerQuery) with 2 errors: …' "record: MethodArgumentNotValidException, 2 errors"
has "$RE" '        maxPrice [abc]: typeMismatch' "record: maxPrice typeMismatch"; has "$RE" '        mealType [veg]: typeMismatch' "record: mealType typeMismatch"
[ "$(aft "$(GQ 19426 '/probe/query/named?type=VEG&maxPrice=130')" "$RE")" = "$(WA '  query=NamedQuery[mealType=VEG, maxPrice=130] 200' 0)" ] && [ "$(aft "$(GQ 19426 '/probe/query/named?mealType=VEG&maxPrice=130')" "$RE")" = "$(WA '  query=NamedQuery[mealType=null, maxPrice=130] 200' 0)" ] || die "record: @BindParam - type binds, mealType no longer"
[ "$(aft "$(GQ 19426 '/probe/query/checked?mealType=VEG&maxPrice=0')" "$RE")" = "$(WA '  query=CheckedQuery[mealType=VEG, maxPrice=0] · field errors: 1 · maxPrice [0] Min, a rule broken 200' 0)" ] || die "record: the rule broken"
[ "$(aft "$(GQ 19426 '/probe/query/checked?mealType=veg&maxPrice=0')" "$RE")" = "$(WA '  query=CheckedQuery[mealType=null, maxPrice=0] · field errors: 1 · mealType [veg] typeMismatch, a binding failure 200' 0)" ] || die "record: a binding failure, and the rule not checked"
has "$RE" "  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0" "record: one WARN"
echo "  record: no annotation -> 28 of 28, @ModelAttribute -> 7 of 28, both ServletModelAttributeMethodProcessor; bound; missing -> null; veg & abc -> 400, MethodArgumentNotValidException with 2 errors, both typeMismatch; @BindParam type -> mealType, mealType -> null; checked: 0 -> Min, a rule broken; veg & 0 -> 1 error, typeMismatch, a binding failure"

# "A: in U.S. English the pattern is month, day, two-digit year: ten fourteen twenty-six works, fourteen ten twenty-six doesn't. B: in
#  U.K. English it's day, month, and a one-letter year, so fourteen ten twenty-six is the year twenty-six. Two hundred, no warning ... A
#  again ... C ... twenty twenty-six. And D ... U.S. English server, a request in U.K. English ... the year twenty-six again"
LA=$(blk locale 'A - the anchor' 'B - the same'); LB=$(blk locale 'B - the same' "A' - A again"); LA2=$(blk locale "A' - A again" "A' against A"); LC=$(blk locale 'C (labelled)' 'D (labelled)'); LD=$(blk locale 'D (labelled)' '')
for b in "$LA" "$LA2"; do
  [ "$(aft "$(GQ 19427 /probe/date/pattern)" "$b")" = "$(WA "  the JVM's locale: en_US · this request's: en_US · its short date pattern: M/d/yy 200" 0)" ] || die "locale A/A': M/d/yy"
  [ "$(aft "$(GQ 19427 '/probe/date?on=10/14/26')" "$b")" = "$(WA "  on=2026-10-14 · the JVM's locale: en_US 200" 0)" ] || die "locale A/A': 10/14/26 - 2026-10-14"
  [ "$(aft "$(GQ 19427 '/probe/date?on=14/10/26')" "$b")" = "$(WA "$(E400 /probe/date)" 1)" ] && [ "$(aft2 "$(GQ 19427 '/probe/date?on=14/10/26')" "$b")" = "$(WMM on java.time.LocalDate "$(FC "$RPD" 14/10/26)")" ] || die "locale A/A': 14/10/26 - 400"; done
x locale "^A' against A, its label aside, line for line the same: yes\$"
has "$LB" '$ cd .harness/anchor && java -Duser.language=en -Duser.country=GB -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19428 --spring.main.sources=probe.web.Dates' "locale B: U.K. English, JVM options before -cp"
[ "$(aft "$(GQ 19428 /probe/date/pattern)" "$LB")" = "$(WA "  the JVM's locale: en_GB · this request's: en_GB · its short date pattern: dd/MM/y 200" 0)" ] || die "locale B: dd/MM/y"
[ "$(aft "$(GQ 19428 '/probe/date?on=10/14/26')" "$LB")" = "$(WA "$(E400 /probe/date)" 1)" ] || die "locale B: 10/14/26 - 400"
[ "$(aft "$(GQ 19428 '/probe/date?on=14/10/26')" "$LB")" = "$(WA "  on=0026-10-14 · the JVM's locale: en_GB 200" 0)" ] || die "locale B: 14/10/26 - the year twenty-six, 200, no warning"
[ "$(aft "$(GQ 19428 '/probe/date/yy?on=14/10/26')" "$LC")" = "$(WA '  on=2026-10-14 200' 0)" ] || die "locale C: dd/MM/yy - 2026-10-14"
[ "$(aft "$(AQ 19427 /probe/date/pattern)" "$LD")" = "$(WA "  the JVM's locale: en_US · this request's: en_GB · its short date pattern: dd/MM/y 200" 0)" ] || die "locale D: the request's locale, en_GB"
[ "$(aft "$(AQ 19427 '/probe/date?on=14/10/26')" "$LD")" = "$(WA "  on=0026-10-14 · the JVM's locale: en_US 200" 0)" ] || die "locale D: the year twenty-six on a U.S. English JVM"
for b in "$LC" "$LD"; do has "$b" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "locale C/D: no WARN"; done
echo "  locale: A en_US M/d/yy, 10/14/26 -> 2026-10-14, 14/10/26 -> 400; B en_GB dd/MM/y, 10/14/26 -> 400, 14/10/26 -> 0026-10-14, 200, 0 WARN; A' = A; C dd/MM/yy -> 2026-10-14; D en_US JVM, Accept-Language en-GB -> dd/MM/y, 0026-10-14"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder; the
# line exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='GET /customers?mealType=veg: 200 · customers: 2 · names: Ravi Sunil'; l0='GET /customers?mealType=veg: 400 · customers: 0 · names: none'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1 · listening on 19429 now: 0" "exercise: the README's commands leave the shell in this unit's folder, one WARN"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19429 now: 0" "exercise: the solution's lines leave the shell in this unit's folder, no WARN"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
r=$(printf '%s\n' "$XS" | grep '^  \$ (cd \.harness/mine/anchor && ' | sed 's/^  \$ //'); r2=$(printf '%s\n' "$XE" | grep '^  \$ (cd \.harness/mine/anchor && ' | sed 's/^  \$ //')
F1='--tiffinbox.port=19429 > '; F2='--tiffinbox.port=19429 --spring.main.sources=probe.web.MealTypeConverter > '; t=${r/"$F1"/$F2}
[ "$t" = "$r2" ] && [ "$r2" != "$r" ] || die "exercise: the solution's last line is the README's with the converter joined, one option, and nothing else"
echo "  exercise: one env -i shell - the README as written (no converter joined) -> 400, 0 customers, 1 WARN; the solution (--spring.main.sources=probe.web.MealTypeConverter) -> 200, 2 - Ravi Sunil; the shell in this unit's folder after each"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit13: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log"
