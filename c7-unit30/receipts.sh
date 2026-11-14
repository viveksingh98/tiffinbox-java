#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · N+1, Measured - this unit's receipts. Section 5's second unit; no change to the anchor (brief flag 1): anchor is the
# link to ../c7-unit29/after (= ../c7-tiffinbox at unit 29's commit; unit 31 moves the anchor next). One query lists the customers;
# then Hibernate runs one more for each customer whose pauses the page reads - counted three ways, at two N - and the counter you
# might reach for first does not see it. Seven captures, each run three times and hashed; a hash that differs from receipts.md5 stops
# the run; every number and string the video says is asserted right after its capture by a check that can fail, against another
# witness of the same run (harness/chk30.py) - never against a typed figure. One database: H2 (brief flag 7) - in the harness JVM's
# memory, and for TiffinBox an H2 TCP server on 127.0.0.1:20098 (only local connections), so a second connection (H2's own Shell)
# counts what TiffinBox stored.
#   count     the page's read (findAll(Sort.by("name")), then every customer's pauses, in a read-only transaction) at -Dn=36 and -Dn=6
#             (unit 20's generator; the customers counted back on a second connection): the three witnesses per N, Statistics' other
#             counters beside them, the line "statements = 1 + 1 x customers" DERIVED from the two points (R.249); the failure
#             receipt: Statistics.getQueryExecutionCount() the same at both N (S5.1); the session-metrics block of the read-only
#             read (no flush) and of a read-write control, labelled (RE-MEASURE 12)
#   page      TiffinBox on the anchor's jar (20090) and on the anchor copied and built again (A', 20091): POST /customers/import of
#             -Dn's generated lines, then GET /dashboard as HTML and as JSON - each request's SQL lines between two markers (the whole
#             request) and the read's own session block (S5.2) - and GET /customers; the second connection's counts
#   inverse   every pause, then its customer's name (harness, both N): 1 + one per pause, Statistics.getEntityFetchCount
#   nested    unit 19's nested projection WithPauses through findAllProjectedByOrderByNameAsc() (harness, both N) - S3's CARRIED 1 + N
#   sql       the two statement texts, read off the SQL logger, each shown once; the repeats counted
#   xcheck    the harness's DDL script over the anchor's libraries = ../c7-unit29/xcheck.sql (no mapping moved)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# The anchor is COPIED under .harness/ (anchor, and anchor2 for A') and built there, never in place, with its README's package line,
# offline. The harness (harness/src, packages probe.v and probe.x, outside com.tiffinbox) is compiled once with javac -parameters
# against the anchor's extracted libraries. Every JVM runs under an alarm (perl -e 'alarm N; exec ...'); an alarm that fires is a
# failed receipt (R.247). Ports (§P, 20090-20099): 20090 page · 20091 page A' · 20098 the H2 TCP server · 20099 never bound; the
# harness JVMs bind none. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process under it), $spid (the
# H2 server); then sweep(): anything of this run still alive in its process group is stopped. After an interrupt a capture's
# unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C; the script exits 130
# after an interrupt. No wait in this script is bare.
pid=""; mpid=""; xpid=""; spid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.v.") || index($0, "probe.x.") || index($0, "org.h2.tools.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid" "$spid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find curl openssl /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - the token lives under .harness/ only"
# ---- the anchor: unit 29's after/, through a link; frozen (its tree's hash pinned); ../c7-tiffinbox equals it until unit 31 ----
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit29/after ] || die "anchor must be the link to ../c7-unit29/after - this unit changes nothing in it"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
T29='43 573dbb79c934b95ca71c6ecaed4c3bb3'            # unit 29's after/ at its commit 9714b74: 43 files (harness/tree30.py)
anchortree() { local t; t=$(python3 -I harness/tree30.py anchor/) || die "the anchor's tree could not be hashed"
  [ "$t" = "$T29" ] || die "R.211: anchor/ (../c7-unit29/after, a shipped unit's frozen tree) is not the tree this unit measured: $t, pinned $T29"
  echo "  the anchor's tree ($1): python3 -I harness/tree30.py anchor/ -> $t = pinned (unit 29's after/, frozen)"; }
