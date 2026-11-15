#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · The Second-Level Cache - this unit's receipts. Section 5's fourth unit; no change to the anchor (brief flag 1): anchor is
# the link to ../c7-unit31/after (= ../c7-tiffinbox at unit 31's commit; unit 33 builds over it too, unit 34 moves the anchor next).
# Hibernate's shared cache keeps the entities it read across transactions, so the next read sends no SELECT - counted per region -
# and a write that never passes through Hibernate leaves it serving the old value. Six captures, each run three times and hashed; a
# hash that differs from receipts.md5 stops the run; every number and string the video says is asserted right after its capture by a
# check that can fail, against another witness of the same run (harness/chk32.py) - never against a typed figure. Two databases
# (brief flag 7): H2 2.5.250 in the harness JVM's memory, and PostgreSQL 18.6 - ONE container per run, from the pinned image, on
# 127.0.0.1:20118, a fresh database per JVM. TiffinBox itself is not started: every capture is the harness's.
#   setup     switching it on, on H2: the two cache sets (dependency:list, the jars the anchor's lib/ does not hold, ls -l, counted and
#             summed here), the keys read off the EntityManagerFactory, the regions, the default strategy's HHH90001006 lines and the
#             strategy "create"'s, the start without the cache module (the keys on: a filed refusal; the keys off: no region), and
#             Ehcache's labelled run (the loser) with its stderr counted
#   ratio     K rounds over the seeded customers, each read in its own transaction, at K = 5 and K = 10 (H2): hit · miss · put per
#             region, the statements by three witnesses, the connections; the ratio DERIVED by chk32 two ways; the collection region
#   trap      a write Hibernate never saw, between two reads of one JVM - on PostgreSQL psql in the container, run by THIS script
#             while the JVM waits on its stdin (a FIFO); on H2 plain JDBC in the JVM - then the anchor's uncached entity; then
#             Hibernate's own bulk paths (native, JPQL) and an edit through Hibernate; both databases (the failure receipt)
#   query     the query cache: a cacheable query that reads only customer, three runs, an INSERT into customer, one into pause;
#             both databases
#   xcheck    Hibernate's DDL script over the anchor's libraries = ../c7-unit31/xcheck.sql (no mapping moved)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# The anchor is COPIED under .harness/anchor and built there, never in place, with its README's package line, offline; its jar is
# extracted and the harness (harness/src, packages probe.k and probe.x, outside com.tiffinbox) is compiled once with javac
# -parameters against its libraries. The cache jars come from the harness's two poms (harness/caffeine, harness/ehcache), resolved
# offline from .m2-demo. Every JVM runs under an alarm (perl -e 'alarm N; exec ...'); an alarm that fires is a failed receipt
# (R.247). Ports (§P, 20110-20119): 20118 the container; 20110-20117 and 20119 never bound; the harness JVMs bind none. Nothing
# leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u32-pg
FIFO=.harness/latch.fifo
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM, the latched one included), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every
# process under it); close the latch's writing end and remove its FIFO; then sweep(): anything of this run still alive in its process
# group is stopped; then the container, if this script created it (CSTARTED), is removed (docker rm -f, pgrm). After an interrupt a
# capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C; the script
# exits 130 after an interrupt. No wait is bare.
pid=""; mpid=""; xpid=""; CSTARTED=""; LOPEN=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.k.") || index($0, "probe.x.") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "docker exec c7u32-pg") || index($0, "docker run -d --pull never --name c7u32-pg")) { print $1 }' | paste -sd' ' -) || l=""
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
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; [ -z "$LOPEN" ] || exec 4>&-; rm -f "$FIFO"; sweep || true; pgrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find mkfifo docker /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - the password lives under .harness/ only"
# ---- the anchor: unit 31's after/, through a link; frozen (its tree's hash pinned); ../c7-tiffinbox equals it until unit 34 ----
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit31/after ] || die "anchor must be the link to ../c7-unit31/after - this unit changes nothing in it"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
T31='43 e6b36271a68a44e785adb24583ae51fb'            # unit 31's after/ at its commit 4e6e7c9: 43 files (harness/tree32.py)
anchortree() { local t; t=$(python3 -I harness/tree32.py anchor/) || die "the anchor's tree could not be hashed"
  [ "$t" = "$T31" ] || die "R.211: anchor/ (../c7-unit31/after, a shipped unit's frozen tree) is not the tree this unit measured: $t, pinned $T31"
  echo "  the anchor's tree ($1): python3 -I harness/tree32.py anchor/ -> $t = pinned (unit 31's after/, frozen)"; }
