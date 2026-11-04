#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · @OneToMany/@ManyToOne and the Owning Side - this unit's receipts. The course's fourth change to the anchor and
# Section 2's third and last: a pause becomes an entity, PauseEntity, on the pause table Database already creates, and
# CustomerEntity gains its pauses - the inverse side, mapped by PauseEntity's customer, the side that owns the foreign key.
# Eight captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number and string the
# video says is asserted right after its capture by a check that can fail; the demo token is masked, and the checks count 0 raw
# copies of it in every capture and every log. One database: H2 (brief ⚑2: 09 is an H2 unit), in each JVM's memory, gone with it.
#   shapes    one customer, two pauses, mapped three ways: a unidirectional list with @JoinColumn; a bare unidirectional list (a
#             join table); bidirectional, mappedBy, both sides set - the SQL between markers, Statistics and the driver's counts
#   inverse   the bidirectional shape, a pause added to the customer's list only (its customer never set): what is written
#   ownpause  on the shipped Database's own tables (pause.customer_id NOT NULL), Kavya with one pause - A bidirectional; B
#             unidirectional, the default @JoinColumn (the failure receipt); B2 nullable = false; C nullable = false,
#             updatable = false; A' = A
#   anchor    the anchor's own change: after/ against before/; the shipped Database seeds its tables, then the anchor's
#             CustomerEntity and PauseEntity read every customer's pauses and add one from the owning side; Hibernate's DDL for
#             the two (a file, never run); then TiffinBox itself (after/'s jar, port 19880) starts with them mapped
#   seven     before/'s jar and after/'s, the seven each (a fresh JVM each, port 19881): a guard (R.190)
#   tests     TiffinBox's tests on after/ (the README's line, offline): Surefire's reports, the console's summary beside their sum
#   xcheck    the harness's DDL for the anchor's CustomerEntity and PauseEntity against Boot's own (after/'s jar, port 19882), cmp -
#             the script units 10-14 compare with, by its md5 (R.212)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f
# "The previous tree" is before/, the link to ../c7-unit07/after: the anchor before this change. after/ is this unit's frozen copy
# of ../c7-tiffinbox after the change - Section 2's last: units 10-14 build on it. Its equality with ../c7-tiffinbox is printed at
# the start and the end, and a later anchor change makes it a note, never a stop (R.211). Both trees are COPIED under .harness/
# and built there, never in place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with a fake
# token (secrets/), listed before every start.
# The harness (harness/src, package probe.map, outside com.tiffinbox) is compiled with javac -parameters against after/'s
# extracted jar into .harness/hc. probe.map.H builds one EntityManagerFactory per run (Jakarta Persistence 3.2's
# PersistenceConfiguration, Boot's two naming strategies, statistics on, schema generation on that run's in-memory database only,
# or none where the shipped Database makes the tables) over a DataSource wrapped in a proxy that counts the driver calls. It runs
# from .harness/run and binds no port. Its JVM flags travel as an array, V, its arguments as an array, A (R.193).
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is ../c5-unit11/curlset.sh (the seven, POST
# /shutdown with the token read from its file); harness/shutdown.sh (the CORS lesson's, byte for byte) stops a JVM;
# harness/surefire.py (the testing lesson's, byte for byte) reads Surefire's reports; harness/dur7.py (Course 7's builders'
# duration pattern, byte for byte) gates this unit's prose: it speaks no time (R.172). "$M2" is this unit's own repository, .m2-demo.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it; the test JVM's comes from the POM's argLine.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline build missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. At run time nothing leaves 127.0.0.1: every database is H2 in a JVM's memory. This unit reads no version file: unit
# 06 made the section's dated sweep (R.223).
# Masks (README.md declares each; awk gsub only): the demo token "[masked: the N-character token]"; this folder "…", the folder
# above it "…/..", home "~", your user name "<user>"; " using Java <version>"; an identity hash "@…"; Hibernate's generated
# constraint names "FK<hash>" (a hash of the table and column names, not anyone's code). A harness JVM's log is printed whole
# (every line it prints, trailing spaces dropped); a TiffinBox log: the named loggers' lines only.
# Ports (§P, 19880-19889): anchor's TiffinBox run 19880 · seven 19881 · xcheck's Boot run 19882 · 19889 never bound.
# 19883-19888 are unused and checked free, and so are 18425 (TiffinBox's default), 8080 and 35729. The harness's JVMs, tests
# and the exercise bind none.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven, with every process under it - Surefire's test JVM), $xpid (an exercise shell, with every process under it);
# then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a harness JVM, a Maven, Surefire's fork -
# is stopped. After an interrupt a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up
# ignores a second Ctrl-C, and the script still exits 130 after an interrupt (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "probe.map.Main") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 curl rsync lsof unzip mvn md5 cmp /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L before ] && [ "$(readlink before)" = ../c7-unit07/after ] || die "before must be the link to ../c7-unit07/after - the anchor before this change"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
# after/ is this unit's frozen tree - Section 2's last anchor; the anchor, ../c7-tiffinbox, equals it until a later unit changes
# the anchor - a note then, never a stop (R.211, the Course 6 form)
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets after ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets after ../c7-tiffinbox: empty - after/ = ../c7-tiffinbox"
  else echo "  (after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3; fi; }
anchornote start
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
SR=tiffinbox-web/target/surefire-reports
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
TOKEN=demo-token-for-owning-side-pause
[ ${#TOKEN} = 32 ] || die "the demo token must be 32 characters: the captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HS=harness/src/probe/map
HFILES='dur7.py logback.xml shutdown.sh src surefire.py'
SFILES='probe/map/H.java probe/map/Main.java probe/map/ex/ExCustomer.java probe/map/ex/ExPause.java probe/map/own/BiOwnCustomer.java probe/map/own/BiOwnPause.java probe/map/own/NnOwnCustomer.java probe/map/own/NuOwnCustomer.java probe/map/own/OwnBase.java probe/map/own/OwnPause.java probe/map/own/UniOwnCustomer.java probe/map/shapes/BiCustomer.java probe/map/shapes/BiPause.java probe/map/shapes/JtCustomer.java probe/map/shapes/JtPause.java probe/map/shapes/UniCustomer.java probe/map/shapes/UniPause.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
cmp -s harness/shutdown.sh ../c6-unit19/harness/shutdown.sh || die "harness/shutdown.sh is not the CORS lesson's (../c6-unit19/harness/shutdown.sh), byte for byte"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19880 19881 19882 19883 19884 19885 19886 19887 19888 19889"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc


# ---- duration words: none - this unit speaks no time (R.172); English names only (R.215); and the claim RED #307 struck ------
cat > .harness/dur.py <<'PY'
import importlib.util, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
n = 0
for f in sys.argv[2:]:
    for i, l in enumerate(open(f, encoding="utf-8"), 1):
        for w in m.DUR.finditer(l):
            n += 1
            print("  %s line %d: %s  <- not allowed: this unit speaks no time" % (f, i, w.group(0)))
print("duration words: %d" % n)
PY
DW=$(python3 -I -B .harness/dur.py harness/dur7.py README.md exercise/README.md exercise/SOLUTION.md) || die "dur7's gate did not run"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'duration words: 0' || die "dur7.DUR found a duration word - this unit speaks no time (R.172): $(printf '%s\n' "$DW" | $G 'not allowed' | paste -sd';' -)"
echo "  duration words: 0 (dur7.DUR over README.md, exercise/README.md, exercise/SOLUTION.md) - this unit speaks no time"
# R.215: meals and dishes have English names here - the AI voice mispronounces Indian dish names (the course's memory rule); the
# list is refused, whole words, any case, in this unit's prose, its harness and (at the end) every capture
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness/src)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, over README.md, exercise/, harness/src)"
# RED #307: the claim that the bidirectional mapping is the one way to write one statement per row is false - ownpause C writes
# two statements for a customer and a pause with a unidirectional list (nullable = false, updatable = false). A line saying
# "only" and "mappedBy" together, in that order, within one sentence, is refused in this unit's prose
OM=$($G -niE '\bonly\b[^.]{0,40}mappedBy' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$OM" ] || die "a line says only mappedBy writes one statement per row - ownpause C shows two statements without it (RED #307): $OM"
echo "  the claim RED #307 struck: 0 lines (\"only\" ... \"mappedBy\" in one sentence, over README.md and exercise/)"

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_GET=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
DDLO1='--spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create'
DDLO2='--spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql'
R_DDL=$(readme "$R_RUN $DDLO1 $DDLO2")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*\" $HS/H.java $HS/Main.java $HS/shapes/*.java $HS/own/*.java")
L_H=$(mine "java $JL -Dlogback.configurationFile=../../harness/logback.xml \"\${V[@]}\" -cp \"../hc:../after/$XD/lib/*\" probe.map.Main \"\${A[@]}\"")
[ "${R_DDL#"$R_RUN "}" = "$DDLO1 $DDLO2" ] || die "the DDL line must be the anchor's run line with the two schema-generation options, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
# at DIR PORT 'LINE': the line run from DIR, its port 18431 made PORT - a java line with the JVM's locale pinned
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in "java $JL "*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(exe "$(at .harness/x 19881 "$R_RUN")")" = "cd .harness/x && exec java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19881" ] && [ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "at()/off(): the run lines are not the anchor README's"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures - before/ and after/, each copied and built with the README's package line offline (each runs
# ---- its tree's tests); each jar extracted (the anchor's line); the harness compiled ---------------------------------------
# mbuild COMMAND LOG WHAT: offline first. If the offline build fails for want of an artifact, its log is kept beside (LOG with
# -offline), the first artifact it names is read from it, and the build runs once more without -o; the label then names that
# artifact and every repository the retry's log says it downloaded from - id, URL scheme, count - and counts the downloads whose
# URL is http(s). It never says "Maven Central" unless the log does.
mbuild() { local how=yes ec=0 c=$1 miss got web
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && $G -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    cp "$2" "${2%.log}-offline.log"
    miss=$($G -oE 'the artifact [^ ]+ has not been downloaded' "$2" | head -1 | sed -E 's/^the artifact ([^ ]+) has not been downloaded$/\1/')
    [ -n "$miss" ] || miss=$($G -oE 'Could not find artifact [^ ]+|No plugin found for prefix [^ ]+|Non-resolvable parent POM for [^ ]+' "$2" | head -1)
    ec=0; (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
    got=$(sed -n -E 's/^\[INFO\] Downloaded from ([^ :]+): ([a-z]+):.*/\1 (\2)/p' "$2" | sort | uniq -c | awk '{ printf "%s%s %s %d", (NR > 1 ? ", " : ""), $2, $3, $1 }')
    web=$($G -cE '^\[INFO\] Downloaded from [^ ]+: https?://' "$2" || true)
    how="no - the offline build could not resolve ${miss:-an artifact (none named in its log)} from .m2-demo, so it ran once more without -o; that run downloaded from: ${got:-nothing}; of them over http(s): $web"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! $G -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from a repository it could reach: a fresh clone's first run needs .m2-demo seeded (README.md, The repository)"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2"; rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; tree "$2"; }
copy before .harness/before; copy after .harness/after
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (before/, the README's package line; its tests ran)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
for t in before after; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the builds - README.md, The repository"; done
(eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/map/ex ] || die "the exercise's classes were compiled into the harness - they are the exercise's own"
echo "  extracted both jars ($(ls .harness/before/$XD/lib | wc -l | tr -d ' ') and $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') libraries) and compiled the harness into .harness/hc"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing}) - every file there is a key (R.158)"
  echo "  secrets/ before the start: $s - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
pv() { echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; }
start() { sec "$(dir "$1")"; echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
listening() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$1"); case " $a " in *":$2 "*) break ;; esac; kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened on $1"; }
  case " $l " in *':8080 '*|*':35729 '*|*':19889 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19889 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"; }
LASTE=""
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
lvl() { $G -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | sed 's/^/  /'; }
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; }
logtok() { local t; t=$(raw "$TOKEN" .harness/run.out); LOGS=$((LOGS + 1)); genw .harness/run.out; [ "$t" = 0 ] || die "a log held the demo token ($t)"; echo "  its log: the demo token 0 times"; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/jdbc:h2:mem:[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f-]+/, "jdbc:h2:mem:<uuid>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/FK[0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z]*/, "FK<hash>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' "$TOKEN" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'alter table if exists bi_pause add constraint FKm2mc7dy22sku3hjrgease2abs foreign key (customer_id) references bi_customer;' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'url=jdbc:h2:mem:<uuid> user=SA' '[masked: the 32-character token]' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'alter table if exists bi_pause add constraint FK<hash> foreign key (customer_id) references bi_customer;')" ] || die "mask: the planted JDK version, generated database name, token, folders, home, identity hash and constraint name must be masked"
rm -f .harness/p1
# tview FILE: a TiffinBox log, in order - the named loggers' lines (level, logger: message); then the counts
TPAT='org\.hibernate\.orm\.core|com\.zaxxer\.hikari\.pool\.HikariPool|org\.hibernate\.SQL|TiffinBoxServer|LocalContainerEntityManagerFactoryBean'
tview() { awk -v pat="$TPAT" '
  function cut(x) { gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); sub(/[ \t]+$/, "", x); return length(x) > 260 ? substr(x, 1, 260) " … (" length(x) - 260 " more characters)" : x }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ {
    s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3)
    if (m ~ /^Starting /) next
    if (m ~ /^Started TiffinBoxServer in /) m = "Started TiffinBoxServer"
    if (lg ~ pat) print "    " $2 " " lg ": " cut(m) }' "$1"
  echo "  its log's lines - org.hibernate.SQL: $($G -cE ' org\.hibernate\.SQL +: ' "$1" || true) · WARN: $(lvl WARN "$1") · ERROR: $(lvl ERROR "$1") · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' "$1" || true)"; }
# hrun: the harness line (V, A set by the caller), run from .harness/run; it exits by itself (bounded: 240 s); its exit code in
# HE; its log .harness/h.log
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "$L_H")
  pv; echo "\$ A=($(printf '%s ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 240 s"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$(raw "$TOKEN" .harness/h.log)" = 0 ] || die "a harness log held the token"; }
# hview: the harness's whole log (PROBE lines, Hibernate's core lines, the SQL and bind loggers' lines), trailing spaces dropped;
# then its exit code
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
script() { echo "  the script it wrote, .harness/run/$1 - every line:"; if [ -f ".harness/run/$1" ]; then sed 's/^/    /' ".harness/run/$1"; else echo "    (none: no such file)"; fi; }
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
  echo "  its diff (diff -U0, its file names cut) - hunks: $($G -c '^@@ ' .harness/code.diff || true) · lines out: $($G -c '^-' .harness/code.diff || true) · in: $($G -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
summ() { $G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
reports() { local s t
  python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  s=$(summ "$2"); t=$(python3 -I harness/surefire.py "$1/$SR" | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"; }


# ---- shapes: one customer, two pauses, three mappings -------------------------------------------------------------------------
shapes() { local k
  for k in uni jt bi; do rm -f .harness/run/$k.sql
    case $k in uni) echo "shape 1 - UniCustomer: @OneToMany(cascade = PERSIST) @JoinColumn(name = \"customer_id\") List<UniPause> pauses; UniPause knows no customer:" ;;
                jt) echo "shape 2 - JtCustomer: @OneToMany(cascade = PERSIST) List<JtPause> pauses, nothing else written; JtPause knows no customer:" ;;
                bi) echo "shape 3 - BiCustomer: @OneToMany(mappedBy = \"customer\", cascade = PERSIST) List<BiPause> pauses; BiPause: @ManyToOne @JoinColumn(name = \"customer_id\") BiCustomer customer; addPause sets both:" ;; esac
    V=(); A=(shapes $k $k.sql); hrun; hview; script $k.sql; done; }

# ---- inverse: a pause added to the customer's list only ----------------------------------------------------------------------
inverse() { echo "the bidirectional shape (BiCustomer, BiPause) - Kavya persisted; then a pause persisted and added to her list only, the bind logger on:"
  V=(-Dbind=TRACE); A=(inverse); hrun; hview; }

# ---- ownpause: the shipped pause table (customer_id NOT NULL), four mappings, A/B/B2/C/A' -------------------------------------
ownpause() { local v e
  for v in A:bi B:uni B2:nn C:nu "A':bi"; do
    case ${v#*:} in bi) e='BiOwnCustomer: @OneToMany(mappedBy = "customer", cascade = PERSIST); BiOwnPause: @ManyToOne(optional = false) @JoinColumn(name = "customer_id") - bidirectional, both sides set' ;;
                   uni) e='UniOwnCustomer: @OneToMany(cascade = PERSIST) @JoinColumn(name = "customer_id") List<OwnPause> - unidirectional, the join column as JPA defaults it' ;;
                    nn) e='NnOwnCustomer: @OneToMany(cascade = PERSIST) @JoinColumn(name = "customer_id", nullable = false) List<OwnPause>' ;;
                    nu) e='NuOwnCustomer: @OneToMany(cascade = PERSIST) @JoinColumn(name = "customer_id", nullable = false, updatable = false) List<OwnPause>' ;; esac
    echo "${v%%:*} - $e:"
    V=(); A=(own ${v#*:}); hrun; hview
    [ "${v%%:*}" != B ] || echo "  the trio: exit $HE · $($G -m1 '^PROBE EXCEPTION ' .harness/h.log | sed 's/^PROBE EXCEPTION //' || echo 'no exception printed') · written: $($G -m1 '^PROBE after the transaction' .harness/h.log | sed 's/^PROBE after the transaction, read by a second connection - //' || echo 'no read')"; done; }

# ---- anchor: the change, and the anchor's two entities on the shipped Database's tables; TiffinBox starts with them ----------
anchor() { local a=$CJ/CustomerEntity.java c
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#; s#^Only in after/(.*): (.*)$#  \1/\2 (new)#' | sort
  echo "CustomerEntity.java:"; cdiff "before/$a" "after/$a"
  echo "PauseEntity.java (new) - its code lines (no comments):"
  $G -vE '^ *(/\*\*|\*|\*/)' "after/$CJ/PauseEntity.java" | $G -v '^$' | sed 's/^/    /'
  echo "the table, as the shipped Database creates it - after/'s Database.java, grep -n the pause table's lines:"
  (cd after && $G -n -A4 'CREATE TABLE pause' $CJ/Database.java) | sed -E 's/^([0-9]+)[:-][[:space:]]*/  \1: /'
  echo "on H2 - the shipped Database (createAndSeed) seeds this run's database; the anchor's CustomerEntity and PauseEntity (after/'s jar) read it:"
  rm -f .harness/run/anchor.sql
  V=(); A=(anchor anchor.sql); hrun; hview; script anchor.sql
  echo "TiffinBox itself - after/'s jar, port 19880, its own H2; GET /customers, then stopped:"
  rm -f .harness/after/hibernate-ddl.sql
  start "$(at .harness/after 19880 "$R_RUN")"; up 19880; ready 19880
  c=$(url "$R_GET" 19880); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  stop 19880 .harness/after; logtok; tview .harness/run.out
  echo "  its log - 'Initialized JPA EntityManagerFactory': $($G -c 'Initialized JPA EntityManagerFactory' .harness/run.out || true)"; rm -f .harness/run.out; }

# ---- seven: the H2 regression - both trees' jars (a guard, R.190) -----------------------------------------------------------
jlog() { local h v
  h=$($G -m1 -oE 'HikariPool-1 - Added connection conn0: url=[^ ]+' "$1" || true); v=$($G -m1 -oE 'HHH000001: Hibernate ORM core version [^ ]+' "$1" || true)
  echo "  its pool: ${h:-no Hikari line} · Hibernate: ${v:-no Hibernate line} · WARN lines: $(lvl WARN "$1") · ERROR lines: $(lvl ERROR "$1")"; }
seven7() { local t
  for t in before after; do
    echo "the seven - $t/'s jar, port 19881, a fresh JVM:"
    start "$(at .harness/$t 19881 "$R_RUN")"; up 19881; ready 19881
    echo "\$ \$CURLSET 19881 .harness/$t/$TF"
    "$CURLSET" 19881 ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    $G '^POST ' .harness/seven-$t.txt | sed 's/^/  /' || echo "  (no POST line)"
    gone 19881
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"; jlog .harness/run.out; logtok; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }

# ---- tests: TiffinBox's tests, read from Surefire's reports -----------------------------------------------------------------------
tests() { local c e=0 n
  echo "TiffinBox's tests - after/ copied to .harness/tests, the README's line, offline:"
  copy after .harness/tests
  c=$(off .harness/tests "$R_TEST"); echo "\$ $c"
  (eval "$c") > .harness/tests.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/tests.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/tests.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"; reports .harness/tests .harness/tests.log
  echo "  Hibernate in the tests' log - lines that say Initialized JPA EntityManagerFactory: $($G -c 'Initialized JPA EntityManagerFactory' .harness/tests.log || true) · Hibernate's SQL lines: $($G -c ' org\.hibernate\.SQL  *: ' .harness/tests.log || true)"
  echo "  its log's WARN lines: $(lvl WARN .harness/tests.log) · ERROR lines: $(lvl ERROR .harness/tests.log) (the tests' own kitchen-on-fire cases) · the demo token in it and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }

# ---- xcheck: the harness's DDL for the anchor's two entities against Boot's --------------------------------------------------
xcheck() {
  echo "Boot's DDL - after/'s jar with the anchor README's DDL line (a file, never run), port 19882:"
  rm -f .harness/after/hibernate-ddl.sql
  start "$(at .harness/after 19882 "$R_DDL")"; up 19882; ready 19882; stop 19882 .harness/after; logtok
  echo "  .harness/after/hibernate-ddl.sql - every line:"; sed 's/^/    /' .harness/after/hibernate-ddl.sql
  echo "the harness's DDL - its own EntityManagerFactory over com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity (from after/'s jar), a file, never run:"
  rm -f .harness/run/xcheck.sql
  V=(); A=(xcheck xcheck.sql); hrun; hview
  echo "  .harness/run/xcheck.sql - every line:"; sed 's/^/    /' .harness/run/xcheck.sql
  echo "\$ cmp .harness/after/hibernate-ddl.sql .harness/run/xcheck.sql"
  echo "  the same, byte for byte: $(cmp -s .harness/after/hibernate-ddl.sql .harness/run/xcheck.sql && echo yes || echo no) · md5 $(md5 -q .harness/run/xcheck.sql)"; }


# ---- exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 240 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the classes it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -) · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$setup" | $G -c .)" = "$(printf '%s\n' "$sol" | $G -c .)" ] || die "SOLUTION.md's block must have the README's lines, one changed"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | $G -qF -- '"${V[@]}"' && printf '%s\n' "$setup" | $G -qE '^V=\(' || die "exercise/README.md must pass its options as an array, V (R.164, R.193)"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  echo "exercise/README.md's $(printf '%s\n' "$setup" | $G -c .) lines, then exercise/SOLUTION.md's, exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), started in this folder:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }


# ---- the captures, each followed by the checks of what the video says from it ------------------------------------------------
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# R.222: a version-shaped claim prints its version in the same capture - Hibernate's own HHH000001 line (its core logger at INFO)
# and the harness's org.hibernate.Version.getVersionString() line, once per harness JVM, read off the log, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
DBL='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:'
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] || die "$1: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its $2 harness JVMs (R.222)"
  [ "$(printf '%s\n' "$c" | $G -cF -- "$DBL")" = "$2" ] || die "$1: the database: line, H2 2.5.250, in each of its $2 harness JVMs (R.217: this unit speaks for H2 only)"; }
# R.184: a count has two witnesses from one run - the SQL logger's lines between "before persist()" and "after commit", and
# getPrepareStatementCount() (S2.3: never Statistics' entity counters for a collection's writes)
sqln() { printf '%s\n' "$1" | sed -n '/^  PROBE before persist()/,/^  PROBE after commit$/p' | $G -c '^  DEBUG org\.hibernate\.SQL : ' || true; }
prep() { printf '%s\n' "$1" | sed -n 's/^  PROBE statistics: statements prepared (getPrepareStatementCount) \([0-9]*\) .*/\1/p' | head -1; }
aft() { printf '%s\n' "$1" | sed -n '/^  PROBE before commit$/,/^  PROBE after commit$/p' | $G '^  DEBUG org\.hibernate\.SQL : ' | sed 's/^  DEBUG org\.hibernate\.SQL : //' || true; }
two() { local n p; n=$(sqln "$1"); p=$(prep "$1"); [ "$n" = "$2" ] && [ "$p" = "$2" ] || die "$3: $2 statements - the SQL log's lines ($n) and getPrepareStatementCount() (${p:-none}) both (R.184)"; }
# the hook: "one customer, two pauses: five statements, two of them update ... set customer_id - and Statistics says updates 0"
chk_shapes() { local S B upd
  S=$(cat .r-shapes.out); ver shapes 3
  B=$(blk shapes 'shape 1 - ' 'shape 2 - ')
  two "$B" 5 "shapes 1 (a unidirectional list with @JoinColumn)"
  for l in '  DEBUG org.hibernate.SQL : insert into uni_pause (days,id) values (?,default)' '  PROBE statistics: statements prepared (getPrepareStatementCount) 5 | entity inserts 3 | entity updates (getEntityUpdateCount) 0 | collection recreates 1 | collection updates 0' \
      '  PROBE jdbc: prepareStatement 5 | executeUpdate 5 | addBatch 0 | executeBatch 0 | executeQuery 0 | execute 0' '  PROBE uni_pause, read by a second connection (id | customer_id | days): [1 | 1 | 3, 2 | 1 | 5]' \
      '    create table uni_pause (days integer not null, customer_id bigint, id bigint generated by default as identity, primary key (id));' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$B" "$l" "shapes 1"; done
  # the two UPDATEs, counted from the SQL log - after "before commit" (S2.3: Statistics' entity updates cannot see them)
  upd=$(aft "$B" | $G -cxF 'update uni_pause set customer_id=? where id=?' || true)
  [ "$upd" = 2 ] && [ "$(aft "$B" | wc -l | tr -d ' ')" = 2 ] || die "shapes 1: two UPDATEs (update uni_pause set customer_id=?), after before commit, and nothing else there - counted from the SQL log ($upd)"
  B=$(blk shapes 'shape 2 - ' 'shape 3 - ')
  two "$B" 5 "shapes 2 (a bare unidirectional list: a join table)"
  for l in '    create table jt_customer_pauses (jt_customer_id bigint not null, pauses_id bigint not null unique);' '    create table jt_pause (days integer not null, id bigint generated by default as identity, primary key (id));' \
      '    alter table if exists jt_customer_pauses add constraint FK<hash> foreign key (pauses_id) references jt_pause;' '  PROBE jt_customer_pauses, read by a second connection (jt_customer_id | pauses_id): [1 | 1, 1 | 2]' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$B" "$l" "shapes 2"; done
  [ "$(aft "$B" | $G -cxF 'insert into jt_customer_pauses (jt_customer_id,pauses_id) values (?,?)' || true)" = 2 ] || die "shapes 2: two inserts into the join table, after before commit"
  B=$(blk shapes 'shape 3 - ' '')
  two "$B" 3 "shapes 3 (bidirectional, mappedBy)"
  [ "$(printf '%s\n' "$B" | $G -cxF '  DEBUG org.hibernate.SQL : insert into bi_pause (customer_id,days,id) values (?,?,default)' || true)" = 2 ] || die "shapes 3: the two pause INSERTs carry customer_id"
  [ -z "$(aft "$B")" ] || die "shapes 3: nothing after before commit"
  for l in '  PROBE bi_pause, read by a second connection (id | customer_id | days): [1 | 1 | 3, 2 | 1 | 5]' '  PROBE read in a new EntityManager: Ravi'"'"'s pauses [3, 5]' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$B" "$l" "shapes 3"; done
  ! $G -qE 'FK[0-9a-z]{10,}' .r-shapes.out || die "shapes: a constraint name unmasked"
  echo "  shapes: 1 @JoinColumn - 5 statements (5 SQL lines = getPrepareStatementCount 5): 3 INSERTs without customer_id, then after before commit 2 x update uni_pause set customer_id=?; Statistics' entity updates 0, collection recreates 1 · 2 bare - the join table jt_customer_pauses (pauses_id ... unique), 5 statements, its 2 inserts after before commit · 3 mappedBy - 3 statements, the FK in each pause's INSERT, nothing after before commit · every read back [3, 5]; H2"; }
# "added to her list only: the INSERT carries customer_id, bound null; a second connection reads customer_id null; a new
# EntityManager reads 0 pauses; Statistics counted the collection as updated"
chk_inverse() { local I; I=$(cat .r-inverse.out); ver inverse 1
  # the witness first: the row a second connection reads, then the new EntityManager's read
  for l in '  PROBE bi_pause, read by a second connection (id | customer_id | days): [1 | null | 4]' "  PROBE read in a new EntityManager: Kavya's pauses 0 []" \
      "  PROBE added to Kavya's list only (getPauses().add) - its customer never set; in memory: Kavya's pauses 1 | the pause's customer null" \
      '  DEBUG org.hibernate.SQL : insert into bi_pause (customer_id,days,id) values (?,?,default)' '  TRACE org.hibernate.orm.jdbc.bind : binding parameter (1:BIGINT) <- [null]' \
      '  PROBE statistics: statements prepared (getPrepareStatementCount) 1 | entity inserts 1 | entity updates (getEntityUpdateCount) 0 | collection recreates 0 | collection updates 1' \
      "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$I" "$l" "inverse: customer_id null"; done
  two "$I" 1 "inverse"
  echo "  inverse: one INSERT, customer_id bound null; a second connection reads 1 | null | 4; a new EntityManager reads Kavya's pauses 0; Statistics: collection updates 1 (it counted the list, which wrote nothing); H2"; }
# the failure receipt (B) and the statement counts on TiffinBox's own table: "A two statements; B refused - NULL not allowed for
# column CUSTOMER_ID, nothing written; B2 three - nullable = false keeps the UPDATE; C two - nullable = false, updatable = false,
# no UPDATE; A' = A"
SEEDL="  PROBE seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name): [1 | Ravi, 2 | Meera, 3 | Sunil, 4 | Priya] | pause (id | customer_id | days): [1 | 3 | 3, 2 | 4 | 2]"
OWNOK="  PROBE after the transaction, read by a second connection - customer (id | name): [1 | Ravi, 2 | Meera, 3 | Sunil, 4 | Priya, 5 | Kavya] | pause (id | customer_id | days): [1 | 3 | 3, 2 | 4 | 2, 3 | 5 | 3]"
chk_ownpause() { local A B B2 C A2 b
  ver ownpause 5
  A=$(blk ownpause 'A - ' 'B - '); B=$(blk ownpause 'B - ' 'B2 - '); B2=$(blk ownpause 'B2 - ' 'C - '); C=$(blk ownpause 'C - ' "A' - "); A2=$(blk ownpause "A' - " '')
  for b in "$A" "$B" "$B2" "$C" "$A2"; do has "$b" "$SEEDL" "ownpause: the shipped Database's seed"; done
  two "$A" 2 "ownpause A (bidirectional)"; [ -z "$(aft "$A")" ] || die "ownpause A: nothing after before commit"
  for l in '  DEBUG org.hibernate.SQL : insert into pause (customer_id,days,id) values (?,?,default)' "$OWNOK" "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$A" "$l" "ownpause A"; done
  [ "$A" = "$A2" ] || die "ownpause A': A re-run prints what A printed (R.1)"
  for l in '  DEBUG org.hibernate.SQL : insert into pause (days,id) values (?,default)' '  WARN  org.hibernate.orm.jdbc.error : NULL not allowed for column "CUSTOMER_ID"; SQL statement:' \
      '  the trio: exit 1 · org.hibernate.exception.ConstraintViolationException: could not execute statement [NULL not allowed for column "CUSTOMER_ID"; SQL statement: · written: customer (id | name): [1 | Ravi, 2 | Meera, 3 | Sunil, 4 | Priya] | pause (id | customer_id | days): [1 | 3 | 3, 2 | 4 | 2]' \
      '  PROBE   Caused by org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "CUSTOMER_ID"; SQL statement:'; do has "$B" "$l" "ownpause B: the trio - exit 1, NULL not allowed for column CUSTOMER_ID, nothing written"; done
  nhas "$B" 'PROBE after persist()' "ownpause B: refused at the pause's INSERT, inside persist()"
  # B2: nullable = false puts the FK in the INSERT and KEEPS the UPDATE - three statements for a customer and one pause
  two "$B2" 3 "ownpause B2 (nullable = false): the UPDATE kept"
  [ "$(aft "$B2")" = 'update pause set customer_id=? where id=?' ] || die "ownpause B2: after before commit, update pause set customer_id=? - and nothing else"
  for l in '  DEBUG org.hibernate.SQL : insert into pause (customer_id,days,id) values (?,?,default)' "$OWNOK"; do has "$B2" "$l" "ownpause B2"; done
  # C: nullable = false, updatable = false - the FK in the INSERT, no UPDATE: two statements (RED #307)
  two "$C" 2 "ownpause C (nullable = false, updatable = false): no UPDATE"
  [ -z "$(aft "$C")" ] || die "ownpause C: nothing after before commit - no UPDATE"
  for l in '  DEBUG org.hibernate.SQL : insert into pause (customer_id,days,id) values (?,?,default)' "$OWNOK" "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$C" "$l" "ownpause C"; done
  echo "  ownpause: A (mappedBy) 2 statements, the FK in the INSERT · B (default @JoinColumn) exit 1 - ConstraintViolationException, NULL not allowed for column \"CUSTOMER_ID\" at the pause's INSERT, nothing written · B2 (nullable = false) 3 - the UPDATE kept after before commit · C (nullable = false, updatable = false) 2 - no UPDATE · A' = A; Hibernate 7.4.13.Final, H2"; }
# the anchor change's witness (R.190/R.194, RED #319): "the seed reads Ravi [] · Meera [] · Sunil [3] · Priya [2] in five statements
# (the count only); a pause added from the owning side is one INSERT, customer_id set"
ARD="  PROBE read by Hibernate (the anchor's two entities): Ravi [] | Meera [] | Sunil [3] | Priya [2]"
chk_anchor() { local AN AH AT r
  AN=$(cat .r-anchor.out); AH=$(blk anchor "on H2 - the shipped" "TiffinBox itself"); AT=$(blk anchor "TiffinBox itself" ""); ver anchor 1
  has "$AH" "$ARD" "anchor: the seed read through the entities"
  r=$(printf '%s\n' "$AH" | sed -n '/^  PROBE every customer/,/^  PROBE read by Hibernate/p' | $G -c '^  DEBUG org\.hibernate\.SQL : select ' || true)
  [ "$r" = 5 ] && [ "$(prep "$(printf '%s\n' "$AH" | sed -n '/^  PROBE read by Hibernate/,/^  PROBE jdbc/p')")" = 5 ] || die "anchor: the read is 5 statements - 5 select lines ($r) and getPrepareStatementCount() 5 (R.184)"
  for l in '  PROBE statistics: statements prepared (getPrepareStatementCount) 5 | entity inserts 0 | entity updates (getEntityUpdateCount) 0 | collection recreates 0 | collection updates 0' \
      '  PROBE statistics: statements prepared (getPrepareStatementCount) 1 | entity inserts 1 | entity updates (getEntityUpdateCount) 0 | collection recreates 0 | collection updates 0' \
      '  PROBE pause, read by a second connection (id | customer_id | days): [1 | 3 | 3, 2 | 4 | 2, 3 | 1 | 5]' "$SEEDL" "  exit 0 · 'GenerationTarget encountered exception': 0" \
      '    create table pause (days integer not null, customer_id bigint not null, id bigint generated by default as identity, primary key (id));' \
      '    alter table if exists pause add constraint FK<hash> foreign key (customer_id) references customer;'; do has "$AH" "$l" "anchor: the anchor's entities"; done
  [ "$(printf '%s\n' "$AH" | sed -n '/^  PROBE before persist(): a pause of 5 days/,/^  PROBE after commit$/p' | $G '^  DEBUG org\.hibernate\.SQL : ')" = '  DEBUG org.hibernate.SQL : insert into pause (customer_id,days,id) values (?,?,default)' ] || die "anchor: the pause added from the owning side is one INSERT, with customer_id"
  [ "$(printf '%s\n' "$AN" | sed -n '/^the change - after/,/^CustomerEntity.java:/p' | $G '^  ' | paste -sd' ' -)" = '  README.md   tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java   tiffinbox-core/src/main/java/com/tiffinbox/PauseEntity.java (new)' ] || die "anchor: the change is CustomerEntity.java, PauseEntity.java (new) and the README, nothing else - Database.java unchanged"
  for l in '    +    @OneToMany(mappedBy = "customer")' '    +    private List<PauseEntity> pauses = new ArrayList<>();' '    +    public List<PauseEntity> getPauses() {' \
      '        @ManyToOne(fetch = FetchType.LAZY, optional = false)' '        @JoinColumn(name = "customer_id")' '        private CustomerEntity customer;' '  44: customer_id BIGINT NOT NULL REFERENCES customer(id),'; do has "$AN" "$l" "anchor: the change, the table"; done
  for l in '  listens on: 127.0.0.1:19880 · loopback only: yes' '  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200' '    INFO org.hibernate.orm.core: HHH000001: Hibernate ORM core version 7.4.13.Final' "  its log - 'Initialized JPA EntityManagerFactory': 1" '  exit 0 · listening on 19880 now: 0'; do has "$AT" "$l" "anchor: TiffinBox starts with the two entities mapped"; done
  echo "  anchor: CustomerEntity.java (pauses, mappedBy = \"customer\"), PauseEntity.java (new: @ManyToOne(fetch = LAZY, optional = false) @JoinColumn(name = \"customer_id\")) and the README; Database's pause table unchanged (customer_id BIGINT NOT NULL REFERENCES customer(id)); the shipped seed read through the entities: Ravi [] | Meera [] | Sunil [3] | Priya [2] - 5 statements (5 select lines = getPrepareStatementCount 5); a pause for Ravi from the owning side: 1 INSERT, 3 | 1 | 5; Hibernate's DDL pause.customer_id bigint not null; TiffinBox starts with them mapped (HHH000001 7.4.13.Final), its customers read by JDBC; H2"; }
# guards (R.190): the seven the same on both trees; the eighteen tests
chk_seven() { local SV S466='466c20ed7e0d5439cb052f32ce09de1b'
  SV=$(cat .r-seven.out)
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] || die "seven: $S466 on both trees"
  has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: 0 lines differ"
  [ "$(printf '%s\n' "$SV" | $G -c '· Hibernate: HHH000001: Hibernate ORM core version 7.4.13.Final ·')" = 2 ] || die "seven: Boot's HHH000001 line in both logs (R.222)"
  echo "  seven: $S466 on before/ and after/, 0 lines differ (a guard: the web layer never reads the entities)"; }