# R.211: anchor/ equals ../c7-tiffinbox until a later unit changes the anchor (unit 31) - a note then, never a stop
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit29/after - a later anchor change has moved ../c7-tiffinbox on; no anchor change in this unit"; fi; }
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchortree start; anchornote start
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
HS=harness/src/probe/v
HFILES='chk30.py csv30.py dur7.py logback.xml s30.py seg30.py src tree30.py'
SFILES='probe/v/Gen.java probe/v/H.java probe/v/Main.java probe/v/Run.java probe/v/Seed.java probe/v/SqlCounter.java probe/v/ex/ExApp.java probe/v/repo/Proj.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql pinned.txt; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not unit 29's, byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20090 20091 20092 20093 20094 20095 20096 20097 20098 20099"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 + S4.7 (R.264) + R.301 (S5.18) + R.287 + R.190, carried from unit 29's s29; S5.1 (R.284), S5.2 (R.285), R.249 and R.224,
# this unit's - per sentence, harness/s30.py, its self-test first
DW=$(python3 -I -B harness/s30.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'self-test: 27 cases · refused: 0' || die "a refused word or reading in this unit's prose (R.172, S4.7, R.301, R.287, R.190, S5.1, S5.2, R.249, R.224): $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s30, 27-case self-test): dur7 words 0 · S4.7's family 0 · R.301's family 0 (a cost word only beside a printed count) · speed words 0 · R.287 old wordings 0 · R.190 the tests as a witness 0 · S5.1 the count of queries as a statement count 0 · S5.2 a page's count unscoped 0 · R.249 a trend beside one N 0 · R.224 DataLoader without its title 0 - over README.md and exercise/"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness pinned.txt)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/ and pinned.txt)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty"
# R.225: a SQL string this unit shows is the logger's - outside the values block, none in README.md
SQLRE='select ce1_0|from customer ce1_0|from pause p1_0|select p1_0|insert into customer|select pe1_0|count\(\*\)'
TS=$(awk '/^<!-- values: begin -->$/ { v = 1; next } /^<!-- values: end -->$/ { v = 0; next } !v { print NR ": " $0 }' README.md | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md (R.225): $TS"
echo "  typed SQL strings: 0 in README.md outside its values block"
# R.302 (S5.19): the page's two counts are printed by the run, typed nowhere - not in the prose (fenced blocks and the values block
# hold what the runs print), not in this script, not in the harness
TN=$(for f in README.md exercise/README.md exercise/SOLUTION.md; do awk -v f="$f" '/^<!-- values: begin -->$/ { v = 1; next } /^<!-- values: end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b && $0 ~ /(^|[^0-9A-Za-z_])4[14]([^0-9A-Za-z_]|$)/ { print f ":" NR ": " $0 }' "$f"; done | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TN" ] || die "R.302: a count typed in the prose, outside a block a run printed and the values block: $TN"
TC=$($G -nwE '4[14]' receipts.sh harness/chk30.py harness/csv30.py harness/seg30.py harness/tree30.py harness/src/probe/v/*.java harness/src/probe/v/*/*.java 2> /dev/null | $G -v '^receipts.sh:[0-9]*:TC=' | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a count typed in this script or the harness: $TC"
echo "  R.302: the page's two counts typed 0 times in the prose (outside printed blocks and the values block), in receipts.sh and in harness/ (s30.py's self-test aside: its refused cases are the plants' sentences)"
# R.252: the pinned sentences, byte-equal - pinned.txt hashed here, each of its lines a whole line of README.md
PIN=ad7bd3fe8510b8199ff33833b6715ee6
[ "$(md5 -q pinned.txt)" = "$PIN" ] || die "R.252: pinned.txt is not the pinned text (md5 $(md5 -q pinned.txt), pinned $PIN) - unit 39's and Course 17's agents diff against it"
[ "$(wc -l < pinned.txt | tr -d ' ')" = 3 ] || die "R.252: pinned.txt holds three lines"
while IFS= read -r l; do $G -qxF -- "$l" README.md || die "R.252: README.md does not hold the pinned line, whole: $l"; done < pinned.txt
echo "  R.252: pinned.txt md5 $PIN (3 lines), each line whole in README.md"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
HSRC="$HS/Gen.java $HS/H.java $HS/Main.java $HS/Run.java $HS/Seed.java $HS/SqlCounter.java $HS/repo/Proj.java harness/src/probe/x/XMain.java"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HSRC")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*\" probe.v.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_H2S=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java $JL -Dh2.bindAddress=127.0.0.1 -cp \"../anchor/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Server -tcp -tcpPort 20098 -ifNotExists")
L_SHELL=$(mine "cd .harness/run && $AL java $JL -cp \"../anchor/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Shell -url \"jdbc:h2:tcp://127.0.0.1:20098/mem:\$DB\" -user sa -password '' -sql \"\$Q\"")
L_CSV=$(mine 'python3 -I harness/csv30.py "$N" > .harness/import.csv')
L_IMP=$(mine "curl -s --noproxy '*' -F 'file=@.harness/import.csv;type=text/csv' http://127.0.0.1:20090/customers/import")
Q_C='select count(*) from customer'
Q_P='select count(*) from pause'
Q_S="select c.name, coalesce(sum(p.days), 0) from customer c left join pause p on p.customer_id = c.id where c.name not like 'Customer %' group by c.name order by c.name"
TBL=(--spring.datasource.username=sa --logging.level.org.hibernate.SQL=debug --logging.level.org.springframework.orm.jpa.JpaTransactionManager=debug --logging.level.org.hibernate.session.metrics=debug --spring.jpa.properties.hibernate.generate_statistics=true)
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# tb TREE PORT DB: the anchor README's run line on TREE, its port, TiffinBox's database on the H2 server (mem:DB), sa, the SQL
# logger, the transaction manager's DEBUG lines, Hibernate's session metrics (DEBUG) and its statistics on (run options) - quoted
tb() { local t=$1 p=$2 d=$3 a x; a="'--tiffinbox.jdbc-url=jdbc:h2:tcp://127.0.0.1:20098/mem:$d;DB_CLOSE_DELAY=-1'"
  for x in "${TBL[@]}"; do a="$a $x"; done; printf '%s %s\n' "$(at .harness/$t $p "$R_RUN")" "$a"; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
[ "$(exe "$(at .harness/anchor 20090 "$R_RUN")")" = "cd .harness/anchor && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20090" ] || die "at(): the run line is not the anchor README's"
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures -------------------------------------------------------------------------------------------
NOPLUG='No plugin'' found for prefix'
mbuild() { local how=yes ec=0 c=$1 miss got web
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && $G -qE "offline mode|Could not resolve|could not be resolved|Cannot access|$NOPLUG" "$2"; then
    cp "$2" "${2%.log}-offline.log"
    miss=$($G -oE 'the artifact [^ ]+ has not been downloaded' "$2" | head -1 | sed -E 's/^the artifact ([^ ]+) has not been downloaded$/\1/')
    [ -n "$miss" ] || miss=$($G -oE "Could not find artifact [^ ]+|$NOPLUG [^ ]+|Non-resolvable parent POM for [^ ]+" "$2" | head -1)
    ec=0; (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
    got=$(sed -n -E 's/^\[INFO\] Downloaded from ([^ :]+): ([a-z]+):.*/\1 (\2)/p' "$2" | sort | uniq -c | awk '{ printf "%s%s %s %d", (NR > 1 ? ", " : ""), $2, $3, $1 }')
    web=$($G -cE '^\[INFO\] Downloaded from [^ ]+: https?://' "$2" || true)
    how="no - the offline build could not resolve ${miss:-an artifact (none named in its log)} from .m2-demo, so it ran once more without -o; that run downloaded from: ${got:-nothing}; of them over http(s): $web"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
summ4() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/\1 \2 \3 \4/' | awk '{ a += $1; b += $2; c += $3; d += $4 } END { print a + 0, b + 0, c + 0, d + 0 }'; }
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy anchor .harness/anchor; copy anchor .harness/anchor2
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/, its README's package line; its tests ran)"
[ "$(summ4 .harness/build-anchor.log)" = '18 0 0 0' ] || die "the anchor's tests: $(summ4 .harness/build-anchor.log) - expected 18 0 0 0 (a guard)"
echo "  the anchor's tests: run, failures, errors, skipped $(summ4 .harness/build-anchor.log) (the build's summary lines summed - a guard, never a witness: R.190)"
mbuild "$(off .harness/anchor2 "$R_PLAIN" package) -DskipTests" .harness/build-anchor2.log ".harness/anchor2 (anchor/ copied again for A', the same line, -DskipTests)"
for t in anchor anchor2; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
(cd .harness/anchor && eval "$R_TOKEN") || die "the token was not written"
TOKEN=$(head -n 1 .harness/anchor/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
mkdir -p .harness/anchor2/secrets/tiffinbox && (umask 077 && cp .harness/anchor/$TF .harness/anchor2/$TF)
for t in anchor anchor2; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
echo "  the token: generated once (openssl rand -hex 16, the anchor README's line, in .harness/anchor), copied into .harness/anchor2's $TF, mode 0600, never printed"
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/v/ex ] || die "the exercise's class compiled into the wrong place"
echo "  extracted two jars ($(for t in anchor anchor2; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: anchor/A'); the harness compiled once - .harness/hc over the anchor's"
# the H2 TCP server: one JVM for this run, loopback only, TiffinBox's databases on it (mem:NAME), the second connection its Shell
echo "\$ $L_H2S" >&3
(eval "$L_H2S") > .harness/h2server.log 2>&1 < /dev/null & spid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20098)" = 0 ]; do kill -0 "$spid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20098)" = 1 ] || { cat .harness/h2server.log >&3; die "the H2 server never listened on 20098"; }
[ "$(lsof -nP -a -p "$spid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20098' ] || die "the H2 server must listen on 127.0.0.1:20098 alone"
H2SL=$($G -m1 'TCP server running at' .harness/h2server.log || true); [ "$H2SL" = 'TCP server running at tcp://localhost:20098 (only local connections)' ] || die "the H2 server's line: ${H2SL:-none}"
echo "  the H2 server: $H2SL - listens on 127.0.0.1:20098 alone"
# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/SessionImpl\([0-9]+</, "SessionImpl(<n><")
    gsub(/\$\$Lambda\/0x[0-9a-f]+/, "$$Lambda/<n>")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/^ *[0-9]+ ns /, "      <ns> ns ")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/virtual-[0-9]+/, "virtual-<n>"); gsub(/omcat-handler-[0-9]+/, "omcat-handler-<n>"); gsub(/ rows?, [0-9]+ ms\)/, " row(s))")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 2 JPA repository interfaces.' "token $TOKEN" 'JDBC [x.HibernateTransactionManager$$Lambda/0x000003ff01b8a310@5d9576a0]' '    6189708 ns preparing 9 JDBC statements' '(1 row, 3 ms)' '(4 rows, 12 ms)' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 2 JPA repository interfaces.' 'token [masked: the token]' 'JDBC [x.HibernateTransactionManager$$Lambda/<n>@…]' '      <ns> ns preparing 9 JDBC statements' '(1 row(s))' '(4 row(s))')" ] || die "mask: the planted JDK version, folders, home, identity hash, EntityManager identity, scan time, the token, a lambda class's address, a session-metrics time figure and the Shell's time must be masked"
