#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Batching and the Write Path - this unit's receipts. Section 5's fifth unit; no change to the anchor (brief flag 1): anchor
# is the link to ../c7-unit31/after (= ../c7-tiffinbox at unit 31's commit; units 32 and 33 build over it, unit 34 moves the anchor
# next). Hibernate sends many INSERTs as one JDBC batch when it knows the ids before it inserts; an identity column hands out the id
# only at the INSERT, so those inserts never batch - TiffinBox's ids are its identity columns'. Nine captures, each run three times and
# hashed; a hash that differs from receipts.md5 stops the run; every number and string the video says is asserted right after its
# capture by a check that can fail, against another witness of the same run (harness/chk33.py) - never against a typed figure. Two
# databases (brief flag 7): H2 2.5.250 in the harness JVM's memory, and PostgreSQL 18.6 - ONE container per run, from the pinned
# image, on 127.0.0.1:20128, a fresh database per JVM. TiffinBox itself runs on H2 only (the anchor capture).
#   batch     N = 200 persists in one transaction - the IDENTITY entity, the SEQUENCE entity, the anchor's CustomerEntity - without a
#             batch size, then with hibernate.jdbc.batch_size=50 (and Spring Data's saveAll); the batch logger at TRACE; both databases
#             (the failure receipt: the anchor's entity, executeBatch 0)
#   order     100 customers each persisted with one pause, alternately, batch 50: without hibernate.order_inserts, then with it; both
#   updates   104 CustomerEntity rows edited in one transaction: batch 50, no batch size, batch 50 + batch_versioned_data=false; the
#             grep -a over the unpacked hibernate-core jar for the keys (S5.10); both databases
#   chunk     1,000 persists in one transaction, then the same with flush() + clear() every 50 - the persistence context counted; H2
#   flush     one unit of work called remove, remove, edit, persist, persist - the SQL read off the logger at the commit; both
#   time      the cost, a fixed design (S2 flag 5, R.207, R.236, R.300): N 1,000 persists per run, W 10 warm-up rounds, R 9 timed, four
#             runs per round (SEQUENCE batch 1 / 50, IDENTITY batch 1 / 50) in an order reversed every other round; TJ JVMs per
#             database per run of the capture, H2 and PostgreSQL in turn - its three runs hold 3 x TJ per database; the medians and
#             ratios masked, PostgreSQL's threshold line hashed, every JVM's ratios tabled (.r-time.table, not hashed)
#   anchor    the labelled copy (brief flag 5): the anchor on SEQUENCE by harness/derive33.py, its tests, its DDL; TiffinBox from it on
#             20120 over H2 TCP (20127): the import of 36 lines with the batch logger at TRACE, the ids on the second connection, the
#             seven; then the anchor itself with hibernate.jdbc.batch_size=50 as a run option: the same import
#   xcheck    Hibernate's DDL script over the anchor's libraries = ../c7-unit32/xcheck.sql (no mapping moved)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# The anchor is COPIED under .harness/anchor and built there, never in place, with its README's package line, offline; its jar is
# extracted and the harness (harness/src, packages probe.b and probe.x, outside com.tiffinbox) is compiled once with javac
# -parameters against its libraries. The labelled copy is .harness/copy-seq. Every JVM runs under an alarm (perl -e 'alarm N; exec
# ...'); an alarm that fires is a failed receipt (R.247). Ports (§P, 20120-20129): 20120 TiffinBox (the copy, then the anchor, in
# turn) · 20127 the H2 TCP server · 20128 the container; 20121-20126 and 20129 never bound; the harness JVMs bind none. Nothing
# leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u33-pg
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# harness JVM or TiffinBox), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process
# under it), $spid (the H2 TCP server); then sweep(): anything of this run still alive in its process group is stopped; then the
# container, if this script created it (CSTARTED), is removed (docker rm -f, pgrm). After an interrupt a capture's unfinished runs
# (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C; the script exits 130 after an
# interrupt. No wait is bare.
pid=""; mpid=""; xpid=""; spid=""; CSTARTED=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.b.") || index($0, "probe.x.") || index($0, "org.h2.tools.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "curlset.sh") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "docker exec c7u33-pg") || index($0, "docker run -d --pull never --name c7u33-pg")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
# pgrm: docker rm -f, again until docker ps -a names it no more (at least three tries, 0.5 apart, at most 20): a docker run cut by
# an interrupt can register its container a moment after the first rm (unit 28's form)
pgrm() { local i=0; [ -n "$CSTARTED" ] || return 0
  while [ $i -lt 20 ]; do docker rm -f "$CN" > /dev/null 2>&1 || true
    [ $i -ge 2 ] && [ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] && break
    sleep 0.5; i=$((i + 1)); done; CSTARTED=""; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid" "$spid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find curl unzip docker /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - the password and the token live under .harness/ only"
# ---- the anchor: unit 31's after/, through a link; frozen (its tree's hash pinned); ../c7-tiffinbox equals it until unit 34 ----
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit31/after ] || die "anchor must be the link to ../c7-unit31/after - this unit changes nothing in it"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
T31='43 e6b36271a68a44e785adb24583ae51fb'            # unit 31's after/ at its commit 4e6e7c9: 43 files (harness/tree33.py)
anchortree() { local t; t=$(python3 -I harness/tree33.py anchor/) || die "the anchor's tree could not be hashed"
  [ "$t" = "$T31" ] || die "R.211: anchor/ (../c7-unit31/after, a shipped unit's frozen tree) is not the tree this unit measured: $t, pinned $T31"
  echo "  the anchor's tree ($1): python3 -I harness/tree33.py anchor/ -> $t = pinned (unit 31's after/, frozen)"; }