# R.211: anchor/ equals ../c7-tiffinbox until a later unit changes the anchor (unit 34) - a note then, never a stop
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit31/after - a later anchor change has moved ../c7-tiffinbox on; no anchor change in this unit"; fi; }
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchortree start; anchornote start
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
HS=harness/src/probe/k
HFILES='caffeine chk32.py dur7.py ehcache logback.xml s32.py src tree32.py'
SFILES='probe/k/H.java probe/k/Main.java probe/k/Run.java probe/k/Seed.java probe/k/SqlCounter.java probe/k/ent/KCustomer.java probe/k/ent/KPause.java probe/k/ex/ExApp.java probe/k/repo/KRepo.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql pinned.txt harness/caffeine/pom.xml harness/ehcache/pom.xml; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls harness/caffeine | paste -sd' ' -)" = pom.xml ] && [ "$(ls harness/ehcache | paste -sd' ' -)" = pom.xml ] || die "harness/caffeine and harness/ehcache hold their pom.xml and nothing else"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not unit 29's, byte for byte"
cmp -s harness/tree32.py ../c7-unit31/harness/tree31.py || die "harness/tree32.py is not unit 31's tree31.py (= unit 30's tree30.py), byte for byte"
[ "$($G -c -- '<version>' harness/caffeine/pom.xml)" = 2 ] && [ "$($G -c -- '<version>' harness/ehcache/pom.xml)" = 2 ] || die "the harness poms type a version beyond the parent's and their own - every cache jar's version is the BOM's"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="20110 20111 20112 20113 20114 20115 20116 20117 20118 20119"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
docker image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - docker pull it once (this script never pulls)"
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it yourself: docker rm -f $CN"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets
echo "  the image: $IMG is on this machine (docker image inspect, the full digest; never pulled)"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
# R.252 first (s32.py reads pinned.txt): the pinned sentence, byte-equal - pinned.txt hashed here, its line whole in README.md
PIN=dbd5b67c2521ccde67a5d0f8b6039a62
[ "$(md5 -q pinned.txt)" = "$PIN" ] || die "R.252: pinned.txt is not the pinned text (md5 $(md5 -q pinned.txt), pinned $PIN) - Course 8's Cache Invalidation diffs against it"
[ "$(wc -l < pinned.txt | tr -d ' ')" = 1 ] || die "R.252: pinned.txt holds one line"
while IFS= read -r l; do $G -qxF -- "$l" README.md || die "R.252: README.md does not hold the pinned line, whole: $l"; done < pinned.txt
echo "  R.252: pinned.txt md5 $PIN (1 line), the line whole in README.md"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 + S4.7 (R.264) + R.301 (S5.18) + R.287 + R.190 + R.224, carried from unit 31's s31; S5.7 (R.290), S5.8 (R.291), R.302,
# R.303, #1516's connection scope and the loser's cache named, this unit's - per sentence, harness/s32.py, its self-test first
DW=$(python3 -I -B harness/s32.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'self-test: 48 cases · refused: 0' || die "a refused word or reading in this unit's prose (R.172, S4.7, R.301, R.287, R.190, R.224, S5.7, S5.8, R.302, R.303, #1516, the loser): $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s32, 48-case self-test): dur7 words 0 · S4.7's family 0 · R.301's family 0 · speed words 0 · R.287 old wordings 0 · R.190 the tests as a witness 0 · R.224 a call-back without its title 0 · S5.7 a ratio or a hit/miss/put triple typed, a cache claim without its three readings 0 · S5.8 stale without its writer, a native query said not to invalidate 0 · R.302 a jar, byte or warning count typed 0 · R.303 a warning quoted without its filed step 0 · #1516 a connection count unscoped 0 · Spring's cache abstraction said for Hibernate's 0 - over README.md and exercise/"
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
# R.225: a SQL string this unit shows is the logger's - outside the values block and the text blocks a run printed, none in README.md
SQLRE='update customer set|update customer k1_0|select k1_0|from customer k1_0|insert into customer|insert into pause|select ce1_0|meals_per_day=\?|version=\? where'
TS=$(awk '/^<!-- values: begin -->$/ { v = 1; next } /^<!-- values: end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print NR ": " $0 }' README.md | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md (R.225): $TS"
echo "  typed SQL strings: 0 in README.md outside its values block and the blocks the runs printed"
# R.302 (S5.19, S5.7): the cache's counts, the ratios, the jar counts and bytes and the warning counts are printed by the run, typed
# nowhere - not in the prose (fenced blocks and the values block hold what the runs print), not in this script, not in the harness
TNRE='0\.[0-9][0-9][0-9]|1,?681,?123|2,?539,?929|[0-9]+ jars|[0-9]+ (WARNING|warning|stderr) lines|hit [0-9]+ · miss [0-9]+|[0-9]+ · [0-9]+ · [0-9]+|[0-9]+/[0-9]+/[0-9]+|[0-9]+ HHH90001006'
TN=$(for f in README.md exercise/README.md exercise/SOLUTION.md; do awk -v f="$f" '/^<!-- values: begin -->$/ { v = 1; next } /^<!-- values: end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print f ":" NR ": " $0 }' "$f"; done | $G -E "$TNRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TN" ] || die "R.302: a count typed in the prose (a ratio, a hit/miss/put triple, a jar count or bytes, a warning count), outside a block a run printed and the values block: $TN"
TC=$($G -nwE '0\.800|0\.900|1681123|2539929|16 · 4 · 4|36 · 4 · 4' receipts.sh harness/chk32.py harness/src/probe/k/*.java harness/src/probe/k/*/*.java 2> /dev/null | $G -vE '^receipts.sh:[0-9]*:T[NC]=' | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a count typed in this script or the harness: $TC"
echo "  R.302: the ratios, the hit/miss/put triples, the jar counts and bytes and the warning counts typed 0 times in the prose (outside printed blocks and the values block), in receipts.sh, chk32.py and the harness's sources (s32.py's self-test aside: its refused cases are the plants' sentences)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
HSRC="$HS/H.java $HS/Main.java $HS/Run.java $HS/Seed.java $HS/SqlCounter.java $HS/ent/KCustomer.java $HS/ent/KPause.java $HS/repo/KRepo.java harness/src/probe/x/XMain.java"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HSRC")
L_DEP=$(mine 'mvn -B dependency:list dependency:copy-dependencies -DoutputDirectory=jars')
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"\$CP\" probe.k.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_RUN=$(mine "docker run -d --pull never --name $CN -p 127.0.0.1:20118:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_PSQLW=$(mine "docker exec $CN psql -U sa -d \"\$DB\" -At -v ON_ERROR_STOP=1 -c \"update customer set meals_per_day = \$NEW where name = 'Ravi'\"")
L_PSQLR=$(mine "docker exec $CN psql -U sa -d \"\$DB\" -qAt -v ON_ERROR_STOP=1 -c \"select name, meals_per_day from customer where name = 'Ravi'\"")
CPC="../hc:../anchor/$XD/lib/*:../cache-caffeine/*:../../.m2-demo/$PGJ"
CPE="../hc:../anchor/$XD/lib/*:../cache-ehcache/*"
CPN="../hc:../anchor/$XD/lib/*"
mine "CP=\"$CPC\"" > /dev/null; mine "CP=\"$CPE\"" > /dev/null; mine "CP=\"$CPN\"" > /dev/null
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds, and the three class paths"
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
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract-anchor.log 2>&1 < /dev/null || die "the extract of the anchor failed: $(tail -3 .harness/extract-anchor.log)"
for s in caffeine ehcache; do mkdir -p .harness/pom-$s; cp harness/$s/pom.xml .harness/pom-$s/
  mbuild "$(off .harness/pom-$s "$L_DEP")" .harness/dep-$s.log ".harness/pom-$s (harness/$s/pom.xml, README.md's dependency line: the $s set listed and copied)"
  mkdir -p .harness/cache-$s
  for j in $(ls .harness/pom-$s/jars); do [ -e ".harness/anchor/$XD/lib/$j" ] || cp ".harness/pom-$s/jars/$j" .harness/cache-$s/; done; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/hibernate/orm/hibernate-jcache/7.4.13.Final/hibernate-jcache-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar "$PGJ"; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
[ ! -e .harness/anchor/$XD/lib/postgresql-42.7.14.jar ] || die "the anchor's lib/ holds the PostgreSQL driver - it never did; the harness takes it from .m2-demo"
[ -z "$(ls .harness/anchor/$XD/lib | $G -iE 'jcache|cache-api|caffeine|ehcache' || true)" ] || die "the anchor's lib/ holds a cache jar - it never did"
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/k/ex ] || die "the exercise's class compiled into the wrong place"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries); the cache sets' added jars in .harness/cache-caffeine ($(ls .harness/cache-caffeine | wc -l | tr -d ' ')) and .harness/cache-ehcache ($(ls .harness/cache-ehcache | wc -l | tr -d ' ')); the harness compiled once - .harness/hc against the anchor's libraries alone; the PostgreSQL driver: .m2-demo/$PGJ (md5 $(md5 -q "$M2/$PGJ"))"

# ---- the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214) ------------
# CSTARTED is set before docker run, so an interrupt during its start removes it too
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(docker port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20118' ] || die "docker port: the container must publish 5432 on 127.0.0.1:20118 alone: $DP"
[ "$(listeners 20118)" -ge 1 ] || die "nothing listens on 20118 after the container started"
echo "  the container: $CN from $IMG (--pull never); docker port: $DP; user sa, the password generated into .harness/secrets/pgpw (24 characters, mode 0600, never printed); pg_isready after $i tries (cap 120)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0; PGJVM=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v pw="$PW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { W = lit(pw); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(W, "<pw>"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/SessionImpl\([0-9]+</, "SessionImpl(<n><")
    gsub(/\$\$Lambda\/0x[0-9a-f]+/, "$$Lambda/<n>")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/ \(20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)$/, "")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting Main using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" "file:$(printf '%s' "$U" | sed 's/ /%20/g')/.harness/cache-ehcache/e.jar" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 2 JPA repository interfaces.' "url jdbc:postgresql://127.0.0.1:20118/u32trap?user=sa&password=$PW" 'JDBC [x.HibernateTransactionManager$$Lambda/0x000003ff01b8a310@5d9576a0]' 'JDBC driver H2 JDBC Driver 2.5.250 (2026-08-29)' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting Main using Java <version>' '…/x' '…/../y' '~/z' 'file:…/.harness/cache-ehcache/e.jar' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 2 JPA repository interfaces.' 'url jdbc:postgresql://127.0.0.1:20118/u32trap?user=sa&password=<pw>' 'JDBC [x.HibernateTransactionManager$$Lambda/<n>@…]' 'JDBC driver H2 JDBC Driver 2.5.250')" ] || die "mask: the planted JDK version, folders (plain and %20-encoded), home, identity hash, EntityManager identity, scan time, the password, a lambda class's address and H2's build date must be masked"
echo "  mask: its self-test passed (the password, folders plain and %20-encoded, home, identities, times, H2's build date); raw password copies after mask: $(mask < .harness/p1 | $G -cF -- "$PW" || true)"
rm -f .harness/p1
KEYS=(--spring.jpa.properties.hibernate.cache.use_second_level_cache=true --spring.jpa.properties.hibernate.cache.region.factory_class=jcache "--spring.jpa.properties.hibernate.javax.cache.provider=\$PROVIDER" --spring.jpa.properties.jakarta.persistence.sharedCache.mode=ENABLE_SELECTIVE)
CREATE=--spring.jpa.properties.hibernate.javax.cache.missing_cache_strategy=create
QC=--spring.jpa.properties.hibernate.cache.use_query_cache=true
PCAF=com.github.benmanes.caffeine.jcache.spi.CaffeineCachingProvider
PEHC=org.ehcache.jsr107.EhcacheCachingProvider
HQ=(--logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.jpa.open-in-view=false --spring.jpa.properties.hibernate.generate_statistics=true --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
HA=('--spring.datasource.url=jdbc:h2:mem:u32;DB_CLOSE_DELAY=-1' "${HQ[@]}")
HE=""
keys() { local p=$1 k; for k in "${KEYS[@]}"; do printf '%s\n' "${k/\$PROVIDER/$p}"; done; }
# hrun [latch]: one harness JVM, its stdout to .harness/h.log and its stderr to a file of its own, .harness/h.err (the JVM's own
# warnings go there); with "latch" its stdin is the FIFO and this script does the outside write while it waits
hrun() { local c i=0 e=0 n o
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  if [ "${HL:-$L_H}" != "$L_X" ]; then echo "\$ CP=\"$CP\""; echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; fi
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c > .harness/h.log 2> .harness/h.err${1:+ < $FIFO}"
  if [ "${1:-}" = latch ]; then
    rm -f "$FIFO"; mkfifo "$FIFO" || die "mkfifo failed"
    (eval "$(exe "$c")") > .harness/h.log 2> .harness/h.err < "$FIFO" & pid=$!
    exec 4> "$FIFO"; LOPEN=1
    while kill -0 "$pid" 2> /dev/null && [ $i -lt 960 ] && ! $G -q '^PROBE ready: ' .harness/h.log; do sleep 0.25; i=$((i + 1)); done
    $G -q '^PROBE ready: ' .harness/h.log || { cat .harness/h.log >&3; die "the latched JVM never printed its ready line"; }
    o=$(sed -n 's/^PROBE ready: phase 1 done, Ravi read \([0-9][0-9]*\) - .*$/\1/p' .harness/h.log)
    [ -n "$o" ] || die "the ready line names no value"
    NEW=$((o + 1))
    echo "the JVM printed its ready line and blocks on System.in.read(); the receipt's outside write - psql in the container (another process, the container's own socket, no password on its command line), the value this script chose: the JVM's read, $o, plus 1 = $NEW:"
    echo "\$ DB=$DB; NEW=$NEW; $L_PSQLW"
    (eval "$L_PSQLW") > .harness/psql.out 2>&1 < /dev/null || die "psql's write failed: $(cat .harness/psql.out)"
    sed 's/^/  psql: /' .harness/psql.out
    echo "\$ DB=$DB; $L_PSQLR"
    (eval "$L_PSQLR") > .harness/psql.out 2>&1 < /dev/null || die "psql's read failed: $(cat .harness/psql.out)"
    sed 's/^/  database truth (psql, another process): /' .harness/psql.out
    echo "the receipt writes one byte to the FIFO; the JVM goes on:"
    printf 'x' >&4; exec 4>&-; LOPEN=""
    i=0
  else
    (eval "$(exe "$c")") > .harness/h.log 2> .harness/h.err < /dev/null & pid=$!; fi
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log; rm -f "$FIFO"
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"
  case " ${V[*]:-} " in *" -Dpg.db="*) PGJVM=$((PGJVM + 1)); n=$(raw "$PW" .harness/h.log .harness/h.err); [ "$n" = 0 ] || die "a harness log held the password, raw ($n)"; echo "  raw password copies in its log and its stderr: $n (before the mask; the URL is printed cut before its ?)" ;; esac; }
# hview: the harness JVM's log - its org.hibernate.SQL lines counted, not shown; its WARN lines and HHH90001006 lines counted by
# grep -c (R.302); then its stderr, a file of its own: its lines, and its WARNING: and objectFieldOffset lines counted by grep -c
hview() { awk '/ org\.hibernate\.SQL : / { q++; next } /HHH90001006/ { next } /^$/ { next } { gsub(/\t/, "    "); sub(/[ \t]+$/, ""); print "  " $0 }
    END { print "  its org.hibernate.SQL lines (counted, not shown here): " q + 0 }' .harness/h.log
  $G 'HHH90001006' .harness/h.log | sort | sed 's/^/  (sorted; Hibernate creates the regions in no fixed order) /' || true
  echo "  its WARN lines (grep -c '^WARN '): $($G -c '^WARN ' .harness/h.log || true) · HHH90001006 lines (grep -c 'HHH90001006'): $($G -c 'HHH90001006' .harness/h.log || true)"
  echo "  its stderr (.harness/h.err): $(wc -l < .harness/h.err | tr -d ' ') lines · grep -c '^WARNING:' $($G -c '^WARNING:' .harness/h.err || true) · grep -c 'objectFieldOffset' $($G -c 'objectFieldOffset' .harness/h.err || true)"
  sed 's/^/  stderr: /' .harness/h.err
  echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
# pgdb NAME: a fresh database for the next PostgreSQL JVM (dropped first, if a run left it)
pgdb() { DB=$1; echo "\$ DB=$DB; $L_DB"; (eval "$L_DB") > .harness/pgdb.log 2>&1 < /dev/null || die "the fresh database $DB was not made: $(tail -2 .harness/pgdb.log)"
  echo "  a fresh database: $DB"; }
# h2 / pg CP SCEN [more V] -- [more A]: one harness JVM on H2 (this JVM's memory) or on the run's fresh PostgreSQL database
h2() { CP=$1; local s=$2; shift 2; V=(-Ds=$s); while [ $# -gt 0 ] && [ "$1" != -- ]; do V+=("$1"); shift; done; [ $# -gt 0 ] && shift
  A=("${HA[@]}" "$@"); hrun; hview; }
pg() { CP=$1; local s=$2 l=""; shift 2; pgdb "u32$s"; V=(-Ds=$s); while [ $# -gt 0 ] && [ "$1" != -- ]; do [ "$1" = -Dlatch=stdin ] && l=latch; V+=("$1"); shift; done; [ $# -gt 0 ] && shift
  V+=(-Dpg.db=u32$s -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" "$@"); hrun $l; hview; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
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
dset() { local s=$1 j n b
  echo "the $s set - harness/$s/pom.xml, dependency:list (its build step's log, .harness/dep-$s.log), each line, and whether the anchor's lib/ holds its jar:"
  $G -E '^\[INFO\]    [^ ]+:[^ ]+:jar:' .harness/dep-$s.log | sed -E 's/^\[INFO\]    //; s/ -- module .*$//' | while IFS= read -r l; do
    j=$(printf '%s\n' "$l" | awk -F: '{ if (NF == 6) print $2 "-" $5 "-" $4 ".jar"; else print $2 "-" $4 ".jar" }')
    if [ -e ".harness/anchor/$XD/lib/$j" ]; then echo "  $l - in the anchor's lib/ ($j)"; else echo "  $l - added ($j)"; fi; done
  echo "ls -l .harness/cache-$s (the jars dependency:copy-dependencies copied that the anchor's lib/ does not hold) - bytes and name:"
  (cd .harness/cache-$s && ls -l) | awk 'NR > 1 { print "  " $5 " " $NF }'
  n=$(ls .harness/cache-$s | wc -l | tr -d ' '); b=$( (cd .harness/cache-$s && ls -l) | awk 'NR > 1 { s += $5 } END { print s + 0 }')
  echo "  the $s set, added: $n jars, $b bytes (ls | wc -l; ls -l's sizes summed by awk) · dependency:list's 'added' lines: $(dset_added $s)"
  echo "  in the anchor's lib/ already: $(dset_in $s)"; }
dset_added() { $G -E '^\[INFO\]    [^ ]+:[^ ]+:jar:' .harness/dep-$1.log | sed -E 's/^\[INFO\]    //; s/ -- module .*$//' | awk -F: -v d=".harness/anchor/$XD/lib/" '{ j = (NF == 6) ? $2 "-" $5 "-" $4 ".jar" : $2 "-" $4 ".jar"; if (system("test -e \"" d j "\"") != 0) n++ } END { print n + 0 }'; }
dset_in() { (cd .harness/pom-$1/jars && ls) | while IFS= read -r j; do [ -e ".harness/anchor/$XD/lib/$j" ] && printf '%s\n' "$j"; done | paste -sd' ' - ; }
setup() {
  echo "setup - switching it on, on H2; the anchor's lib/ holds $(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') jars (ls | wc -l), none of them a cache jar:"
  dset caffeine; dset ehcache
  echo "(ii)-(iv) Caffeine's set, the four keys, the default missing_cache_strategy (the keys and the regions read off the run):"
  h2 "$CPC" setup -- $(keys $PCAF)
  echo "the same with the fifth key, missing_cache_strategy=create:"
  h2 "$CPC" setup -- $(keys $PCAF) $CREATE
  echo "(v) the anchor's libraries as they are - no cache module, no provider - with the four keys (a filed refusal: R.303):"
  h2 "$CPN" setup -- $(keys $PCAF)
  echo "the anchor's libraries as they are, the keys off (the labelled control): K = 5 rounds, the same reads:"
  h2 "$CPN" ratio -DK=5
  echo "(vi) the loser, labelled: Ehcache's set, the four keys (its provider) and the fifth, K = 5 rounds, the same reads:"
  h2 "$CPE" ratio -DK=5 -- $(keys $PEHC) $CREATE; }
ratio() { echo "ratio - K rounds over the seeded customers, each em.find in its own transaction; Caffeine's set, the four keys and the fifth; H2:"
  h2 "$CPC" ratio -DK=5 -- $(keys $PCAF) $CREATE
  h2 "$CPC" ratio -DK=10 -- $(keys $PCAF) $CREATE; }
trap32() { echo "trap - a write Hibernate never saw, then Hibernate's own writes; Caffeine's set, the four keys and the fifth:"
  echo "H2 (in the harness JVM's memory; the outside writer is plain JDBC in the same JVM - a second java.sql.Connection, no server, no FIFO):"
  h2 "$CPC" trap -- $(keys $PCAF) $CREATE
  echo "PostgreSQL (the container, a fresh database; the outside writer is psql in the container, run by this script while the JVM waits on its stdin, a FIFO):"
  pg "$CPC" trap -Dlatch=stdin -- $(keys $PCAF) $CREATE; }
query() { echo "query - the query cache on (use_query_cache=true); Caffeine's set, the four keys and the fifth:"
  echo "H2 (in the harness JVM's memory):"; h2 "$CPC" query -- $(keys $PCAF) $CREATE $QC
  echo "PostgreSQL (the container, a fresh database):"; pg "$CPC" query -- $(keys $PCAF) $CREATE $QC; }
X31=9cf92b8cae3abfd0f1c0706bfe7a4373                # Hibernate's script since unit 27's C2 - ../c7-unit31/xcheck.sql; no mapping moves in 32
[ "$(md5 -q xcheck.sql)" = "$X31" ] && cmp -s xcheck.sql ../c7-unit31/xcheck.sql || die "xcheck.sql is not ../c7-unit31/xcheck.sql (md5 $X31)"
XA=('--spring.datasource.url=jdbc:h2:mem:x32;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL over the anchor's libraries - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed, no cache entity), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql; V=(); A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script over the anchor's libraries"
  mv .harness/run/hibernate-ddl.sql .harness/ddl-anchor.sql
  echo "  .harness/ddl-anchor.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-anchor.sql
  echo "  its md5: $(md5 -q .harness/ddl-anchor.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-anchor.sql xcheck.sql && echo 'the same, byte for byte' || echo differ) · the fetch-plan lesson's xcheck.sql: $(cmp -s .harness/ddl-anchor.sql ../c7-unit31/xcheck.sql && echo 'the same, byte for byte' || echo differ)"; }
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
  o=$(python3 -I -B harness/chk32.py "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk32.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  has "$XC" "  its md5: $X31 · the filed xcheck.sql: $X31 · cmp: the same, byte for byte · the fetch-plan lesson's xcheck.sql: the same, byte for byte" "xcheck: the anchor's script = unit 31's, byte for byte (no mapping moved)"
  [ "$(cnt "$XC" '  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final')" = 1 ] || die "xcheck: HHH000001"
  ! $G -qi 'cache' .harness/ddl-anchor.sql || die "xcheck: the script names a cache - the harness's @Cache is not on the schema"
  echo "  xcheck: the anchor's script $X31 = xcheck.sql = ../c7-unit31/xcheck.sql; no line names a cache"; VALS="$VALS · xcheck: $X31"; }
EXQ="Your turn: the README's cache keeps serving Ravi's old meals after a plain JDBC update changed them. Make the next read see the database."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
chk_exercise() { local EB EZ b ER ES w x
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    has "$ER" '    the JVM: exit 0' "exercise: the README runs"; has "$ES" '    the JVM: exit 0' "exercise: the solution runs"
    x=$(python3 -I -c '
import re, sys
def pts(t):
    r = re.findall(r"^    PROBE read (\d): Ravi.s meals (\d+) · region hit (\d+) · miss (\d+)$", t, re.M)
    w = re.findall(r"^    PROBE plain JDBC set Ravi.s meals to (\d+)$", t, re.M)
    return [(int(a), int(b), int(c), int(d)) for a, b, c, d in r], [int(v) for v in w]
(br, bw), (so, sw) = pts(sys.argv[1]), pts(sys.argv[2])
ok = len(br) == 2 and len(so) == 2 and len(bw) == 1 and len(sw) == 1 and br[0] == so[0] and bw == sw
ok = ok and bw[0] == br[0][1] + 1 and br[1][1] == br[0][1] and br[1][2] == 1 and br[1][3] == 0
ok = ok and so[1][1] == sw[0] and so[1][2] == 0 and so[1][3] == 1
print(("PASS" if ok else "FAIL") + " the README: read 1 %s, plain JDBC %s, read 2 %s (hit %s, miss %s); the solution: read 2 %s (hit %s, miss %s)" % (
    br[0][1] if br else "-", bw[0] if bw else "-", br[1][1] if len(br) > 1 else "-", br[1][2] if len(br) > 1 else "-", br[1][3] if len(br) > 1 else "-",
    so[1][1] if len(so) > 1 else "-", so[1][2] if len(so) > 1 else "-", so[1][3] if len(so) > 1 else "-"))' "$ER" "$ES")
    case $x in PASS*) ;; *) die "exercise: the broken read 2 the old value, a hit; the solution's read 2 the new value, a miss (R.196): $x" ;; esac
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
cap setup setup; chk setup setup .r-setup.out; pub setup
cap ratio ratio; chk ratio ratio .r-ratio.out .r-setup.out; pub ratio
cap trap trap32; chk trap trap .r-trap.out; pub trap
cap query query; chk query query .r-query.out; pub query
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# R.302: every line of README.md's ```text blocks is a line a run printed - a capture's or a check's (leading spaces aside)
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
# R.303: Ehcache's first stderr line and the refusal's cause, quoted in README.md, are lines of their filed steps (setup)
for q in 'stderr: WARNING: A terminally deprecated method in sun.misc.Unsafe has been called' 'PROBE caused by: java.lang.ClassNotFoundException: Could not load requested class: jcache'; do
  $G -qF -- "$q" .r-setup.out || die "R.303: the quoted line is not in its filed step's capture (setup): $q"
  $G -qF -- "${q#stderr: }" README.md || die "R.303: README.md does not quote its filed line: $q"; done
echo "  R.303: Ehcache's first stderr line and the start's refusal without the module - each quoted in README.md and found in the setup capture's labelled step"
VS="the values the video may say: on H2 2.5.250 and PostgreSQL 18.6, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - $VALS · pinned.txt: $PIN"
printf '%s\n' "$VS" > .harness/values.txt
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"
# hygiene: every capture and every file this unit holds - 0 raw passwords
for f in .harness/rawpw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the password ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the password, raw"; done
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
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b|[0-9] ns ' "$f" || die "$f holds a millisecond or nanosecond figure (R.207)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'password=[^<]' "$f" || die "$f holds a password in a URL"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -q . || die "$f holds a URL"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.k' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep|while *\(true\)|TimeUnit\.[A-Z]+\.sleep|LockSupport\.park' harness/src || die "a harness sleeps or polls (S4.18): the latch is System.in.read()"
[ "$($G -c '= System\.in\.read();' $HS/Run.java)" = 1 ] && [ "$($G -rc 'System\.in\.read' harness/src | awk -F: '{ s += $2 } END { print s }')" = "$($G -c 'System\.in\.read' $HS/Run.java)" ] || die "the latch: Run.java blocks on System.in.read() once, and nothing else in the harness reads stdin"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o -type p -print)" ] || die "a FIFO exists outside .harness"
echo "  hygiene: raw password copies after mask: 0 in $(ls .harness/rawpw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs, $PGJVM of them on PostgreSQL); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond or nanosecond figure, thread number, OS token, unmasked identity, password, URL or stack frame in any capture; every JVM pinned and under its alarm; no kill by name; no bare wait; no sleep or polling loop in the harness (the latch: System.in.read() once); no H2 file; no FIFO outside .harness"
# ---- the end: the anchor, the container, the ports ------------------------------------------------------------------------
pgrm; [ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
anchortree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20110-20119 at the end - the container bound 20118 and was removed; 20110-20117 and 20119 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit32: every capture 3/3 and = published; every spoken number asserted; 0 raw passwords; no port bound but 20118"