rm -f .harness/p1
HA=('--spring.datasource.url=jdbc:h2:mem:u30;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.jpa.open-in-view=false --spring.jpa.properties.hibernate.generate_statistics=true --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
METL=--logging.level.org.hibernate.session.metrics=debug
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  if [ "${HL:-$L_H}" != "$L_X" ]; then echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; fi
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"; }
# hview: the harness JVM's log - its org.hibernate.SQL lines counted, not shown (the sql capture shows each text once); the
# session-metrics blocks of the context's own start (outside every step: each reads 0) counted, not shown; tabs as four spaces
hview() { awk '/^PROBE >>> / { s = 1 } /^PROBE <<< / { s = 0 }
    / org\.hibernate\.SQL : / { q++; next }
    / org\.hibernate\.session\.metrics : HHH000401: / && !s { k = 1; d++; next }
    k && (/^\t/ || /^$/) { next }
    { k = 0 } /^$/ { next }
    { gsub(/\t/, "    "); sub(/[ \t]+$/, ""); print "  " $0 }
    END { print "  its org.hibernate.SQL lines (counted, not shown): " q + 0 " · session-metrics blocks outside the steps (the context'"'"'s own start, counted, not shown): " d + 0 }' .harness/h.log
  echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-13s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-13s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-13s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# ---- TiffinBox: started from its tree, readiness polled, asked, stopped by its pid ---------------------------------------------
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing})"
  echo "  secrets/ before the start: $s (mode $(stat -f '%Lp' "$1/secrets/$s")) - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { [ "$(listeners "$2")" = 0 ] || die "something listens on $2 before the start"; sec "$(dir "$1")"; echo "\$ $1"; : > .harness/run.out; (eval "$(exe "$1")") >> .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
up() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$pid"); case " $a " in *":$1 "*) break ;; esac; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":$1 "*) ;; *) tail -20 .harness/run.out >&3; die "it never listened on $1" ;; esac
  echo "  listens on: $a"; echo "  Boot's first line: $(first .harness/run.out)"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"; echo "  GET /actuator/health/readiness -> 200"; }
LASTE=""
stopit() { local i=0 e=0; kill "$pid" 2> /dev/null || true
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill -9 "$pid"; die "the server on $1 was still running after its SIGTERM"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; echo "  stopped by its pid (SIGTERM): exit $LASTE · listening on $1 now: 0"; }
logtok() { local t; t=$(raw "$TOKEN" .harness/run.out); LOGS=$((LOGS + 1)); genw .harness/run.out; [ "$t" = 0 ] || die "a TiffinBox log held the token ($t)"; echo "  its log: the token 0 times"; }
lines() { wc -l < .harness/run.out | tr -d ' '; }
settle() { local a b i=0; a=$(lines); while [ $i -lt 20 ]; do sleep 0.25; b=$(lines); [ "$a" = "$b" ] && break; a=$b; i=$((i + 1)); done; }
# ---- the requests: each between two markers this script appends to the JVM's log (opened for append), read per request -----
U30M=U30MARK
mark() { printf '%s %s\n' "$U30M" "$1" >> .harness/run.out; }
seg() { awk -v a="$U30M $1 start" -v b="$U30M $1 end" '$0 == a { f = 1; next } $0 == b { f = 0 } f' .harness/run.out; }
# rq LABEL PATH ACCEPT PORT: one GET - its status, then (by its kind) the HTML table, the JSON's counts or the list's length, and
# its own log lines between its markers, summarised by harness/seg30.py
rq() { local l=$1 p=$4 code
  mark "$l start"; echo "\$ curl -s --noproxy '*' -H 'Accept: $3' http://127.0.0.1:$p$2"
  code=$(curl -s --noproxy '*' -o .harness/body-$l -w '%{http_code}' -H "Accept: $3" "http://127.0.0.1:$p$2" 2> /dev/null || true)
  settle; mark "$l end"; seg "$l" > .harness/seg-$l.log
  case $l in
    list) echo "  -> $code · entries parsed (python3 -I): $(python3 -I -c 'import json,sys; print(len(json.load(open(sys.argv[1]))))' .harness/body-$l 2> /dev/null || echo 'no answer')" ;;
    *) echo "  -> $code" ;; esac
  python3 -I -B harness/seg30.py .harness/seg-$l.log
  case $l in
    html) python3 -I -B harness/chk30.py table .harness/body-$l || echo "  the table: not parsed" ;;
    json) echo "  the JSON (python3 -I): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print("customers %d · names %d" % (d["customers"], len(d["names"])))' .harness/body-$l 2> /dev/null || echo 'no answer')" ;; esac; }
