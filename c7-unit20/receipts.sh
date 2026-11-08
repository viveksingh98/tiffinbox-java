#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Paging and Sorting - this unit's receipts. No change to the anchor (brief ⚑11): anchor/ is the link to
# ../c7-unit17/after, Section 3's frozen anchor. A page is a query and a count; a slice is a query and one extra row; OFFSET
# walks every row it skips, keyset asks for what comes after the last row it saw. Two databases (brief ⚑2: 20 is the one Postgres
# unit): H2 in each JVM's memory, and PostgreSQL 18 in a container this script starts on 127.0.0.1:19998 and removes on every exit.
# Eight captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every number and string
# the video says is asserted right after its capture by a check that can fail.
#   page      Page vs Slice (H2, one harness JVM): a Page = its SELECT + a count; a Slice = its SELECT alone, one row more; page 0
#             has no offset clause, a later page offset ? rows fetch first ? rows only; no count when page 0 is not full (S3.11)
#   sort      Sort (H2 and PostgreSQL, one JVM each): two keys; a misspelt property at the call (S3.9, S3.10); a sort across the
#             join - NULLs first on H2, last on PostgreSQL - the ordering key printed per row, never the names among ties (S3.7)
#   count     the join's count (H2, three JVMs: B, A, A'): B the join without distinct - Sunil's two pauses count twice, total 3;
#             A select distinct - count(distinct ...), total 2; A' = A; the second connection's count(distinct customer_id) beside
#   keyset    Window and ScrollPosition (H2, one JVM): keyset() adds the id to the order by, positionAt(1), the next windows'
#             predicate (S3.4), three windows walk six; an offset scroll on its own method (⚑10); WindowIterator, capped (S3.16)
#   trap      labelled - measured on Spring Data JPA 4.1.2 (H2, three JVMs: A keyset() · B offset() then keyset() on one method ·
#             A' = A): B runs the offset SQL for the keyset position, the first window again, the iterator capped at 10
#   time      OFFSET vs keyset, the fixed design (⚑5; three JVMs per database, a fresh database each): 1,000,000 generated rows +
#             the seed's, counted; per round pages r / last-r, keyset after 20r / last-20r (r = round % 7), the depth pages; every
#             call's rows and first and last id checked every round; W 10, R 9; the SQL logger at WARN while timing; the three
#             threshold lines and the depth line hashed, the figures printed and masked (R.207); the plans (S3.14): PostgreSQL's
#             explain (analyze, timing off, summary off, costs off, buffers off) of the captured SELECTs with their bound values,
#             H2's EXPLAIN ANALYZE scanCount beside them, labelled H2
#   xcheck    the harness's DDL script (@EntityScan("com.tiffinbox") alone, scripts.action=create) against the owning-side
#             lesson's published md5: no mapping moved (R.212, brief ⚑3)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# No anchor change: anchor/ equals ../c7-tiffinbox until a later unit changes the anchor - printed at the start and the end, a note
# then, never a stop (R.211). The anchor is COPIED under .harness/anchor and built there (its README's package line, offline; its
# tests run); its jar extracted (the anchor's own line). The harness (harness/src, probe.q and probe.x) is compiled against the
# anchor's extracted libraries with javac -parameters into .harness/hc: probe.q.Main is a Spring Boot context with no web server
# (WebApplicationType.NONE: it binds no port) over those libraries, @EntityScan on com.tiffinbox, @EnableJpaRepositories on
# probe.q.repo (Customers). probe.q.Seed builds the shipped Database in code on the run's database, which seeds it; Hibernate
# writes no schema (ddl-auto none), its statistics are on. On PostgreSQL the harness reads the password from .harness/secrets/pgpw
# (generated here, never printed, never on a command line); the PostgreSQL JDBC driver 42.7.14 comes from .m2-demo. Its JVM flags
# travel as an array, V, its arguments as an array, A (R.193). Every JVM runs under an alarm (perl -e 'alarm N; exec ...': 120 for
# a harness JVM, 300 for a timing JVM); an alarm that fires is a failed receipt (R.247). Commands are printed exactly as they run.
# harness/dur7.py (Course 7's builders' duration pattern, byte for byte) gates this unit's prose: 20 is the one unit of the section
# that speaks time - the words it may use are listed in README.md, every other duration word is refused, and each listed word rests
# on time's threshold lines (R.172, ⚑5). "$M2" is this unit's own repository, .m2-demo.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); at run time the only connection
# is the loopback JDBC (and docker exec) to this script's own container. This unit reads no version file: the section's dated sweep
# is the brief's (R.223; _research/spring-boot-metadata-2026-11-07.xml).
# Masks (README.md declares each; awk gsub only): this folder "…", the folder above it "…/..", home "~", your user name "<user>";
# " using Java <version>"; an identity hash "@…"; Spring Data's scan time "scanning in <n> ms"; H2's generated names
# "CONSTRAINT_<n>", "CONSTRAINT_INDEX_<n>"; the figures of a "PROBE ms" line (a timing) "<n>" - those lines print whole to the
# terminal, outside the capture. The PostgreSQL password, after each PostgreSQL JVM: "<pw>" (its raw copies counted, 0 asserted).
# Ports (§P, 19990-19999): 19998 is the container's (127.0.0.1 only); no JVM binds one. 19990-19997 and 19999, 18425, 8080 and 35729
# are checked free at the start and the end; 19998 free at the start and after the container is removed; 19999 is never bound.
set -e
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
CN=c7u20-pg
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started: $pid (a JVM), $mpid (a Maven or a javac, with
# every process under it), $xpid (an exercise shell, with every process under it); sweep() its process group; then the container,
# if this script created it (CSTARTED), is removed (docker rm -f). After an interrupt a capture's unfinished runs (.r-NAME.1-3) go
# too; after a failed check they stay. The clean-up ignores a second Ctrl-C, and the script still exits 130 after an interrupt.
pid=""; mpid=""; xpid=""; CSTARTED=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.q.") || index($0, "probe.x.") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "docker exec c7u20-pg")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
# pgrm: docker rm -f, again until docker ps -a names it no more (at least three tries, 0.5 apart, at most 20): a docker run cut by
# Ctrl-C may leave the daemon creating the container after the first rm found nothing
pgrm() { local i=0; [ -n "$CSTARTED" ] || return 0
  while [ $i -lt 20 ]; do docker rm -f "$CN" > /dev/null 2>&1 || true
    [ $i -ge 2 ] && [ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] && break
    sleep 0.5; i=$((i + 1)); done; CSTARTED=""; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find docker /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS PGPASSWORD PGUSER; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - the password lives under .harness/secrets, generated by each run"
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit17/after ] || die "anchor must be the link to ../c7-unit17/after - Section 3's frozen anchor; this unit changes nothing in it"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): anchor/ = ../c7-unit17/after (frozen); diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit17/after (frozen) - no anchor change in this unit"; fi; }
anchornote start
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted
HS=harness/src/probe/q
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
HFILES='dur7.py logback.xml src'
SFILES='probe/q/Main.java probe/q/Run.java probe/q/Seed.java probe/q/ex/ExApp.java probe/q/repo/Customers.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19990 19991 19992 19993 19994 19995 19996 19997 19999"
for p in $PORTS 19998; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
# the container: its image must be on this machine (never pulled), and no container of its name may exist - this script never
# removes a container it did not create
docker image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - docker pull it once (this script never pulls)"
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it yourself: docker rm -f $CN"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets; chmod 700 .harness/secrets