# R.211: anchor/ equals ../c7-tiffinbox until a later unit changes the anchor (unit 34) - a note then, never a stop
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit31/after - a later anchor change has moved ../c7-tiffinbox on; no anchor change in this unit"; fi; }
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchortree start; anchornote start
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
HS=harness/src/probe/b
HFILES='chk33.py csv33.py derive33.py dur7.py logback.xml s33.py src tree33.py'
SFILES='probe/b/H.java probe/b/Main.java probe/b/Run.java probe/b/Seed.java probe/b/SqlCounter.java probe/b/Time.java probe/b/ent/WCustomer.java probe/b/ent/WPause.java probe/b/ent/XIdent.java probe/b/ent/XSeq.java probe/b/ex/ExApp.java probe/b/repo/XSeqRepo.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql pinned.txt; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not unit 29's, byte for byte"
cmp -s harness/tree33.py ../c7-unit31/harness/tree31.py && cmp -s harness/csv33.py ../c7-unit31/harness/csv31.py || die "harness/tree33.py and csv33.py are unit 31's tree31.py and csv31.py, byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="20120 20121 20122 20123 20124 20125 20126 20127 20128 20129"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
docker image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - docker pull it once (this script never pulls)"
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it yourself: docker rm -f $CN"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets
echo "  the image: $IMG is on this machine (docker image inspect, the full digest; never pulled)"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
# R.252 first (s33.py reads pinned.txt): the pinned sentence, byte-equal - pinned.txt hashed here, its line whole in README.md
PIN=67907942ffce51fcc9286b29acf3be67
[ "$(md5 -q pinned.txt)" = "$PIN" ] || die "R.252: pinned.txt is not the pinned text (md5 $(md5 -q pinned.txt), pinned $PIN) - Course 14's Chunk-Oriented Processing diffs against it"
[ "$(wc -l < pinned.txt | tr -d ' ')" = 1 ] || die "R.252: pinned.txt holds one line"
while IFS= read -r l; do $G -qxF -- "$l" README.md || die "R.252: README.md does not hold the pinned line, whole: $l"; done < pinned.txt
echo "  R.252: pinned.txt md5 $PIN (1 line), the line whole in README.md"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 (dur7, "faster"/"slower" only beside PostgreSQL's threshold line) + S4.7 (R.264) + R.301 (S5.18, BLUE's tm.py) + R.287 +
# R.190 + R.224, carried; S5.9 (R.292), S5.10 (R.293), R.206, R.207, R.302 and the SQL order, this unit's - per sentence, harness/s33.py
DW=$(python3 -I -B harness/s33.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose (R.172, S4.7, R.301, R.287, R.190, R.224, S5.9, S5.10, R.206, R.207, R.302, the flush order): $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s33, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): dur7 words 0 but \"faster\" beside PostgreSQL's threshold line, on this Mac · S4.7's family 0 · R.301's family 0 but beside the threshold line or a printed count · R.287 old wordings 0 · R.190 the tests as a witness 0 · R.224 a call-back without its title 0 · S5.9 a duration word or a verdict on H2 0 · S5.10 batch_versioned_data credited 0 · R.206 IDENTITY said to batch, the SQL log as a batch witness 0 · R.207 a spoken median 0 · R.302 a ratio or a count typed 0 · the flush order said in call order 0 - over README.md and exercise/"
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
# R.225: a SQL string this unit shows is the logger's - outside the values block, the table and the text blocks a run printed, none
SQLRE='insert into x_|insert into w_|insert into customer|update customer set|update w_customer|delete from w_|select next value for|nextval\(|where id=\? and version=\?|values \(\?'
prose() { awk -v f="$1" '/^<!-- (values|time-table): begin -->$/ { v = 1; next } /^<!-- (values|time-table): end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print f ":" NR ": " $0 }' "$1"; }
TS=$(for f in $PROSE; do prose "$f"; done | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in the prose (R.225): $TS"
echo "  typed SQL strings: 0 in README.md and exercise/ outside the values block, the time table and the blocks the runs printed"
# R.302 (S5.19): the ratios, the medians, the counts the video says and the md5s the runs print are printed by the run, typed nowhere
# - not in the prose (fenced blocks, the values block and the time table hold what the runs print), not in this script or the harness
TNRE='(^|[^0-9A-Za-z.])[0-9]{1,2}\.[0-9][0-9]([^0-9.]|$)|\b(addBatch|executeBatch|executeUpdate|prepareStatement|getPrepareStatementCount|getEntityCount\(\)) [0-9]+|\b[0-9]+ (statements|SQL lines|batches|transactions|batch lines)\b|\b[0-9]+ / [0-9]+ / [0-9]+\b|\b[0-9]+/[0-9]+/[0-9]+\b|e501''fad0|466c''20ed'
TN=$(for f in $PROSE; do prose "$f"; done | $G -E "$TNRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TN" ] || die "R.302: a count, a ratio or a printed md5 typed in the prose, outside a block a run printed, the values block and the time table: $TN"
TC=$($G -nE '10\.68|11\.44|11\.13|e501''fad0|466c''20ed|1/51/''101/151' receipts.sh harness/chk33.py harness/src/probe/b/*.java harness/src/probe/b/*/*.java 2> /dev/null | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a probe's figure or a printed md5 typed in this script or the harness: $TC"
echo "  R.302: the counts, ratios, medians and the copy's md5s typed 0 times in the prose (outside printed blocks, the values block and the time table), in receipts.sh, chk33.py and the harness's sources (s33.py's self-test aside: its refused cases are the plants' sentences)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
HSRC="$HS/H.java $HS/Main.java $HS/Run.java $HS/Seed.java $HS/SqlCounter.java $HS/Time.java $HS/ent/WCustomer.java $HS/ent/WPause.java $HS/ent/XIdent.java $HS/ent/XSeq.java $HS/repo/XSeqRepo.java harness/src/probe/x/XMain.java"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HSRC")
L_VERIFY=$(mine 'mvn -B clean verify')
L_DERIVE=$(mine 'python3 -I harness/derive33.py .harness/copy-seq')
L_UNZIP=$(mine "unzip -q -o .harness/anchor/$XD/lib/hibernate-core-7.4.13.Final.jar -d .harness/hibernate-core")
L_GREPA=$(mine 'grep -a -r -l -F "$K" .harness/hibernate-core')
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*:../../.m2-demo/$PGJ\" probe.b.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../\$T/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_H2S=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java $JL -Dh2.bindAddress=127.0.0.1 -cp \"../anchor/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Server -tcp -tcpPort 20127 -ifNotExists")
L_SHELL=$(mine "cd .harness/run && $AL java $JL -cp \"../anchor/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Shell -url \"jdbc:h2:tcp://127.0.0.1:20127/mem:\$DB\" -user sa -password '' -sql \"\$Q\"")
L_CSV=$(mine 'python3 -I harness/csv33.py "$N" > .harness/import.csv')
L_IMP=$(mine "curl -s --noproxy '*' -F 'file=@.harness/import.csv;type=text/csv' http://127.0.0.1:20120/customers/import")
L_RUN=$(mine "docker run -d --pull never --name $CN -p 127.0.0.1:20128:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# tb TREE DB [more]: the README's run line on TREE, port 20120, TiffinBox's database on the H2 server (mem:DB), sa (unit 29's step:
# without it Boot treats the TCP URL as not embedded and the start fails), the SQL logger, the transaction manager's DEBUG lines and
# the batch logger at TRACE (run options) - quoted
TBL=(--spring.datasource.username=sa --logging.level.org.hibernate.SQL=debug --logging.level.org.springframework.orm.jpa.JpaTransactionManager=debug --logging.level.org.hibernate.orm.jdbc.batch=trace)
tb() { local t=$1 d=$2 a x; shift 2; a="'--tiffinbox.jdbc-url=jdbc:h2:tcp://127.0.0.1:20127/mem:$d;DB_CLOSE_DELAY=-1'"
  for x in "${TBL[@]}" "$@"; do a="$a $x"; done; printf '%s %s\n' "$(at .harness/$t 20120 "$R_RUN")" "$a"; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
[ "$(off .harness/copy-seq "$L_VERIFY")" = 'cd .harness/copy-seq && mvn -o -B -Dmaven.repo.local="$M2" clean verify' ] || die "off(): the copy's build line is not README.md's verify line, offline"
[ "$(exe "$(at .harness/anchor 20120 "$R_RUN")")" = "cd .harness/anchor && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20120" ] || die "at(): the run line is not the README's"
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
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy anchor .harness/anchor
mbuild "$(off .harness/anchor "$R_PLAIN" package) -DskipTests" .harness/build-anchor.log ".harness/anchor (anchor/, the README's package line, -DskipTests: its tests are unit 31's)"
copy anchor .harness/copy-seq
(eval "$L_DERIVE") > .harness/derive.log 2>&1 < /dev/null || die "harness/derive33.py failed: $(tail -3 .harness/derive.log)"
mbuild "$(off .harness/copy-seq "$L_VERIFY")" .harness/build-copy.log ".harness/copy-seq (the labelled copy: anchor/ copied, harness/derive33.py, README.md's verify line - its tests run, a guard)"
for t in anchor copy-seq; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar "$PGJ"; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
[ ! -e .harness/anchor/$XD/lib/postgresql-42.7.14.jar ] || die "the anchor's lib/ holds the PostgreSQL driver - it never did; the harness takes it from .m2-demo"
cmp -s .harness/anchor/$XD/lib/hibernate-core-7.4.13.Final.jar "$M2/org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar" || die "the anchor's hibernate-core jar is not .m2-demo's"
for t in anchor copy-seq; do (cd .harness/$t && eval "$R_TOKEN") || die "the token was not written in $t"; done
TOKEN=$(head -n 1 .harness/anchor/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
(umask 077 && cp .harness/anchor/$TF .harness/copy-seq/$TF)
for t in anchor copy-seq; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
echo "  the token: generated once (openssl rand -hex 16, the README's line, in .harness/anchor), copied into .harness/copy-seq's $TF, mode 0600, never printed"
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/b/ex ] || die "the exercise's class compiled into the wrong place"
echo "  extracted two jars ($(for t in anchor copy-seq; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: the anchor / the copy); the harness compiled once - .harness/hc against the anchor's libraries alone; the PostgreSQL driver: .m2-demo/$PGJ (md5 $(md5 -q "$M2/$PGJ"))"
# the H2 TCP server: one JVM for this run, loopback only, TiffinBox's databases on it (mem:NAME), the second connection its Shell
echo "\$ $L_H2S" >&3
(eval "$L_H2S") > .harness/h2server.log 2>&1 < /dev/null & spid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20127)" = 0 ]; do kill -0 "$spid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20127)" = 1 ] || { cat .harness/h2server.log >&3; die "the H2 server never listened on 20127"; }
[ "$(lsof -nP -a -p "$spid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20127' ] || die "the H2 server must listen on 127.0.0.1:20127 alone"
H2SL=$($G -m1 'TCP server running at' .harness/h2server.log || true); [ "$H2SL" = 'TCP server running at tcp://localhost:20127 (only local connections)' ] || die "the H2 server's line: ${H2SL:-none}"
echo "  the H2 server: $H2SL - listens on 127.0.0.1:20127 alone"

# ---- the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214) ------------
# CSTARTED is set before docker run, so an interrupt during its start removes it too
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(docker port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20128' ] || die "docker port: the container must publish 5432 on 127.0.0.1:20128 alone: $DP"
[ "$(listeners 20128)" -ge 1 ] || die "nothing listens on 20128 after the container started"
echo "  the container: $CN from $IMG (--pull never); docker port: $DP; user sa, the password generated into .harness/secrets/pgpw (24 characters, mode 0600, never printed); pg_isready after $i tries (cap 120)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0; PGJVM=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v t="$TOKEN" -v pw="$PW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); W = lit(pw); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the token]"); gsub(W, "<pw>"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/SessionImpl\([0-9]+</, "SessionImpl(<n><")
    gsub(/\$\$Lambda\/0x[0-9a-f]+/, "$$Lambda/<n>")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"<time>\"")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/ \(20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)$/, "")
    gsub(/omcat-handler-[0-9]+/, "omcat-handler-<n>"); gsub(/ rows?, [0-9]+ ms\)/, " row(s))")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting Main using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 2 JPA repository interfaces.' "token $TOKEN" "url jdbc:postgresql://127.0.0.1:20128/u33time1?user=sa&password=$PW" 'JDBC [x.HibernateTransactionManager$$Lambda/0x000003ff01b8a310@5d9576a0]' 'JDBC driver H2 JDBC Driver 2.5.250 (2026-08-29)' '(1 row, 3 ms)' '(40 rows, 12 ms)' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting Main using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 2 JPA repository interfaces.' 'token [masked: the token]' 'url jdbc:postgresql://127.0.0.1:20128/u33time1?user=sa&password=<pw>' 'JDBC [x.HibernateTransactionManager$$Lambda/<n>@…]' 'JDBC driver H2 JDBC Driver 2.5.250' '(1 row(s))' '(40 row(s))')" ] || die "mask: the planted JDK version, folders (plain and %20-encoded), home, identity hash, EntityManager identity, scan time, the token, the password, a lambda class's address, H2's build date and the Shell's time must be masked"
