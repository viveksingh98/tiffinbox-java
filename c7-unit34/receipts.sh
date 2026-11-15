#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Reading the SQL Hibernate Writes - this unit's receipts. Section 5's sixth unit and its third and last change to the
# anchor (brief flag 1, C3): before is the link to ../c7-unit31/after (its tree's hash pinned), after/ is this unit's tree - Section 5's
# frozen anchor - and ../c7-tiffinbox equals after/ from this unit's commit on. Four ways to see what Hibernate sent - a print, a logger
# with its values, counters, and a driver that writes the finished statement - then one statement found slow on PostgreSQL, traced to
# a mapping that never asked for an index, and fixed in TiffinBox. Nine captures, each run three times and hashed; a hash that differs
# from receipts.md5 stops the run; every number and string the video says is asserted right after its capture by a check that can
# fail, against another witness of the same run (harness/chk34.py) - never against a typed figure. Two databases (brief flag 7): H2
# 2.5.250 in the harness JVM's memory, and PostgreSQL 18.6 - ONE container per run, from the pinned image, on 127.0.0.1:20138, a fresh
# database per JVM. TiffinBox itself runs on PostgreSQL for the anchor capture (RE-MEASURE 8) and on H2 over TCP for the seven.
#   ways      the one read - findByName("Sunil") and her pauses, in one transaction - six harness JVMs on H2: show-sql (the SQL logger at
#             WARN); show-sql with the SQL logger and every org.hibernate logger OFF (the OFF run, its level control); the SQL logger
#             and the bind logger; format_sql; highlight_sql; use_sql_comments - three witnesses per statement count beside each
#   spy       p6spy 3.9.1 as the driver: on H2 without Boot's user name (the failing start, filed), then with it; on PostgreSQL, the
#             password in spy.log counted before the mask and after it; the file deleted
#   dsproxy   datasource-proxy 1.11.1 around Boot's pool, on H2: its line for each statement; the BOM's lines for either tool
#   slow      the lookup of one customer's pauses by the foreign key, a fixed design (R.207, R.236, R.300): 2,000 generated customers
#             with 100 pauses each, M 50 lookups per half, W 5 + R 9 rounds, each round without and with the index - the index dropped
#             and created between the halves, the order reversed every other round; the index lists, the plan pair, the SQL_SLOW
#             lines at a configured hibernate.log_slow_query; TJ JVMs per database per capture run, H2 and PostgreSQL in turn; the
#             medians and ratios masked, PostgreSQL's threshold line hashed, every JVM's figures tabled (.r-slow.table, not hashed)
#   anchor    TiffinBox on PostgreSQL, B (before/, 20130), A (after/, 20131), A' (after/ copied and built again, 20132): each on a
#             fresh database, then the generator on a second connection, the indexes on pause from the catalogue, the plan of the
#             lazy collection's statement, GET /dashboard - its SQL lines between two markers (the failure receipt: B's seq scan)
#   seven     the comparison set on before/ and after/ (20133), TiffinBox's database on the H2 server: its md5, the SQL lines during it
#   tests     TiffinBox's tests on after/, offline, read from Surefire's reports
#   xcheck    Hibernate's DDL script over after/'s libraries (and over before/'s, beside it): moved by one line, the index
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# Every tree is COPIED under .harness/ (before, after, after2 for A', tests) and built there, never in place, with its README's
# package line, offline. The harness (harness/src, packages probe.q and probe.x, outside com.tiffinbox) is compiled once with javac
# -parameters against after/'s extracted libraries and the two tools' jars (harness/tools/pom.xml, resolved offline). Every JVM runs
# under an alarm (perl -e 'alarm N; exec ...'); an alarm that fires is a failed receipt (R.247). Ports (§P, 20130-20139): 20130 B ·
# 20131 A · 20132 A' · 20133 seven · 20137 the H2 TCP server · 20138 the container · 20134-20136 and 20139 never bound; the harness JVMs
# bind none. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u34-pg
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process under it), $spid (the
# H2 server); then sweep(): anything of this run still alive in its process group is stopped; then the container, if this script
# created it (CSTARTED), is removed (docker rm -f, pgrm); then spy.log, if a run left one. After an interrupt a capture's unfinished
# runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C; the script exits 130 after an
# interrupt. No wait is bare.
pid=""; tpid=""; mpid=""; xpid=""; spid=""; CSTARTED=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.q.") || index($0, "probe.x.") || index($0, "org.h2.tools.") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "curlset.sh") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "docker exec c7u34-pg") || index($0, "docker run -d --pull never --name c7u34-pg")) { print $1 }' | paste -sd' ' -) || l=""
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
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$tpid" "$mpid" "$xpid" "$spid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; rm -f .harness/run/spy.log; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find curl openssl docker git /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - the token and the password live under .harness/ only"
# ---- the trees: before/ is unit 31's after/, through a link, frozen (its tree's hash pinned); after/ is this unit's -------------
[ -L before ] && [ "$(readlink before)" = ../c7-unit31/after ] || die "before must be the link to ../c7-unit31/after - the anchor before this change"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
T31='43 e6b36271a68a44e785adb24583ae51fb'            # unit 31's after/ at its commit 4e6e7c9: 43 files (units 32 and 33 pin the same; harness/tree34.py)
beforetree() { local t; t=$(python3 -I harness/tree34.py before/) || die "before/'s tree could not be hashed"
  [ "$t" = "$T31" ] || die "R.211: before/ (../c7-unit31/after, a shipped unit's frozen tree) is not the tree this unit changed: $t, pinned $T31"
  echo "  before/'s tree ($1): python3 -I harness/tree34.py before/ -> $t = pinned (unit 31's after/, frozen; units 32 and 33 pin the same)"; }
# R.211: after/ equals ../c7-tiffinbox from this unit's commit on - should a later unit change the anchor, a note, never a stop
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox: empty - after/ = ../c7-tiffinbox"
  else echo "  (after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): after/ is this unit's tree (C3) - a later anchor change has moved ../c7-tiffinbox on"; fi; }