# ---- the prose gates: the duration words 20 may speak (R.172, ⚑5); English names (R.215); placeholders; typed values ---------
# 20 speaks time - as ratios on this Mac, never a figure of elapsed time. dur7.DUR's matches over README.md and the exercise's files
# must each be one of DWL (listed in README.md, its "Duration words" line, asserted whole); each listed word rests on time's
# threshold lines, asserted after time (every JVM, both databases). Every other duration word stops the run.
DWL='slow slower faster'
DWLINE="**Duration words this unit speaks** (dur7.DUR's matches, each one of these three, any case; every other duration word is refused): slow · slower · faster"
cat > .harness/dur.py <<'PY'
import importlib.util, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
ok = set(sys.argv[2].split()); n = 0; bad = 0; seen = {}
for f in sys.argv[3:]:
    for i, l in enumerate(open(f, encoding="utf-8"), 1):
        for w in m.DUR.finditer(l):
            n += 1; k = w.group(0).lower(); seen[k] = seen.get(k, 0) + 1
            if k not in ok:
                bad += 1; print("  %s line %d: %s  <- not one of the words this unit lists" % (f, i, w.group(0)))
print("duration words: %d (%s) · outside the list: %d" % (n, ", ".join("%s %d" % (k, seen[k]) for k in sorted(seen)), bad))
PY
DW=$(python3 -I -B .harness/dur.py harness/dur7.py "$DWL" README.md exercise/README.md exercise/SOLUTION.md) || die "dur7's gate did not run"
printf '%s\n' "$DW" | tail -1 | $G -qE ' · outside the list: 0$' || die "dur7.DUR found a duration word this unit does not list (R.172, ⚑5): $(printf '%s\n' "$DW" | $G 'not one of' | paste -sd';' -)"
$G -qxF -- "$DWLINE" README.md || die "README.md must list the duration words it speaks, in its line: $DWLINE"
DWN=$(printf '%s\n' "$DW" | tail -1 | sed -n 's/^duration words: \([0-9]*\) .*/\1/p')
echo "  $(printf '%s\n' "$DW" | tail -1) - over README.md, exercise/README.md, exercise/SOLUTION.md; the list: $DWL"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness/src)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose - the exercise's blocks hold the measured output: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty (exercise compares it with the run, line for line)"
OLDP='org\.springframework\.data\.mapping\.PropertyReferenceException'
OP=$($G -rnE -- "$OLDP" README.md exercise harness/src 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$OP" ] || die "a line names the exception by the package it does not have on Spring Data JPA 4.1.2 - S3.10 (R.241): $OP"
echo "  S3.10's refused class name: 0 lines over README.md, exercise/, harness/src"
# S3.12: the row count is the load's own, read back by select count(*) - "a million" is never typed, and the count itself stands
# only in the lines this script composes (the values line, the design table)
VALP='the values the video may say:'
MIL=$($G -niE '\bmillion\b|1,000,00[0-9]|1 000 00[0-9]' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$MIL" ] || die "a typed row count - the load's count is read back by select count(*) and composed, never typed (S3.12): $MIL"
NT=$($G -nE '\b1000004\b' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF -- "$VALP" | $G -vE '^([a-zA-Z/.]+:)?[0-9]+:\| rows \(select count\(\*\)\) \| ' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$NT" ] || die "the row count typed outside the values line and the design table (S3.12): $NT"
echo "  typed row counts: 0 ('a million' refused; the count stands in the values line and the design table, composed from time)"
# S3.14: a plan on a slide is actual rows only - no cost, no time, no planning or execution figure
PC=$($G -niE 'cost=|actual time|time=|Planning( Time)?:|Execution Time|width=' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PC" ] || die "a plan with costs or times (S3.14: explain (analyze, timing off, summary off, costs off, buffers off), actual rows only): $PC"
echo "  plan text: no cost, time, width, planning or execution line (S3.14)"
# R.225, R.227: a SQL string this unit shows is the logger's, composed into README.md's values line and its plan block by this
# script - a line holding Hibernate's aliases (ce1_0., p1_0.) anywhere else is a typed SQL string, refused
TS=$($G -nE 'ce1_0\.|p1_0\.' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF -- "$VALP" | $G -vE '^([a-zA-Z/.]+:)?[0-9]+:PROBE plan \(PostgreSQL\) ' | $G -vE '^exercise/[A-Z]+\.md:[0-9]+:org\.hibernate\.SQL : ' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string outside README.md's values line and plan block and the exercise's measured blocks (R.225, R.227): $TS"
echo "  typed SQL strings: 0 outside README.md's values line and plan block and the exercise's measured blocks"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 120; exec @ARGV'"; ALT="perl -e 'alarm 300; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/Main.java $HS/Run.java $HS/Seed.java $HS/repo/Customers.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*\" probe.q.Main \"\${A[@]}\"")
L_HT=$(mine "$ALT java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*\" probe.q.Main \"\${A[@]}\"")
L_P=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*:../../.m2-demo/$PGJ\" probe.q.Main \"\${A[@]}\"")
L_PT=$(mine "$ALT java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*:../../.m2-demo/$PGJ\" probe.q.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_RUN=$(mine "docker run -d --pull never --name $CN -p 127.0.0.1:19998:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: the anchor copied and built with its README's package line offline (its tests run); its jar extracted; the harness
# ---- compiled against its libraries ---------------------------------------------------------------------------------------
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
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/anchor/
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/, its README's package line; its tests ran)"
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar com/h2database/h2/2.5.250/h2-2.5.250.jar $PGJ; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
jc "$L_JAVAC" .harness/javac.log
[ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/q/ex ] || die "the exercise's class was compiled into the harness - it is compiled on its own"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries); the harness compiled into .harness/hc ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes); the PostgreSQL driver: .m2-demo/$PGJ (md5 $(md5 -q "$M2/$PGJ"))"

# ---- the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a file (R.214) ---------------
# CSTARTED is set before docker run, so an interrupt during its start removes it too
LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] || die "the password file was not written"
chmod 644 .harness/secrets/pgpw                      # the container's postgres user reads it through the bind mount
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
[ "$(docker inspect -f '{{range $p, $b := .NetworkSettings.Ports}}{{$p}} {{range $b}}{{.HostIp}}:{{.HostPort}}{{end}}{{end}}' "$CN")" = '5432/tcp 127.0.0.1:19998' ] || die "the container must publish 5432 on 127.0.0.1:19998 alone"
echo "  the container: $CN from $IMG (--pull never), 5432/tcp on 127.0.0.1:19998 only; user sa, the password generated into .harness/secrets/pgpw (24 characters, never printed); pg_isready after $i tries (cap 120)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
LOGS=0; GENW=0; PGJVM=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/CONSTRAINT_INDEX_[0-9A-F]+/, "CONSTRAINT_INDEX_<n>"); gsub(/CONSTRAINT_[0-9A-F]+ /, "CONSTRAINT_<n> ")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    if ($0 ~ /^ *PROBE ms /) gsub(/ *[0-9]+\.[0-9]+/, " <n>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_52 INDEX PUBLIC.CONSTRAINT_INDEX_5 ON PUBLIC.CUSTOMER' '  PROBE ms median offset-last     69.353 ms (R 9)' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_<n> INDEX PUBLIC.CONSTRAINT_INDEX_<n> ON PUBLIC.CUSTOMER' '  PROBE ms median offset-last <n> ms (R 9)')" ] || die "mask: the planted JDK version, folders, home, identity hash, scan time, H2's generated names and a timing figure must be masked"
rm -f .harness/p1
# the harness's arguments: the run's own database (H2: in this JVM's memory; PostgreSQL: the URL built by Main from -Dpg.db), the
# harness's Logback file, no schema written, no banner, Thymeleaf not looking for templates, Hibernate's statistics on
HQ=(--logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.hibernate.generate_statistics=true)
HA=('--spring.datasource.url=jdbc:h2:mem:u20;DB_CLOSE_DELAY=-1' "${HQ[@]}")
# pgdb NAME: a fresh PostgreSQL database (dropped with force if it is there, created) - printed, its exit asserted
pgdb() { DB=$1; echo "\$ DB=$DB"; echo "\$ $L_DB"
  (eval "$L_DB") > .harness/psql.log 2>&1 < /dev/null || die "psql could not make the database $DB: $(tail -2 .harness/psql.log)"
  echo "  exit 0 · a fresh database $DB"; }