echo "  mask: its self-test passed (the token, the password, folders, home, identities, times, H2's build date); raw password copies after mask: $(mask < .harness/p1 | $G -cF -- "$PW" || true)"
rm -f .harness/p1
HQ=(--logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.jpa.open-in-view=false --spring.jpa.properties.hibernate.generate_statistics=true --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
HA=('--spring.datasource.url=jdbc:h2:mem:u33;DB_CLOSE_DELAY=-1' "${HQ[@]}")
B50=--spring.jpa.properties.hibernate.jdbc.batch_size=50
OI=--spring.jpa.properties.hibernate.order_inserts=true
BVD=--spring.jpa.properties.hibernate.jdbc.batch_versioned_data=false
TRC=--logging.level.org.hibernate.orm.jdbc.batch=trace
TXD=--logging.level.org.springframework.orm.jpa.JpaTransactionManager=debug
SQW=--logging.level.org.hibernate.SQL=warn
HE=""
# hrun: one harness JVM, its stdout and stderr to .harness/h.log
hrun() { local c i=0 e=0 n
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  [ "${HL:-$L_H}" = "$L_X" ] || echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"
  [ "${HL:-$L_H}" != "$L_X" ] || echo "\$ T=$T"
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"
  case " ${V[*]:-} " in *" -Dpg.db="*) PGJVM=$((PGJVM + 1)); n=$(raw "$PW" .harness/h.log); [ "$n" = 0 ] || die "a harness log held the password, raw ($n)"; echo "  raw password copies in its log: $n (before the mask; the URL is printed cut before its ?)" ;; esac; }