beforetree start; anchornote start
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
SR=tiffinbox-web/target/surefire-reports
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
UF=secrets/tiffinbox/jdbc-url                         # TiffinBox's database URL on PostgreSQL, read by its own config tree (anchor)
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
HS=harness/src/probe/q
HFILES='chk34.py dur7.py logback.xml s34.py spy.properties src surefire.py tools tree34.py'
SFILES='probe/q/DsProxyImpl.java probe/q/Gen.java probe/q/GenMain.java probe/q/H.java probe/q/Main.java probe/q/Run.java probe/q/Seed.java probe/q/Slow.java probe/q/SqlCounter.java probe/q/ex/ExApp.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql harness/tools/pom.xml; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] && [ "$(ls harness/tools | paste -sd' ' -)" = pom.xml ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not unit 29's, byte for byte"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
cmp -s harness/tree34.py ../c7-unit33/harness/tree33.py || die "harness/tree34.py is unit 33's tree33.py, byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20130 20131 20132 20133 20134 20135 20136 20137 20138 20139"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
docker image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - docker pull it once (this script never pulls)"
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it yourself: docker rm -f $CN"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets
echo "  the image: $IMG is on this machine (docker image inspect, the full digest; never pulled)"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 (dur7: "slow" only beside PostgreSQL's threshold line, on this Mac) + S4.7 (R.264) + R.301 (S5.18, BLUE's tm.py) + R.287 +
# R.190 + R.224, carried; S5.11 (R.294), S5.12 (R.295), S5.13 (R.296), S5.17 (R.300), S5.9 (R.292), R.245, R.252/R.302 (a typed
# hash), the developer boundary named once, this unit's - per sentence (S5.13 per paragraph), harness/s34.py, its self-test first
DW=$(python3 -I -B harness/s34.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose (R.172, S4.7, R.301, R.287, R.190, R.224, S5.9, S5.11, S5.12, S5.13, S5.17, R.245, R.302): $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s34, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): dur7 words 0 but \"slow\" beside PostgreSQL's threshold line, on this Mac · S4.7's family 0 · R.301's family 0 but beside the threshold line or a printed count · R.287 old wordings 0 · R.190 the tests as a witness 0 · R.224 a call-back without its title 0 · S5.9/S5.11 H2 characterised, slow on H2 or beside the SQL_SLOW chip alone 0 · S5.12 a raw password or URL 0 · S5.13 show-sql's claim without its control 0 · S5.17 a grouped design 0 · R.245 a plan's cost or rows 0 · R.302 a typed hash, ratio or jar count 0 · the developer boundary once, with its title - over README.md and exercise/"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/ and harness/)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty"
# R.225: a SQL string this unit shows is the logger's - outside the values block, the tables and the text blocks a run printed, none
SQLRE='select ce1_0|from customer ce1_0|from pause p1_0|from pause pe1_0|select p1_0|select pe1_0|where ce1_0\.name|customer_id=\?|Seq Scan on|Bitmap (Heap|Index) Scan on|Rows Removed by Filter|create index pause_customer_id_idx on pause'
prose() { awk -v f="$1" '/^<!-- (values|slow-table): begin -->$/ { v = 1; next } /^<!-- (values|slow-table): end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print f ":" NR ": " $0 }' "$1"; }
TS=$(for f in $PROSE; do prose "$f"; done | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string or plan line in the prose (R.225, R.245): $TS"
echo "  typed SQL strings and plan lines: 0 in README.md and exercise/ outside the values block, the slow table and the blocks the runs printed"
# R.302 (S5.19): the ratios, the medians, the counts the video says and the md5s the runs print are printed by the run, typed nowhere
TNRE='(^|[^0-9A-Za-z.])[0-9]{1,2}\.[0-9][0-9]([^0-9.]|$)|\b(prepareStatement|getPrepareStatementCount) [0-9]+|\b[0-9]+ (statements|SQL lines|lines without|of [0-9]+ lines)\b|\b(1999''02|200,?0''02|2,?0''04)\b|7f69''42f0|9cf9''2b8c|466c''20ed|[0-9a-f]{32}'
TN=$(for f in $PROSE; do prose "$f"; done | $G -E "$TNRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TN" ] || die "R.302: a count, a ratio or a printed md5 typed in the prose, outside a block a run printed, the values block and the slow table: $TN"
TC=$($G -nE '13\.(37|38|71)|1999''02|2000''02|7f69''42f0|466c''20ed|CONSTRAINT_INDEX_''4' receipts.sh harness/chk34.py harness/src/probe/q/*.java 2> /dev/null | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a probe's figure or a printed md5 typed in this script or the harness: $TC"
echo "  R.302: the counts, ratios, medians and md5s typed 0 times in the prose (outside printed blocks, the values block and the slow table), in receipts.sh, chk34.py and the harness's sources (s34.py's self-test aside: its refused cases are the plants' sentences)"

# ---- R.250: C3 and every sentence it makes false - a gate before any build -------------------------------------------------------
PE=after/$CJ/PauseEntity.java; DB=after/$CJ/Database.java
$G -qxF '@Table(name = "pause", indexes = @Index(name = "pause_customer_id_idx", columnList = "customer_id"))' "$PE" && $G -qxF 'import jakarta.persistence.Index;' "$PE" || die "C3: after/'s PauseEntity names the index in its @Table (and imports jakarta.persistence.Index)"
[ "$($G -cxF '            st.execute("CREATE INDEX pause_customer_id_idx ON pause (customer_id)");' "$DB")" = 1 ] || die "C3: after/'s Database creates the index once, after the pause table"
awk '/CREATE TABLE pause \(/ { p = NR } /CREATE INDEX pause_customer_id_idx ON pause \(customer_id\)/ { i = NR } END { exit !(p > 0 && i > p) }' "$DB" || die "C3: the index is created after the pause table"
[ "$($G -c 'pause_customer_id_idx' before/$CJ/PauseEntity.java before/$CJ/Database.java | awk -F: '{ s += $2 } END { print s }')" = 0 ] || die "before/ must not hold unit 34's index"
F250=$($G -rnE '9cf92b8c|names no index|creates no index|creates none|no index on (the )?(pause|customer_id)|0 index lines|without an index' after 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$F250" ] || die "R.250: a sentence C3 makes false is still in after/: $F250"
python3 -I -c 'import re, sys; s = open(sys.argv[1], encoding="utf-8").read().replace("\n", " "); o = [m.end() for m in re.finditer(r"unit 27.s, byte for byte", s)]; sys.exit(not (len(o) == 4 and all("*(Course 7, unit 34: it moved there" in s[e:e + 48] for e in o)))' after/README.md || die "R.250/R.252: after/README.md - each sentence that says Hibernate's DDL is unit 27's carries unit 34's note (4)"
$G -qF '## Course 7 · unit 34 — the index' after/README.md && $G -qF "**Section 5's third and last change to this folder — this tree is Section 5's frozen anchor**" after/README.md || die "R.250: after/README.md - unit 34's header note and section are there"
$G -qF 'Course 7, unit 34: the foreign key column carries an index' "$PE" && $G -qF 'Course 7, unit 34: the pause table' "$DB" || die "R.250: PauseEntity's Javadoc and Database's comment say why the index is there"
echo "  R.250: after/ - @Index on PauseEntity's @Table, CREATE INDEX after the pause table in Database; the sentences C3 makes false (the old script's md5 as current, \"names no index\", \"creates none\", \"no index on the pause\", \"0 index lines\") 0; the four \"Hibernate's own DDL is unit 27's\" sentences carry unit 34's note (R.252, said as moved); PauseEntity's Javadoc and Database's comment; the anchor README's header note and section"

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
HSRC="$HS/DsProxyImpl.java $HS/Gen.java $HS/GenMain.java $HS/H.java $HS/Main.java $HS/Run.java $HS/Seed.java $HS/Slow.java $HS/SqlCounter.java harness/src/probe/x/XMain.java"
L_DEP=$(mine 'mvn -B dependency:list dependency:copy-dependencies -DoutputDirectory=../tools')
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*:.harness/tools/*\" $HSRC")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../after/$XD/lib/*:../../.m2-demo/$PGJ\$CPX\" probe.q.Main \"\${A[@]}\"")
L_GEN=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../after/$XD/lib/*:../../.m2-demo/$PGJ\" probe.q.GenMain")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../\$T/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_TPG=$(mine "java $JL -cp \"$XD/tiffinbox-web-1.0.0.jar:$XD/lib/*:../../.m2-demo/$PGJ\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.datasource.username=sa --logging.level.org.hibernate.SQL=debug")
L_H2S=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java $JL -Dh2.bindAddress=127.0.0.1 -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Server -tcp -tcpPort 20137 -ifNotExists")
L_RUN=$(mine "docker run -d --pull never --name $CN -p 127.0.0.1:20138:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; l=${l/java $JL $JL /java $JL }; printf 'cd %s && %s\n' "$1" "$l"; }
# tb TREE PORT DB: the README's run line on TREE, its port, TiffinBox's database on the H2 server (mem:DB), sa (unit 29's step:
# without it Boot treats the TCP URL as not embedded and the start fails, 28000-250), the SQL logger at DEBUG - quoted
tb() { local t=$1 p=$2 d=$3; printf '%s %s\n' "$(at .harness/$t $p "$L_SQL")" "'--tiffinbox.jdbc-url=jdbc:h2:tcp://127.0.0.1:20137/mem:$d;DB_CLOSE_DELAY=-1' --spring.datasource.username=sa"; }
[ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
[ "$(exe "$(at .harness/after 20131 "$R_RUN")")" = "cd .harness/after && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20131" ] || die "at(): the run line is not the README's"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
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
copy before .harness/before; copy after .harness/after; copy after .harness/after2
mbuild "$(off .harness/before "$R_PLAIN" package) -DskipTests" .harness/build-before.log ".harness/before (before/, the README's package line, -DskipTests: its tests are unit 31's)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
[ "$(summ4 .harness/build-after.log)" = '18 0 0 0' ] || die "after/'s tests: $(summ4 .harness/build-after.log) - expected 18 0 0 0 (a guard)"
mbuild "$(off .harness/after2 "$R_PLAIN" package) -DskipTests" .harness/build-after2.log ".harness/after2 (after/ copied again for A', the same line, -DskipTests)"
for t in before after after2; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
mkdir -p .harness/pom-tools .harness/tools; cp harness/tools/pom.xml .harness/pom-tools/
mbuild "$(off .harness/pom-tools "$L_DEP")" .harness/dep-tools.log ".harness/pom-tools (harness/tools/pom.xml: dependency:list and dependency:copy-dependencies into .harness/tools)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/springframework/boot/spring-boot-dependencies/4.1.2/spring-boot-dependencies-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar "$PGJ"; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
[ ! -e .harness/after/$XD/lib/postgresql-42.7.14.jar ] || die "after/'s lib/ holds the PostgreSQL driver - it never did; the harness takes it from .m2-demo"
[ -z "$(ls .harness/after/$XD/lib | $G -iE 'p6spy|datasource-proxy' || true)" ] || die "after/'s lib/ holds p6spy or datasource-proxy - it never did"
(cd .harness/after && eval "$R_TOKEN") || die "the token was not written"
TOKEN=$(head -n 1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
for t in before after2; do mkdir -p .harness/$t/secrets/tiffinbox && (umask 077 && cp .harness/after/$TF .harness/$t/$TF); done
for t in before after after2; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
echo "  the token: generated once (openssl rand -hex 16, the README's line, in .harness/after), copied into before's and after2's $TF, mode 0600, never printed"
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/q/ex ] || die "the exercise's class compiled into the wrong place"
cp harness/spy.properties .harness/run/spy.properties
echo "  extracted three jars ($(for t in before after after2; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: before/after/A'); the two tools' jars in .harness/tools ($(ls .harness/tools | wc -l | tr -d ' ')); the harness compiled once - .harness/hc over after/'s libraries and .harness/tools; the PostgreSQL driver: .m2-demo/$PGJ (md5 $(md5 -q "$M2/$PGJ")); p6spy's settings: harness/spy.properties copied into .harness/run, the harness JVMs' folder"
# the H2 TCP server: one JVM for this run, loopback only, the seven's databases on it (mem:NAME)
echo "\$ $L_H2S" >&3
(eval "$L_H2S") > .harness/h2server.log 2>&1 < /dev/null & spid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20137)" = 0 ]; do kill -0 "$spid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20137)" = 1 ] || { cat .harness/h2server.log >&3; die "the H2 server never listened on 20137"; }
[ "$(lsof -nP -a -p "$spid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20137' ] || die "the H2 server must listen on 127.0.0.1:20137 alone"
H2SL=$($G -m1 'TCP server running at' .harness/h2server.log || true); [ "$H2SL" = 'TCP server running at tcp://localhost:20137 (only local connections)' ] || die "the H2 server's line: ${H2SL:-none}"
echo "  the H2 server: $H2SL - listens on 127.0.0.1:20137 alone"

# ---- the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214) ------------
# CSTARTED is set before docker run, so an interrupt during its start removes it too
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(docker port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20138' ] || die "docker port: the container must publish 5432 on 127.0.0.1:20138 alone: $DP"
[ "$(listeners 20138)" -ge 1 ] || die "nothing listens on 20138 after the container started"
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
    gsub(/Slow query took [0-9]+ milliseconds/, "Slow query took <ms> milliseconds")
    gsub(/Connection:[0-9]+, Time:[0-9]+,/, "Connection:<n>, Time:<ms>,")
    gsub(/^[0-9]+\|[0-9]+\|/, "<time>|<ms>|"); gsub(/\|connection [0-9]+\|/, "|connection <n>|")
    gsub(/virtual-[0-9]+/, "virtual-<n>"); gsub(/omcat-handler-[0-9]+/, "omcat-handler-<n>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting Main using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 2 JPA repository interfaces.' "token $TOKEN" "1794550162654|2|statement|connection 10|url jdbc:p6spy:postgresql://127.0.0.1:20138/u34spy?user=sa&password=$PW|select 1|select 1" 'JDBC [x.HibernateTransactionManager$$Lambda/0x000003ff01b8a310@5d9576a0]' 'JDBC driver H2 JDBC Driver 2.5.250 (2026-08-29)' 'INFO  [main] org.hibernate.SQL_SLOW : Slow query took 7 milliseconds [select 1]' 'Name:tiffinbox, Connection:12, Time:3, Success:True' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting Main using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 2 JPA repository interfaces.' 'token [masked: the token]' '<time>|<ms>|statement|connection <n>|url jdbc:p6spy:postgresql://127.0.0.1:20138/u34spy?user=sa&password=<pw>|select 1|select 1' 'JDBC [x.HibernateTransactionManager$$Lambda/<n>@…]' 'JDBC driver H2 JDBC Driver 2.5.250' 'INFO  [main] org.hibernate.SQL_SLOW : Slow query took <ms> milliseconds [select 1]' 'Name:tiffinbox, Connection:<n>, Time:<ms>, Success:True')" ] || die "mask: the planted JDK version, folders (plain and %20-encoded), home, identity hash, EntityManager identity, scan time, the token, the password in a p6spy line (its time and milliseconds too), a lambda class's address, H2's build date, a SQL_SLOW line's milliseconds and datasource-proxy's connection and time must be masked"
echo "  mask: its self-test passed (the token, the password - in a p6spy line too - folders, home, identities, times, H2's build date, SQL_SLOW's milliseconds, datasource-proxy's Connection and Time); raw password copies after mask: $(mask < .harness/p1 | $G -cF -- "$PW" || true)"
rm -f .harness/p1
CORE=--logging.level.org.hibernate.orm.core=info     # HHH000001 (S4.13): a run option in every JVM but the OFF run - logback.xml pins no Hibernate core level
HQ0=(--logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.jpa.open-in-view=false --spring.jpa.properties.hibernate.generate_statistics=true --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
HQ=("${HQ0[@]}" "$CORE")
SHOW=--spring.jpa.show-sql=true
SQW=--logging.level.org.hibernate.SQL=warn
P6D=--spring.datasource.driver-class-name=com.p6spy.engine.spy.P6SpyDriver
SAU=--spring.datasource.username=sa
SLOWQ=5                                              # hibernate.log_slow_query, the configured value (milliseconds) - read back off the EMF
HE=""
CPX=""
# hrun: one harness JVM (HL: another of this README's java lines), its stdout and stderr to .harness/h.log
hrun() { local c i=0 e=0 n
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  [ "${HL:-$L_H}" = "$L_X" ] || echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"
  [ "${HL:-$L_H}" != "$L_X" ] || echo "\$ T=$T"
  [ "${HL:-$L_H}" = "$L_GEN" ] || echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"
  [ -z "$CPX" ] || echo "\$ CPX=$CPX"
  echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"
  case " ${V[*]:-} " in *" -Dpg.db="*) PGJVM=$((PGJVM + 1)); n=$(raw "$PW" .harness/h.log); [ "$n" = 0 ] || die "a harness log held the password, raw ($n)"; echo "  raw password copies in its log: $n (before the mask; the URL is printed cut before its ?)" ;; esac; }
# hview: the JVM's log, every line (an escape byte shown as cat -v does, ^[; tabs as four spaces), its exit, its WARN lines
hview() { sed $'s/\x1b/^[/g' .harness/h.log | awk '/^$/ { next } { gsub(/\t/, "    "); sub(/[ \t]+$/, ""); print "  " $0 }'
  echo "  its WARN lines (grep -c '^WARN '): $($G -c '^WARN ' .harness/h.log || true) · exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
# pgdb NAME: a fresh database for the next PostgreSQL JVM (dropped first, if a run left it)
pgdb() { local DB=$1; echo "\$ DB=$DB; $L_DB"; (eval "$L_DB") > .harness/pgdb.log 2>&1 < /dev/null || die "the fresh database $DB was not made: $(tail -2 .harness/pgdb.log)"
  echo "  a fresh database: $DB"; }
# step(): the read's own lines, between the step's two markers (PROBE >>> and PROBE <<<)
inside() { awk '/^PROBE >>> / { f = 1; next } /^PROBE <<< / { f = 0 } f' .harness/h.log; }
outside() { awk '/^PROBE >>> / { f = 1; next } /^PROBE <<< / { f = 0; next } !f' .harness/h.log; }
hib() { $G -cE '^[A-Z]+ +\[[^]]*\] org\.hibernate[.A-Za-z_]* : ' "$1" || true; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; raw "$PW" .harness/cap.raw > ".harness/rawpw-$nm.$i"
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
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $($G -c '^@@ ' .harness/code.diff || true) · lines out: $($G -c '^-' .harness/code.diff || true) · in: $($G -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
# ---- the captures --------------------------------------------------------------------------------------------------------
# ways: the one read, six ways - each one harness JVM on H2 (this JVM's memory), its whole log shown, then the counts this script
# reads off that log: the "Hibernate:" lines (show-sql's, on stdout) inside the read's markers and outside them (HTE_ named), the
# org.hibernate logger lines in the whole log, the bind lines, the escapes
wayrun() { local l=$1; shift; echo "$l:"; V=(-Ds=read); A=('--spring.datasource.url=jdbc:h2:mem:u34;DB_CLOSE_DELAY=-1' "$@"); hrun; hview
  echo "  read off its log - 'Hibernate:' lines (show-sql, stdout) inside the read's markers: $(inside | $G -c '^Hibernate: ' || true) · outside them: $(outside | $G -c '^Hibernate: ' || true) (of them create global temporary table HTE_: $(outside | $G -c '^Hibernate: create global temporary table HTE_' || true))"
  echo "  read off its log - org.hibernate logger lines in the whole log (grep -cE '^LEVEL [thread] org.hibernate...'): $(hib .harness/h.log) · org.hibernate.SQL lines inside the read's markers: $(inside | $G -cE '^DEBUG \[main\] org\.hibernate\.SQL : ' || true) · bind lines (org.hibernate.orm.jdbc.bind) inside them: $(inside | $G -cE '^TRACE \[main\] org\.hibernate\.orm\.jdbc\.bind : binding parameter ' || true)"; }
ways() { echo "ways - the one read, findByName(\"Sunil\") and her pauses in one transaction, six ways; one harness JVM each, on H2 (in the harness JVM's memory):"
  wayrun "(i) spring.jpa.show-sql=true, the SQL logger at WARN" "${HQ[@]}" $SHOW $SQW
  wayrun "(ii) the OFF run: show-sql on, org.hibernate.SQL OFF, every org.hibernate logger OFF (logging.level.org.hibernate=off), no Hibernate core level pinned" "${HQ0[@]}" $SHOW --logging.level.org.hibernate.SQL=off --logging.level.org.hibernate=off
  wayrun "(iii) the SQL logger at DEBUG and the bind logger at TRACE (show-sql off)" "${HQ[@]}" --logging.level.org.hibernate.orm.jdbc.bind=trace
  wayrun "(iv) hibernate.format_sql=true" "${HQ[@]}" --spring.jpa.properties.hibernate.format_sql=true
  wayrun "(v) hibernate.highlight_sql=true" "${HQ[@]}" --spring.jpa.properties.hibernate.highlight_sql=true
  echo "  its log FILE, .harness/h.log, read with grep: lines holding ESC[34m (grep -c): $($G -c $'\x1b\\[34m' .harness/h.log || true) · ESC[34m occurrences (grep -o | wc -l): $($G -o $'\x1b\\[34m' .harness/h.log | wc -l | tr -d ' ') · its first statement line through cat -v:"
  $G -m1 $'org.hibernate.SQL : \x1b' .harness/h.log | cat -v | sed 's/^/    /'
  wayrun "(vi) hibernate.use_sql_comments=true" "${HQ[@]}" --spring.jpa.properties.hibernate.use_sql_comments=true; }
# spy: p6spy as the driver - its jar on the class path, its URL, its driver class, spy.properties in .harness/run; spy.log read
# right after each JVM (the read's lines), then deleted; on PostgreSQL the raw file's password counted first, then masked
spylines() { local f=$1; echo "  spy.log - lines: $(wc -l < "$f" | tr -d ' ') · the read's two statements (the SQL with its binds inlined, the last field):"
  $G -E "where ce1_0\.name='|where p1_0\.customer_id=[0-9]" "$f" | sed -E 's/^[0-9]+\|[0-9]+\|/<time>|<ms>|/; s/^/    /'; }
spy() { local n m
  echo "spy - p6spy 3.9.1 (harness/tools/pom.xml, offline): dependency:list (its build log), then ls -l .harness/tools - bytes and name:"
  sed -n -E 's/^\[INFO\]    ([^ ]+) .*$/  \1/p' .harness/dep-tools.log
  (cd .harness/tools && ls -l) | awk 'NR > 1 { print "  " $5 " " $NF }'
  echo "  the section's other seed jars (the cache providers) on no class path here; spy.properties (harness/spy.properties, in .harness/run):"
  sed -n '/^[a-z]/s/^/    /p' .harness/run/spy.properties
  CPX=:../tools/p6spy-3.9.1.jar
  echo "on H2 - the p6spy URL without Boot's user name (the failing start, filed - S5.20):"
  rm -f .harness/run/spy.log; V=(-Ds=read); A=('--spring.datasource.url=jdbc:p6spy:h2:mem:u34spy;DB_CLOSE_DELAY=-1' $P6D "${HQ[@]}"); hrun; hview
  echo "  the failing start's step - exit $HE · its line (grep -o): $($G -m1 -oE 'Wrong user name or password \[28000-250\]' .harness/h.log || echo none)"
  rm -f .harness/run/spy.log
  echo "on H2 - the same with --spring.datasource.username=sa (the fixed run):"
  V=(-Ds=read); A=('--spring.datasource.url=jdbc:p6spy:h2:mem:u34spy;DB_CLOSE_DELAY=-1' $P6D $SAU "${HQ[@]}"); hrun; hview
  echo "  JVM warnings on its stderr (grep -c '^WARNING'): $($G -c '^WARNING' .harness/h.log || true)"
  [ -f .harness/run/spy.log ] || die "spy: no spy.log on H2"
  spylines .harness/run/spy.log; rm -f .harness/run/spy.log
  echo "on PostgreSQL (the container, a fresh database) - jdbc:p6spy:postgresql, built inside the JVM:"
  pgdb u34spy; V=(-Ds=read -Dspy=true -Dpg.db=u34spy -Dpg.pwfile=../secrets/pgpw); A=($P6D "${HQ[@]}"); hrun; hview
  [ -f .harness/run/spy.log ] || die "spy: no spy.log on PostgreSQL"
  n=$(wc -l < .harness/run/spy.log | tr -d ' '); m=$(LC_ALL=C $G -cF -- "$PW" .harness/run/spy.log || true)
  echo "  spy.log, raw, before the mask: lines holding the generated password $m of $n"
  mask < .harness/run/spy.log > .harness/spy-pg.masked.log; rm -f .harness/run/spy.log
  echo "  masked into .harness/spy-pg.masked.log; raw copies after the mask: $(raw "$PW" .harness/spy-pg.masked.log) · the raw file deleted: spy.log under .harness now $(find .harness -name spy.log | wc -l | tr -d ' ') · git check-ignore spy.log: $(git check-ignore -q spy.log 2> /dev/null && echo ignored || echo 'not ignored')"
  echo "  one masked line in full (the first):"; sed -n 1p .harness/spy-pg.masked.log | sed 's/^/    /'
  spylines .harness/spy-pg.masked.log; CPX=""; }
dsproxy() { local BOM=org/springframework/boot/spring-boot-dependencies/4.1.2/spring-boot-dependencies-4.1.2.pom
  echo "dsproxy - datasource-proxy 1.11.1 (its jar, .harness/tools: $( (cd .harness/tools && ls -l datasource-proxy-1.11.1.jar) | awk '{ print $5 " " $NF }')) around Boot's pool, a BeanPostProcessor, on H2:"
  CPX=:../tools/datasource-proxy-1.11.1.jar
  V=(-Ds=read -Ddsp=true); A=('--spring.datasource.url=jdbc:h2:mem:u34;DB_CLOSE_DELAY=-1' "${HQ[@]}"); hrun; hview; CPX=""
  echo "  read off its log - datasource-proxy's lines inside the read's markers: $(inside | $G -c 'SLF4JQueryLoggingListener : Name:tiffinbox' || true) · 'jdbc:' in all its lines: $($G 'SLF4JQueryLoggingListener : ' .harness/h.log | $G -o 'jdbc:' | wc -l | tr -d ' ')"
  echo "  Spring Boot 4.1.2's BOM (.m2-demo/$BOM): lines naming p6spy or datasource-proxy (grep -ciE 'p6spy|datasource-proxy|ttddyy'): $($G -ciE 'p6spy|datasource-proxy|ttddyy' "$M2/$BOM" || true)"; }
# slow: the fixed design, TJ JVMs per database per capture run, H2 and PostgreSQL in turn
TJ=4; TT=7; SN=2000; SK=100                          # JVMs per database per capture run, T (fixed before the runs of record), customers and pauses each
thr() { awk -v r="$1" -v t="$2" 'BEGIN { print (r + 0 >= t + 0) ? "true" : "false" }'; }
slow_() { local j d n r k0 k1 m0
  echo "slow - the fixed design: the shipped seed and $SN generated customers with $SK pauses each; M 50 lookups per half, W 5 warm-up rounds, R 9 timed, each round without and with the index, the order reversed every other round; $TJ JVMs per database, H2 and PostgreSQL in turn; org.hibernate.SQL at WARN, org.hibernate.SQL_SLOW at INFO, hibernate.log_slow_query=$SLOWQ; the medians, ratios and SQL_SLOW figures masked here (.r-slow.table holds them); PostgreSQL's threshold T = $TT:"
  echo "  (terminal only) slow, capture run $CAPRUN of 3 - load average before: $(sysctl -n vm.loadavg)" >&3
  printf 'capture run %s - load average before: %s\n' "$CAPRUN" "$(sysctl -n vm.loadavg)" >> .harness/slow-load
  for j in $(seq 1 $TJ); do for d in h2 pg; do n=H2; [ $d = h2 ] || n=PostgreSQL
    echo "on $n - JVM $j of $TJ:"
    V=(-Ds=slow -Dn=$SN -Dk=$SK -DW=5 -DR=9 -DM=50)
    if [ $d = h2 ]; then A=('--spring.datasource.url=jdbc:h2:mem:u34;DB_CLOSE_DELAY=-1' "${HQ[@]}" $SQW --logging.level.org.hibernate.SQL_SLOW=info --spring.jpa.properties.hibernate.log_slow_query=$SLOWQ)
    else pgdb "u34slow$j"; V+=(-Dpg.db=u34slow$j -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" $SQW --logging.level.org.hibernate.SQL_SLOW=info --spring.jpa.properties.hibernate.log_slow_query=$SLOWQ); fi
    hrun
    awk '/^PROBE timed (without|with) the index \(ms\): / { sub(/: \[.*\]$/, ": [<masked>]") }
         /^PROBE median \(ms\): / { gsub(/ [0-9]+\.[0-9]/, " <ms>") }
         /^PROBE ratio without \/ with the index: / { sub(/: [0-9]+\.[0-9][0-9]$/, ": <ratio>") }
         /^PROBE org\.hibernate\.SQL_SLOW lines over the timed rounds: / { k0 = $0; sub(/^.*without the index /, "", k0); sub(/ .*$/, "", k0); k1 = $0; sub(/^.* with the index /, "", k1)
           $0 = "PROBE org.hibernate.SQL_SLOW lines over the timed rounds, without the index and with it: counted, to the table" }
         /^PROBE the smallest time a SQL_SLOW line reported \(ms\): / { $0 = "PROBE the smallest time a SQL_SLOW line reported (ms): to the table" }
         / org\.hibernate\.SQL_SLOW : / { next }
         /^$/ { next } { sub(/[[:space:]]+$/, ""); print "  " $0 }' .harness/h.log
    echo "  its WARN lines (grep -c '^WARN '): $($G -c '^WARN ' .harness/h.log || true) · its SQL_SLOW lines: counted per half over the timed rounds alone (above; the warm-up rounds' lines are not counted)"
    r=$(sed -n 's/^PROBE ratio without \/ with the index: \([0-9.]*\)$/\1/p' .harness/h.log); [ -n "$r" ] || r=none
    k0=$(sed -n 's/^PROBE org\.hibernate\.SQL_SLOW lines over the timed rounds: without the index \([0-9]*\) · with the index \([0-9]*\)$/\1 · with \2/p' .harness/h.log)
    m0=$(sed -n 's/^PROBE the smallest time a SQL_SLOW line reported (ms): //p' .harness/h.log)
    printf '%s · capture run %s · JVM %s · ratio without / with the index: %s · %s · SQL_SLOW lines (timed rounds): without %s · smallest logged time (ms): %s\n' "$n" "$CAPRUN" "$j" "$r" "$($G '^PROBE median ' .harness/h.log | sed 's/^PROBE //')" "$k0" "$m0" >> .harness/slow-table
    if [ $d = pg ]; then echo "  exit $HE · on PostgreSQL, JVM $j: ratio >= $TT: $( [ "$r" = none ] && echo 'no ratio printed' || thr "$r" $TT)"
    else echo "  exit $HE · on H2, JVM $j: its ratio goes to the table as a number - no threshold on H2 (S5.11)"; fi; done; done
  echo "  (terminal only) slow, capture run $CAPRUN of 3 - load average after: $(sysctl -n vm.loadavg)" >&3
  printf 'capture run %s - load average after: %s\n' "$CAPRUN" "$(sysctl -n vm.loadavg)" >> .harness/slow-load; }
# ---- TiffinBox: started from its tree, readiness polled, asked, stopped by its pid ---------------------------------------------
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = "${2:-tiffinbox/shutdown-token}" ] || die "$1/secrets holds other files than expected (${s:-nothing})"
  echo "  secrets/ before the start: $s (mode $(cd "$1/secrets" && find . -type f | sort | while read -r f; do stat -f '%Lp' "$f"; done | paste -sd' ' -)) - $( [ -n "${2:-}" ] && echo "the token's file and TiffinBox's database URL (its config tree: tiffinbox.jdbc-url), nothing else" || echo "the token's file, and nothing else")"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { [ "$(listeners "$2")" = 0 ] || die "something listens on $2 before the start"; sec "$(dir "$1")" "${3:-}"; echo "\$ $1"; : > .harness/run.out; (eval "$(exe "$1")") >> .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
up() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$pid"); case " $a " in *":$1 "*) break ;; esac; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":$1 "*) ;; *) tail -20 .harness/run.out | mask >&3; die "it never listened on $1" ;; esac
  echo "  listens on: $a"; echo "  Boot's first line: $(first .harness/run.out)"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out | mask >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"; echo "  GET /actuator/health/readiness -> 200"; }
LASTE=""
stopit() { local i=0 e=0; kill "$pid" 2> /dev/null || true
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill -9 "$pid"; die "the server on $1 was still running after its SIGTERM"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; echo "  stopped by its pid (SIGTERM): exit $LASTE · listening on $1 now: 0"; }
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
logtok() { local t w; t=$(raw "$TOKEN" .harness/run.out); w=$(raw "$PW" .harness/run.out); LOGS=$((LOGS + 1)); genw .harness/run.out; [ "$t" = 0 ] || die "a TiffinBox log held the token ($t)"; [ "$w" = 0 ] || die "a TiffinBox log held the password, raw ($w)"; echo "  its log: the token 0 times, the password 0 times (raw, before the mask)"; }
lines() { wc -l < .harness/run.out | tr -d ' '; }
settle() { local a b i=0; a=$(lines); while [ $i -lt 20 ]; do sleep 0.25; b=$(lines); [ "$a" = "$b" ] && break; a=$b; i=$((i + 1)); done; }
U34M=U34MARK
mark() { printf '%s %s\n' "$U34M" "$1" >> .harness/run.out; }
seg() { awk -v a="$U34M $1 start" -v b="$U34M $1 end" '$0 == a { f = 1; next } $0 == b { f = 0 } f' .harness/run.out; }
rq() { local l=$1 p=$3 code
  mark "$l start"; echo "\$ curl -s --noproxy '*' -H 'Accept: text/html' http://127.0.0.1:$p$2"
  code=$(curl -s --noproxy '*' -o .harness/body-$l -w '%{http_code}' -H "Accept: text/html" "http://127.0.0.1:$p$2" 2> /dev/null || true)
  settle; mark "$l end"; seg "$l" > .harness/seg-$l.log
  echo "  -> $code · the page's rows (<tr> lines): $($G -c '<tr' .harness/body-$l || true) · the whole request's org.hibernate.SQL lines, between its two markers: $($G -cE ' org\.hibernate\.SQL +: ' .harness/seg-$l.log || true) · WARN lines: $($G -cE '^[^ ]+ +WARN ' .harness/seg-$l.log || true) · ERROR lines: $($G -cE '^[^ ]+ +ERROR ' .harness/seg-$l.log || true)"; }
treeis() { if [ "$1" = before ]; then echo "before/, the anchor before this change"; elif [ "$1" = after ]; then echo "after/'s jar"; else echo "after/ copied again and built again"; fi; }
QC=""                                                 # the lazy collection's statement - read off the ways capture (the bind run's log)
anchor() { local f t p d
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#' | sort
  for f in $CJ/PauseEntity.java $CJ/Database.java; do echo "$f:"; cdiff "before/$f" "after/$f"; done
  for f in before:20130:u34b:B after:20131:u34a:A after2:20132:u34a2:A2; do t=${f%%:*}; p=$(echo "$f" | cut -d: -f2); d=$(echo "$f" | cut -d: -f3)
    echo "${f##*:} - TiffinBox on PostgreSQL from .harness/$t ($(treeis $t)), port $p, a fresh database $d; its URL - the password in it - in its own config tree, secrets/tiffinbox/jdbc-url (mode 0600):"
    pgdb $d
    (umask 077 && printf '%s' "jdbc:postgresql://127.0.0.1:20138/$d?user=sa&password=$PW" > .harness/$t/$UF)
    start "$(at .harness/$t $p "$L_TPG") --logging.level.org.hibernate.orm.connections.pooling=warn" $p "tiffinbox/jdbc-url tiffinbox/shutdown-token"; up $p; ready $p
    echo "  its log, read off: HHH000001 lines $($G -c 'HHH000001: Hibernate ORM core version 7.4.13.Final' .harness/run.out || true) · ERROR lines $($G -cE '^[^ ]+ +ERROR ' .harness/run.out || true)"
    echo "the second connection (plain JDBC, the harness's GenMain), while TiffinBox runs:"
    tpid=$pid; V=(-Dpg.db=$d -Dpg.pwfile=../secrets/pgpw -Dn=$SN -Dk=$SK "-Dq=$QC"); HL=$L_GEN; hrun; HL=""; pid=$tpid; tpid=""; hview
    rq html /dashboard $p
    stopit $p; logtok; rm -f .harness/run.out .harness/$t/$UF; done; }
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t n0
  for t in before after; do
    echo "the seven - $t/'s jar, port 20133, a fresh JVM, its database mem:u34s7$t on the H2 server, Hibernate's SQL logger on:"
    start "$(tb $t 20133 u34s7$t)" 20133; up 20133; ready 20133; n0=$(lines)
    echo "\$ \$CURLSET 20133 .harness/$t/$TF"
    "$CURLSET" 20133 ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    gone 20133
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"
    echo "  its dashboard line: $($G '^GET   /dashboard ' .harness/seven-$t.txt | cut -c1-120)"
    echo "  its log's org.hibernate.SQL lines during the seven: $(sqlseg "$((n0 + 1))" '$')"
    logtok; rm -f .harness/run.out; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }
summ() { $G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
reports() { local s t
  python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  s=$(summ "$2"); t=$(python3 -I harness/surefire.py "$1/$SR" | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"; }
tests() { local c e=0 n
  echo "TiffinBox's tests - after/ copied to .harness/tests, the README's line, offline:"
  rm -rf .harness/tests; copy after .harness/tests
  c=$(off .harness/tests "$R_TEST"); echo "\$ $c"
  (eval "$c") > .harness/tests.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/tests.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/tests.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"; reports .harness/tests .harness/tests.log
  echo "  the token in its log and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }
X33=9cf92b8cae3abfd0f1c0706bfe7a4373                # Hibernate's script from unit 27 to unit 33 - ../c7-unit33/xcheck.sql; unit 34 moves it
[ "$(md5 -q ../c7-unit33/xcheck.sql)" = "$X33" ] || die "../c7-unit33/xcheck.sql is not the script units 27-33 filed (md5 $X33)"
XA=('--spring.datasource.url=jdbc:h2:mem:x34;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml "$CORE" --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
ddl() { T=$1; rm -f .harness/run/hibernate-ddl.sql; V=(); A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script over $1's libraries"
  mv .harness/run/hibernate-ddl.sql "$2"; }
xcheck() {
  echo "Hibernate's DDL over after/'s libraries - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  ddl after .harness/ddl-after.sql
  echo "  .harness/ddl-after.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-after.sql
  echo "the same over before/'s libraries (the anchor before this change):"
  ddl before .harness/ddl-before.sql
  echo "  after/'s md5: $(md5 -q .harness/ddl-after.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-after.sql xcheck.sql && echo 'the same, byte for byte' || echo differ)"
  echo "  before/'s md5: $(md5 -q .harness/ddl-before.sql) · the batching lesson's xcheck.sql: $(md5 -q ../c7-unit33/xcheck.sql) · cmp: $(cmp -s .harness/ddl-before.sql ../c7-unit33/xcheck.sql && echo 'the same, byte for byte' || echo differ)"
  echo "  the lines that differ (diff, the batching lesson's xcheck.sql against after/'s script): added $(diff ../c7-unit33/xcheck.sql .harness/ddl-after.sql | $G -c '^>' || true) · removed $(diff ../c7-unit33/xcheck.sql .harness/ddl-after.sql | $G -c '^<' || true):"
  diff ../c7-unit33/xcheck.sql .harness/ddl-after.sql | $G -E '^[<>]' | sed 's/^/    /' || true; }
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
  o=$(python3 -I -B harness/chk34.py "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk34.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)        # the seven since unit 27, read off ../c7-unit31/receipts.sh (its seven capture)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
chk_seven() { local SV SVB SVA
  SV=$(cat .r-seven.out)
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] && has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: $S466 on both trees (a guard)" || die "seven: $S466 on both trees"
  SVB=$(printf '%s\n' "$SV" | sed -n "s/^  its log's org.hibernate.SQL lines during the seven: //p" | sed -n 1p); SVA=$(printf '%s\n' "$SV" | sed -n "s/^  its log's org.hibernate.SQL lines during the seven: //p" | sed -n 2p)
  [ -n "$SVB" ] && [ "$SVA" = "$SVB" ] || die "seven: the SQL lines during the seven, the same on before/ and after/ (an index changes no statement): $SVB -> $SVA"
  echo "  seven: $S466 on before/ and after/, 0 lines differ (a guard); SQL lines during the seven $SVB on both (an index changes no statement)"
  VALS="$VALS · seven: $S466 on before/ and after/, SQL lines during it $SVB on both"; }
chk_tests() { local TS l
  TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" '  exit 0 · BUILD SUCCESS · offline: yes' \
      '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' '  the token in its log and every report: 0 times'; do has "$TS" "$l" "tests"; done
  echo "  tests: 18 (14/3/1) on after/ from the reports, the console the same - a guard (R.190; C7-4, carried to U39)"; VALS="$VALS · tests: 18 (14/3/1) on after/, offline"; }
chk_xcheck() { local XC XN XL
  XC=$(cat .r-xcheck.out)
  XN=$(printf '%s\n' "$XC" | sed -n "s/^  after\/'s md5: \([0-9a-f]*\) · the filed xcheck.sql: \([0-9a-f]*\) · cmp: the same, byte for byte$/\1 \2/p")
  [ -n "$XN" ] && [ "${XN% *}" = "${XN#* }" ] && [ "${XN% *}" = "$(md5 -q xcheck.sql)" ] && [ "${XN% *}" != "$X33" ] || die "xcheck: after/'s script = the filed xcheck.sql, and not the old one ($XN)"
  has "$XC" "  before/'s md5: $X33 · the batching lesson's xcheck.sql: $X33 · cmp: the same, byte for byte" "xcheck: before/'s script is unit 33's, byte for byte"
  has "$XC" "  the lines that differ (diff, the batching lesson's xcheck.sql against after/'s script): added 1 · removed 0:" "xcheck: one line added, none removed"
  XL=$(printf '%s\n' "$XC" | sed -n 's/^    > //p')
  [ "$XL" = 'create index pause_customer_id_idx on pause (customer_id);' ] && has "$XC" "    $XL" "xcheck: the line in after/'s script" || die "xcheck: the added line is the index: $XL"
  [ "$(cnt "$XC" '  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final')" = 2 ] || die "xcheck: HHH000001 in each XMain JVM"
  echo "  xcheck: after/'s script ${XN% *} = xcheck.sql; before/'s $X33 = ../c7-unit33/xcheck.sql; one line added: $XL"
  VALS="$VALS · xcheck: Hibernate's script moved, $X33 -> ${XN% *}, one line added: $XL"; }
EXQ="Your turn: the README's schema script has no index on a pause's customer. Add one in the mapping, so Hibernate's script creates it."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
chk_exercise() { local EB EZ b ER ES w x
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    has "$ER" '    the JVM: exit 0' "exercise: the README runs"; has "$ES" '    the JVM: exit 0' "exercise: the solution runs"
    x=$(python3 -I -c '
import re, sys
def pts(t):
    s = re.findall(r"^    PROBE Hibernate.s schema script: (\d+) lines · lines with \"index\": (\d+) · md5 ([0-9a-f]{32})$", t, re.M)
    i = re.findall(r"^    PROBE (create index \S+ on \S+ \(\S+\);)$", t, re.M)
    return s, i
(bs, bi), (ss, si) = pts(sys.argv[1]), pts(sys.argv[2])
ok = len(bs) == 1 and len(ss) == 1 and int(bs[0][1]) == 0 == len(bi) and int(ss[0][1]) == 1 == len(si) and int(ss[0][0]) == int(bs[0][0]) + 1 and bs[0][2] != ss[0][2]
print(("PASS" if ok else "FAIL") + " the README: %s lines, index lines %s, md5 %s; the solution: %s lines, index lines %s, md5 %s - %s" % (
    bs[0][0] if bs else "-", bs[0][1] if bs else "-", bs[0][2] if bs else "-", ss[0][0] if ss else "-", ss[0][1] if ss else "-", ss[0][2] if ss else "-", si[0] if si else "no index line"))' "$ER" "$ES")
    case $x in PASS*) ;; *) die "exercise: the broken script no index line, the solution one more line - the index - and another md5 (R.196): $x" ;; esac
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  [ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "exercise: broken and solved print the same (R.196)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" = 23 ] || die "exercise: the spoken line is the brief's 23 words: $EXW"
  x=${x#PASS }
  echo "  exercise: bash and zsh alike - $x; each file's What it prints = the run, the two md5s differ; the spoken line $EXW words (wc -w)"
  VALS="$VALS · exercise: $x ($EXW words)"; }
cap ways ways; chk ways ways .r-ways.out; pub ways
QC=$(python3 -I -B harness/chk34.py collection .r-ways.out | tail -1) && [ "${QC#select }" != "$QC" ] || die "the lazy collection's statement could not be read off the ways capture"
cap spy spy; chk spy spy .r-spy.out; pub spy
cap dsproxy dsproxy; chk dsproxy dsproxy .r-dsproxy.out; pub dsproxy
: > .harness/slow-table; : > .harness/slow-load
cap slow slow_; cp .harness/slow-table .r-slow.table; cat .harness/slow-load >> .r-slow.table
chk slow slow .r-slow.out .r-slow.table "$TT" "$TJ" "$SLOWQ"; pub slow
cap anchor anchor; chk anchor anchor .r-anchor.out "$QC"; pub anchor
cap seven seven7; chk_seven; pub seven
cap tests tests; chk_tests; pub tests
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# R.236: README.md's table of the timing JVMs (the run of record's) - at least ten per database, every PostgreSQL ratio at or above T,
# the margin line = the smallest PostgreSQL ratio minus T, the SQL_SLOW margin line (chk34.py table, the same reading as this run's own)
awk '/^<!-- slow-table: begin -->$/ { f = 1; next } /^<!-- slow-table: end -->$/ { f = 0 } f' README.md > .harness/readme-table.md
python3 -I -B harness/chk34.py table .harness/readme-table.md "$TT" "$SLOWQ" > .harness/chk-table.out 2>&1 || { cat .harness/chk-table.out >&3; die "R.236: README.md's slow table does not hold its threshold (above)"; }
sed 's/^/  README.md /' .harness/chk-table.out | $G -v '^  README.md VALUES ' || true
# R.302: every line of README.md's ```text blocks is a line a run printed - a capture's or a check's (leading spaces aside)
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
# R.303 (S5.20): the refusal quoted in README.md is a line of the spy capture's filed step
q='Wrong user name or password [28000-250]'
$G -qF -- "  the failing start's step - exit 1 · its line (grep -o): $q" .r-spy.out || die "R.303: the quoted refusal is not the filed step's line"
echo "  R.303: '$q' - the spy capture's labelled step, exit 1, its line grepped from that step's log, beside the fixed run"
VS="the values the video may say: on H2 2.5.250 and PostgreSQL 18.6, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"
# hygiene: every capture and every file this unit holds - 0 raw tokens, 0 raw passwords
for f in .harness/raw-* .harness/rawpw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the token or the password ($f)"; done
for f in .r-*.out .r-slow.table README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] && [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the token or the password, raw"; done
[ -z "$(find . -name spy.log -not -path './.m2-demo/*' 2> /dev/null)" ] || die "a spy.log is still on disk - it is deleted right after its run"
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGJVM" -gt 0 ] || die "no JVM ran, or none on PostgreSQL"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -vE '^    [-+]' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number (the quoted diff lines of the change aside)"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]|virtual-[0-9]|started on [A-Z]' "$f" || die "$f holds a log time, a timestamp, a thread number or a context's start date"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl|Debian|pgdg' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'SessionImpl\([0-9]|scanning in [0-9]+ ms|Lambda/0x' "$f" || die "$f holds an EntityManager's identity, a lambda's address or a scan time, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b|[0-9] ns |\(ms\): \[[0-9]|took [0-9]+ milli|Time:[0-9]|^ *[0-9]{10,}\|' "$f" || die "$f holds a millisecond figure, unmasked (R.207, S5.12)"
  ! $G -qE 'ratio [^:]*: [0-9]+\.[0-9]' "$f" || die "$f holds a ratio, unmasked (R.207)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'password=[^<]' "$f" || die "$f holds a password in a URL"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:2013[0-3]' || die "$f holds a URL (only TiffinBox's own loopback ports 20130-20133 may appear)"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.q' after/tiffinbox-web after/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep|while *\(true\)|TimeUnit\.[A-Z]+\.sleep|LockSupport\.park' harness/src || die "a harness sleeps or polls (S4.18)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw token and password copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures, the slow table and every log ($LOGS JVM logs, $PGJVM of them on PostgreSQL); no spy.log on disk; 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, unmasked ratio, thread number, OS token, unmasked identity, password, URL or stack frame in any capture; every JVM pinned and under its alarm; no kill by name; no bare wait; no sleep or polling loop in the harness; no H2 file"
# ---- the end: the H2 server, the container, the anchor, the ports ------------------------------------------------------------
if [ -n "$spid" ] && kill "$spid" 2> /dev/null; then wait "$spid" 2> /dev/null || true; fi; spid=""
pgrm; [ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
beforetree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 20130-20139 at the end - TiffinBox bound 20130-20133 and stopped, the H2 server 20137 and stopped, the container 20138 and removed; 20134-20136 and 20139 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit34: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens, 0 raw passwords; no port bound but 20130-20133, 20137 and 20138"