# hrun: the harness line (V, A set by the caller; HL the line), run from .harness/run; it exits by itself (its alarm); its exit
# code in HE; its log .harness/h.log. After a PostgreSQL JVM the password is masked in the log and its raw copies counted (0).
HE=""
hrun() { local c i=0 e=0 lim=520 n
  case "$HL" in *"alarm 300;"*) lim=1240 ;; esac
  c=$(printf 'cd .harness/run && %s\n' "$HL")
  [ "$HL" = "$L_X" ] || echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt $lim ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running past its alarm - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  case "$HL" in *postgresql-42*) PGJVM=$((PGJVM + 1))
    n=$($G -c -- "$PW" .harness/h.log || true); sed -i '' "s/$PW/<pw>/g" .harness/h.log
    n=$($G -c -- "$PW" .harness/h.log || true); [ "$n" = 0 ] || die "a raw copy of the password survived the mask"
    echo "  raw password copies in its log after the mask: $n" ;; esac
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"; }
# hview: the harness's whole log, trailing spaces dropped; a timing's "PROBE ms" lines also to the terminal, whole; its exit code
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log
  $G '^PROBE ms ' .harness/h.log | sed "s/^/  (terminal only) ${TL:-} /" >&3 || true
  [ -z "${TL:-}" ] || $G '^PROBE ms ratios' .harness/h.log | sed "s/^/$TL /" >> .harness/ratios.log || true
  echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- the captures -----------------------------------------------------------------------------------------------------------