chk_tests() { local TS l
  TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" '  exit 0 · BUILD SUCCESS · offline: yes' \
      "  Hibernate in the tests' log - lines that say Initialized JPA EntityManagerFactory: 2 · Hibernate's SQL lines: 0"; do has "$TS" "$l" "tests"; done
  echo "  tests: 18 (14/3/1) from the reports, the console the same; 2 EntityManagerFactories, 0 SQL lines (a guard, R.190; C7-4)"; }
# R.212: Boot's script for the two entities = the harness's, byte for byte; its md5 is what units 10-14 compare with
XMD5=""
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out); ver xcheck 1
  XMD5=$(printf '%s\n' "$XC" | sed -n 's/^  the same, byte for byte: yes · md5 \([0-9a-f]\{32\}\)$/\1/p')
  [ -n "$XMD5" ] || die "xcheck: the harness's DDL is not Boot's, byte for byte"
  for l in "    create table customer (meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, name varchar(60) not null unique, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id));" \
      '    create table pause (days integer not null, customer_id bigint not null, id bigint generated by default as identity, primary key (id));' \
      '    alter table if exists pause add constraint FK<hash> foreign key (customer_id) references customer;'; do [ "$(cnt "$XC" "$l")" = 2 ] || die "xcheck: the line, in both scripts: $l"; done
  [ "$XMD5" != 820b43fcc96665c2d457212a156204eb ] || die "xcheck: the script still hashes as unit 07's (820b43fc…) - the entities did not change"
  echo "  xcheck: Boot's script (after/'s jar, port 19882) = the harness's, byte for byte, md5 $XMD5 (unit 07's was 820b43fc…: the pause table and its foreign key now) - units 10-14 compare with it"; }