# imp PORT: the import - unit 20's generator writes the file (-Dn's N lines and a header), POST /customers/import sends it
imp() { local p=$1 code c N=$NIMP
  echo "\$ N=$NIMP; $L_CSV"; eval "$L_CSV" || die "the import's file was not written"
  echo "  the generated file: .harness/import.csv - a header and $(($(wc -l < .harness/import.csv) - 1)) lines (wc -l: $(wc -l < .harness/import.csv | tr -d ' '))"
  c=${L_IMP/20090/$p}; mark "import start"; echo "\$ $c"
  code=$(curl -s --noproxy '*' -o .harness/body-import -w '%{http_code}' -F 'file=@.harness/import.csv;type=text/csv' "http://127.0.0.1:$p/customers/import" 2> /dev/null || true)
  settle; mark "import end"; seg import > .harness/seg-import.log
  echo "  -> $code $(cut -c1-200 .harness/body-import)"; python3 -I -B harness/seg30.py .harness/seg-import.log; }
# second DB: the second connection - H2's own Shell over TCP, the same database, run by this script while TiffinBox still runs
second() { local DB=$1 Q f
  echo "the second connection (H2's Shell over TCP, mem:$DB):"
  for Q in "$Q_C" "$Q_P" "$Q_S"; do echo "\$ Q=\"$Q\"; $L_SHELL" | sed "s#\\\$DB#$DB#"
    (eval "$L_SHELL") > .harness/second.txt 2>&1 < /dev/null || die "the second connection failed: $(head -3 .harness/second.txt)"
    sed -E 's/[[:space:]]+$//; s/^/  /' .harness/second.txt; done; }