h2() { HL=$L_H; A=("${HA[@]}"); hrun; hview; }
c_page() { echo "Page vs Slice - one harness JVM, H2 (.harness/hc):"; V=(-Ds=page); h2; }
c_sort() { echo "sort - H2 (one harness JVM):"; V=(-Ds=sort); h2
  echo "sort - PostgreSQL (one harness JVM, a fresh database):"; pgdb u20s
  V=(-Ds=sort -Dpg.db=u20s -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}"); HL=$L_P; hrun; hview; }
c_count() { echo "B - the join without distinct (one harness JVM, H2):"; V=(-Ds=count -Dv=B); h2
  echo "A - select distinct (one harness JVM, H2):"; V=(-Ds=count -Dv=A); h2
  echo "A' - A again, in a fresh JVM:"; V=(-Ds=count -Dv=A); h2; }
c_keyset() { echo "keyset - one harness JVM, H2:"; V=(-Ds=keyset); h2; }
c_trap() { echo "A - keyset() on a method no offset position has reached (one harness JVM, H2):"; V=(-Ds=trap -Dv=A); h2
  echo "B - offset() first, then keyset() on the same method (one harness JVM, H2):"; V=(-Ds=trap -Dv=B); h2
  echo "A' - A again, in a fresh JVM:"; V=(-Ds=trap -Dv=A); h2; }
c_time() { local k
  for k in 1 2 3; do echo "time - H2, JVM $k of 3 (its own database in its memory):"
    TL="run $CAPRUN H2 JVM $k:"; V=(-Ds=time); A=("--spring.datasource.url=jdbc:h2:mem:u20t$k;DB_CLOSE_DELAY=-1" "${HQ[@]}"); HL=$L_HT; hrun; hview; TL=""; done
  for k in 1 2 3; do echo "time - PostgreSQL, JVM $k of 3 (a fresh database):"; pgdb u20t$k
    TL="run $CAPRUN PostgreSQL JVM $k:"; V=(-Ds=time -Dpg.db=u20t$k -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}"); HL=$L_PT; hrun; hview; TL=""; done; }
X09=f595637014e786fa38606859951e4f97
X09CAP=9072c6f11c8c8e713c997b58d3a79d74
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
XA=('--spring.datasource.url=jdbc:h2:mem:x20;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
c_xcheck() {
  echo "the harness's DDL - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone, no repository, no seed), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  echo "  .harness/run/hibernate-ddl.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/run/hibernate-ddl.sql
  echo "  its md5: $(md5 -q .harness/run/hibernate-ddl.sql) · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: $( [ "$(md5 -q .harness/run/hibernate-ddl.sql)" = "$X09" ] && echo yes || echo no)"
  rm -f .harness/run/hibernate-ddl.sql; }
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1200 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran past its cap (1200 polls, 0.25 apart)"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the classes it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -) · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
c_exercise() { local setup sol
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

# ---- the checks of what the video says from each capture, right after it ----------------------------------------------------
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
VERD='  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2'
FOUND1='  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); read by a second connection - customers 4 · pauses 2'
DBH='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:'
DBP='  PROBE database: PostgreSQL 18.6 | url jdbc:postgresql://127.0.0.1:19998/'
# ver TEXT N H P: the version lines once in each of the N harness JVMs (R.222, S3.15/R.246); H of them on H2 2.5.250, P on
# PostgreSQL 18.6 (the database line, R.214, R.217); each seeded, each ending by itself, exit 0
ver() { local c=$1
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] || die "$5: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its $2 harness JVMs (R.222, S3.15/R.246)"
  [ "$(printf '%s\n' "$c" | $G -cF -- "$DBH" || true)" = "$3" ] && [ "$(printf '%s\n' "$c" | $G -cF -- "$DBP" || true)" = "$4" ] || die "$5: the database lines - $3 on H2 2.5.250, $4 on PostgreSQL 18.6"
  [ "$(cnt "$c" "$SEEDL")" = "$2" ] && [ "$(cnt "$c" "$FOUND1")" = "$2" ] || die "$5: the shipped seed and Spring Data's Found 1 in each of its $2 harness JVMs"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = "$2" ] || die "$5: each of its $2 harness JVMs ends by itself, exit 0"
  [ "$(cnt "$c" '  raw password copies in its log after the mask: 0')" = "$4" ] || die "$5: each PostgreSQL JVM's log holds 0 raw copies of the password after the mask"; }
call() { printf '%s\n' "$1" | awk -v a="  PROBE >>> $2" -v b="  PROBE <<< $2 · " 'index($0, a) == 1 && length($0) == length(a) { f = 1 } f { print } f && index($0, b) == 1 { f = 0 }'; }
sqll() { printf '%s\n' "$1" | $G '^  DEBUG org\.hibernate\.SQL : ' | sed 's/^  DEBUG org\.hibernate\.SQL : //' || true; }
two() { local b n p; b=$(call "$1" "$2"); [ -n "$b" ] || die "$4: no call named $2"
  n=$(sqll "$b" | $G -c . || true); p=$(printf '%s\n' "$b" | sed -n 's/^  PROBE <<< .* · statements (getPrepareStatementCount) \([0-9]*\) · .*/\1/p')
  [ "$n" = "$3" ] && [ "$p" = "$3" ] || die "$4: $3 statements - the SQL log's lines ($n) and getPrepareStatementCount() (${p:-none}) both (R.184)"; }
res() { printf '%s\n' "$1" | sed -n 's/^  PROBE result: //p'; }
thr() { printf '%s\n' "$1" | sed -n 's/^  PROBE threw: //p'; }
loads() { printf '%s\n' "$1" | sed -n 's/^  PROBE <<< .* · entity loads \([0-9]*\) · queries [0-9]*$/\1/p'; }
SELC='select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0'
PG0SQL=""; PG1SQL=""; PGCOUNT=""; PGTOT=""; PGPAGES=""; SLLOADS=""; SLSIZE=""; NFULL=""
chk_page() { local P l b
  P=$(cat .r-page.out); ver "$P" 1 1 0 page
  l='findByMealType(VEG, PageRequest.of(0, 2, Sort.by("name"))) - a Page, page 0'; two "$P" "$l" 2 "page: a Page is its SELECT and a count"; b=$(call "$P" "$l")
  PG0SQL=$(sqll "$b" | sed -n 1p); PGCOUNT=$(sqll "$b" | sed -n 2p)
  [ "$PG0SQL" = "$SELC where ce1_0.meal_type=? order by ce1_0.name fetch first ? rows only" ] || die "page: page 0's SELECT has no offset clause: $PG0SQL"
  [ "$PGCOUNT" = 'select count(ce1_0.id) from customer ce1_0 where ce1_0.meal_type=?' ] || die "page: the count Spring Data derives: $PGCOUNT"
  [ "$(res "$b")" = 'Page 0 of 3 · total 6 · content [Asha, Dev]' ] || die "page: page 0 - Page 0 of 3, total 6, [Asha, Dev]: $(res "$b")"
  PGTOT=6; PGPAGES=3
  l='findByMealType(VEG, PageRequest.of(1, 2, Sort.by("name"))) - a Page, page 1'; two "$P" "$l" 2 "page: page 1"; b=$(call "$P" "$l")
  PG1SQL=$(sqll "$b" | sed -n 1p)
  [ "$PG1SQL" = "$SELC where ce1_0.meal_type=? order by ce1_0.name offset ? rows fetch first ? rows only" ] && [ "$(sqll "$b" | sed -n 2p)" = "$PGCOUNT" ] || die "page: a later page - offset ? rows fetch first ? rows only, then the count: $PG1SQL"
  [ "$(res "$b")" = 'Page 1 of 3 · total 6 · content [Nina, Omar]' ] || die "page: page 1: $(res "$b")"
  l='findSliceByMealType(VEG, PageRequest.of(0, 2, Sort.by("name"))) - a Slice, page 0'; two "$P" "$l" 1 "page: a Slice is its SELECT alone"; b=$(call "$P" "$l")
  [ "$(sqll "$b")" = "$PG0SQL" ] || die "page: the Slice's SELECT is the Page's, with no count"
  SLLOADS=$(loads "$b"); SLSIZE=2
  [ "$SLLOADS" = $((SLSIZE + 1)) ] || die "page: a Slice of 2 loads 3 entities - the one more row it reads to know hasNext: $SLLOADS"
  [ "$(res "$b")" = 'Slice 0 · hasNext true · content [Asha, Dev]' ] || die "page: the Slice, hasNext true: $(res "$b")"
  l='findSliceByMealType(VEG, PageRequest.of(2, 2, Sort.by("name"))) - a Slice, page 2'; two "$P" "$l" 1 "page: the last Slice"; b=$(call "$P" "$l")
  [ "$(res "$b")" = 'Slice 2 · hasNext false · content [Ravi, Sunil]' ] || die "page: the last Slice, hasNext false: $(res "$b")"
  l='findByMealType(VEGAN, PageRequest.of(0, 10, Sort.by("name"))) - a Page, page 0 not full'; two "$P" "$l" 1 "page: no count when page 0 is not full (S3.11)"; b=$(call "$P" "$l")
  [ "$(res "$b")" = 'Page 0 of 1 · total 1 · content [Priya]' ] || die "page: page 0 not full: $(res "$b")"; NFULL=1
  echo "  page: a Page - 2 statements (its SELECT, then $PGCOUNT), total $PGTOT, $PGPAGES pages; page 0 no offset, page 1 offset ? rows fetch first ? rows only; a Slice - 1 statement, $SLLOADS entity loads for a page of $SLSIZE, hasNext; page 0 not full - $NFULL statement, no count; H2"; }
SRT2=""; SRTT=""; SRTJ=""; NH2=""; NPG=""; NULH=""; NULP=""
chk_sort() { local S BH BP x l
  S=$(cat .r-sort.out); ver "$S" 2 1 1 sort
  BH=$(blk sort 'sort - H2' 'sort - PostgreSQL'); BP=$(blk sort 'sort - PostgreSQL' '')
  for x in "$BH" "$BP"; do
    l='findAll(Sort.by(DESC, "mealsPerDay").and(Sort.by("name")))'; two "$x" "$l" 1 "sort: two keys"
    SRT2=$(sqll "$(call "$x" "$l")"); [ "$SRT2" = "$SELC order by ce1_0.meals_per_day desc,ce1_0.name" ] || die "sort: two keys - order by ce1_0.meals_per_day desc,ce1_0.name: $SRT2"
    [ "$(res "$(call "$x" "$l")")" = '[3 Sunil, 2 Ravi, 1 Meera, 1 Priya]' ] || die "sort: two keys, the rows (the second key, the name, unique, breaks the tie: S3.7)"
    l='findAll(Sort.by("nmae"))'; two "$x" "$l" 0 "sort: the misspelt property fails at the call, before any SQL (S3.9)"
    SRTT=$(thr "$(call "$x" "$l")")
    [ "$SRTT" = "org.springframework.data.core.PropertyReferenceException: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'" ] || die "sort: Sort.by(\"nmae\") - class, message, no cause (S3.10): $SRTT"
    l='findAll(Sort.by("pauses.days")) - the ordering key of each row, in the order returned'; two "$x" "$l" 1 "sort: across the join"
    SRTJ=$(sqll "$(call "$x" "$l")"); [ "$SRTJ" = "$SELC left join pause p1_0 on ce1_0.id=p1_0.customer_id order by p1_0.days" ] || die "sort: Sort.by(\"pauses.days\") - left join pause ... order by p1_0.days: $SRTJ"
    res "$(call "$x" "$l")" | $G -qxE '^pause days: \[(null|[0-9]+)(, (null|[0-9]+))*\]$' || die "sort: a sort with ties prints its ordering key only, never the names among the ties (S3.7)"; done
  NH2=$(res "$(call "$BH" "$l")"); NPG=$(res "$(call "$BP" "$l")")
  [ "$NH2" = 'pause days: [null, null, 2, 3]' ] && NULH=first || die "sort: H2 sorts the customers without a pause first: $NH2"
  [ "$NPG" = 'pause days: [2, 3, null, null]' ] && NULP=last || die "sort: PostgreSQL sorts them last: $NPG"
  [ "$(sqll "$BH")" = "$(sqll "$BP")" ] || die "sort: H2 and PostgreSQL run the same SQL text, byte for byte"
  echo "  sort: H2 and PostgreSQL run the same three SQL texts; two keys $SRT2; Sort.by(\"nmae\") at the call, 0 statements: $SRTT; Sort.by(\"pauses.days\") - NULLs $NULH on H2, $NULP on PostgreSQL (the ordering key printed, S3.7)"; }
CB=""; CBSQL=""; CA=""; CASQL=""; CB10=""; CBA=""; C2=""
chk_count() { local B A1 A2 l x
  ver "$(cat .r-count.out)" 3 3 0 count
  B=$(blk count 'B - ' 'A - '); A1=$(blk count 'A - ' "A' - "); A2=$(blk count "A' - " '')
  for x in "$B" "$A1" "$A2"; do
    has "$x" '  PROBE pause (customer_id | days), read by a second connection after a second pause for Sunil: 3 | 3, 4 | 2, 3 | 4' "count: Sunil's two pauses"
    has "$x" '  PROBE customers with a pause of at least 2 days, by a second connection (count(distinct customer_id)): 2 · their pauses (count(*)): 3' "count: the second connection - 2 customers, 3 pauses"; done
  C2=2
  l='pausedSince(2, PageRequest.of(0, 2, Sort.by(DESC, "id"))) - join, no distinct'; two "$B" "$l" 2 "count B: content, then the count"
  CBSQL=$(sqll "$(call "$B" "$l")" | sed -n 2p); [ "$CBSQL" = 'select count(ce1_0.id) from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>=?' ] || die "count B: the derived count, no distinct: $CBSQL"
  CB=$(res "$(call "$B" "$l")"); [ "$CB" = 'Page 0 of 2 · total 3 · content [Priya, Sunil]' ] || die "count B: total 3 - one customer counted twice: $CB"
  l='pausedSince(2, PageRequest.of(0, 10, Sort.by(DESC, "id"))) - join, no distinct, page 0 not full'; two "$B" "$l" 1 "count B at size 10: no count runs"
  CB10=$(res "$(call "$B" "$l")"); [ "$CB10" = 'Page 0 of 1 · total 2 · content [Priya, Sunil]' ] || die "count B at size 10: total 2 - the broken state says what the solved one says (RED #918): $CB10"
  l='pausedSince(2, PageRequest.of(0, 2, Sort.by("id"))) - join, no distinct, ascending: Sunil'"'"'s two rows fill page 0'; two "$B" "$l" 1 "count B ascending"
  CBA=$(res "$(call "$B" "$l")"); [ "$CBA" = 'Page 0 of 1 · total 1 · content [Sunil]' ] || die "count B ascending - Sunil's two rows fill page 0, one customer, no count: $CBA"
  for x in "$A1" "$A2"; do
    l='pausedSinceDistinct(2, PageRequest.of(0, 2, Sort.by(DESC, "id"))) - select distinct'; two "$x" "$l" 2 "count A: content, then count(distinct)"
    CASQL=$(sqll "$(call "$x" "$l")" | sed -n 2p); [ "$CASQL" = 'select count(distinct ce1_0.id) from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>=?' ] || die "count A: count(distinct ce1_0.id): $CASQL"
    CA=$(res "$(call "$x" "$l")"); [ "$CA" = 'Page 0 of 1 · total 2 · content [Priya, Sunil]' ] || die "count A: total 2: $CA"
    two "$x" 'pausedSinceDistinct(2, PageRequest.of(0, 10, Sort.by(DESC, "id"))) - select distinct, page 0 not full' 1 "count A at size 10"; done
  [ "$(printf '%s\n' "$A1" | sed 1d)" = "$(printf '%s\n' "$A2" | sed 1d)" ] || die "count A': A again prints what A printed (R.1)"
  [ "${CB#*total }" != "${CA#*total }" ] || die "count: broken and solved give the same total"
  echo "  count: B (no distinct) at PageRequest.of(0, 2, Sort.by(DESC, \"id\")) - $CB, 2 statements, $CBSQL; at size 10 - $CB10, 1 statement; ascending - $CBA; A and A' (select distinct) - $CA, $CASQL; the second connection: $C2 customers; H2"; }
KW1=""; KPOS=""; KPRED=""; KSIX=""; KOFF=""; KIT=""
chk_keyset() { local K l b s
  K=$(cat .r-keyset.out); ver "$K" 1 1 0 keyset
  l='findFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.keyset())'; two "$K" "$l" 1 "keyset: window 1"; b=$(call "$K" "$l")
  KW1=$(sqll "$b"); [ "$KW1" = "$SELC where ce1_0.meal_type=? order by ce1_0.name,ce1_0.id fetch first ? rows only" ] || die "keyset: keyset() adds the id to the order by: $KW1"
  KPOS=$(res "$b" | sed -n 's/.* · positionAt(1) //p'); [ "$KPOS" = 'KeysetScrollPosition [FORWARD, {id=6, name=Dev}]' ] || die "keyset: window 1's positionAt(1): $KPOS"
  [ "$(res "$b")" = "Window size 2 · hasNext true · content [Asha, Dev] · positionAt(1) $KPOS" ] || die "keyset: window 1: $(res "$b")"
  for l in 'findFirst2ByMealTypeOrderByNameAsc(VEG, window 1.positionAt(1)) - window 2' 'findFirst2ByMealTypeOrderByNameAsc(VEG, window 2.positionAt(1)) - window 3'; do
    two "$K" "$l" 1 "keyset: $l"; s=$(sqll "$(call "$K" "$l")")
    [ "$s" = "$SELC where (ce1_0.meal_type=?) and (ce1_0.name>? or ce1_0.name=? and ce1_0.id>?) order by ce1_0.name,ce1_0.id fetch first ? rows only" ] || die "keyset: S3.4 - the next window's predicate on the sort keys and the id: $s"; done
  KPRED='(ce1_0.name>? or ce1_0.name=? and ce1_0.id>?)'
  has "$K" '  PROBE three windows walked: 6 customers · [Asha, Dev, Nina, Omar, Ravi, Sunil]' "keyset: three windows walk six"; KSIX=6
  [ "$(res "$(call "$K" 'findFirst2ByMealTypeOrderByNameAsc(VEG, window 2.positionAt(1)) - window 3')" | sed -n 's/^Window size 2 · hasNext \([a-z]*\) .*/\1/p')" = false ] || die "keyset: window 3 has no next"
  l='queryFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.offset()) - offset scroll, its own method'; two "$K" "$l" 1 "keyset: the offset scroll"
  KOFF=$(sqll "$(call "$K" "$l")"); [ "$KOFF" = "$SELC where ce1_0.meal_type=? order by ce1_0.name fetch first ? rows only" ] || die "keyset: offset() - no id in the order by: $KOFF"
  l='WindowIterator.of(readFirst2ByMealTypeOrderByNameAsc).startingAt(ScrollPosition.keyset()) - capped at 10 elements'; two "$K" "$l" 3 "keyset: the iterator - three windows"
  KIT=$(res "$(call "$K" "$l")"); [ "$KIT" = 'the cap 10 · elements 6 · the iterator has more: false · [Asha, Dev, Nina, Omar, Ravi, Sunil]' ] || die "keyset: the iterator ends by itself under its cap (S3.16): $KIT"
  ! sqll "$K" | $G -v 'insert into' | $G -q 'offset' || die "keyset: no keyset method saw an offset position (⚑10)"
  echo "  keyset: keyset() - order by ce1_0.name,ce1_0.id; positionAt(1) $KPOS; next windows $KPRED; three windows walk $KSIX; offset() on its own method - order by ce1_0.name; the iterator: $KIT; H2"; }
TB=""; TBIT=""
chk_trap() { local T A1 B A2 l s1 s2
  ver "$(cat .r-trap.out)" 3 3 0 trap
  A1=$(blk trap 'A - ' 'B - '); B=$(blk trap 'B - ' "A' - "); A2=$(blk trap "A' - " '')
  for x in "$A1" "$B" "$A2"; do has "$x" '  PROBE a trap measured on Spring Data JPA 4.1.2' "trap: labelled with its version (⚑10, S3.15)"; done
  for x in "$A1" "$A2"; do
    l='findFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.keyset())'; [ "$(sqll "$(call "$x" "$l")")" = "$KW1" ] || die "trap A: keyset() - the keyset SQL (keyset's window 1)"
    [ "$(res "$(call "$x" 'WindowIterator.of(findFirst2ByMealTypeOrderByNameAsc).startingAt(ScrollPosition.keyset()) - capped at 10 elements')")" = 'the cap 10 · elements 6 · the iterator has more: false · [Asha, Dev, Nina, Omar, Ravi, Sunil]' ] || die "trap A: the iterator ends by itself"; done
  [ "$(printf '%s\n' "$A1" | sed 1d)" = "$(printf '%s\n' "$A2" | sed 1d)" ] || die "trap A': A again prints what A printed"
  s1=$(sqll "$(call "$B" 'findFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.offset()) - first, on the keyset method')")
  s2=$(sqll "$(call "$B" 'findFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.keyset())')")
  [ "$s1" = "$KOFF" ] && [ "$s2" = "$KOFF" ] || die "trap B: offset() then keyset() on one method - the offset SQL twice: $s1 | $s2"
  TB=$(res "$(call "$B" 'findFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.keyset())')" | sed 's/ · positionAt.*//')
  [ "$TB" = 'Window size 2 · hasNext true · content [Asha, Dev]' ] || die "trap B: the first window again"
  TBIT=$(res "$(call "$B" 'WindowIterator.of(findFirst2ByMealTypeOrderByNameAsc).startingAt(ScrollPosition.keyset()) - capped at 10 elements')")
  [ "$TBIT" = 'the cap 10 · elements 10 · the iterator has more: true · [Asha, Dev, Asha, Dev, Asha, Dev, Asha, Dev, Asha, Dev]' ] || die "trap B: the iterator stopped by its cap alone: $TBIT"
  echo "  trap (labelled, Spring Data JPA 4.1.2): A and A' - keyset() correct, the iterator ends by itself; B - offset() then keyset() on one method: the offset SQL twice, $TB again, the iterator: $TBIT; H2"; }
TN=""; TGEN=""; TLAST=""; TCHK=""; TKP=""; PLR=""; H2SC=""; PLB=""; TROWS=""
chk_time() { local X b k db l s bnd want r i lab cn plan pg1=""
  X=$(cat .r-time.out); ver "$X" 6 3 3 time
  for k in 1 2 3 4 5 6; do
    if [ $k -le 3 ]; then db=H2; b=$(blk time "time - H2, JVM $k of 3" "time - $( [ $k = 3 ] && echo 'PostgreSQL, JVM 1' || echo "H2, JVM $((k + 1))") of 3")
    else db=PostgreSQL; b=$(blk time "time - PostgreSQL, JVM $((k - 3)) of 3" "$( [ $k = 6 ] && echo '' || echo "time - PostgreSQL, JVM $((k - 2)) of 3")"); fi
    [ -n "$b" ] || die "time: no block for $db JVM $k"
    # S3.12: the row count is the load's, read back by select count(*), never typed
    l=$(printf '%s\n' "$b" | sed -n 's/^  PROBE rows counted by select count(\*) after the load (\([0-9]*\) generated by a JDBC batch + the seed.s): \([0-9]*\)\( · ANALYZE customer ran\)*$/\1 \2/p')
    [ -n "$l" ] || die "time $db: the row count line"; TGEN=${l% *}; TN=${l#* }
    [ "$TN" = $((TGEN + 4)) ] || die "time $db: the rows counted ($TN) are the generated ($TGEN) and the seed's four"
    [ $db = H2 ] || printf '%s\n' "$b" | $G -q ' · ANALYZE customer ran$' || die "time PostgreSQL: ANALYZE customer after the load"
    TLAST=$((TN / 20 - 1))
    has "$b" "  PROBE the design: page size 20 · the last full page $TLAST · W 10 warm-up rounds · R 9 timed rounds · per round: offset pages r and $TLAST-r, keyset after id 20r and after id $((TLAST * 20))-20r (r = round % 7), the depth pages $((TLAST / 4))-r, $((TLAST / 2))-r, $((3 * TLAST / 4))-r; the calls rotate their order each round; the SQL logger at WARN while timing" "time $db: the design (⚑5, R.207)"
    for cn in offset-first offset-last keyset-first keyset-last offset-q1 offset-q2 offset-q3; do
      two "$b" "round 0 $cn" 1 "time $db: round 0 $cn"; r=$(res "$(call "$b" "round 0 $cn")")
      printf '%s\n' "$r" | $G -qxE 'rows 20 · ids ([0-9]+)\.\.([0-9]+) · expected \1\.\.\2' || die "time $db: round 0 $cn - 20 rows, its first and last id as expected (RED #906): $r"; done
    [ "$(sqll "$(call "$b" 'round 0 keyset-last')")" = "$SELC where ce1_0.id>? order by ce1_0.id fetch first ? rows only" ] || die "time $db: S3.4 - the SQL-shown keyset-last line carries its predicate, where ce1_0.id>? (predicate lines 0 of 1)"
    [ "$(sqll "$(call "$b" 'round 0 keyset-first')")" = "$SELC order by ce1_0.id fetch first ? rows only" ] || die "time $db: keyset-first - keyset(), no predicate yet"
    [ "$(sqll "$(call "$b" 'round 0 offset-last')")" = "$SELC order by ce1_0.id offset ? rows fetch first ? rows only" ] || die "time $db: offset-last - offset ? rows fetch first ? rows only"
    [ "$(sqll "$(call "$b" 'round 0 offset-first')")" = "$SELC order by ce1_0.id fetch first ? rows only" ] || die "time $db: offset-first - no offset clause"
    TKP='where ce1_0.id>?'
    has "$b" '  PROBE content checks passed: 133 calls (19 rounds × 7; each 20 rows, its first and last id as expected)' "time $db: the content checks, every call of every round (RED #906, S3.4)"; TCHK=133
    for l in 'offset last/first >= 10: true' 'offset-last/keyset-last >= 10: true' 'keyset last/first <= 2: true'; do has "$b" "  PROBE $l" "time $db JVM $k: the threshold line (⚑5, RED #907)"; done
    has "$b" "  PROBE depth: the medians of pages 0 · $((TLAST / 4)) · $((TLAST / 2)) · $((3 * TLAST / 4)) · $TLAST strictly increase - the deeper you go: true" "time $db JVM $k: the depth series (S3.18) - the trend phrase 'the deeper you go' rests on it; without it the phrase is refused"
    # S3.14 and R.227: each plan explains a SELECT the logger printed, with the values Hibernate bound for it
    [ "$(printf '%s\n' "$b" | $G -c "^  PROBE plan ($db" || true)" = 6 ] && [ "$(printf '%s\n' "$b" | $G -c '^  PROBE plan (' || true)" = 6 ] || die "time $db JVM $k: six plans, each labelled with its own database ($db) - a plan labelled with the other database is refused"
    for i in 'first page (offset-first, round 0)|offset-first' "offset last (page $TLAST)|offset-last" "keyset last (after id $((TLAST * 20)))|keyset-last" "depth page $((TLAST / 4))|offset-q1" "depth page $((TLAST / 2))|offset-q2" "depth page $((3 * TLAST / 4))|offset-q3"; do
      lab=${i%|*}; cn=${i#*|}
      bnd="[$(call "$b" "round 0 $cn" | sed -n 's/^  TRACE org\.hibernate\.orm\.jdbc\.bind : binding parameter ([0-9]*:[A-Z]*) <- \[\([0-9]*\)\]$/\1/p' | paste -sd',' - | sed 's/,/, /g')]"
      if [ $db = PostgreSQL ]; then
        has "$b" "  PROBE plan (PostgreSQL) $lab: explain (analyze, timing off, summary off, costs off, buffers off) $(sqll "$(call "$b" "round 0 $cn")") · bound $bnd" "time PostgreSQL: the plan of $cn explains its captured SELECT with its bound values (S3.14, R.227)"
      else printf '%s\n' "$b" | $G -qE "^  PROBE plan \\(H2, EXPLAIN ANALYZE\\) $(printf '%s' "$lab" | sed 's/[().]/\\&/g'): scanCount [0-9]+ · bound \\$(printf '%s' "$bnd" | sed 's/\]$/\\]/')\$" || die "time H2: the scanCount of $cn, with its bound values $bnd"; fi; done
    if [ $db = PostgreSQL ]; then
      plan=$(printf '%s\n' "$b" | $G -E '^  PROBE (plan \(PostgreSQL\)|  \| )')
      [ -z "$pg1" ] && pg1=$plan; [ "$plan" = "$pg1" ] || die "time PostgreSQL: the plans are equal over the three fresh databases (RE-MEASURE 7)"
      PLR=$(printf '%s\n' "$plan" | sed -n 's/^  PROBE   |   ->  Index Scan using customer_pkey on customer ce1_0 (actual rows=\([0-9.]*\) loops=1)$/\1/p' | paste -sd' ' -)
      [ "$PLR" = "20.00 $((TLAST * 20 + 20)).00 21.00 $((TLAST / 4 * 20 + 20)).00 $((TLAST / 2 * 20 + 20)).00 $((3 * TLAST / 4 * 20 + 20)).00" ] || die "time PostgreSQL: actual rows - the first page 20, the last page by OFFSET every row up to it, keyset 21 (20 and the one that says hasNext), the depth pages the rows up to each: $PLR"
    else
      s=$(printf '%s\n' "$b" | sed -n 's/^  PROBE plan (H2, EXPLAIN ANALYZE) .*: scanCount \([0-9]*\) · .*/\1/p' | paste -sd' ' -)
      [ -z "$H2SC" ] && H2SC=$s; [ "$s" = "$H2SC" ] || die "time H2: the scanCounts are equal in the three JVMs"; fi; done
  [ "$H2SC" = "20 $((TLAST * 20 + 20)) 22 $((TLAST / 4 * 20 + 20)) $((TLAST / 2 * 20 + 20)) $((3 * TLAST / 4 * 20 + 20))" ] || die "time H2: scanCount - $H2SC"
  # the duration words this unit lists rest on the threshold lines: each in all six JVMs, both databases
  for l in 'offset last/first >= 10: true' 'offset-last/keyset-last >= 10: true' 'keyset last/first <= 2: true'; do
    [ "$(cnt "$X" "  PROBE $l")" = 6 ] || die "time: $l in 6 of 6 JVMs - the duration words ($DWL) rest on it"; done
  PLB=$(printf '%s\n' "$pg1" | awk '/^  PROBE plan \(PostgreSQL\) (first page|offset last|keyset last)/ { f = 1; print; next } /^  PROBE plan/ { f = 0 } f' | sed 's/^  //')
  TROWS="| rows (select count(*)) | $TN - $TGEN generated by one JDBC batch per JVM, and the shipped seed's 4 |
| page size | 20 - the last full page $TLAST |
| rounds | W 10 warm-up, R 9 timed - the median of the 9 per call |
| per round (r = round % 7) | offset pages r and $TLAST-r; keyset after id 20r and after id $((TLAST * 20))-20r; depth pages $((TLAST / 4))-r, $((TLAST / 2))-r, $((3 * TLAST / 4))-r; the order of the 7 calls rotates each round |
| content checks | $TCHK calls per JVM, each 20 rows with its first and last id as computed from the counted rows |
| JVMs | 3 on H2 (each its own database in its memory) + 3 on PostgreSQL 18.6 (a fresh database each, ANALYZE customer) per capture run; 3 capture runs |
| thresholds (hashed) | offset last/first >= 10 · offset-last/keyset-last >= 10 · keyset last/first <= 2, in every JVM |
"
  [ "$(awk '/^<!-- time: the design table/ { f = 1; next } f && /^\| [A-Za-z]/ && !/^\| what \|/ { print; next } f && /^\|/ { next } f { exit }' README.md)" = "$(printf '%s' "$TROWS")" ] || die "README.md's design table is not the capture's (R.207, composed from time): $(diff <(awk '/^<!-- time: the design table/ { f = 1; next } f && /^\| [A-Za-z]/ && !/^\| what \|/ { print; next } f && /^\|/ { next } f { exit }' README.md) <(printf '%s' "$TROWS") | head -4 | paste -sd' ' -)"
  [ "$(awk '/^<!-- time: the plans/ { f = 1; next } f == 1 && /^```$/ { f = 2; next } f == 2 && /^```$/ { exit } f == 2 { print }' README.md)" = "$PLB" ] || die "README.md's plan block is not the capture's PostgreSQL plans (S3.14, R.227)"
  echo "  time: $TN rows (counted) · page size 20, the last full page $TLAST · W 10, R 9 · $TCHK content-checked calls per JVM · the SQL-shown keyset line carries $TKP · the three threshold lines true in 6 of 6 JVMs (3 H2, 3 PostgreSQL) · the depth medians increasing in 6 of 6 · PostgreSQL actual rows $PLR (equal over 3 fresh databases) · H2 scanCount $H2SC"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: yes")" = 1 ] || die "xcheck: the harness's script must be Boot's for the anchor's entities, md5 $X09 (R.212) - a mapping moved"
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ' || true)" = 3 ] || die "xcheck: two create table lines and one alter table"
  echo "  xcheck: the harness's script (@EntityScan(\"com.tiffinbox\") alone), md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README pages customers who took a pause, and the page counts one customer twice. Make the count count customers."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXT1=""; EXT2=""
chk_exercise() { local EXB EXZ b ER ES w
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    has "$ER" '    the JVM: exit 0' "exercise: the README's app runs"; has "$ES" '    the JVM: exit 0' "exercise: the solution runs"
    nhas "$ER" 'PROBE threw' "exercise: the README runs"; nhas "$ES" 'PROBE threw' "exercise: the solution runs"
    # broken != solved by the total and the count's own SQL - both exit 0 - each = count's B and A (the README's page of two)
    has "$ER" "    org.hibernate.SQL : $CBSQL" "exercise: the README's count - no distinct (= count B's)"
    has "$ES" "    org.hibernate.SQL : $CASQL" "exercise: the solution's count - count(distinct ce1_0.id) (= count A's)"
    EXT1=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE total \([0-9]*\) · .*/\1/p'); EXT2=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE total \([0-9]*\) · .*/\1/p')
    [ "$EXT1" = "$(printf '%s\n' "$CB" | sed -n 's/.* · total \([0-9]*\) · .*/\1/p')" ] && [ "$EXT1" = 3 ] || die "exercise: the README's page says total 3 - count B's, Sunil counted twice: ${EXT1:-none}"
    [ "$EXT2" = "$(printf '%s\n' "$CA" | sed -n 's/.* · total \([0-9]*\) · .*/\1/p')" ] && [ "$EXT2" = "$C2" ] || die "exercise: the solution's page says total $C2 - count A's and the second connection's: ${EXT2:-none}"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EXB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EXB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qF -- 'PageRequest.of(0, 2, Sort.by(Sort.Direction.DESC, "id"))' harness/src/probe/q/ex/ExApp.java || die "exercise: ExApp asks for a page of two - the size at which the count runs (RED #918)"
  echo "  exercise: bash and zsh alike - the README as written (the join, no distinct): exit 0, total $EXT1 (= count B's); the solution (select distinct): exit 0, total $EXT2 (= count A's, = the second connection's $C2); each file's What it prints = the run; $EXW words"; }
cap page c_page; chk_page; pub page
cap sort c_sort; chk_sort; pub sort
cap count c_count; chk_count; pub count
cap keyset c_keyset; chk_keyset; pub keyset
cap trap c_trap; chk_trap; pub trap
cap time c_time; chk_time; pub time
cap xcheck c_xcheck; chk_xcheck; pub xcheck
cap exercise c_exercise; chk_exercise; pub exercise
# the timings of every timing JVM of this run (3 capture runs × 6), whole - printed, never hashed (R.207)
echo "  the ratios of this run's $(wc -l < .harness/ratios.log | tr -d ' ') timing JVMs (medians of R 9; printed, never hashed):"; sed 's/^/    /; s/PROBE ms ratios: //' .harness/ratios.log
VS="the values the video may say: a Page - $PGTOT customers, $PGPAGES pages, 2 statements: $PG0SQL, then $PGCOUNT · page 1: $PG1SQL · a Slice - 1 statement, $SLLOADS entity loads for a page of $SLSIZE, hasNext · page 0 not full: $NFULL statement · sort: $SRT2 · Sort.by(\"nmae\"): $SRTT · Sort.by(\"pauses.days\"): $SRTJ - NULLs $NULH on H2, $NULP on PostgreSQL · count B: $CB ($CBSQL) · at size 10: $CB10 · A: $CA ($CASQL) · keyset: $KW1 · positionAt(1): $KPOS · next: $KPRED · three windows walk $KSIX · the iterator: $KIT · the trap (Spring Data JPA 4.1.2): offset() then keyset() on one method - $TB again, $TBIT · time: $TN rows; offset last/first >= 10, offset-last/keyset-last >= 10, keyset last/first <= 2 - on H2 and PostgreSQL, every JVM · the deeper you go: the depth medians increase · PostgreSQL actual rows (first page, offset last, keyset last, depth): $PLR · H2 scanCount: $H2SC · xcheck: $X09 · exercise: total $EXT1, then $EXT2 ($EXW words)"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"

# hygiene: every capture and every file this unit holds
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGJVM" -gt 0 ] || die "no harness JVM ran, or none on PostgreSQL"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qF -- "$PW" "$f" || die "$f holds the password"
  ! $G -qiE 'password=|user=sa&' "$f" || die "$f holds a connection's credentials"
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE 'scanning in [0-9]+ ms|CONSTRAINT_[0-9]' "$f" || die "$f holds a scan time or an H2 constraint name, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b' "$f" || die "$f holds a millisecond figure (R.207: printed, never hashed)"
  ! $G -E '^ *PROBE ms ' "$f" | $G -qE '[0-9]\.[0-9]' || die "$f holds a timing figure, unmasked"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'https?://' "$f" || die "$f holds a URL"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.q' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory (R.195)"
echo "  hygiene: $(ls .r-*.out | wc -l | tr -d ' ') captures, $LOGS harness JVM logs ($PGJVM on PostgreSQL); 'GenerationTarget encountered exception' 0; no password, credential, path, unit number, time, millisecond figure, OS token, unmasked identity or generated name, URL or stack frame in any capture; every JVM pinned and under its alarm; no H2 file"

# ---- the end: the container removed, the anchor, the ports ----------------------------------------------------------------
pgrm
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
[ "$(listeners 19998)" = 0 ] || die "something listens on 19998 after the container was removed"
echo "  the container: removed (docker rm -f $CN); docker ps -a names no $CN; nothing listens on 19998"
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19990-19999 at the end - no JVM here bound one; 19999 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit20: every capture 3/3 and = published; every spoken number asserted; the container gone"