EXQ="Your turn: the README adds a pause to Kavya's list and the table never hears who it belongs to. Fix it."
chk_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    exit 0' '    PROBE ex_pause, read by a second connection (id | customer_id | days): [1 | null | 4]' "    PROBE read in a new EntityManager: Kavya's pauses 0"; do has "$ER" "$l" "exercise: the README - customer_id null"; done
    for l in '    exit 0' '    PROBE ex_pause, read by a second connection (id | customer_id | days): [1 | 1 | 4]' "    PROBE read in a new EntityManager: Kavya's pauses 1"; do has "$ES" "$l" "exercise: the solution - customer_id 1"; done
    nhas "$b" 'EXCEPTION' "exercise: both halves run"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" = 21 ] || die "exercise: the spoken line is 21 words (R.203)"
  [ "$($G -c 'setCustomer' harness/src/probe/map/ex/ExCustomer.java || true)" = 0 ] || die "exercise: ExCustomer ships with addPause setting the list only"
  echo "  exercise: bash and zsh alike - the README as written: the pause in, customer_id null, a new EntityManager reads Kavya's pauses 0; the solution (one line: addPause sets pause.setCustomer(this)): customer_id 1, pauses 1; 21 words"; }
cap shapes shapes; chk_shapes
cap inverse inverse; chk_inverse
cap ownpause ownpause; chk_ownpause
cap anchor anchor; chk_anchor
cap seven seven7; chk_seven
cap tests tests; chk_tests
cap xcheck xcheck; chk_xcheck
cap exercise exercise; chk_exercise