NIMP=36                                               # the generator's N - the import's lines, the harness's -Dn (the second point: 6)
# ---- the captures --------------------------------------------------------------------------------------------------------
RO='the page: findAll(Sort.by("name")), then every customer'"'"'s pauses - in a read-only transaction'
count() { local n
  echo "count - the page's read at two N, one harness JVM each over the anchor's libraries, then the session-metrics JVM:"
  for n in $NIMP 6; do echo "the page at -Dn=$n:"; V=(-Ds=count -Dn=$n); A=("${HA[@]}"); hrun; hview; done
  echo "the session metrics at -Dn=$NIMP (org.hibernate.session.metrics at DEBUG, a run option): the read-only read, then the control (labelled, read-write):"
  V=(-Ds=metrics -Dn=$NIMP); A=("${HA[@]}" $METL); hrun; hview; }
page() { local f t p d
  for f in anchor:20090:u30p:page anchor2:20091:u30p2:A2; do t=${f%%:*}; p=$(echo "$f" | cut -d: -f2); d=$(echo "$f" | cut -d: -f3)
    echo "${f##*:} - TiffinBox on .harness/$t ($( [ $t = anchor ] && echo "the anchor's jar" || echo "the anchor copied again and built again")), port $p, its database mem:$d on the H2 server:"
    start "$(tb $t $p $d)" $p; up $p; ready $p
    imp $p; rq html /dashboard text/html $p; rq json /dashboard application/json $p; rq list /customers application/json $p
    second $d; stopit $p; logtok; rm -f .harness/run.out; done; }
inverse() { local n
  echo "inverse - every pause, then its customer's name, at two N:"
  for n in $NIMP 6; do echo "the inverse at -Dn=$n:"; V=(-Ds=inverse -Dn=$n); A=("${HA[@]}"); hrun; hview; done; }
PROJ=nested
nested() { local n
  echo "nested - the nested projection WithPauses (the projections lesson's), at two N:"
  for n in $NIMP 6; do echo "the nested at -Dn=$n:"; V=(-Ds=nested -Dn=$n -Dproj=$PROJ); A=("${HA[@]}"); hrun; hview; done; }
sqlt() { echo "sql - the page's statements at -Dn=$NIMP, read off Hibernate's SQL logger: each text once, in the order it first appears, with how many times it was sent:"
  V=(-Ds=count -Dn=$NIMP); A=("${HA[@]}"); hrun
  $G '^PROBE generated ' .harness/h.log | sed 's/^/  /'
  sed -n 's/^DEBUG \[main\] org\.hibernate\.SQL : //p' .harness/h.log | awk '{ if (!($0 in c)) o[++n] = $0; c[$0]++ } END { for (i = 1; i <= n; i++) print "  " c[o[i]] " x " o[i] }'
  echo "  exit $HE"; }
X29=9cf92b8cae3abfd0f1c0706bfe7a4373                # Boot's script since unit 27's C2 - ../c7-unit29/xcheck.sql; no mapping moves in 30
[ "$(md5 -q xcheck.sql)" = "$X29" ] && cmp -s xcheck.sql ../c7-unit29/xcheck.sql || die "xcheck.sql is not ../c7-unit29/xcheck.sql (md5 $X29)"
XA=('--spring.datasource.url=jdbc:h2:mem:x30;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL over the anchor's libraries - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql; A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script over the anchor's libraries"
  mv .harness/run/hibernate-ddl.sql .harness/ddl-anchor.sql
  echo "  .harness/ddl-anchor.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-anchor.sql
  echo "  its md5: $(md5 -q .harness/ddl-anchor.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-anchor.sql xcheck.sql && echo 'the same, byte for byte' || echo differ) · the lazy-loading lesson's xcheck.sql: $(cmp -s .harness/ddl-anchor.sql ../c7-unit29/xcheck.sql && echo 'the same, byte for byte' || echo differ)"; }