# hview [sql]: the harness JVM's log - its org.hibernate.SQL lines counted, not shown (with "sql": shown, in the order sent); the
# batch logger's TRACE lines counted per step, never shown: "Adding to JDBC batch (n / 50)" (those at (1 / 50) and (50 / 50) apart),
# "Created JDBC batch", "Executing JDBC batch" - a summary line before each step's end marker; its WARN lines counted (R.302)
hview() { awk -v show="${1:-}" -v tr="$TRACING" '
    / org\.hibernate\.SQL : / { q++; if (show == "sql") { sub(/[ \t]+$/, ""); print "  " $0 }; next }
    / org\.hibernate\.orm\.jdbc\.batch : (Adding to|Created|Executing) JDBC batch/ {
      if ($0 ~ /Adding to JDBC batch/) { ad++; if ($0 ~ /\(1 \/ 50\)/) a1++; if ($0 ~ /\(50 \/ 50\)/) af++; if (fa == "") fa = substr($0, index($0, "Adding")) }
      else if ($0 ~ /Executing JDBC batch/) { ex++; if (fe == "") fe = substr($0, index($0, "Executing")) } else cr++
      next }
    /^PROBE <<< / && tr == 1 { print "  batch TRACE in this step (org.hibernate.orm.jdbc.batch, counted, not shown): Adding to JDBC batch " ad + 0 " (at (1 / 50): " a1 + 0 ", at (50 / 50): " af + 0 ") · Created JDBC batch " cr + 0 " · Executing JDBC batch " ex + 0 (fa != "" ? " · first: " fa : "") (fe != "" ? " · first: " fe : ""); ad = 0; a1 = 0; af = 0; ex = 0; cr = 0; fa = ""; fe = "" }
    /^$/ { next }
    { gsub(/\t/, "    "); sub(/[ \t]+$/, ""); print "  " $0 }
    END { print "  its org.hibernate.SQL lines" (show == "sql" ? " (shown above, in the order sent): " : " (counted, not shown here): ") q + 0 }' .harness/h.log
  echo "  its WARN lines (grep -c '^WARN '): $($G -c '^WARN ' .harness/h.log || true) · HHH100501 lines (grep -c): $($G -c 'HHH100501' .harness/h.log || true)"
  echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
# pgdb NAME: a fresh database for the next PostgreSQL JVM (dropped first, if a run left it)
pgdb() { local DB=$1; echo "\$ DB=$DB; $L_DB"; (eval "$L_DB") > .harness/pgdb.log 2>&1 < /dev/null || die "the fresh database $DB was not made: $(tail -2 .harness/pgdb.log)"
  echo "  a fresh database: $DB"; }
# h2 / pg SCEN TAG N [more V] -- [more A]: one harness JVM on H2 (this JVM's memory) or on the run's fresh PostgreSQL database u33TAG
TRACING=0; SHOW=""
vset() { V=(-Ds=$1 -DN=$2); shift 2; while [ $# -gt 0 ] && [ "$1" != -- ]; do V+=("$1"); shift; done; [ $# -gt 0 ] && shift; AX=("$@")
  TRACING=0; case " ${AX[*]:-} " in *" $TRC "*) TRACING=1 ;; esac; }
h2() { local s=$1 t=$2; shift 2; vset "$s" "$@"; A=("${HA[@]}" "${AX[@]}"); hrun; hview $SHOW; }
pg() { local s=$1 t=$2; shift 2; pgdb "u33$t"; vset "$s" "$@"; V+=(-Dpg.db=u33$t -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" "${AX[@]}"); hrun; hview $SHOW; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$PW" .harness/cap.raw > ".harness/rawpw-$nm.$i"
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
# ---- the captures --------------------------------------------------------------------------------------------------------
NB=200; NO=100; NU=100; NC=1000                       # the writes per step: batch, order, updates (generated beside the four), chunk
batch() { echo "batch - $NB persists per step in one transaction; the batch logger (org.hibernate.orm.jdbc.batch) at TRACE:"
  for d in h2 pg; do
    echo "on $( [ $d = h2 ] && echo 'H2 (in the harness JVM'"'"'s memory)' || echo 'PostgreSQL (the container, a fresh database)') - (i) no batch size:"
    $d batch batch0 $NB -- $TRC
    echo "the same, (ii) hibernate.jdbc.batch_size=50 (a run option, read back off the EntityManagerFactory):"
    $d batch batch50 $NB -- $TRC $B50; done; }
order() { echo "order - $NO customers, each persisted with one pause right after it, SEQUENCE ids, batch 50:"
  for d in h2 pg; do
    echo "on $( [ $d = h2 ] && echo H2 || echo PostgreSQL) - without hibernate.order_inserts:"; $d order order0 $NO -- $B50
    echo "the same with hibernate.order_inserts=true:"; $d order order1 $NO -- $B50 $OI; done; }
updates() { local K
  echo "updates - the anchor's CustomerEntity (versioned): $NU customers generated beside the four seeded, then every one edited in one transaction:"
  for d in h2 pg; do
    echo "on $( [ $d = h2 ] && echo H2 || echo PostgreSQL) - hibernate.jdbc.batch_size=50:"; $d updates upd50 $NU -- $B50
    echo "no batch size:"; $d updates upd0 $NU --
    echo "hibernate.jdbc.batch_size=50 and hibernate.jdbc.batch_versioned_data=false:"; $d updates updnv $NU -- $B50 $BVD; done
  echo "the keys, in Hibernate's own jar - hibernate-core-7.4.13.Final.jar (the anchor's lib/), unpacked, then grep -a over every file (S5.10):"
  echo "\$ $L_UNZIP"; rm -rf .harness/hibernate-core; (eval "$L_UNZIP") > .harness/unzip.log 2>&1 < /dev/null || die "the unzip failed: $(tail -2 .harness/unzip.log)"
  echo "  files unpacked: $(find .harness/hibernate-core -type f | wc -l | tr -d ' ')"
  for K in batch_versioned_data hibernate.jdbc.batch_size hibernate.order_inserts hibernate.order_updates; do
    echo "\$ K=$K; $L_GREPA"
    (eval "$L_GREPA") > .harness/grepa.txt 2> /dev/null || true
    echo "  files holding it: $(wc -l < .harness/grepa.txt | tr -d ' ')"
    sed 's#^\.harness/hibernate-core/#  #' .harness/grepa.txt | sort; done; }
chunk() { echo "chunk - $NC persists in one transaction, batch 50, on H2 (in the harness JVM's memory) - the persistence context counted:"
  h2 chunk chunk $NC -- $B50; }
flush() { echo "flush - the write path: one unit of work on w_customer / w_pause (SEQUENCE, a version on w_customer), the SQL logger shown, the transaction manager's DEBUG lines:"
  SHOW=sql
  echo "on H2:"; h2 flush flush 0 -- $TXD
  echo "on PostgreSQL:"; pg flush flush 0 -- $TXD
  SHOW=""; }
# ---- time: the cost, a fixed design -----------------------------------------------------------------------------------------
TW=10; TR=9; TN=1000; TJ=4; TT=5                     # warm-up rounds, timed rounds, persists per run, JVMs per database per capture run, T
thr() { awk -v r="$1" -v t="$2" 'BEGIN { print (r + 0 >= t + 0) ? "true" : "false" }'; }
time_() { local j d n r ri
  echo "time - the fixed design: N $TN persists per run in one transaction, W $TW warm-up rounds, R $TR timed, four runs per round in an order reversed every other round; $TJ JVMs per database, H2 and PostgreSQL in turn; org.hibernate.SQL at WARN; the medians and ratios masked here (.r-time.table holds them); PostgreSQL's threshold T = $TT:"
  echo "  (terminal only) time, capture run $CAPRUN of 3 - load average before: $(sysctl -n vm.loadavg)" >&3
  printf 'capture run %s - load average before: %s\n' "$CAPRUN" "$(sysctl -n vm.loadavg)" >> .harness/time-load
  for j in $(seq 1 $TJ); do for d in h2 pg; do n=H2; [ $d = h2 ] || n=PostgreSQL
    echo "on $n - JVM $j of $TJ:"
    if [ $d = h2 ]; then vset time $TN -DW=$TW -DR=$TR -- $SQW; A=("${HA[@]}" "${AX[@]}"); else pgdb "u33time$j"; vset time $TN -DW=$TW -DR=$TR -- $SQW; V+=(-Dpg.db=u33time$j -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" "${AX[@]}"); fi
    hrun
    awk '/^PROBE timed / { sub(/: \[.*\]$/, ": [<masked>]") }
         /^PROBE median \(ms\): / { gsub(/ [0-9]+\.[0-9]/, " <ms>") }
         /^PROBE ratio SEQUENCE / { gsub(/: [0-9]+\.[0-9][0-9]/, ": <ratio>") }
         /^$/ { next } { sub(/[[:space:]]+$/, ""); print "  " $0 }' .harness/h.log
    r=$(sed -n 's/^PROBE ratio SEQUENCE batch 1 \/ batch 50: \([0-9.]*\) · ratio IDENTITY batch 1 \/ batch 50: \([0-9.]*\)$/\1/p' .harness/h.log)
    ri=$(sed -n 's/^PROBE ratio SEQUENCE batch 1 \/ batch 50: \([0-9.]*\) · ratio IDENTITY batch 1 \/ batch 50: \([0-9.]*\)$/\2/p' .harness/h.log)
    [ -n "$r" ] && [ -n "$ri" ] || { r=none; ri=none; }
    printf '%s · capture run %s · JVM %s · %s · %s\n' "$n" "$CAPRUN" "$j" "$($G '^PROBE ratio SEQUENCE ' .harness/h.log | sed 's/^PROBE //')" "$($G '^PROBE median ' .harness/h.log | sed 's/^PROBE //')" >> .harness/time-table
    if [ $d = pg ]; then echo "  exit $HE · on PostgreSQL, JVM $j: SEQUENCE ratio >= $TT: $( [ "$r" = none ] && echo 'no ratio printed' || thr "$r" $TT)"
    else echo "  exit $HE · on H2, JVM $j: its ratios go to the table as numbers - no threshold on H2 (S5.9)"; fi; done; done
  echo "  (terminal only) time, capture run $CAPRUN of 3 - load average after: $(sysctl -n vm.loadavg)" >&3
  printf 'capture run %s - load average after: %s\n' "$CAPRUN" "$(sysctl -n vm.loadavg)" >> .harness/time-load; }
# ---- anchor: the labelled copy, and the anchor itself with the key as a run option ----------------------------------------------
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing})"
  echo "  secrets/ before the start: $s (mode $(stat -f '%Lp' "$1/secrets/$s")) - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { [ "$(listeners 20120)" = 0 ] || die "something listens on 20120 before the start"; sec "$(dir "$1")"; echo "\$ $1"; : > .harness/run.out; (eval "$(exe "$1")") >> .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
up() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$pid"); case " $a " in *":20120 "*) break ;; esac; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":20120 "*) ;; *) tail -20 .harness/run.out >&3; die "it never listened on 20120" ;; esac
  echo "  listens on: $a"; echo "  Boot's first line: $(first .harness/run.out)"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:20120/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on 20120"; echo "  GET /actuator/health/readiness -> 200"; }
LASTE=""
stopit() { local i=0 e=0; kill "$pid" 2> /dev/null || true
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill -9 "$pid"; die "the server on 20120 was still running after its SIGTERM"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners 20120)" = 0 ] || die "something still listens on 20120"; echo "  stopped by its pid (SIGTERM): exit $LASTE · listening on 20120 now: 0"; }
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on 20120 was still running after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners 20120)" = 0 ] || die "something still listens on 20120"; }
logtok() { local t; t=$(raw "$TOKEN" .harness/run.out); LOGS=$((LOGS + 1)); genw .harness/run.out; [ "$t" = 0 ] || die "a TiffinBox log held the token ($t)"; echo "  its log: the token 0 times"; }
lines() { wc -l < .harness/run.out | tr -d ' '; }
settle() { local a b i=0; a=$(lines); while [ $i -lt 20 ]; do sleep 0.25; b=$(lines); [ "$a" = "$b" ] && break; a=$b; i=$((i + 1)); done; }
U33M=U33MARK
mark() { printf '%s %s\n' "$U33M" "$1" >> .harness/run.out; }
seg() { awk -v a="$U33M $1 start" -v b="$U33M $1 end" '$0 == a { f = 1; next } $0 == b { f = 0 } f' .harness/run.out; }
# imp: the import - unit 20's generator writes the file (N lines and a header), POST /customers/import sends it; its own log lines
# between its markers, counted: the SQL logger's, the batch logger's "Adding to JDBC batch" (and those at (1 / 50)), the transaction
# manager's "Creating new transaction with name [com.tiffinbox.CustomerRepository.add]"
NIMP=36
imp() { local code N=$NIMP
  echo "\$ N=$NIMP; $L_CSV"; eval "$L_CSV" || die "the import's file was not written"
  echo "  the generated file: .harness/import.csv - a header and $(($(wc -l < .harness/import.csv) - 1)) lines (wc -l: $(wc -l < .harness/import.csv | tr -d ' '))"
  mark "import start"; echo "\$ $L_IMP"
  code=$(curl -s --noproxy '*' -o .harness/body-import -w '%{http_code}' -F 'file=@.harness/import.csv;type=text/csv' "http://127.0.0.1:20120/customers/import" 2> /dev/null || true)
  settle; mark "import end"; seg import > .harness/seg-import.log
  echo "  -> $code $(cut -c1-200 .harness/body-import)"
  echo "  between its markers: org.hibernate.SQL lines $($G -cE ' org\.hibernate\.SQL +: ' .harness/seg-import.log || true) (of them select nextval / next value: $($G -cE ' org\.hibernate\.SQL +: select (next value for|nextval)' .harness/seg-import.log || true)) · 'Adding to JDBC batch' $($G -c 'Adding to JDBC batch' .harness/seg-import.log || true) (at (1 / 50): $($G -cF 'Adding to JDBC batch (1 / 50)' .harness/seg-import.log || true)) · 'Executing JDBC batch' $($G -c 'Executing JDBC batch' .harness/seg-import.log || true) · 'Creating new transaction with name [com.tiffinbox.CustomerRepository.add]' $($G -cF 'Creating new transaction with name [com.tiffinbox.CustomerRepository.add]' .harness/seg-import.log || true) · WARN lines $($G -cE '^[^ ]+ +WARN ' .harness/seg-import.log || true) · ERROR lines $($G -cE '^[^ ]+ +ERROR ' .harness/seg-import.log || true)"
  echo "  its first 'Adding to JDBC batch' line (the message): $($G -m1 'Adding to JDBC batch' .harness/seg-import.log | sed 's/^.* : //' || true)"
  echo "  its first INSERT (the message): $($G -m1 -E ' org\.hibernate\.SQL +: insert into customer' .harness/seg-import.log | sed 's/^.* : //' || true)"; }