# hygiene: every raw capture run and every file this unit holds - 0 raw tokens
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$LOGS" -gt 0 ] || die "a token count never ran"
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  # a line quoted from the anchor's own files (a diff's -/+ lines, the entity's code lines) may name the unit that wrote it
  ! $G -vE '^(  (README\.md|tiffinbox-core/[^ :]+):[0-9]+:|    [-+])' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a Surefire booter path, a time or Boot's seconds"
  ! $G -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE 'FK[0-9a-z]{10,}' "$f" || die "$f holds a generated constraint name, unmasked"
  ! $G -qE '(127\.0\.0\.1:|port )(49|5[0-9]|6[0-5])[0-9][0-9][0-9]([^0-9]|$)' "$f" || die "$f holds a random port (R.147)"
  ! $G -qE '[0-9]+\.[0-9]+ ms' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -oE 'https?://[^ '"'"']+' | $G -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
for f in .r-*.out; do ! $G -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
for f in .r-*.out; do a=$($G -cE '^\$ cd \.harness/(before|after) && java ' "$f" || true); b=$($G -cxF "  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else" "$f" || true)
  [ "$a" = "$b" ] || die "$f: $a starts, $b secrets/ listings (R.158)"; done
K1='pki''ll'; K2='kill''all'; for f in receipts.sh harness/shutdown.sh; do ! $G -v '^ *#' "$f" | $G -qwE "$K1|$K2" || die "$f names $K1 or $K2 - every process is stopped by its pid"; done
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.map' after/tiffinbox-web after/tiffinbox-core || die "after/'s code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
# R.213: SQL keywords are never a name here (the harness's tables and columns)
! $G -rqiwE '(class|String|Long|int|List<[A-Za-z]+>) +(order|offset|user|value|key)\b' harness/src || die "a harness entity or field is named after an SQL keyword (R.213)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory"
echo "  hygiene: 0 raw tokens in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, unmasked constraint name, random port or stack frame in any capture; every JVM pinned; every start's secrets/ listed; no kill by name; no bare wait; options as arrays; no H2 file; no dish name"

# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19880-19889 at the end; 19889 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit09: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens; no port bound but 19880-19882"