# ---- exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1200 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 300 s"; }
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
  printf '%s\n' "$setup" | $G -qF -- '"${A[@]}"' && printf '%s\n' "$setup" | $G -qE '^A=\(' || die "exercise/README.md must pass its arguments as an array, A (R.164, R.193)"
  printf '%s\n' "$setup" | $G -E ' java ' | $G -qF "perl -e 'alarm " || die "exercise/README.md's JVM must run under its alarm (R.247)"
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
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# ---- the checks: every number and string the video says, read off its capture -------------------------------------------------
SC=Statistics.getPrepareStatementCount               # the statement counter (S5.1): the one unit 39 asserts
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk30.py "$@" --counter "$SC") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk30.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  has "$XC" "  its md5: $X29 · the filed xcheck.sql: $X29 · cmp: the same, byte for byte · the lazy-loading lesson's xcheck.sql: the same, byte for byte" "xcheck: the anchor's script = unit 29's, byte for byte (no mapping moved)"
  [ "$(cnt "$XC" '  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final')" = 1 ] || die "xcheck: HHH000001"
  echo "  xcheck: the anchor's script $X29 = xcheck.sql = ../c7-unit29/xcheck.sql"; VALS="$VALS · xcheck: $X29"; }
EXQ="Your turn: the README prints the page's query count, and it stays the same however many customers there are. Print the count that grows."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
chk_exercise() { local EB EZ b ER ES w x
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    has "$ER" '    the JVM: exit 0' "exercise: the README runs"; has "$ES" '    the JVM: exit 0' "exercise: the solution runs"
    x=$(python3 -I -c '
import re, sys
def pts(t): return [(int(a), int(b)) for a, b in re.findall(r"^    PROBE diners (\d+) · the page.s count: (\d+)$", t, re.M)]
br, so = pts(sys.argv[1]), pts(sys.argv[2])
ok = len(br) == 2 and len(so) == 2 and [d for d, _ in br] == [d for d, _ in so] and br[0][0] != br[1][0]
ok = ok and br[0][1] == br[1][1] and all(c == 1 + d for d, c in so) and br != so
print(("PASS" if ok else "FAIL") + " the README: " + " · ".join("%d diners %d" % p for p in br) + "; the solution: " + " · ".join("%d diners %d" % p for p in so))' "$ER" "$ES")
    case $x in PASS*) ;; *) die "exercise: the broken count the same at both N, the solution's 1 + the diners at both, the two differ (R.196): $x" ;; esac
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  [ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "exercise: broken and solved print the same (R.196)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" = 24 ] || die "exercise: the spoken line is the brief's 24 words: $EXW"
  x=${x#PASS }
  echo "  exercise: bash and zsh alike - $x; each file's What it prints = the run, the two md5s differ; $EXW words"
  VALS="$VALS · exercise: $x ($EXW words)"; }
cap count count; chk count count .r-count.out --ro "$RO"; pub count
cap page page; chk page page .r-page.out; pub page
cap inverse inverse; chk inverse inverse .r-inverse.out; pub inverse
cap nested nested; chk nested nested .r-nested.out; pub nested
cap sql sqlt; chk sql sql .r-sql.out; pub sql
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# R.302: every line of README.md's ```text blocks is a line a run printed - a capture's or a check's (leading spaces aside)
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
# the versions, once per harness JVM in every capture that ran one (chk30's jvm() asserts each line in count, inverse and nested)
VS="the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - $VALS · pinned.txt: $PIN"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"
# hygiene: every capture and every file this unit holds - 0 raw tokens
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 pinned.txt .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the token, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] || die "no JVM ran"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]|virtual-[0-9]|started on [A-Z]' "$f" || die "$f holds a log time, a timestamp, a thread number or a context's start date"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'SessionImpl\([0-9]|scanning in [0-9]+ ms|Lambda/0x' "$f" || die "$f holds an EntityManager's identity, a lambda's address or a scan time, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b|[0-9] ns ' "$f" || die "$f holds a millisecond or nanosecond figure (R.207, S5.2)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:2009[01]' || die "$f holds a URL (only TiffinBox's own loopback ports 20090-20091 may appear)"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.v' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep' harness/src || die "a harness sleeps (S4.18)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw token copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond or nanosecond figure, thread number, OS token, unmasked identity, URL or stack frame in any capture; every JVM pinned and under its alarm; no kill by name; no bare wait; no sleep in the harness; no H2 file"
# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
if [ -n "$spid" ] && kill "$spid" 2> /dev/null; then wait "$spid" 2> /dev/null || true; fi; spid=""
anchortree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 20090-20099 at the end - TiffinBox bound 20090-20091 and stopped, the H2 server 20098 and stopped; 20092-20097 and 20099 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit30: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens; no port bound but 20090, 20091 and 20098"