second() { local DB=$1 Q
  echo "the second connection (H2's Shell over TCP, mem:$DB):"
  for Q in 'select id, name from customer order by id' 'select id, customer_id, days from pause order by id'; do echo "\$ Q=\"$Q\"; $L_SHELL" | sed "s#\\\$DB#$DB#"
    (eval "$L_SHELL") > .harness/second.txt 2>&1 < /dev/null || die "the second connection failed: $(head -3 .harness/second.txt)"
    sed -E 's/[[:space:]]+$//; s/^/  /' .harness/second.txt; done; }
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  $G -vE '^@@' .harness/code.diff | sed 's/^/  /'; }
X31=9cf92b8cae3abfd0f1c0706bfe7a4373                # Hibernate's script since unit 27's C2 - ../c7-unit32/xcheck.sql; no mapping moves in 33
[ "$(md5 -q xcheck.sql)" = "$X31" ] && cmp -s xcheck.sql ../c7-unit32/xcheck.sql || die "xcheck.sql is not ../c7-unit32/xcheck.sql (md5 $X31)"
XA=('--spring.datasource.url=jdbc:h2:mem:x33;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
ddl() { T=$1; rm -f .harness/run/hibernate-ddl.sql; V=(); A=("${XA[@]}"); HL=$L_X; hrun; TRACING=0; hview; HL=""
  [ -f .harness/run/hibernate-ddl.sql ] || die "no DDL script over $1's libraries"
  mv .harness/run/hibernate-ddl.sql "$2"; }
anchor() { local f S
  echo "anchor - the labelled copy (brief flag 5): .harness/copy-seq = anchor/ copied, then python3 -I harness/derive33.py (TiffinBox keeps its identity column; this copy is never shipped):"
  sed 's/^/  /' .harness/derive.log
  echo "the copy against the anchor (diff -rq, the file names):"
  diff -rq -x target -x secrets anchor .harness/copy-seq | sed -E 's#^Files anchor/(.*) and \.harness/copy-seq/.* differ$#  \1#' | sort
  for f in $CJ/CustomerEntity.java $CJ/PauseEntity.java $CJ/Database.java tiffinbox-web/src/main/resources/application.yaml; do echo "$f:"; cdiff "anchor/$f" ".harness/copy-seq/$f"; done
  echo "its build (README.md's verify line, offline - a guard, R.190): Surefire's summary lines, summed: $($G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' .harness/build-copy.log | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/\1 \2 \3 \4/' | awk '{ a += $1; b += $2; c += $3; d += $4 } END { print "tests " a + 0 " · failures " b + 0 " · errors " c + 0 " · skipped " d + 0 }') · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/build-copy.log || echo 'no BUILD line')"
  echo "Hibernate's DDL script over the copy's libraries (probe.x.XMain, scripts.action=create, a file, never run):"
  ddl copy-seq .harness/ddl-copy.sql
  echo "  its md5: $(md5 -q .harness/ddl-copy.sql) · the anchor's (xcheck.sql): $(md5 -q xcheck.sql) · the lines that differ (diff xcheck.sql .harness/ddl-copy.sql):"
  diff xcheck.sql .harness/ddl-copy.sql | $G -E '^[<>]' | sed 's/^/    /' || true
  echo "  lines that differ: $(diff xcheck.sql .harness/ddl-copy.sql | $G -cE '^[<>]' || true)"
  echo "TiffinBox from the copy - port 20120, its database mem:u33c on the H2 server; the batch logger at TRACE:"
  start "$(tb copy-seq u33c)"; up; ready; imp; second u33c; stopit; logtok; rm -f .harness/run.out
  echo "the seven - the copy's jar, port 20120, a fresh JVM (TiffinBox's own in-memory database):"
  start "$(at .harness/copy-seq 20120 "$R_RUN")"; up; ready
  echo "\$ \$CURLSET 20120 .harness/copy-seq/$TF"
  "$CURLSET" 20120 ".harness/copy-seq/$TF" | $G ' -> ' > .harness/responses.txt || true
  awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-copy.txt
  gone
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-copy.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-copy.txt)"
  logtok; rm -f .harness/run.out
  echo "the anchor itself (TiffinBox's identity columns) with hibernate.jdbc.batch_size=50 as a run option - port 20120, its database mem:u33a on the H2 server; the batch logger at TRACE:"
  start "$(tb anchor u33a "$B50")"; up; ready; imp; stopit; logtok; rm -f .harness/run.out; }
