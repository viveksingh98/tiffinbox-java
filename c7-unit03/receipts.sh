#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Your First Entity and EntityManager - this unit's receipts. The course's first change to the anchor: Spring Boot's
# parent moves to 4.1.2, Spring Data JPA's starter joins tiffinbox-web, tiffinbox-core gains CustomerEntity (the customer table,
# mapped), TiffinBoxApp gains @EntityScan, and application.yaml three keys (Boot's DataSource on TiffinBox's own URL, ddl-auto
# none, open-in-view false). Eleven captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5;
# every number the video says is asserted at the bottom by a check that can fail; the demo token is masked, and the checks count
# 0 raw copies of it in every capture and every log.
#   move      the previous tree and the move alone (parent 4.1.2, no starter): the README's one changed line, the tests each ran
#             (Surefire's reports), BOOT-INF/lib's versions that moved, the seven on each (a fresh JVM each, the seven first),
#             the extras on each (the three messages, the size message, the page's title, health, readiness)
#   seven     after/'s jar: the seven, the extras - each against the previous tree's, line for line; which database its pool opened
#   two       A/B/C/A' - which database Hibernate talks to: A after/ + the harness; B one flip (--spring.datasource.url= : Boot's
#             generated database), the failure receipt; C (labelled) two flips (and ddl-auto create-drop); A' = A
#   entity    CustomerEntity's mapping lines, @EntityScan's line and its jar; the auto-configuration package; the EMF's own
#             properties (ddl-auto, the naming strategies, each with its jar); a query against the entity
#   scan      the failure receipt for a class change: B TiffinBoxApp recompiled without @EntityScan, ahead of the jar (labelled):
#             the context starts, the first query fails; A' after/ as shipped
#   persist   persist and its SQL: the INSERT and its four binds, logged before the "before commit" line; the id as printed;
#             Statistics; the anchor's own repository reads Kavya; a 61-letter name refused by the validator, 0 statements
#   ddl       Hibernate's DDL for the entity written to a file, never run, beside Database.java's; two labelled controls; the C7-5
#             check (javap of the shipped class vs both DDLs), and the same check on the control that plants length = 61: FAIL
#   ddlauto   A/B/B2/A' - A after/ (0 DDL lines); B create-drop: the order around Started and Closing JPA EntityManagerFactory;
#             B2 validate: exit 1; A' = A
#   osiv      A/B/B2/A' - the OpenEntityManagerInViewInterceptor bean count, the property, the WARN: A after/; B open-in-view=true;
#             B2 a copy of application.yaml without the key, ahead of the jar (labelled); A' = A. The check "beans 0" on each
#   tests     TiffinBox's tests on after/ (the README's line, offline): Surefire's reports, the console's summary beside their sum
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f
# "The previous tree" is before/, the link to ../c6-unit31/after: the anchor before this change (c7-tiffinbox's setup commit
# copied it, README aside - `move` shows it from git), COPIED under .harness/before; after/ is this unit's frozen copy of
# ../c7-tiffinbox after the change (asserted equal below), COPIED under .harness/after; .harness/move is the previous tree with the
# parent's version changed. Every tree is built where it is copied, never in place. Every run of TiffinBox starts in a folder under
# .harness/ that holds a config tree with a fake token (secrets/), listed before every start (the token's file, and nothing else).
# The harness (harness/src, package probe.jpa, outside com.tiffinbox) is compiled with javac -parameters against after/'s
# extracted jar into .harness/hc and joined to a run by --spring.main.sources=probe.jpa.Probe; it acts only when the run sets
# --probe.steps, prints PROBE lines, then closes the context and exits. Its run options travel as an array, V (R.193). Commands are
# printed exactly as they run: each goes through eval. "$CURLSET" is ../c5-unit11/curlset.sh (the seven, POST /shutdown with the
# token read from its file); harness/shutdown.sh (the CORS lesson's, byte for byte) stops a JVM the extras ran on; harness/surefire.py
# (the testing lesson's, byte for byte) reads Surefire's reports. "$M2" is this unit's own repository, .m2-demo.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it; the test JVM's comes from the POM's argLine.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). At run time nothing leaves 127.0.0.1, and every
# database is H2 in this JVM's memory.
# Masks (README.md declares each; awk gsub only): the demo token "[masked: the N-character token]"; this folder "…", the folder
# above it "…/..", home "~", your user name "<user>"; " using Java <version>"; H2's generated database name "jdbc:h2:mem:<uuid>";
# an identity hash "@…"; Spring's error timestamp "…". A JVM's log is never printed whole: Boot's first line, the lines of named
# loggers (each labelled by its logger, "Started TiffinBoxServer" without its seconds), the harness's PROBE lines, an exception's
# first line and its distinct "Caused by" lines; WARN and ERROR lines counted. A Maven log: its BUILD line, Surefire's reports, the
# console's summary; the rest counted. No duration is captured.
# Ports (§P, 19820-19829): move 19820 · seven 19821 · two 19822 · entity and scan 19823 · persist 19824 · ddl 19825 · ddlauto 19826
# · osiv 19827 · exercise 19828 · 19829 never bound. Each port's runs are sequential, each JVM waited for by its pid before the next.
# 18425 (TiffinBox's default), 8080 and 35729 are checked free too, and never bound. tests binds none (Surefire's mock environment).
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven, with every process under it - Surefire's test JVM), $xpid (an exercise shell, with every process under it);
# then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a Maven, Surefire's fork - is stopped.
# After an interrupt a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second
# Ctrl-C, and the script still exits 130 after an interrupt (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | grep -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 curl rsync lsof unzip mvn md5 cmp javap git tar /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L before ] && [ "$(readlink before)" = ../c6-unit31/after ] || die "before must be the link to ../c6-unit31/after - the anchor before this change"
PREV=before
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] && die "$t holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
  true; done