xcheck() {
  echo "the harness's DDL over the anchor's libraries - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  ddl anchor .harness/ddl-anchor.sql
  echo "  .harness/ddl-anchor.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-anchor.sql
  echo "  its md5: $(md5 -q .harness/ddl-anchor.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-anchor.sql xcheck.sql && echo 'the same, byte for byte' || echo differ) · the second-level cache lesson's xcheck.sql: $(cmp -s .harness/ddl-anchor.sql ../c7-unit32/xcheck.sql && echo 'the same, byte for byte' || echo differ)"; }
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
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk33.py "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk33.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  has "$XC" "  its md5: $X31 · the filed xcheck.sql: $X31 · cmp: the same, byte for byte · the second-level cache lesson's xcheck.sql: the same, byte for byte" "xcheck: the anchor's script = unit 32's, byte for byte (no mapping moved)"
  [ "$(cnt "$XC" '  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final')" = 1 ] || die "xcheck: HHH000001"
  echo "  xcheck: the anchor's script $X31 = xcheck.sql = ../c7-unit32/xcheck.sql"; VALS="$VALS · xcheck: $X31"; }
EXQ="Your turn: the README saves customers with a pause each, and every insert goes in a batch of its own. Make the batches full."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
chk_exercise() { local EB EZ b ER ES w x
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    has "$ER" '    the JVM: exit 0' "exercise: the README runs"; has "$ES" '    the JVM: exit 0' "exercise: the solution runs"
    x=$(python3 -I -c '
import re, sys
def pts(t):
    k = re.findall(r"^    PROBE hibernate\.jdbc\.batch_size (\S+) · hibernate\.order_inserts (\S+)$", t, re.M)
    r = re.findall(r"^    PROBE rows read back: diner (\d+) · break_day (\d+)$", t, re.M)
    e = re.findall(r"^    PROBE executeBatch (\d+)$", t, re.M)
    return k, r, [int(v) for v in e]
(bk, br, be), (sk, sr, se) = pts(sys.argv[1]), pts(sys.argv[2])
ok = len(bk) == len(br) == len(be) == len(sk) == len(sr) == len(se) == 1
ok = ok and bk[0] == ("50", "null") and sk[0] == ("50", "true") and br[0] == sr[0] and int(br[0][0]) == int(br[0][1])
n = int(br[0][0]) if ok else 0
ok = ok and be[0] == 2 * n and se[0] == -(-2 * n // 50)
print(("PASS" if ok else "FAIL") + " the README: batch_size %s, order_inserts %s, %s diners and %s breaks, executeBatch %s (one per insert: 2 x %s); the solution: order_inserts %s, executeBatch %s (derived ceil(2 x %s / 50) = %s)" % (
    bk[0][0] if bk else "-", bk[0][1] if bk else "-", br[0][0] if br else "-", br[0][1] if br else "-", be[0] if be else "-", n,
    sk[0][1] if sk else "-", se[0] if se else "-", n, -(-2 * n // 50)))' "$ER" "$ES")
    case $x in PASS*) ;; *) die "exercise: the broken run one batch per insert, the solution full batches (R.196): $x" ;; esac
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
  echo "  exercise: bash and zsh alike - $x; each file's What it prints = the run, the two md5s differ; the spoken line $EXW words (wc -w)"
  VALS="$VALS · exercise: $x ($EXW words)"; }
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)        # the seven since unit 27, read off ../c7-unit31/receipts.sh (its seven capture): no route's JSON carries an id
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
cap batch batch; chk batch batch .r-batch.out; pub batch
cap order order; chk order order .r-order.out; pub order
cap updates updates; chk updates updates .r-updates.out; pub updates
cap chunk chunk; chk chunk chunk .r-chunk.out; pub chunk
cap flush flush; chk flush flush .r-flush.out; pub flush
: > .harness/time-table; : > .harness/time-load
cap time time_; cp .harness/time-table .r-time.table; cat .harness/time-load >> .r-time.table
chk time time .r-time.out .r-time.table "$TT" "$TJ"; pub time
cap anchor anchor; chk anchor anchor .r-anchor.out .r-batch.out "$S466"; pub anchor
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# R.236: README.md's table of the timing JVMs (the run of record's) - at least ten per database, every PostgreSQL SEQUENCE ratio at
# or above T, the margin line = the smallest PostgreSQL ratio minus T (chk33.py table, the same reading as this run's own table)
awk '/^<!-- time-table: begin -->$/ { f = 1; next } /^<!-- time-table: end -->$/ { f = 0 } f' README.md > .harness/readme-table.md
python3 -I -B harness/chk33.py table .harness/readme-table.md "$TT" > .harness/chk-table.out 2>&1 || { cat .harness/chk-table.out >&3; die "R.236: README.md's time table does not hold its threshold (above)"; }
sed 's/^/  README.md /' .harness/chk-table.out | $G -v '^  README.md VALUES ' || true
# R.302: every line of README.md's ```text blocks is a line a run printed - a capture's or a check's (leading spaces aside)
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
# R.303 / R.206: HHH100501, quoted once in README.md, is a line of the batch capture's keyed JVMs - never a witness
q='INFO  [main] org.hibernate.orm.jdbc.batch : HHH100501: Automatic JDBC statement batching enabled (maximum batch size 50)'
$G -qF -- "$q" .r-batch.out || die "HHH100501: the quoted line is not in the batch capture"
[ "$($G -cF -- "${q#*: }" README.md)" = 1 ] || die "HHH100501: README.md quotes it once"
echo "  HHH100501: quoted once in README.md, a line of the batch capture's keyed JVMs (its INFO line - never a batching witness, R.206)"
VS="the values the video may say: on H2 2.5.250 and PostgreSQL 18.6, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - $VALS · pinned.txt: $PIN"
printf '%s\n' "$VS" > .harness/values.txt
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"
# hygiene: every capture and every file this unit holds - 0 raw passwords, 0 tokens
for f in .harness/rawpw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the password ($f)"; done
for f in .r-*.out .r-time.table README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$PW" "$f")" = 0 ] && [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the password or the token, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGJVM" -gt 0 ] || die "no JVM ran, or none on PostgreSQL"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]|virtual-[0-9]|started on [A-Z]' "$f" || die "$f holds a log time, a timestamp, a thread number or a context's start date"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl|Debian|pgdg' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'SessionImpl\([0-9]|scanning in [0-9]+ ms|Lambda/0x' "$f" || die "$f holds an EntityManager's identity, a lambda's address or a scan time, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b|[0-9] ns |\(ms\): \[[0-9]|: [0-9]+\.[0-9][0-9]( |$)' "$f" || die "$f holds a millisecond figure or a ratio, unmasked (R.207)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'password=[^<]' "$f" || die "$f holds a password in a URL"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -vF 'http://127.0.0.1:20120' | $G -q . || die "$f holds a URL other than TiffinBox's own on 127.0.0.1:20120"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.b' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep|while *\(true\)|TimeUnit\.[A-Z]+\.sleep|LockSupport\.park' harness/src || die "a harness sleeps or polls (S4.18)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw password and token copies after mask: 0 in $(ls .harness/rawpw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs, $PGJVM of them on PostgreSQL); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, unmasked ratio, thread number, OS token, unmasked identity, password, URL but TiffinBox's own or stack frame in any capture; every JVM pinned and under its alarm; no kill by name; no bare wait; no sleep or polling loop in the harness; no H2 file"
# ---- the end: TiffinBox, the H2 server, the container, the anchor, the ports ------------------------------------------------------
kill "$spid" 2> /dev/null || true; i=0; while kill -0 "$spid" 2> /dev/null && [ $i -lt 40 ]; do sleep 0.25; i=$((i + 1)); done; wait "$spid" 2> /dev/null || true; spid=""
pgrm; [ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
anchortree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20120-20129 at the end - TiffinBox bound 20120 (the copy, then the anchor, in turn), the H2 server 20127, the container 20128; all stopped or removed; 20121-20126 and 20129 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit33: every capture 3/3 and = published; every spoken number asserted; 0 raw passwords; no port bound but 20120, 20127 and 20128"