# after/ IS the anchor: ../c7-tiffinbox, byte for byte (its local repository and build output aside)
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
D_=$(diff -rq -x .m2-demo -x target -x secrets after ../c7-tiffinbox 2>&1 || true)
[ -z "$D_" ] || die "after/ is not ../c7-tiffinbox: $(printf '%s\n' "$D_" | head -3 | paste -sd';' -)"
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
MJ=tiffinbox-web/src/main/java/com/tiffinbox/web     # the web module's main sources
YML=tiffinbox-web/src/main/resources/application.yaml
SR=tiffinbox-web/target/surefire-reports
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
TOKEN=demo-token-for-the-first-entity
[ ${#TOKEN} = 31 ] || die "the demo token must be 31 characters: the captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
for f in harness/shutdown.sh harness/surefire.py harness/src/probe/jpa/Probe.java harness/src/probe/jpa/Steps.java exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = 'shutdown.sh src surefire.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/jpa/Probe.java probe/jpa/Steps.java' ] || die "harness/ holds another file"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
cmp -s harness/shutdown.sh ../c6-unit19/harness/shutdown.sh || die "harness/shutdown.sh is not the CORS lesson's (../c6-unit19/harness/shutdown.sh), byte for byte"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19820 19821 19822 19823 19824 19825 19826 19827 19828 19829"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_PAGE=$(readme "curl -s -H 'Accept: text/html' http://127.0.0.1:18431/dashboard")
R_HEALTH=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
# this unit's line in the anchor's README: Hibernate's DDL for the entities, written to a file and never run
DDLO1='--spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create'
DDLO2='--spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql'
R_DDL=$(readme "$R_RUN $DDLO1 $DDLO2")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
A61=$(printf 'A%.0s' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61)
[ ${#A61} = 61 ] || die "the 61-letter name must be 61 characters"
XC=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"     # after/'s extracted jar, from this folder
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_H=$(mine "java $JL -cp \"../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 \"\${V[@]}\"")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \"$XC\" harness/src/probe/jpa/Probe.java harness/src/probe/jpa/Steps.java")
L_MOVE=$(mine "sed 's#<version>4.1.1</version>#<version>4.1.2</version>#' pom.xml > pom.xml.new && mv pom.xml.new pom.xml")
L_NOSCAN=$(mine "sed '/^@EntityScan(\"com.tiffinbox\")\$/d' after/$MJ/TiffinBoxApp.java > .harness/ov-noscan/TiffinBoxApp.java")
L_NOSCANC=$(mine "javac -parameters -d .harness/ov-noscan/classes -cp \"$XC\" .harness/ov-noscan/TiffinBoxApp.java")
L_NOOSIV=$(mine "sed '/^    open-in-view: false\$/d' after/$YML > .harness/ov-noosiv/application.yaml")
L_CTL1=$(mine "sed -e '/^    @Size(max = 60)\$/d' -e 's/@Column(length = 60, /@Column(length = 61, /' after/$CJ/CustomerEntity.java > .harness/ctl1/CustomerEntity.java")
L_CTL2=$(mine "sed -e 's/@Column(length = 60, /@Column(length = 61, /' after/$CJ/CustomerEntity.java > .harness/ctl2/CustomerEntity.java")
L_CTL1C=$(mine "javac -parameters -d .harness/ctl1/classes -cp \"$XC\" .harness/ctl1/CustomerEntity.java")
L_CTL2C=$(mine "javac -parameters -d .harness/ctl2/classes -cp \"$XC\" .harness/ctl2/CustomerEntity.java")
INV='{"name":"","mealsPerDay":0,"pricePerMeal":0,"mealType":"VEG"}'
L_INV=$(mine "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '$INV' http://127.0.0.1:18431/customers")
L_BIG=$(mine "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"$A61\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
# The derivations, each asserted: one change each, and nothing else
P_='java '; Q_="java $JL "; [ "${R_RUN/"$P_"/$Q_}" = "$L_RUNL" ] || die "the pinned run line must be the anchor's with $JL after java, and nothing else"
P_='java -cp "'; Q_="java $JL -cp \"../hc:"; [ "${R_CP/"$P_"/$Q_} \"\${V[@]}\"" = "$L_H" ] || die "the harness line must be the anchor's extracted-jar line with $JL, ../hc first on the class path and the options array after it, and nothing else"
P_='"name":"Asha"'; Q_="\"name\":\"$A61\""; [ "${R_POST/"$P_"/$Q_}" = "$L_BIG" ] || die "the 61-letter POST must be the README's POST with the name made 61 letters, and nothing else"
P_="--data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'"; Q_="--data '$INV'"; [ "${R_POST/"$P_"/$Q_}" = "$L_INV" ] || die "the invalid POST must be the README's POST with the slice test's invalid customer, and nothing else"
[ "${R_DDL#"$R_RUN "}" = "$DDLO1 $DDLO2" ] || die "the DDL line must be the anchor's run line with the two schema-generation options, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - a java line with the JVM's locale pinned
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in "java $JL "*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# hl PORT [PREFIX]: the harness line, run from .harness/after, its port made PORT, PREFIX (a folder, from there) first on the class path
hl() { local l; l=$(at .harness/after "$1" "$L_H"); [ -z "${2:-}" ] || l=${l/-cp \"/-cp \"$2:}; printf '%s\n' "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(exe "$(at .harness/x 19821 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19821}" ] && [ "$(hl 19822 ../ov)" = "cd .harness/after && java $JL -cp \"../ov:../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19822 \"\${V[@]}\"" ] || die "at()/hl(): the run lines are not README.md's"
echo "  the commands: after/README.md gives the $(grep -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $(grep -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - Boot's first line names it; the captures say Java <version>" >&3

# ---- build: before the captures - the previous tree, the move and after/, each copied and built with the README's package line
# ---- offline (each runs its tree's tests); after/'s jar extracted (the anchor's line); the harness compiled against it ----------
rm -rf .harness; mkdir -p .harness
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs .m2-demo seeded (README.md, The repository) or the network once"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2"; rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; tree "$2"; }
copy "$PREV" .harness/before; copy "$PREV" .harness/move; copy after .harness/after
(cd .harness/move && eval "$L_MOVE") < /dev/null || die "the move's sed failed"
[ "$(diff .harness/before/pom.xml .harness/move/pom.xml | grep -c '^[<>]' || true)" = 2 ] || die "the move must change one line of the root pom.xml"
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (the previous tree, the README's package line; its tests ran)"
mbuild "$(off .harness/move "$R_PLAIN" package)" .harness/build-move.log ".harness/move (the previous tree, parent 4.1.2; its tests ran)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/boot/spring-boot-starter-data-jpa/4.1.2/spring-boot-starter-data-jpa-4.1.2.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the builds - README.md, The repository"; done
(cd .harness/after && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
mkdir -p .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
echo "  extracted after/'s jar ($(ls .harness/after/$XD/lib | wc -l | tr -d ' ') libraries) and compiled the harness into .harness/hc"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0
first() { grep -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing}) - every file there is a key (R.158)"
  echo "  secrets/ before the start: $s - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { sec "$(dir "$1")"; echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
listening() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$1"); case " $a " in *":$2 "*) break ;; esac; kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened on $1"; }
  case " $l " in *':8080 '*|*':35729 '*|*':19829 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19829 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }'; }
sortj() { python3 -c '
import json, sys
for l in sys.stdin.read().splitlines():
    b, _, s = l.rpartition(" ")
    try: o = json.dumps(json.loads(b), sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    except ValueError: print("  " + l); continue
    print("  " + o + " " + s + ("    (keys sorted)" if o != b else ""))'; }
askj() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sortj; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"; }
logtok() { local t; t=$(raw "$TOKEN" "${1:-.harness/run.out}"); LOGS=$((LOGS + 1)); [ "$t" = 0 ] || die "a log held the demo token ($t)"
  echo "  its log: the demo token 0 times"; }
LASTE=""
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
OSIVW=' WARN .*spring\.jpa\.open-in-view is enabled by default'
# jlog FILE: which database the run's pool opened (Hikari's line), Hibernate's version line, the open-in-view WARN, WARN/ERROR counted
jlog() { local h v
  h=$(grep -m1 -oE 'HikariPool-1 - Added connection conn0: url=[^ ]+' "$1" || true); v=$(grep -m1 -oE 'HHH000001: Hibernate ORM core version [^ ]+' "$1" || true)
  echo "  its pool: ${h:-no Hikari line - no DataSource pool in this run} · Hibernate: ${v:-no Hibernate line} · the open-in-view WARN: $(grep -cE "$OSIVW" "$1" || true) · WARN lines: $(lvl WARN "$1") · ERROR lines: $(lvl ERROR "$1")"; }
seven() { local m
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  gone "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  jlog .harness/run.out; logtok; }
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | tsmask | sed 's/^/  /'; }
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; jlog .harness/run.out; logtok; }
# extras PORT DIR LABEL: the three messages, the size message, the page's title, health, readiness - then POST /shutdown
extras() { local c
  { askj "$L_INV" "$1"; askj "$L_BIG" "$1"
    c=$(url "$R_PAGE" "$1"); echo "\$ $c"; (eval "$c") < /dev/null 2>&1 | grep -o '<title>[^<]*</title>' | sed 's/^/  the page: /' || echo "  the page: no title"
    askj "$R_HEALTH" "$1"; askj "$R_READY" "$1"; } > ".harness/extras-$3.txt"
  sed 's/^/  /' ".harness/extras-$3.txt"; grep -v '^\$ ' ".harness/extras-$3.txt" > ".harness/extras-$3.ans" || true
  echo "  the extras: $(grep -vc '^\$ ' ".harness/extras-$3.txt") answers · md5 $(grep -v '^\$ ' ".harness/extras-$3.txt" | md5 -q)"
  stop "$1" "$2"; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/jdbc:h2:mem:[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f-]+/, "jdbc:h2:mem:<uuid>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' "$TOKEN" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'url=jdbc:h2:mem:<uuid> user=SA' '[masked: the 31-character token]')" ] || die "mask: the planted JDK version, generated database name and token must be masked"
# view FILE 'LOGGER-REGEX': a run's log, in order: the harness's PROBE lines, the lines of the named loggers (level, logger:
# message; "Started TiffinBoxServer" without its seconds; a message over 200 characters cut there), and for an ERROR line of
# SpringApplication ("Application run failed") the exception's first line and each distinct "Caused by:" line (at most four,
# each cut at 200 characters); its frames and the rest counted, never shown
view() { awk -v pat="$2" '
  function cut(x) { gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); sub(/[ \t]+$/, "", x); return length(x) > 260 ? substr(x, 1, 260) " … (" length(x) - 260 " more characters)" : x }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ { ex = 0
    s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3)
    if (m ~ /^Starting /) next
    if (m ~ /^Started TiffinBoxServer in /) m = "Started TiffinBoxServer"
    if (lg ~ /SpringApplication$/ && $2 == "ERROR") { print "    " $2 " " lg ": " cut(m); ex = 1; nc = 0; delete seen; next }
    if (lg ~ pat) print "    " $2 " " lg ": " cut(m)
    next }
  /^PROBE / { ex = 0; print "  " cut($0); next }
  ex == 1 && NF > 0 && !/^\tat / && !/^\t\.\.\. / && !/^Caused by: / { print "      " cut($0); ex = 2; next }
  ex && /^Caused by: / { c = cut($0); if (!(c in seen) && nc < 4) { seen[c] = 1; nc++; print "      " c } }' "$1"; }
# hrun PORT [PREFIX]: the harness line (V, the options array, set by the caller), run from .harness/after; it starts, runs its
# steps and exits by itself (bounded: 120 s); its exit code in HE; nothing left listening on PORT
HE=""
hrun() { local c i=0 e=0
  c=$(hl "$1" "${2:-}"); sec .harness/after
  echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"
  echo "\$ $c"
  (eval "$(exe "$c")") > .harness/run.out 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run on $1 was still running after 120 s"; }
  wait "$pid" || e=$?; pid=""; HE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1 after the harness run"
  logtok > /dev/null; }
# hres: the run's end - its exit code, Boot's first line, which database its pool opened, the counts
hres() { echo "  exit $HE · Boot's first line: $(first .harness/run.out)"; jlog .harness/run.out; }
HV=(--spring.main.sources=probe.jpa.Probe --spring.jpa.properties.hibernate.generate_statistics=true)    # every harness run's two
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
summ() { grep -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
# reports DIR LOG: Surefire's reports (harness/surefire.py), then the console's summary beside their sum (R.144)
reports() { local s t
  python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  s=$(summ "$2"); t=$(python3 -I harness/surefire.py "$1/$SR" | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"; }

# ---- move: the previous tree, and the move alone ---------------------------------------------------------------------------------
libs() { unzip -Z1 "$1" | sed -n 's#^BOOT-INF/lib/##p' | grep . | sort; }
move() {
  echo "the previous tree - before/, which c7-tiffinbox's setup commit copied (5c718e8; read from git, README aside):"
  rm -rf .harness/at5c; mkdir -p .harness/at5c
  echo "\$ git -C .. archive 5c718e8 c7-tiffinbox | tar -x -C .harness/at5c"
  git -C .. archive 5c718e8 c7-tiffinbox | tar -x -C .harness/at5c || die "git archive 5c718e8 failed - this folder must sit in a clone of tiffinbox-java with its history"
  echo "  files that differ, before/ against the anchor at 5c718e8: $(diff -rq before .harness/at5c/c7-tiffinbox | sed 's#.*/c7-tiffinbox/##; s# differ$##' | paste -sd' ' -) · files only in one: $(diff -rq before .harness/at5c/c7-tiffinbox | grep -c '^Only in' || true)"
  echo "the move - the previous tree copied to .harness/move, one line changed (this unit's line):"
  echo "\$ cd .harness/move && $L_MOVE"
  cdiff before/pom.xml .harness/move/pom.xml
  echo "the tests each tree ran in its build (the README's package line, offline):"
  echo "  the previous tree:"; reports .harness/before .harness/build-before.log
  echo "  the move:"; reports .harness/move .harness/build-move.log
  echo "the jars' libraries (BOOT-INF/lib) - the previous tree's and the move's:"
  libs ".harness/before/$JARP" > .harness/libs-before.txt; libs ".harness/move/$JARP" > .harness/libs-move.txt
  python3 - .harness/libs-before.txt .harness/libs-move.txt <<'PY'
import re, sys
def rd(f):
    d = {}
    for l in open(f).read().split():
        m = re.match(r"^(.+?)-(\d.*)\.jar$", l)
        d[m.group(1)] = m.group(2)
    return d
a, b = rd(sys.argv[1]), rd(sys.argv[2])
moved = sorted(k for k in a if k in b and a[k] != b[k])
print("  the previous tree: %d jars · the move: %d · the same name and version: %d · a new version: %d · only in one: %d"
      % (len(a), len(b), sum(1 for k in a if b.get(k) == a[k]), len(moved), len(set(a) ^ set(b))))
for k in moved:
    print("    %s %s -> %s" % (k, a[k], b[k]))
PY
  echo "the seven - the previous tree's jar, then the move's, port 19820, a fresh JVM each:"
  start "$(at .harness/before 19820 "$R_RUN")"; up 19820; ready 19820; seven 19820 .harness/before; cp .harness/responses.m.txt .harness/seven-before.txt
  start "$(at .harness/move 19820 "$R_RUN")"; up 19820; ready 19820; seven 19820 .harness/move; cp .harness/responses.m.txt .harness/seven-move.txt
  echo "  lines that differ: $(diff .harness/seven-before.txt .harness/seven-move.txt | grep -c '^[<>]' || true) · the same, byte for byte: $(awk 'NR == FNR { a[FNR] = $0; next } a[FNR] == $0 { n++ } END { print n + 0 }' .harness/seven-before.txt .harness/seven-move.txt)"
  echo "the extras - the previous tree's jar, then the move's, port 19820, a fresh JVM each:"
  start "$(at .harness/before 19820 "$R_RUN")"; up 19820; ready 19820; extras 19820 .harness/before before
  start "$(at .harness/move 19820 "$R_RUN")"; up 19820; ready 19820; extras 19820 .harness/move move
  echo "  the extras, the move against the previous tree: the same: $(cmp -s .harness/extras-before.ans .harness/extras-move.ans && echo yes || echo no)"; }

# ---- seven: after/'s jar ----------------------------------------------------------------------------------------------------------
seven7() {
  echo "the seven - after/'s jar, port 19821, a fresh JVM:"
  start "$(at .harness/after 19821 "$R_RUN")"; up 19821; ready 19821; seven 19821 .harness/after; cp .harness/responses.m.txt .harness/seven-after.txt
  echo "  against the previous tree's (move): lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | grep -c '^[<>]' || true) · the same, byte for byte: $(awk 'NR == FNR { a[FNR] = $0; next } a[FNR] == $0 { n++ } END { print n + 0 }' .harness/seven-before.txt .harness/seven-after.txt)"
  echo "the extras - after/'s jar, port 19821, a fresh JVM:"
  start "$(at .harness/after 19821 "$R_RUN")"; up 19821; ready 19821; extras 19821 .harness/after after
  echo "  the extras, after/ against the previous tree: the same: $(cmp -s .harness/extras-before.ans .harness/extras-after.ans && echo yes || echo no)"; }

# ---- two: which database Hibernate talks to -------------------------------------------------------------------------------------
TWOL='HikariPool|org\.hibernate\.SQL'
dsline() { awk '/DataSourceAutoConfiguration\.PooledDataSourceConfiguration matched:/ { f = 1; next } f && /@ConditionalOnMissingBean \(types: javax\.sql\.DataSource/ { sub(/^ +- /, ""); print "  Boot'"'"'s condition report: PooledDataSourceConfiguration matched - " $0; exit } f && /^$/ { f = 0 }' .harness/run.out; }
CRL='--logging.level.org.springframework.boot.autoconfigure.logging.ConditionEvaluationReportLogger=debug'
two() {
  echo "A - after/ and the harness (steps ds, two, query), port 19822:"
  V=("${HV[@]}" --probe.steps=ds,two,query "$CRL"); hrun 19822; view .harness/run.out "$TWOL"; dsline; hres
  echo "B - A with one run option more, --spring.datasource.url= (an empty value), port 19822:"
  V=("${HV[@]}" --probe.steps=ds,two,query "$CRL" --spring.datasource.url=); hrun 19822; view .harness/run.out "$TWOL"; dsline; hres
  echo "C (labelled: two flips) - B with --spring.jpa.hibernate.ddl-auto=create-drop as well, port 19822:"
  V=("${HV[@]}" --probe.steps=ds,two,query "$CRL" --spring.datasource.url= --spring.jpa.hibernate.ddl-auto=create-drop); hrun 19822; view .harness/run.out "$TWOL"; dsline; hres
  echo "A' - A again (a fresh JVM), port 19822:"
  V=("${HV[@]}" --probe.steps=ds,two,query "$CRL"); hrun 19822; view .harness/run.out "$TWOL"; dsline; hres; }

# ---- entity: the class, @EntityScan, the EMF's properties, a query ---------------------------------------------------------------
entity() {
  echo "CustomerEntity, as after/'s tiffinbox-core declares it - its annotations and fields:"
  grep -nE '^@|^public class|^    @|^    private ' "after/$CJ/CustomerEntity.java" | sed 's/^/  /'
  echo "  tiffinbox-core's POM, the API it compiles against: $(grep -A1 '<groupId>jakarta.persistence</groupId>' after/tiffinbox-core/pom.xml | grep -o '<artifactId>[^<]*</artifactId>' | sed 's/<[^>]*>//g') (no version: Boot's parent manages it) · in after/'s jar: $(ls .harness/after/$XD/lib | grep -E '^jakarta\.persistence-api-')"
  echo "  TiffinBoxApp (tiffinbox-web): $(grep -E '^@EntityScan' "after/$MJ/TiffinBoxApp.java") · its import: $(grep -E '^import .*EntityScan;' "after/$MJ/TiffinBoxApp.java")"
  echo "  the class EntityScan, in after/'s jar: $(for j in .harness/after/$XD/lib/*.jar; do unzip -Z1 "$j" 2> /dev/null | grep -qx 'org/springframework/boot/persistence/autoconfigure/EntityScan.class' && basename "$j"; done | paste -sd' ' -)"
  echo "after/ and the harness (steps pkg, props, query), Hibernate's SQL logger at DEBUG, port 19823:"
  V=("${HV[@]}" --probe.steps=pkg,props,query --logging.level.org.hibernate.SQL=debug); hrun 19823; view .harness/run.out 'org\.hibernate\.SQL'; hres; }

# ---- scan: an entity Boot does not scan ------------------------------------------------------------------------------------------
scan() {
  echo "B (labelled: a class change, ahead of the jar) - TiffinBoxApp without @EntityScan (this unit's lines), port 19823:"
  rm -rf .harness/ov-noscan; mkdir -p .harness/ov-noscan
  echo "\$ $L_NOSCAN"; (eval "$L_NOSCAN") < /dev/null || die "the sed failed"
  cdiff "after/$MJ/TiffinBoxApp.java" .harness/ov-noscan/TiffinBoxApp.java
  echo "\$ $L_NOSCANC"; (eval "$L_NOSCANC") > .harness/javac-noscan.log 2>&1 < /dev/null || die "the copy did not compile: $(head -3 .harness/javac-noscan.log)"
  echo "  compiled: $(cd .harness/ov-noscan/classes && find . -name '*.class' | sed 's#^\./##' | paste -sd' ' -)"
  V=("${HV[@]}" --probe.steps=pkg,query); hrun 19823 ../ov-noscan/classes; view .harness/run.out 'TiffinBoxServer|org\.hibernate\.SQL'
  echo "  lines that say Started TiffinBoxServer: $(grep -c ' : Started TiffinBoxServer in ' .harness/run.out || true)"; hres
  echo "A' - after/ as shipped, the same steps, port 19823:"
  V=("${HV[@]}" --probe.steps=pkg,query); hrun 19823; view .harness/run.out 'TiffinBoxServer|org\.hibernate\.SQL'
  echo "  lines that say Started TiffinBoxServer: $(grep -c ' : Started TiffinBoxServer in ' .harness/run.out || true)"; hres; }

# ---- persist: the INSERT, before the commit ----------------------------------------------------------------------------------------
SQLV=(--logging.level.org.hibernate.SQL=debug --logging.level.org.hibernate.orm.jdbc.bind=trace)
persist() {
  echo "after/ and the harness (steps anchor, persist, valid), Hibernate's SQL logger at DEBUG and its bind logger at TRACE, port 19824 - in the order the log printed them:"
  V=("${HV[@]}" --probe.steps=anchor,persist,valid "${SQLV[@]}"); hrun 19824; view .harness/run.out 'HikariPool|org\.hibernate\.SQL|org\.hibernate\.orm\.jdbc\.bind'; hres
  echo "  the lines of org.hibernate.SQL: $(grep -c ' org\.hibernate\.SQL  *: ' .harness/run.out || true) · of org.hibernate.orm.jdbc.bind: $(grep -c ' org\.hibernate\.orm\.jdbc\.bind  *: ' .harness/run.out || true)"
  echo "  the INSERT's place: after the line 'before the transaction', before 'after persist(), before commit': $(awk '/^PROBE before the transaction/ { a = 1 } a && !b && / org\.hibernate\.SQL  *: insert into customer / { i = 1 } /^PROBE after persist\(\), before commit/ { b = 1 } END { print (a && i && b) ? "yes" : "no" }' .harness/run.out)"; }

# ---- ddl: Hibernate's DDL, the controls, and the C7-5 check ----------------------------------------------------------------------
# c75 CLASSPATH DDLFILE: C7-5 - @Size(max) and @Column(length) of CustomerEntity's field name, read off the class (javap), against
# Hibernate's DDL (name varchar(n)) and Database.java's (name VARCHAR(n)): all four equal, or FAIL naming each value
c75() { local jv size col ddl db
  echo "\$ javap -v -p -cp $1 com.tiffinbox.CustomerEntity    (the field name's annotations)"
  jv=$(javap -v -p -cp "$1" com.tiffinbox.CustomerEntity | awk '/private java.lang.String name;/ { f = 1; next } f && /^  [a-z].*;$/ { f = 0 } f')
  size=$(printf '%s\n' "$jv" | grep -A1 'constraints.Size(' | grep -oE 'max=[0-9]+' | head -1 | cut -d= -f2)
  col=$(printf '%s\n' "$jv" | grep -A1 'persistence.Column(' | grep -oE 'length=[0-9]+' | head -1 | cut -d= -f2)
  ddl=$(grep -oE 'name varchar\([0-9]+\)' "$2" | grep -oE '[0-9]+' | head -1)
  db=$(grep -oE 'name +VARCHAR\([0-9]+\)' "after/$CJ/Database.java" | grep -oE '[0-9]+' | head -1)
  echo "  C7-5: @Size(max=${size:-none}) @Column(length=${col:-none}) hibernate-ddl varchar(${ddl:-none}) Database.java VARCHAR(${db:-none})"
  if [ -n "$size" ] && [ "$size" = "$col" ] && [ "$col" = "$ddl" ] && [ "$ddl" = "$db" ]; then echo "  C7-5 PASS"; else echo "  C7-5 FAIL: the four values differ"; fi; }
ddlrun() { rm -f .harness/after/hibernate-ddl.sql
  V=("${HV[@]}" --probe.steps=props "$DDLO1" "$DDLO2"); hrun 19825 "${1:-}"
  echo "  exit $HE · Hibernate's DDL, the file it wrote (hibernate-ddl.sql, never run), every line:"; sed 's/^/    /' .harness/after/hibernate-ddl.sql
  echo "  the name column there: $(grep -oE 'name varchar\([0-9]+\)' .harness/after/hibernate-ddl.sql | head -1) · the open-in-view WARN: $(grep -cE "$OSIVW" .harness/run.out || true) · DDL lines in the log: $(grep -cE ' org\.hibernate\.SQL  *: (create|drop|alter) ' .harness/run.out || true)"
  cp .harness/after/hibernate-ddl.sql ".harness/ddl-$2.sql"; }
ddl() {
  echo "Database.java's DDL for the column (tiffinbox-core, the table TiffinBox creates): $(grep -nE 'name +VARCHAR\([0-9]+\)' "after/$CJ/Database.java" | sed 's/^\([0-9]*\): */line \1: /')"
  echo "shipped - after/ and the harness, the anchor's two schema-generation options (the README's DDL line), port 19825:"
  ddlrun "" shipped
  echo "control 1 (labelled) - no @Size, @Column(length = 61): a copy of the entity, ahead of the jar (this unit's lines), port 19825:"
  rm -rf .harness/ctl1; mkdir -p .harness/ctl1; echo "\$ $L_CTL1"; (eval "$L_CTL1") < /dev/null || die "the sed failed"
  cdiff "after/$CJ/CustomerEntity.java" .harness/ctl1/CustomerEntity.java
  echo "\$ $L_CTL1C"; (eval "$L_CTL1C") > .harness/javac-ctl1.log 2>&1 < /dev/null || die "control 1 did not compile"
  ddlrun ../ctl1/classes ctl1
  echo "control 2 (labelled) - @Size(max = 60) kept, @Column(length = 61): ahead of the jar, port 19825:"
  rm -rf .harness/ctl2; mkdir -p .harness/ctl2; echo "\$ $L_CTL2"; (eval "$L_CTL2") < /dev/null || die "the sed failed"
  cdiff "after/$CJ/CustomerEntity.java" .harness/ctl2/CustomerEntity.java
  echo "\$ $L_CTL2C"; (eval "$L_CTL2C") > .harness/javac-ctl2.log 2>&1 < /dev/null || die "control 2 did not compile"
  ddlrun ../ctl2/classes ctl2
  echo "  control 2's DDL against the shipped DDL: the same, byte for byte: $(cmp -s .harness/ddl-shipped.sql .harness/ddl-ctl2.sql && echo yes || echo no)"
  echo "the C7-5 check on the shipped class (after/'s jar, tiffinbox-core's jar in it) and the shipped DDL:"
  c75 ".harness/after/$XD/lib/tiffinbox-core-1.0.0.jar" .harness/ddl-shipped.sql
  echo "the same check with length = 61 planted (control 2's class, and the DDL it made):"
  c75 .harness/ctl2/classes .harness/ddl-ctl2.sql; }

# ---- ddlauto: what ddl-auto would have done ----------------------------------------------------------------------------------------
DAL='org\.hibernate\.SQL|TiffinBoxServer|LocalContainerEntityManagerFactoryBean'
ddlc() { echo "  DDL lines Hibernate logged: $(grep -cE ' org\.hibernate\.SQL  *: (create|drop|alter) ' .harness/run.out || true)"; }
ddlauto() {
  echo "A - after/ and the harness (steps ds, query), Hibernate's SQL logger at DEBUG, port 19826:"
  V=("${HV[@]}" --probe.steps=ds,query --logging.level.org.hibernate.SQL=debug); hrun 19826; view .harness/run.out "$DAL"; ddlc; hres
  echo "B - A with --spring.jpa.hibernate.ddl-auto=create-drop (the run's own in-memory database), port 19826:"
  V=("${HV[@]}" --probe.steps=ds,query --logging.level.org.hibernate.SQL=debug --spring.jpa.hibernate.ddl-auto=create-drop); hrun 19826; view .harness/run.out "$DAL"; ddlc; hres
  echo "B2 - A with --spring.jpa.hibernate.ddl-auto=validate, port 19826:"
  V=("${HV[@]}" --probe.steps=ds,query --logging.level.org.hibernate.SQL=debug --spring.jpa.hibernate.ddl-auto=validate); hrun 19826; view .harness/run.out "$DAL"; ddlc; hres
  echo "A' - A again (a fresh JVM), port 19826:"
  V=("${HV[@]}" --probe.steps=ds,query --logging.level.org.hibernate.SQL=debug); hrun 19826; view .harness/run.out "$DAL"; ddlc; hres; }

# ---- osiv: open-in-view, by the interceptor bean ------------------------------------------------------------------------------------
oscheck() { grep -q '^PROBE open-in-view: property .* | OpenEntityManagerInViewInterceptor beans 0$' .harness/run.out && echo "  the check (interceptor beans 0): PASS" || echo "  the check (interceptor beans 0): FAIL"
  echo "  the open-in-view WARN (${OSIVW# }): $(grep -cE "$OSIVW" .harness/run.out || true)"; }
osiv() {
  echo "A - after/ and the harness (step osiv), port 19827:"
  V=("${HV[@]}" --probe.steps=osiv); hrun 19827; view .harness/run.out 'JpaWebConfiguration'; oscheck; hres
  echo "B - A with --spring.jpa.open-in-view=true, port 19827:"
  V=("${HV[@]}" --probe.steps=osiv --spring.jpa.open-in-view=true); hrun 19827; view .harness/run.out 'JpaWebConfiguration'; oscheck; hres
  echo "B2 (labelled: a file, ahead of the jar) - a copy of application.yaml without the key (this unit's line), port 19827:"
  rm -rf .harness/ov-noosiv; mkdir -p .harness/ov-noosiv; echo "\$ $L_NOOSIV"; (eval "$L_NOOSIV") < /dev/null || die "the sed failed"
  cdiff "after/$YML" .harness/ov-noosiv/application.yaml
  V=("${HV[@]}" --probe.steps=osiv); hrun 19827 ../ov-noosiv; view .harness/run.out 'JpaWebConfiguration'; oscheck; hres
  echo "A' - A again (a fresh JVM), port 19827:"
  V=("${HV[@]}" --probe.steps=osiv); hrun 19827; view .harness/run.out 'JpaWebConfiguration'; oscheck; hres; }

# ---- tests: TiffinBox's tests, read from Surefire's reports -----------------------------------------------------------------------
tests() { local c e=0 n
  echo "TiffinBox's tests - after/ copied to .harness/tests, the README's line, offline:"
  copy after .harness/tests
  c=$(off .harness/tests "$R_TEST"); echo "\$ $c"
  (eval "$c") > .harness/tests.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  n=$(grep -cE '^\[INFO\] Download(ing|ed) from ' .harness/tests.log || true)
  echo "  exit $e · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/tests.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"; reports .harness/tests .harness/tests.log
  echo "  Hibernate in the tests' log - lines that say Initialized JPA EntityManagerFactory: $(grep -c 'Initialized JPA EntityManagerFactory' .harness/tests.log || true) · the open-in-view WARN: $(grep -cE "$OSIVW" .harness/tests.log || true) · Hibernate's SQL lines: $(grep -c ' org\.hibernate\.SQL  *: ' .harness/tests.log || true)"
  echo "  its log's WARN lines: $(lvl WARN .harness/tests.log) · ERROR lines: $(lvl ERROR .harness/tests.log) (the tests' own kitchen-on-fire cases) · the demo token in it and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }

# ---- exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 240 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1") · listening on 19828 now: $(listeners 19828)"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · listening on 19828 now: $(listeners 19828) · the demo token in the JVM's log: $(raw "$TOKEN" .harness/mine.log) times"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$setup" | grep -c .)" = "$(printf '%s\n' "$sol" | grep -c .)" ] || die "SOLUTION.md's block must have the README's lines, one changed"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | grep -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | grep -qF -- '"${V[@]}"' && printf '%s\n' "$setup" | grep -qE '^V=\(' || die "exercise/README.md must pass its options as an array, V (R.164, R.193)"
  printf '%s\n' "$setup" | grep -qF -- "--tiffinbox.port=19828" || die "exercise/README.md must run on port 19828"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  sec .harness/after
  echo "exercise/README.md's $(printf '%s\n' "$setup" | grep -c .) lines, then exercise/SOLUTION.md's, exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), started in this folder:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | grep '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }

# ---- the captures -------------------------------------------------------------------------------------------------------------
cap move move
cap seven seven7
cap two two
cap entity entity
cap scan scan
cap persist persist
cap ddl ddl
cap ddlauto ddlauto
cap osiv osiv
cap tests tests
cap exercise exercise

# ---- every number the video says, asserted. Each check reads a line a program computed - a Surefire report, the harness's own line,
# ---- a count - never a label this script prints unconditionally.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 harness/src/probe/jpa/*.java .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$LOGS" -gt 0 ] || die "a token count never ran"
# no capture prints a path, a version token of the OS or the JDK, a time, a pid, a random port, a unit number or a stack frame
for f in .r-*.out; do
  ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! grep -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a Surefire booter path, a time or Boot's seconds"
  ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! grep -qE 'using Java [0-9]|Darwin|arm64|aarch64' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! grep -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! grep -qE '(127\.0\.0\.1:|port )(49|5[0-9]|6[0-5])[0-9][0-9][0-9]([^0-9]|$)' "$f" || die "$f holds a random port (R.147)"
  ! grep -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
for f in .r-*.out; do ! grep -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
for f in .r-*.out; do a=$(grep -cE '^\$ cd \.harness/[a-z]+ && java ' "$f" || true); b=$(grep -cxF "  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else" "$f" || true)
  [ "$a" = "$b" ] || [ "$f" = .r-exercise.out ] || die "$f: $a starts, $b secrets/ listings (R.158)"; done
K1='pki''ll'; K2='kill''all'; for f in receipts.sh harness/shutdown.sh; do ! grep -v '^ *#' "$f" | grep -qwE "$K1|$K2" || die "$f names $K1 or $K2 - every process is stopped by its pid"; done
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
# R.193: run options travel as an array - no variable holds several options in one string
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! grep -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! grep -rq 'probe\.jpa' after/tiffinbox-web after/tiffinbox-core || die "after/'s code names the course's harness - it is never TiffinBox's"
! grep -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, every file this unit ships, every build log and the log of every JVM ($LOGS); no path, no unit number, no time, no generated database name, no stack frame in any capture; every JVM's locale pinned; every start's secrets/ listed; no kill by name; no bare wait; options as arrays"

S466='466c20ed7e0d5439cb052f32ce09de1b'
EIGHT='  in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0'
CONS="  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes"
# "the move first: eighteen tests, the same seven, byte for byte, seven ... the versions that moved"
MV=$(cat .r-move.out)
has "$MV" '  files that differ, before/ against the anchor at 5c718e8: README.md · files only in one: 0' "move: before/ is the anchor at 5c718e8, README aside"
has "$MV" '    -    <version>4.1.1</version>' "move: the one line out"; has "$MV" '    +    <version>4.1.2</version>' "move: the one line in"
has "$MV" '  its diff (diff -U0, its file names cut) - hunks: 1 · lines out: 1 · in: 1 - whole:' "move: one line changed"
[ "$(cnt "$MV" "  $EIGHT")" = 2 ] && [ "$(cnt "$MV" "$CONS")" = 2 ] || die "move: 18 tests on each tree, from the reports, the console the same"
for c in TiffinBoxWebTest:14 FullStackTest:3 FeedTest:1; do [ "$(cnt "$MV" "    TEST-com.tiffinbox.web.${c%%:*}.xml: tests ${c#*:} · failures 0 · errors 0 · skipped 0")" = 2 ] || die "move: ${c%%:*} ${c#*:} on each tree"; done
printf '%s\n' "$MV" | grep -qE '^  the previous tree: 61 jars · the move: 61 · the same name and version: [0-9]+ · a new version: [1-9][0-9]* · only in one: 0$' || die "move: BOOT-INF/lib 61 = 61, nothing in only one"
for l in '    hibernate-validator 9.1.3.Final -> 9.1.5.Final' '    tomcat-embed-core 11.0.24 -> 11.0.27' '    spring-core 7.0.9 -> 7.0.10' '    spring-boot 4.1.1 -> 4.1.2'; do has "$MV" "$l" "move: the versions that moved"; done
[ "$(cnt "$MV" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466")" = 2 ] || die "move: $S466 on both trees"
has "$MV" '  lines that differ: 0 · the same, byte for byte: 7' "move: the seven, the same 7"
has "$MV" '  the extras, the move against the previous tree: the same: yes' "move: the extras the same"
printf '%s\n' "$MV" | grep -qE '^  its pool: no Hikari line - no DataSource pool in this run · Hibernate: no Hibernate line · the open-in-view WARN: 0 · ' || die "move: no pool, no Hibernate before the starter"
echo "  move: before/ = the anchor at 5c718e8 (README aside); one line (4.1.1 -> 4.1.2); 18 tests on each (14/3/1); BOOT-INF/lib 61 = 61, versions moved (Hibernate Validator 9.1.5, Tomcat 11.0.27, Framework 7.0.10); the seven $S466 on both, 0 lines differ; the extras the same"

# "after the starter: the same seven, the same messages - and one pool, on TiffinBox's own database"
SV=$(cat .r-seven.out)
has "$SV" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "seven: $S466 on after/"
has "$SV" "  against the previous tree's (move): lines that differ: 0 · the same, byte for byte: 7" "seven: the same 7"
has "$SV" '  the extras, after/ against the previous tree: the same: yes' "seven: the extras the same"
# the seven's JVM logs one WARN on every tree (Spring MVC's PageNotFound: the seven's GET /shutdown); the extras' JVM none
[ "$(cnt "$SV" '  its pool: HikariPool-1 - Added connection conn0: url=jdbc:h2:mem:tiffinbox · Hibernate: HHH000001: Hibernate ORM core version 7.4.13.Final · the open-in-view WARN: 0 · WARN lines: 1 · ERROR lines: 0')" = 1 ] && [ "$(cnt "$SV" '  its pool: HikariPool-1 - Added connection conn0: url=jdbc:h2:mem:tiffinbox · Hibernate: HHH000001: Hibernate ORM core version 7.4.13.Final · the open-in-view WARN: 0 · WARN lines: 0 · ERROR lines: 0')" = 1 ] || die "seven: after/'s pool on jdbc:h2:mem:tiffinbox, Hibernate 7.4.13.Final, no open-in-view WARN, in both JVMs (the seven's one WARN, as on the previous tree)"
[ "$(cnt "$MV" '  its pool: no Hikari line - no DataSource pool in this run · Hibernate: no Hibernate line · the open-in-view WARN: 0 · WARN lines: 1 · ERROR lines: 0')" = 2 ] || die "move: the seven's one WARN on each tree"
echo "  seven: $S466 on after/, the same 7 as the previous tree; the extras the same; Hikari on jdbc:h2:mem:tiffinbox, Hibernate 7.4.13.Final, 0 open-in-view WARN"

# "A: Hikari on TiffinBox's URL, id 5, the anchor sees Kavya. B: Boot's own database - Table CUSTOMER not found, exit 1. C: id 1, the anchor does not"
TA=$(blk two "A - after/" "B - A with"); TB=$(blk two "B - A with" "C (labelled"); TC=$(blk two "C (labelled" "A' - A again"); TA2=$(blk two "A' - A again" "")
for b in "$TA" "$TA2"; do for l in '  PROBE   dataSource -> jdbc:h2:mem:tiffinbox (com.zaxxer.hikari.HikariDataSource)' '  PROBE DataSource beans: 1 [dataSource]' '  PROBE emf property hibernate.hbm2ddl.auto = null' \
    '  PROBE persist: id 5 | statements 1 | inserts 1 | updates 0 | deletes 0 | flushes 1' '  PROBE anchor repo sees Kavya: true' '  PROBE entity query names: [Kavya, Meera, Priya, Ravi, Sunil]' '    INFO com.zaxxer.hikari.pool.HikariPool: HikariPool-1 - Added connection conn0: url=jdbc:h2:mem:tiffinbox user=SA'; do has "$b" "$l" "two A: TiffinBox's own database"; done
  printf '%s\n' "$b" | grep -qE '^  exit 0 · ' || die "two A: exit 0"; done
[ "$(printf '%s\n' "$TA" | grep -v '^\$ ')" = "$(printf '%s\n' "$TA2" | grep -v '^\$ ')" ] || die "two: A' = A, line for line (their \$ lines aside)"
[ "$(printf '%s\n' "$TA" | grep '^\$ ')" = "$(printf '%s\n' "$TA2" | grep '^\$ ')" ] || die "two: A' has A's \$ lines"
for l in '  PROBE   dataSource -> jdbc:h2:mem:<uuid> (com.zaxxer.hikari.HikariDataSource)' '  PROBE emf property hibernate.hbm2ddl.auto = null' '    ERROR o.s.boot.SpringApplication: Application run failed' \
    '      org.hibernate.exception.SQLGrammarException: Could not prepare statement [Table "CUSTOMER" not found (this database is empty); SQL statement:' \
    '      Caused by: org.h2.jdbc.JdbcSQLSyntaxErrorException: Table "CUSTOMER" not found (this database is empty); SQL statement:' \
    '  Boot'"'"'s condition report: PooledDataSourceConfiguration matched - @ConditionalOnMissingBean (types: javax.sql.DataSource,javax.sql.XADataSource; SearchStrategy: all) did not find any beans (OnBeanCondition)'; do has "$TB" "$l" "two B: Boot's generated database, the failure receipt"; done
printf '%s\n' "$TB" | grep -qE '^  exit 1 · ' || die "two B: exit 1"; nhas "$TB" 'PROBE persist: id' "two B: no id"
for l in '  PROBE emf property hibernate.hbm2ddl.auto = create-drop' '  PROBE persist: id 1 | statements 1 | inserts 1 | updates 0 | deletes 0 | flushes 1' '  PROBE anchor repo sees Kavya: false' '  PROBE entity query names: [Kavya]' '  PROBE   dataSource -> jdbc:h2:mem:<uuid> (com.zaxxer.hikari.HikariDataSource)'; do has "$TC" "$l" "two C: the INSERT where TiffinBox never looks"; done
printf '%s\n' "$TC" | grep -qE '^  exit 0 · ' || die "two C: exit 0"
echo "  two: A Hikari on jdbc:h2:mem:tiffinbox, hbm2ddl null, id 5, the anchor sees Kavya, query 5 names; B (--spring.datasource.url=) jdbc:h2:mem:<uuid>, Table \"CUSTOMER\" not found, exit 1, Boot's condition: did not find any beans; C (+create-drop) id 1, the anchor does not see her, query [Kavya]; A' = A"

# "the entity: one class, its annotations; @EntityScan, from spring-boot-persistence; the naming strategies; the query"
EN=$(cat .r-entity.out)
for l in '  PROBE auto-configuration packages: [com.tiffinbox.web]' '  PROBE emf property hibernate.hbm2ddl.auto = null' \
    '  PROBE emf property hibernate.physical_naming_strategy = org.hibernate.boot.model.naming.PhysicalNamingStrategySnakeCaseImpl (in hibernate-core-7.4.13.Final.jar)' \
    '  PROBE emf property hibernate.implicit_naming_strategy = org.springframework.boot.hibernate.SpringImplicitNamingStrategy (in spring-boot-hibernate-4.1.2.jar)' \
    '  PROBE transaction manager: org.springframework.orm.jpa.JpaTransactionManager (in spring-orm-7.0.10.jar)' '  PROBE entity query names: [Meera, Priya, Ravi, Sunil]' \
    '  the class EntityScan, in after/'"'"'s jar: spring-boot-persistence-4.1.2.jar' '  TiffinBoxApp (tiffinbox-web): @EntityScan("com.tiffinbox") · its import: import org.springframework.boot.persistence.autoconfigure.EntityScan;' \
    '  tiffinbox-core'"'"'s POM, the API it compiles against: jakarta.persistence-api (no version: Boot'"'"'s parent manages it) · in after/'"'"'s jar: jakarta.persistence-api-3.2.0.jar' \
    '    DEBUG org.hibernate.SQL: select ce1_0.name from customer ce1_0 order by ce1_0.name'; do has "$EN" "$l" "entity"; done
for l in '  26:@Entity' '  27:@Table(name = "customer")' '  31:    @GeneratedValue(strategy = GenerationType.IDENTITY)' '  35:    @Size(max = 60)' '  36:    @Column(length = 60, nullable = false, unique = true)'; do has "$EN" "$l" "entity: the mapping's lines"; done
echo "  entity: @Entity @Table(name = \"customer\"), IDENTITY, @Size(max = 60) + @Column(length = 60); @EntityScan from spring-boot-persistence-4.1.2; auto-configuration package [com.tiffinbox.web]; hbm2ddl null; snake case (hibernate-core) + SpringImplicitNamingStrategy (spring-boot-hibernate); JpaTransactionManager (spring-orm); the query 4 names"

# "without @EntityScan the context starts - and the first query fails"
SB=$(blk scan "B (labelled" "A' - after/"); SA=$(blk scan "A' - after/" "")
for l in '    INFO com.tiffinbox.web.TiffinBoxServer: Started TiffinBoxServer' '  lines that say Started TiffinBoxServer: 1' '    ERROR o.s.boot.SpringApplication: Application run failed' \
    "      java.lang.IllegalArgumentException: org.hibernate.query.sqm.UnknownEntityException: Could not resolve root entity 'CustomerEntity'" '    -@EntityScan("com.tiffinbox")' \
    '  its diff (diff -U0, its file names cut) - hunks: 1 · lines out: 1 · in: 0 - whole:' '  PROBE auto-configuration packages: [com.tiffinbox.web]'; do has "$SB" "$l" "scan B: the context starts, the query fails"; done
printf '%s\n' "$SB" | grep -qE '^  exit 1 · ' || die "scan B: exit 1"; nhas "$SB" 'PROBE entity query names' "scan B: no names"
for l in '  lines that say Started TiffinBoxServer: 1' '  PROBE entity query names: [Meera, Priya, Ravi, Sunil]'; do has "$SA" "$l" "scan A': the query answers"; done
printf '%s\n' "$SA" | grep -qE '^  exit 0 · ' || die "scan A': exit 0"
echo "  scan: B (no @EntityScan, ahead of the jar) Started TiffinBoxServer 1, then UnknownEntityException: Could not resolve root entity 'CustomerEntity', exit 1; A' exit 0, 4 names"

# "persist: one INSERT, its four binds, before the commit; id 5; the anchor reads her; sixty-one letters: refused, nothing sent"
PE=$(cat .r-persist.out)
for l in '    DEBUG org.hibernate.SQL: insert into customer (meal_type,meals_per_day,name,price_per_meal,id) values (?,?,?,?,default)' '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (1:VARCHAR) <- [VEG]' \
    '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (2:INTEGER) <- [2]' '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (3:VARCHAR) <- [Kavya]' '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (4:INTEGER) <- [110]' \
    '  PROBE before the transaction: id null' '  PROBE after persist(), before commit: id 5 | contains true' '  PROBE after commit: id 5 | statements 1 | inserts 1 | updates 0 | deletes 0 | flushes 1' '  PROBE anchor repo sees Kavya: true' \
    '  PROBE anchor CustomerRepository.findAll() names: [Meera, Priya, Ravi, Sunil]' \
    '  PROBE a 61-letter name: jakarta.validation.ConstraintViolationException: Validation failed for classes [com.tiffinbox.CustomerEntity] during persist time for groups [jakarta.validation.groups.Default, ]' \
    '  PROBE   violation: name - size must be between 0 and 60' '  PROBE a 61-letter name: statements 0 | inserts 0 | updates 0 | deletes 0 | flushes 0' '  PROBE anchor CustomerRepository.findAll() names after it: [Kavya, Meera, Priya, Ravi, Sunil]' \
    "  the INSERT's place: after the line 'before the transaction', before 'after persist(), before commit': yes" '  the lines of org.hibernate.SQL: 1 · of org.hibernate.orm.jdbc.bind: 4'; do has "$PE" "$l" "persist"; done
printf '%s\n' "$PE" | grep -qE '^  exit 0 · ' || die "persist: exit 0"
echo "  persist: insert into customer (meal_type,meals_per_day,name,price_per_meal,id) values (?,?,?,?,default), 4 binds, before 'before commit'; id 5; statements 1, inserts 1; the anchor sees Kavya; 61 letters: ConstraintViolationException, statements 0"

# "Database says VARCHAR(60); Hibernate's DDL says varchar(60) - and with @Size, even when @Column says 61. So the check reads the class"
DL=$(cat .r-ddl.out); DS=$(blk ddl "shipped - after/" "control 1"); D1=$(blk ddl "control 1" "control 2"); D2=$(blk ddl "control 2" "the C7-5 check on the shipped")
has "$DL" 'Database.java'"'"'s DDL for the column (tiffinbox-core, the table TiffinBox creates): line 32: name          VARCHAR(60) NOT NULL UNIQUE,' "ddl: Database.java's line"
has "$DS" '    create table customer (meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, meal_type varchar(10) not null, name varchar(60) not null unique, primary key (id));' "ddl: the shipped DDL"
for b in "$DS" "$D1" "$D2"; do printf '%s\n' "$b" | grep -qE '^  exit 0 · ' && printf '%s\n' "$b" | grep -qE ' · DDL lines in the log: 0$' || die "ddl: each run exit 0, no DDL run"; done
printf '%s\n' "$DS" | grep -qxF '  the name column there: name varchar(60) · the open-in-view WARN: 0 · DDL lines in the log: 0' || die "ddl: shipped varchar(60)"
printf '%s\n' "$D1" | grep -qxF '  the name column there: name varchar(61) · the open-in-view WARN: 0 · DDL lines in the log: 0' || die "ddl: control 1 varchar(61)"
printf '%s\n' "$D2" | grep -qxF '  the name column there: name varchar(60) · the open-in-view WARN: 0 · DDL lines in the log: 0' || die "ddl: control 2 varchar(60) - @Size wins"
has "$DL" '  control 2'"'"'s DDL against the shipped DDL: the same, byte for byte: yes' "ddl: control 2's DDL = the shipped DDL"
has "$DL" '  C7-5: @Size(max=60) @Column(length=60) hibernate-ddl varchar(60) Database.java VARCHAR(60)' "ddl: C7-5 on the shipped class"
has "$DL" '  C7-5: @Size(max=60) @Column(length=61) hibernate-ddl varchar(60) Database.java VARCHAR(60)' "ddl: C7-5 on the plant"
[ "$(blk ddl "the C7-5 check on the shipped" "the same check with" | grep -cxF '  C7-5 PASS')" = 1 ] && [ "$(blk ddl "the same check with" "" | grep -cxF '  C7-5 FAIL: the four values differ')" = 1 ] || die "ddl: C7-5 PASS on the shipped class, FAIL on the planted length = 61"
echo "  ddl: Database.java VARCHAR(60); Hibernate's DDL (a file, never run) name varchar(60); control 1 (no @Size, 61) varchar(61); control 2 (@Size, 61) varchar(60), byte-identical to the shipped DDL; C7-5 60 60 60 60 PASS, planted 61: FAIL"

# "ddl-auto: none - 0 DDL lines. create-drop: built its own table at start, dropped TiffinBox's at shutdown. validate: the start fails"
AA=$(blk ddlauto "A - after/" "B - A with"); AB=$(blk ddlauto "B - A with" "B2 - A with"); AB2=$(blk ddlauto "B2 - A with" "A' - A again"); AA2=$(blk ddlauto "A' - A again" "")
for b in "$AA" "$AA2"; do for l in '  PROBE emf property hibernate.hbm2ddl.auto = null' '  DDL lines Hibernate logged: 0' '  PROBE entity query names: [Meera, Priya, Ravi, Sunil]'; do has "$b" "$l" "ddlauto A"; done; done
[ "$(printf '%s\n' "$AA" | grep -v '^\$ ')" = "$(printf '%s\n' "$AA2" | grep -v '^\$ ')" ] || die "ddlauto: A' = A"
has "$AB" '  PROBE emf property hibernate.hbm2ddl.auto = create-drop' "ddlauto B"; has "$AB" '  DDL lines Hibernate logged: 3' "ddlauto B: three DDL lines"
printf '%s\n' "$AB" | grep -E '^    (DEBUG org\.hibernate\.SQL: (drop|create) table|INFO com\.tiffinbox\.web\.TiffinBoxServer: Started|INFO j\.LocalContainerEntityManagerFactoryBean: Closing)|^  PROBE entity query' | sed -E 's/^ +//; s/ \(meals_per_day.*$/ (…)/' > .harness/order.txt
[ "$(paste -sd'|' .harness/order.txt)" = "DEBUG org.hibernate.SQL: drop table if exists customer cascade|DEBUG org.hibernate.SQL: create table customer (…)|INFO com.tiffinbox.web.TiffinBoxServer: Started TiffinBoxServer|PROBE entity query names: [Meera, Priya, Ravi, Sunil]|INFO j.LocalContainerEntityManagerFactoryBean: Closing JPA EntityManagerFactory for persistence unit 'default'|DEBUG org.hibernate.SQL: drop table if exists customer cascade" ] || die "ddlauto B: the order - drop, create, Started, the query (the seed's 4), Closing JPA EntityManagerFactory, drop (R.197): $(paste -sd'|' .harness/order.txt)"
has "$AB2" '      Caused by: org.hibernate.tool.schema.spi.SchemaManagementException: Schema validation: missing table [customer]' "ddlauto B2: validate"
printf '%s\n' "$AB2" | grep -qE '^  exit 1 · ' || die "ddlauto B2: exit 1"
echo "  ddlauto: A hbm2ddl null, 0 DDL lines; B create-drop: drop + create before Started, the seed's 4 names, then after Closing JPA EntityManagerFactory a drop of TiffinBox's table (3 DDL lines); B2 validate: missing table [customer], exit 1; A' = A"

# "open-in-view false: no interceptor. true: the interceptor, and no WARN. No key: the interceptor and the WARN"
OA=$(blk osiv "A - after/" "B - A with"); OB=$(blk osiv "B - A with" "B2 (labelled"); OB2=$(blk osiv "B2 (labelled" "A' - A again"); OA2=$(blk osiv "A' - A again" "")
for b in "$OA" "$OA2"; do has "$b" '  PROBE open-in-view: property false | OpenEntityManagerInViewInterceptor beans 0' "osiv A"; has "$b" '  the check (interceptor beans 0): PASS' "osiv A"; has "$b" "  the open-in-view WARN (${OSIVW# }): 0" "osiv A"; done
has "$OB" '  PROBE open-in-view: property true | OpenEntityManagerInViewInterceptor beans 1' "osiv B"; has "$OB" '  the check (interceptor beans 0): FAIL' "osiv B: the check fails on true"; has "$OB" "  the open-in-view WARN (${OSIVW# }): 0" "osiv B: no WARN"
has "$OB2" '  PROBE open-in-view: property null | OpenEntityManagerInViewInterceptor beans 1' "osiv B2"; has "$OB2" '  the check (interceptor beans 0): FAIL' "osiv B2"; has "$OB2" "  the open-in-view WARN (${OSIVW# }): 1" "osiv B2: the WARN"
has "$OB2" '    -    open-in-view: false' "osiv B2: the key out"
printf '%s\n' "$OB2" | grep -qE '^    WARN JpaBaseConfiguration\$JpaWebConfiguration: spring\.jpa\.open-in-view is enabled by default' || die "osiv B2: the WARN's logger"
[ "$(printf '%s\n' "$OA" | grep -v '^\$ ')" = "$(printf '%s\n' "$OA2" | grep -v '^\$ ')" ] || die "osiv: A' = A"
echo "  osiv: A false, beans 0, WARN 0 (PASS); B true, beans 1, WARN 0 (FAIL - the WARN could not see it); B2 no key, beans 1, WARN 1 (FAIL); A' = A"

# "the eighteen tests still pass - a guard: two of them start Hibernate, none asks it anything"
TS=$(cat .r-tests.out)
for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
    "  $EIGHT" "$CONS" '  exit 0 · BUILD SUCCESS · offline: yes' '  Hibernate in the tests'"'"' log - lines that say Initialized JPA EntityManagerFactory: 2 · the open-in-view WARN: 0 · Hibernate'"'"'s SQL lines: 0'; do has "$TS" "$l" "tests"; done
echo "  tests: TiffinBoxWebTest 14, FullStackTest 3, FeedTest 1 - 18 from the reports, the console the same; 2 EntityManagerFactories started, 0 SQL lines"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - bash, then zsh
EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
for b in "$EXB" "$EXZ"; do
  for l in '    exit 1' '    PROBE   dataSource -> jdbc:h2:mem:<uuid> (com.zaxxer.hikari.HikariDataSource)' '    org.hibernate.exception.SQLGrammarException: Could not prepare statement [Table "CUSTOMER" not found (this database is empty); SQL statement:' \
      '    exit 0' '    PROBE   dataSource -> jdbc:h2:mem:tiffinbox (com.zaxxer.hikari.HikariDataSource)' '    PROBE persist: id 5 | statements 1 | inserts 1 | updates 0 | deletes 0 | flushes 1' '    PROBE anchor repo sees Kavya: true'; do has "$b" "$l" "exercise: README's failure, then the solution's id 5"; done
  [ "$(printf '%s\n' "$b" | grep -cE "^  the shell is now in: this unit's folder · listening on 19828 now: 0")" = 2 ] || die "exercise: the shell back in this folder, nothing listening"; done
[ "$(printf '%s\n' "$EXB" | grep -v '^in ')" = "$(printf '%s\n' "$EXZ" | grep -v '^in ')" ] || die "exercise: bash and zsh print the same"
EXQ="Your turn: the README starts TiffinBox with one option too many, and Hibernate cannot find the customer table. Take it out."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
block exercise/README.md | grep -qF -- '--spring.datasource.url=)' && ! block exercise/SOLUTION.md | grep -qF -- '--spring.datasource.url=' || die "exercise: the README's array holds --spring.datasource.url=, the solution's does not"
echo "  exercise: bash and zsh alike - the README as written: jdbc:h2:mem:<uuid>, Table \"CUSTOMER\" not found, exit 1; the solution: jdbc:h2:mem:tiffinbox, id 5, the anchor sees Kavya, exit 0; the shell back in this folder, nothing listening"

for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19820-19829 at the end; 19829 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit03: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens; after/ = ../c7-tiffinbox"
