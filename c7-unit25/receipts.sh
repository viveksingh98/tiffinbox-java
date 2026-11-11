#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Isolation Levels - this unit's receipts. No change to the anchor (brief flag 1): anchor/ is the link to
# ../c7-unit17/after. Isolation decides what one transaction may see of another's work: four levels, five anomalies, two databases
# that do not agree. Seven captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every
# number and string the video says is asserted right after its capture by a check that can fail. Two databases (brief flag 2):
# H2 2.5.250 in each JVM's memory, and PostgreSQL 18.6 in ONE container this script starts from the pinned image and removes.
# TiffinBox itself never runs here.
#   anomalies  two JDBC connections of their own, one thread, the fixed interleaves - dirty read, non-repeatable read, phantom read,
#              lost update, write skew - x four levels x two databases = 40 cell lines (one H2 JVM, one PostgreSQL JVM); every
#              cell prints its control (S4.17) and the checker (anomalies.py, below) re-derives each verdict from the cell's own
#              numbers, checks the controls, and compares with the brief's table; H2's refused lost-update cells must carry
#              MVStoreException's empty cause line and must NOT carry a deadlock victim's (S4.8, RED #1205)
#   psql       two live psql sessions, A and B (harness/two25.py, S4.12): nine scenes, each on a fresh database copied from a
#              template the shipped Database seeded (a harness JVM, -Ds=seed); the transcript compared byte for byte (cmp)
#              across the three runs; README.md holds it, byte for byte
#   spring     @Transactional(isolation = ...) through Boot's JpaTransactionManager, DEFAULT between each: the JDBC level and the
#              database's own answer inside, the physical connection numbered (one), Hikari's transactionIsolation (H2, PostgreSQL)
#   context    the persistence context (S4.5): a READ_COMMITTED and a REPEATABLE_READ reader, two threads and two latches, the
#              reader's two reads by native SQL (A) and by findById (B, the failure receipt), three rounds each (H2, PostgreSQL)
#   readonly   readOnly = true: flush mode, JDBC isReadOnly and isCurrentTransactionReadOnly() printed inside; an edit of the
#              loaded object, then a native UPDATE inside (H2, PostgreSQL)
#   xcheck     the harness's DDL script (@EntityScan("com.tiffinbox") alone) against the owning-side lesson's published md5 (R.212)
#   exercise   exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#              shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# The anchor is COPIED under .harness/anchor and built there, never in place (its README's package line, offline; its tests run);
# its jar extracted (the anchor's own line). The harness (harness/src, packages probe.t and probe.x, outside com.tiffinbox) is
# compiled against the anchor's extracted libraries with javac -parameters into .harness/hc. probe.t.Main is a Spring Boot context
# with no web server (WebApplicationType.NONE: it binds no port), @EntityScan and @EnableJpaRepositories on com.tiffinbox - the
# anchor's entities and its own CustomerEntityRepository; probe.t.Seed builds the shipped Database in code on the run's own
# database, which seeds it - its DDL text is the shipped class's, never a copy (RE-MEASURE 3); ddl-auto none. The PostgreSQL driver
# (42.7.14) is on every harness JVM's class path from this unit's .m2-demo (the anchor's lib/ has none). Logback
# (harness/logback.xml) prints Hibernate's SQL logger and the transaction manager's DEBUG lines. Every JVM's flags travel as an
# array, V, its arguments as an array, A (R.193); every JVM runs under an alarm (perl -e 'alarm N; exec ...': macOS has no timeout);
# an alarm that fires is a failed receipt (R.247). Commands are printed exactly as they run: each goes through eval.
# harness/dur7.py (Course 7's builders' duration pattern, byte for byte) and S4.7's duration-meaning family (below, BLUE's s47.py
# regex) gate this unit's prose: it speaks no time (R.172, R.264); psql's lock_timeout is quoted as configured text. "$M2" is this
# unit's .m2-demo. The locale: every JVM has its locale pinned on its run line (-Duser.language=en -Duser.country=US).
# The network: every Maven run is offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an artifact
# offline is run once more without -o and says so, naming what it fetched. docker run never pulls (--pull never): the image must be
# on this machine (docker image inspect, before anything starts). At run time nothing leaves the machine: H2 in memory; PostgreSQL
# on 127.0.0.1:20048 only, asked by the harness's JDBC, two psql sessions and docker exec. This unit reads no version file: the
# section's dated sweep is the brief's (R.223; _research/spring-boot-metadata-2026-11-10.xml, spring-data-bom-metadata-2026-11-10.xml).
# PostgreSQL's password (R.214): generated here into .harness/secrets/pgpw, mode 0600, read by the container (POSTGRES_PASSWORD_FILE,
# a read-only bind mount), by the harness (-Dpg.pwfile: the URL is built inside the JVM, every printed URL cut before its "?") and by
# the psql driver (into its two children's environment only, PGPASSWORD); never on a command line, never printed. Every capture's
# raw output is counted for raw copies BEFORE the mask (0: nothing printed it) and after (0); the mask is self-tested with it planted.
# Per-database settings: none are made (S4.11 allows only `alter database <its db> set`; this script holds no ALTER SYSTEM).
# Masks (README.md declares each; awk gsub only): the password "<pw>"; this folder "…", the folder above "…/..", home "~", your
# user name "<user>"; " using Java <version>"; an identity hash "@…"; an EntityManager's identity "SessionImpl(<n><open>)";
# Spring Data's scan time.
# Ports (§P, 20040-20049): 20048 the container (127.0.0.1 only) · 20040-20047 unused (the harness JVMs and psql bind none) · 20049
# never bound; all ten checked free at the start and the end.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u25-pg
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM or the psql driver), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process
# under it); then sweep(): anything of this run still alive in its process group is stopped; then the container, if this script
# created it (CSTARTED), is removed (docker rm -f, pgrm). After an interrupt a capture's unfinished runs (.r-NAME.1-3) go too;
# after a failed check they stay. The clean-up ignores a second Ctrl-C; the script exits 130 after an interrupt. No wait is bare.
pid=""; mpid=""; xpid=""; CSTARTED=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.t.") || index($0, "probe.x.") || index($0, "two25.py") || index($0, "/opt/homebrew/bin/psql -X") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "docker exec c7u25-pg")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
# pgrm: docker rm -f, again until docker ps -a names it no more (at least three tries, 0.5 apart, at most 20): a docker run cut by
# an interrupt can register its container a moment after the first rm
pgrm() { local i=0; [ -n "$CSTARTED" ] || return 0
  while [ $i -lt 20 ]; do docker rm -f "$CN" > /dev/null 2>&1 || true
    [ $i -ge 2 ] && [ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] && break
    sleep 0.5; i=$((i + 1)); done; CSTARTED=""; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find docker /opt/homebrew/bin/psql /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - the password lives under .harness/ only"
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit17/after ] || die "anchor must be the link to ../c7-unit17/after - this unit changes nothing in it"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
# R.211: anchor/ equals ../c7-tiffinbox until a later unit (26, 27) changes the anchor - a note then, never a stop
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): anchor/ = ../c7-unit17/after (frozen); diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit17/after (frozen) - no anchor change in this unit"; fi; }
anchornote start
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted
HS=harness/src/probe/t
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
HFILES='dur7.py logback.xml src two25.py'
SFILES='probe/t/H.java probe/t/Iso25.java probe/t/Main.java probe/t/Run.java probe/t/Seed.java probe/t/ex/ExApp.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="20040 20041 20042 20043 20044 20045 20046 20047 20048 20049"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
docker image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - docker pull it once (this script never pulls)"
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it yourself: docker rm -f $CN"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets
echo "  the image: $IMG is on this machine (docker image inspect; never pulled)"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 + S4.7 (R.264, RED #1211): dur7.DUR, and BLUE's duration-meaning family beside it (dur7.py is not edited by BLUE: the
# family is this builder's, as the brief's CARRIED says). psql's lock_timeout is quoted as its configured text ('1s'), never voiced.
cat > .harness/dur.py <<'PY'
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|a|\d+)\s+(?:second|minute|hour)s?|half a second|eventually)\b", re.I)
for t, want in (("forever", 1), ("at once", 1), ("immediately", 1), ("one second", 1), ("a moment", 1), ("3 seconds", 1),
                ("lock_timeout waits one second", 1), ("a timeout of one, as configured", 0), ("the second connection reads Ravi", 0),
                ("lock_timeout = '1s', as configured", 0), ("another bean", 0)):
    assert bool(m.DUR.search(t) or FAM.search(t)) == bool(want), t
n = f = 0
for p in sys.argv[2:]:
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        for w in m.DUR.finditer(l):
            n += 1; print("  %s line %d: %s  <- dur7: this unit speaks no time" % (p, i, w.group(0)))
        for w in FAM.finditer(l):
            f += 1; print("  %s line %d: %s  <- S4.7's family: a duration meaning" % (p, i, w.group(0)))
print("duration words: %d · duration meanings: %d" % (n, f))
PY
DW=$(python3 -I -B .harness/dur.py harness/dur7.py $PROSE) || die "the duration gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'duration words: 0 · duration meanings: 0' || die "a duration word or meaning - this unit speaks no time (R.172, S4.7): $(printf '%s\n' "$DW" | $G '<-' | paste -sd';' -)"
echo "  duration words: 0 (dur7.DUR) · duration meanings: 0 (S4.7's family) over README.md, exercise/README.md, exercise/SOLUTION.md"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness/src harness/two25.py)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src, harness/two25.py)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose - the exercise's blocks hold the measured output: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty (exercise compares it with the run, line for line)"
# S4.14 (R.271) and S4.4 (R.261): the refuted readings this unit could tempt, refused per sentence (README.md's psql transcript and
# its cell table are the captures' text and are left out, and so is the values line: the receipt compares them with the captures below). The self-test first.
cat > .harness/s414.py <<'PY'
import re, sys
NEG = re.compile(r"\b(?:not|no|never|none|cannot|can't|refus\w*|without)\b", re.I); NEG2 = re.compile(r"\b(?:not|no|never|none|cannot|can't|without)\b", re.I)
DIRTY = re.compile(r"\bdirty reads?\b", re.I); PG = re.compile(r"\bPostgre(?:SQL|s)\b", re.I)
RO = re.compile(r"\breadOnly\b|\bread-only\b|\bread only\b", re.I); ROV = re.compile(r"\b(?:refus\w*|reject\w*|stops?|block\w*|forbids?|fails?)\b", re.I)
DL = re.compile(r"\bdeadlock", re.I); DLOK = re.compile(r"\bcause line\b|\bnone was chosen\b|\bno deadlock\b|Pessimistic Locking and Deadlocks", re.I); H2 = re.compile(r"\bH2\b")
LVL = re.compile(r"\b(?:READ[ _]UNCOMMITTED|READ[ _]COMMITTED|REPEATABLE[ _]READ|SERIALIZABLE)\b", re.I)
PREV = re.compile(r"\b(?:prevents?|stops?|blocks?|forbids?|rules? out)\b", re.I); ANOM = re.compile(r"\b(?:dirty|non-repeatable|phantom|lost update|write skew)", re.I)
CLAIM = re.compile(r"\binterface\w*\b[^.!?]*\b(?:means?|meant|gets?|got|gives?|gave|is|are|was|becomes?|uses?|used)\b[^.!?]*\b(?:JDK|J-D-K)(?:'s)?\b[^.!?]*\bprox(?:y|ies)\b"
                   r"|\b(?:JDK|J-D-K)(?:'s)?\b[^.!?]*\bprox(?:y|ies)\b[^.!?]*\b(?:for|on|around)\b[^.!?]*\binterface", re.I)
SCOPE = re.compile(r"\bplain Spring\b|\bwithout (?:Spring )?Boot\b|\bCourse (?:4|four)\b|proxy[-. ]target[-. ]class|\bthe (?:labelled )?flag\b", re.I)
def why(s):
    if DIRTY.search(s) and PG.search(s) and not NEG.search(s): return "S4.14: a dirty read said of PostgreSQL (it reads 2)"
    if RO.search(s) and ROV.search(s) and not PG.search(s) and not NEG2.search(s): return "S4.14: readOnly refuses writes, without PostgreSQL (H2 commits it)"
    if DL.search(s) and not (H2.search(s) and DLOK.search(s)) and not re.search(r"Pessimistic Locking and Deadlocks", s): return "S4.14: a deadlock said of the lost-update cell (H2's word only quoted as H2's, beside its cause line)"
    if LVL.search(s) and PREV.search(s) and ANOM.search(s) and not (H2.search(s) or PG.search(s)) and not NEG.search(s): return "S4.4: a level prevents an anomaly, without the database"
    if CLAIM.search(s) and not SCOPE.search(s): return "S4.3: an interface means a JDK proxy, unscoped"
    return None
cases = [("Postgres shows a dirty read.", True), ("Here is a dirty read on PostgreSQL.", True), ("PostgreSQL cannot show a dirty read; H2 can.", False),
         ("readOnly refuses writes.", True), ("On PostgreSQL readOnly refuses the UPDATE with 25006.", False), ("H2 commits the write under readOnly.", False),
         ("The lost update ends in a deadlock.", True), ("H2 names this refusal a deadlock; its own cause line shows none was chosen.", False),
         ("SERIALIZABLE prevents write skew.", True), ("On PostgreSQL SERIALIZABLE stops write skew; on H2 it does not.", False),
         ("An interface means a JDK proxy.", True), ("REPEATABLE READ keeps both reads at 2 on H2 and on PostgreSQL.", False)]
m = sum(bool(why(t)) != w for t, w in cases)
assert m == 0, "s414 self-test: %d mismatches" % m
n = 0
for p in sys.argv[1:]:
    t = open(p, encoding="utf-8").read()
    t = re.sub(r"<!-- captured: begin -->.*?<!-- captured: end -->", " ", t, flags=re.S)
    t = re.sub(r"<!-- values: begin -->.*?<!-- values: end -->", " ", t, flags=re.S)
    t = re.sub(r"(?m)^\| (?:H2|PostgreSQL) \|.*$", " ", t)
    for s in re.split(r"(?<=[.!?])\s+", t.replace("\n", " ")):
        w = why(s)
        if w:
            n += 1; print("  %s: %s  <- %s" % (p, s.strip()[:160], w))
print("S4.14/S4.4/S4.3 refused sentences: %d (self-test: %d cases, 0 mismatches)" % (n, len(cases)))
PY
SW=$(python3 -I -B .harness/s414.py $PROSE) || die "S4.14's gate did not run (or its self-test failed)"
printf '%s\n' "$SW" | tail -1 | $G -q '^S4.14/S4.4/S4.3 refused sentences: 0 ' || die "S4.14 / S4.4 / S4.3: $(printf '%s\n' "$SW" | $G '<-' | head -3 | paste -sd';' -)"
echo "  $(printf '%s\n' "$SW" | tail -1) over README.md, exercise/"
# R.225: a SQL string this unit shows is a capture's - outside README.md's captured blocks (the psql transcript, compared byte for
# byte below) and its cell table, a line holding a statement's head is a typed SQL string, refused
SQLRE='update customer set|insert into customer|select meals_per_day from|select count\(\*\) from customer|select sum\(meals_per_day\)|ce1_0\.'
TS=$(awk '/<!-- (captured|values): begin -->/ { f = 1 } !f { print NR ": " $0 } /<!-- (captured|values): end -->/ { f = 0 }' README.md | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md (R.225): $TS"
echo "  typed SQL strings: 0 in README.md outside its captured blocks"
ASY='alter'' system'; ! $G -rniE "$ASY" receipts.sh harness | $G -vE '^receipts.sh:[0-9]+: *#' > /dev/null || die "S4.11: a server-wide setting statement ($ASY) in this script or the harness - per-database settings only"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/H.java $HS/Iso25.java $HS/Main.java $HS/Run.java $HS/Seed.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*:../../.m2-demo/$PGJ\" probe.t.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_RUN=$(mine "docker run -d --pull never --name $CN -p 127.0.0.1:20048:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_TWO=$(mine "perl -e 'alarm 120; exec @ARGV' python3 -I -B harness/two25.py 20048 .harness/secrets/pgpw u25psql 3.0 2.0 5.0")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
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
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/anchor/
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/, its README's package line; its tests ran)"
TR=$($G -E '^\[(INFO|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' .harness/build-anchor.log | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/\1 \2 \3 \4/' | awk '{ a += $1; b += $2; c += $3; d += $4 } END { print a + 0, b + 0, c + 0, d + 0 }')
[ "$TR" = '18 0 0 0' ] || die "the anchor's tests: Tests run, Failures, Errors, Skipped = ${TR:-none} - expected 18 0 0 0"
echo "  the anchor's tests: 18 run, 0 failures, 0 errors, 0 skipped (the build's log, its modules' summary lines summed)"
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar org/springframework/spring-orm/7.0.10/spring-orm-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar "$PGJ"; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
[ ! -e .harness/anchor/$XD/lib/postgresql-42.7.14.jar ] || die "the anchor's lib/ holds the PostgreSQL driver - it never did; the harness takes it from .m2-demo"
jc "$L_JAVAC" .harness/javac.log
[ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/t/ex ] || die "the exercise's class was compiled into the harness - it is compiled on its own"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries); the harness compiled into .harness/hc; the PostgreSQL driver: .m2-demo/$PGJ (md5 $(md5 -q "$M2/$PGJ"))"

# ---- the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214, S4.11) -------
# CSTARTED is set before docker run, so an interrupt during its start removes it too
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(docker port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20048' ] || die "docker port: the container must publish 5432 on 127.0.0.1:20048 alone: $DP"
[ "$(listeners 20048)" -ge 1 ] || die "nothing listens on 20048 after the container started"
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
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' "url jdbc:postgresql://127.0.0.1:20048/u25an?user=sa&password=$PW" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' 'url jdbc:postgresql://127.0.0.1:20048/u25an?user=sa&password=<pw>')" ] || die "mask: the planted JDK version, folders, home, identity hash, EntityManager identity, scan time and the password must be masked"
[ "$(mask < .harness/p1 | raw "$PW")" = 0 ] || die "mask: a raw copy of the password survived its self-test"
rm -f .harness/p1
echo "  the mask's self-test: the password planted, raw password copies after mask: 0"
# the harness's arguments: no schema written, no banner, Thymeleaf not looking for templates; H2: this JVM's own database; PostgreSQL:
# the URL built by Main from -Dpg.db and -Dpg.pwfile (no password on the command line)
HQ=(--logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
HA=('--spring.datasource.url=jdbc:h2:mem:u25;DB_CLOSE_DELAY=-1' "${HQ[@]}")
# pgdb NAME: a fresh PostgreSQL database (dropped with force if it is there, created) - printed, its exit asserted
pgdb() { DB=$1; echo "\$ DB=$DB"; echo "\$ $L_DB"
  (eval "$L_DB") > .harness/psql.log 2>&1 < /dev/null || die "psql could not make the database $DB: $(tail -2 .harness/psql.log)"
  echo "  exit 0 · a fresh database $DB"; }
HE=""
hrun() { local c i=0 e=0 n
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  if [ "${HL:-$L_H}" != "$L_X" ]; then echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; fi
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  n=$(raw "$PW" .harness/h.log); [ "$n" = 0 ] || die "a harness JVM printed the password ($n raw copies before any mask) - R.214"
  case " ${V[*]:-} " in *" -Dpg.db="*) PGJVM=$((PGJVM + 1)); echo "  raw password copies in its log: $n (before the mask; the URL is printed cut before its ?)" ;; esac
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"; }
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
unpub=""; CAPRUN=0
cap() { local nm=$1 i; shift
  for i in 1 2 3; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    echo "$(raw "$PW" .harness/cap.raw)" > ".harness/raw-$nm.$i"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot, Maven or image, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# both NAME DBPREFIX: the scenario on H2, then on its own fresh PostgreSQL database
both() { echo "H2 - one harness JVM, -Ds=$1, this JVM's own H2 database:"; V=(-Ds=$1); A=("${HA[@]}"); hrun; hview
  echo "PostgreSQL - a fresh database, then one harness JVM, -Ds=$1:"; pgdb "$2"
  V=(-Ds=$1 -Dpg.db=$2 -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}"); hrun; hview; }

# ---- the captures --------------------------------------------------------------------------------------------------------
anomalies() { echo "anomalies - 5 interleaves x 4 levels, two JDBC connections of their own on one thread, the seed again before every cell:"; both anomalies u25an; }
psqlcap() { local c i=0 e=0
  echo "psql - the template: a fresh database, seeded by the shipped Database (one harness JVM, -Ds=seed):"; pgdb u25psql
  V=(-Ds=seed -Dpg.db=u25psql -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}"); hrun; hview
  echo "the two sessions' client: $(/opt/homebrew/bin/psql --version)"
  echo "\$ $L_TWO"
  (eval "exec $L_TWO") > .harness/two.out 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 560 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { killtree "$pid"; die "the psql driver was still running past its alarm"; }
  wait "$pid" || e=$?; pid=""
  [ "$e" != 142 ] || die "the psql driver's alarm fired (exit 142) - R.247"
  [ "$(raw "$PW" .harness/two.out)" = 0 ] || die "the psql transcript holds the password, raw (R.214)"
  cp .harness/two.out ".harness/two-$CAPRUN.out"
  echo "--- the transcript, as the driver wrote it ---"; sed 's/^/  /' .harness/two.out; echo "--- the transcript's end ---"
  echo "  the driver: exit $e"; }
spring() { echo "spring - @Transactional(isolation = ...) and DEFAULT between each, through Boot's JpaTransactionManager:"; both spring u25sp; }
context() { echo "context - a READ_COMMITTED and a REPEATABLE_READ reader, its writer on another thread, two latches, three rounds each:"; both context u25cx; }
readonly() { echo "readonly - readOnly = true: an edit of the loaded object, then a native UPDATE, each in its own read-only transaction:"; both readonly u25ro; }
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # ../c7-unit09's published xcheck capture
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
XA=('--spring.datasource.url=jdbc:h2:mem:x25;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  V=(); A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  echo "  .harness/run/hibernate-ddl.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/run/hibernate-ddl.sql
  echo "  its md5: $(md5 -q .harness/run/hibernate-ddl.sql) · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: $( [ "$(md5 -q .harness/run/hibernate-ddl.sql)" = "$X09" ] && echo yes || echo no)"
  rm -f .harness/run/hibernate-ddl.sql; }
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
# ---- the checks of what the video says from each capture, right after it ----------------------------------------------------
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# S4.13 (R.270): Framework's version in the same capture beside HHH000001 and Spring Data's - once per harness JVM, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
VERD='  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2'
VERF='  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10'
DBH='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:u25;DB_CLOSE_DELAY=-1 | JDBC driver H2 JDBC Driver 2.5.250 (2026-08-29)'
dbp() { printf '  PROBE database: PostgreSQL 18.6 | url jdbc:postgresql://127.0.0.1:20048/%s | JDBC driver PostgreSQL JDBC Driver 42.7.14\n' "$1"; }
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); the second connection reads: customer rows 4 [1 Ravi 2, 2 Meera 1, 3 Sunil 3, 4 Priya 1]'
CODES='  PROBE the level codes (java.sql.Connection): READ_UNCOMMITTED 1 · READ_COMMITTED 2 · REPEATABLE_READ 4 · SERIALIZABLE 8'
FOUND1='  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
ver() { local c; c=$1
  [ "$(cnt "$c" "$VERL")" = 1 ] && [ "$(cnt "$c" "$VERH")" = 1 ] && [ "$(cnt "$c" "$VERD")" = 1 ] && [ "$(cnt "$c" "$VERF")" = 1 ] || die "$2: the version lines - getVersionString(), Hibernate's HHH000001, Spring Data JPA's 4.1.2 and Spring Framework's 7.0.10 - once in its harness JVM (S4.13)"
  [ "$(cnt "$c" "$3")" = 1 ] && [ "$(cnt "$c" "$SEEDL")" = 1 ] && [ "$(cnt "$c" "$CODES")" = 1 ] && [ "$(cnt "$c" "$FOUND1")" = 1 ] || die "$2: the database: line ($(printf '%s' "$3" | sed 's/^  PROBE database: //; s/ |.*//')), the shipped seed read by the second connection, the level codes and Spring Data's Found 1"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = 1 ] || die "$2: its harness JVM ends by itself, exit 0"; }
# vb NAME DBNAME: the H2 block and the PostgreSQL block of a two-database capture, each checked by ver()
VH=""; VP=""
vb() { VH=$(blk "$1" 'H2 - ' 'PostgreSQL - '); VP=$(blk "$1" 'PostgreSQL - ' '')
  ver "$VH" "$1 H2" "$DBH"; ver "$VP" "$1 PostgreSQL" "$(dbp "$2")"
  has "$VP" '  raw password copies in its log: 0 (before the mask; the URL is printed cut before its ?)' "$1 PostgreSQL: the password"; }
# the anomaly checker (S4.4, S4.8, S4.17, R.226): reads one database's 20 cell lines; checks each cell's levels (the code A and B
# report, the level B's session says), its control (A's update count 1 and A's own read beside B's read; write skew's invariant),
# RE-DERIVES the verdict from the cell's own numbers, compares it with the printed verdict and with the brief's table (the expected
# column below - the receipt's check, never the README's text), checks each refusal's chain in the cell's own block (class with
# package, message, first cause, SQLState; on H2 the MVStoreException cause line present and a deadlock victim's absent); prints
# the cell table's rows README.md must hold and "mismatches N"; exits 1 on any mismatch
cat > .harness/anomalies.py <<'PY'
import re, sys
cap, db = sys.argv[1], sys.argv[2]
LV = ["READ_UNCOMMITTED", "READ_COMMITTED", "REPEATABLE_READ", "SERIALIZABLE"]; CODE = {"READ_UNCOMMITTED": 1, "READ_COMMITTED": 2, "REPEATABLE_READ": 4, "SERIALIZABLE": 8}
AN = ["dirty read", "non-repeatable read", "phantom read", "lost update", "write skew"]
S, N, R = "SEEN", "not seen", "refused"
EXP = {"H2": {"READ_UNCOMMITTED": [S, S, S, S, S], "READ_COMMITTED": [N, S, S, S, S], "REPEATABLE_READ": [N, N, N, R, S], "SERIALIZABLE": [N, N, N, R, S]},
       "PostgreSQL": {"READ_UNCOMMITTED": [N, S, S, S, S], "READ_COMMITTED": [N, S, S, S, S], "REPEATABLE_READ": [N, N, N, R, S], "SERIALIZABLE": [N, N, N, R, R]}}
def said(lv): s = lv.replace("_", " "); return s if db == "H2" else s.lower()
H2LOST = ("  PROBE B's update refused: org.h2.jdbc.JdbcSQLTransactionRollbackException: Deadlock detected. The current transaction was rolled back. "
          "Details: \"CUSTOMER\"; SQL statement: ⏎ update customer set meals_per_day = 3 where name = 'Ravi' [40001-250]")
H2CAUSE = "  PROBE   <- org.h2.mvstore.MVStoreException:  [2.5.250/105]"
VICTIM = "has been chosen as a deadlock victim"
PGLOST = "  PROBE B's update refused: org.postgresql.util.PSQLException: ERROR: could not serialize access due to concurrent update"
PGSKEW = ("  PROBE B's commit refused: org.postgresql.util.PSQLException: ERROR: could not serialize access due to read/write dependencies among transactions"
          " ⏎   Detail: Reason code: Canceled on identification as a pivot, during commit attempt. ⏎   Hint: The transaction might succeed if retried.")
L = [l.rstrip("\n") for l in open(cap, encoding="utf-8")]
bad = []; rows = []; order = []; comp = {}
HEAD = re.compile(r"^  PROBE cell (H2|PostgreSQL) · (\w+) · ([a-z -]+?) · A at (\d+), B at (\d+), B's session says (.+?) · (.*)$")
RX = {"dirty read": re.compile(r"^B reads Ravi (\d+) · A updates Ravi to 9: (\d+) row, A reads Ravi (\d+), not committed · B reads Ravi (\d+) · A rolls back · (SEEN|not seen)$"),
      "non-repeatable read": re.compile(r"^B reads Ravi (\d+) · A updates Ravi to 9: (\d+) row, A reads Ravi (\d+), A commits · B reads Ravi (\d+) · (SEEN|not seen)$"),
      "phantom read": re.compile(r"^B counts VEG (\d+) · A inserts Asha \(VEG\): (\d+) row, A counts VEG (\d+), A commits · B counts VEG (\d+) · (SEEN|not seen)$"),
      "lost update": re.compile(r"^A and B read Ravi (\d+)/(\d+) · A sets (\d+): (\d+) row, A reads Ravi (\d+), A commits · (?:B sets (\d+): (\d+) row, B commits · two increments, Ravi now (\d+) · (SEEN|not seen)|B's update refused (\S+) \(SQLState (\w+)\) · Ravi now (\d+) · refused)$"),
      "write skew": re.compile(r"^A and B read the VEG sum (\d+)/(\d+) · A lowers Ravi to 1: (\d+) row, B lowers Sunil to 1: (\d+) row, A commits · (?:B commits|B's commit refused (\S+) \(SQLState (\w+)\)) · the invariant: before (\d+), A alone leaves (\d+), B alone leaves (\d+), after (\d+) · (SEEN|not seen|refused)$")}
for i, l in enumerate(L):
    m = HEAD.match(l)
    if not m: continue
    d, lv, an, ca, cb, sd, rest = m.groups(); order.append((lv, an)); k = "%s %s %s" % (d, lv, an)
    if d != db: bad.append("%s: a cell of another database" % k); continue
    try:
        a = L.index("  PROBE >>> cell %s · %s · %s" % (d, lv, an)); b = L.index("  PROBE <<< cell %s · %s · %s" % (d, lv, an))
    except ValueError:
        bad.append("%s: no >>> / <<< block" % k); continue
    blk = L[a:b + 1]
    if not (a < i < b): bad.append("%s: the cell line outside its block" % k)
    if int(ca) != CODE[lv] or int(cb) != CODE[lv]: bad.append("%s: A at %s, B at %s - expected %d" % (k, ca, cb, CODE[lv]))
    if sd != said(lv): bad.append("%s: B's session says %s - expected %s" % (k, sd, said(lv)))
    x = RX[an].match(rest)
    if not x: bad.append("%s: the cell's line has not its anomaly's shape: %s" % (k, rest[:120])); continue
    g = x.groups(); got = None; ctl = ""
    if an in ("dirty read", "non-repeatable read", "phantom read"):
        b1, ua, ar, b2, v = int(g[0]), int(g[1]), int(g[2]), int(g[3]), g[4]
        want_ar = 3 if an == "phantom read" else 9; base = 2
        if ua != 1: bad.append("%s: the control - A's %s matched %d rows, not 1 (S4.17): the cell proves nothing" % (k, "insert" if an == "phantom read" else "update", ua))
        if ar != want_ar: bad.append("%s: the control - A's own read %d, not %d (S4.17)" % (k, ar, want_ar))
        if b1 != base: bad.append("%s: B's first read %d, not the seed's %d" % (k, b1, base))
        got = S if (b2 == ar and b2 != b1) else N
        verb = "counts" if an == "phantom read" else "reads"
        ctl = "B %s %d, then %d · A: %d row, A %s %d%s" % (verb, b1, b2, ua, verb, ar, ", not committed" if an == "dirty read" else ", committed")
    elif an == "lost update":
        va, vb, sa_, ua, ar = int(g[0]), int(g[1]), int(g[2]), int(g[3]), int(g[4])
        if ua != 1: bad.append("%s: the control - A's update matched %d rows, not 1 (S4.17)" % (k, ua))
        if (va, vb, sa_, ar) != (2, 2, 3, 3): bad.append("%s: the control - both read 2, A set 3 and read 3: got %s" % (k, (va, vb, sa_, ar)))
        if g[5] is not None:
            ub, now = int(g[6]), int(g[7])
            if ub != 1: bad.append("%s: B's update matched %d rows, not 1" % (k, ub))
            got = S if now == va + 1 else N
            ctl = "both read %d · A: %d row, reads %d, commits · B: %d row, commits · Ravi now %d after two increments" % (va, ua, ar, ub, now)
            if g[8] != got: bad.append("%s: printed %s, derived %s" % (k, g[8], got))
        else:
            got = R; now = int(g[11])
            if now != 3: bad.append("%s: refused, but Ravi now %d (A's 3 expected)" % (k, now))
            ctl = "both read %d · A: %d row, reads %d, commits · B's update refused: %s, SQLState %s · Ravi now %d" % (va, ua, ar, g[9], g[10], now)
            if g[10] != "40001": bad.append("%s: SQLState %s, not 40001" % (k, g[10]))
            if db == "H2":
                if H2LOST not in blk: bad.append("%s: H2's refusal line (class, message) missing" % k)
                if H2CAUSE not in blk: bad.append("%s: H2's first cause, MVStoreException's empty [2.5.250/105], missing (S4.8)" % k)
                if any(VICTIM in z for z in blk): bad.append("%s: a deadlock victim's cause line in a lost-update cell (S4.8, RED #1205) - this is 28's chain, not 25's" % k)
            else:
                if PGLOST not in blk: bad.append("%s: PostgreSQL's refusal line missing" % k)
            if "  PROBE   SQLState 40001" not in blk: bad.append("%s: the SQLState line missing" % k)
            v = R
    else:
        sa, sb, ua, ub = int(g[0]), int(g[1]), int(g[2]), int(g[3]); cls, st = g[4], g[5]
        before, aA, bA, after, v = int(g[6]), int(g[7]), int(g[8]), int(g[9]), g[10]
        if ua != 1 or ub != 1: bad.append("%s: the control - A's and B's updates matched %d/%d rows, not 1/1 (S4.17)" % (k, ua, ub))
        if (sa, sb, before, aA, bA) != (5, 5, 5, 4, 3): bad.append("%s: the invariant's numbers: %s" % (k, (sa, sb, before, aA, bA)))
        if cls is None:
            got = S if after not in (aA, bA) else N
            ctl = "VEG sum %d before · A alone leaves %d, B alone %d · both commit · %d after" % (before, aA, bA, after)
        else:
            got = R
            if after != aA: bad.append("%s: refused, but the sum %d is not A's alone (%d)" % (k, after, aA))
            if st != "40001": bad.append("%s: SQLState %s, not 40001" % (k, st))
            if db == "PostgreSQL" and PGSKEW not in blk: bad.append("%s: PostgreSQL's write-skew refusal line missing" % k)
            ctl = "VEG sum %d before · A alone leaves %d, B alone %d · B's commit refused: %s, SQLState %s · %d after" % (before, aA, bA, cls, st, after)
        if v != got: bad.append("%s: printed %s, derived %s from the invariant" % (k, v, got))
    if an != "lost update" and an != "write skew" and v != got: bad.append("%s: printed %s, derived %s" % (k, v, got))
    exp = EXP[db][lv][AN.index(an)]
    if got != exp: bad.append("%s: %s - the brief's table says %s" % (k, got, exp))
    comp[(lv, an)] = got
    rows.append("| %s | %s (%d) | %s | %s | %s |" % (db, lv, CODE[lv], an, "**SEEN**" if got == S else got, ctl))
want = [(lv, an) for lv in LV for an in AN]
if order != want: bad.append("the cells: %d, in the order %s..., expected 20 in level-then-anomaly order" % (len(order), order[:2]))
for x in bad: print("  mismatch: " + x)
if not bad:
    for r in rows: print(r)
    print("COMPACT " + db + ": " + " · ".join("%s %s" % (lv.replace("READ_UNCOMMITTED", "RU").replace("READ_COMMITTED", "RC").replace("REPEATABLE_READ", "RR").replace("SERIALIZABLE", "SER"),
          "".join({"SEEN": "S", "not seen": "-", "refused": "R"}[comp[(lv, an)]] for an in AN)) for lv in LV))
print("cells %d · mismatches %d" % (len(order), len(bad)))
sys.exit(1 if bad else 0)
PY
ATBL=""; ACH=""; ACP=""; AH2L=""; AH2C=""; APGL=""; APGS=""
chk_anomalies() { local o
  vb anomalies u25an
  printf '%s\n' "$VH" > .harness/an-h2.out; printf '%s\n' "$VP" > .harness/an-pg.out
  o=$(python3 -I -B .harness/anomalies.py .harness/an-h2.out H2) || die "anomalies H2: $(printf '%s\n' "$o" | $G -E 'mismatch|^cells' | head -4 | paste -sd';' -)"
  [ "$(printf '%s\n' "$o" | tail -1)" = 'cells 20 · mismatches 0' ] || die "anomalies H2: 20 cells"
  ATBL=$(printf '%s\n' "$o" | $G '^| '); ACH=$(printf '%s\n' "$o" | sed -n 's/^COMPACT H2: //p')
  o=$(python3 -I -B .harness/anomalies.py .harness/an-pg.out PostgreSQL) || die "anomalies PostgreSQL: $(printf '%s\n' "$o" | $G -E 'mismatch|^cells' | head -4 | paste -sd';' -)"
  [ "$(printf '%s\n' "$o" | tail -1)" = 'cells 20 · mismatches 0' ] || die "anomalies PostgreSQL: 20 cells"
  ATBL=$(printf '%s\n%s\n' "$ATBL" "$(printf '%s\n' "$o" | $G '^| ')"); ACP=$(printf '%s\n' "$o" | sed -n 's/^COMPACT PostgreSQL: //p')
  [ "$(printf '%s\n' "$ATBL" | $G -c . || true)" = 40 ] && [ "$($G -c '^  PROBE cell ' .r-anomalies.out || true)" = 40 ] || die "anomalies: 40 cell lines (len) and 40 table rows"
  # the hook: the same interleave, B at READ UNCOMMITTED while A's 9 is uncommitted - H2 reads 9, PostgreSQL 2
  has "$VH" "  PROBE cell H2 · READ_UNCOMMITTED · dirty read · A at 1, B at 1, B's session says READ UNCOMMITTED · B reads Ravi 2 · A updates Ravi to 9: 1 row, A reads Ravi 9, not committed · B reads Ravi 9 · A rolls back · SEEN" "anomalies: the hook on H2"
  has "$VP" "  PROBE cell PostgreSQL · READ_UNCOMMITTED · dirty read · A at 1, B at 1, B's session says read uncommitted · B reads Ravi 2 · A updates Ravi to 9: 1 row, A reads Ravi 9, not committed · B reads Ravi 2 · A rolls back · not seen" "anomalies: the hook on PostgreSQL"
  AH2L=$(printf '%s\n' "$VH" | sed -n "s/^  PROBE B's update refused: //p" | sort -u); AH2C=$(printf '%s\n' "$VH" | sed -n 's/^  PROBE   <- //p' | sort -u)
  [ "$(printf '%s\n' "$AH2L" | $G -c . || true)" = 1 ] && [ "$AH2C" = 'org.h2.mvstore.MVStoreException:  [2.5.250/105]' ] || die "anomalies H2: one refusal message, one cause line: $AH2C"
  [ "$($G -c 'has been chosen as a deadlock victim' .r-anomalies.out || true)" = 0 ] || die "anomalies: a deadlock victim's cause line (S4.8)"
  APGL=$(printf '%s\n' "$VP" | sed -n "s/^  PROBE B's update refused: //p" | sort -u); APGS=$(printf '%s\n' "$VP" | sed -n "s/^  PROBE B's commit refused: //p" | sort -u)
  echo "  anomalies: 40 cell lines (len), mismatches 0 on each database, every verdict re-derived from its cell's numbers and its control checked; H2 $ACH · PostgreSQL $ACP (S seen, - not seen, R refused; dirty · non-repeatable · phantom · lost update · write skew); H2's lost-update refusal: $AH2L <- $AH2C, no deadlock victim's line; PostgreSQL's: $APGL · $APGS"; }
TWO=""
chk_psql() { local C x i
  C=$(cat .r-psql.out)
  ver "$C" psql "$(dbp u25psql)"; has "$C" '  raw password copies in its log: 0 (before the mask; the URL is printed cut before its ?)' "psql: the seed JVM's password"
  has "$C" '  the driver: exit 0' "psql: the driver ends by itself"
  # S4.12: the three transcripts byte for byte (cmp), and each the capture's
  for i in 2 3; do cmp -s .harness/two-1.out ".harness/two-$i.out" || die "psql: the transcript of run $i is not run 1's, byte for byte (cmp) - S4.12"; done
  TWO=$(awk '$0 == "--- the transcript, as the driver wrote it ---" { f = 1; next } $0 == "--- the transcript'"'"'s end ---" { f = 0 } f { sub(/^  /, ""); print }' .r-psql.out)
  [ "$TWO" = "$(cat .harness/two-1.out)" ] || die "psql: the capture's transcript is not the driver's output"
  has "$TWO" '# read bounds, as configured: 3.0 for each answer · 2.0 for a statement expected to block · 5.0 for the answer after a release and for the lock_timeout statement' "psql: the bounds in the header (S4.12)"
  [ "$(printf '%s\n' "$TWO" | $G -c '^## ' || true)" = 9 ] || die "psql: nine scenes"
  sc() { printf '%s\n' "$TWO" | awk -v n="## $1 " 'index($0, n) == 1 { f = 1; next } /^## / { f = 0 } f'; }
  x=$(sc 1); for l in 'B  read uncommitted' 'A  9'; do has "$x" "$l" "psql 1"; done; [ "$(printf '%s\n' "$x" | $G -c '^B  2$')" = 2 ] || die "psql 1: B reads 2, twice, while A's 9 is uncommitted - no dirty read on PostgreSQL"
  x=$(sc 2); [ "$(printf '%s\n' "$x" | $G '^B  [0-9]' | paste -sd' ' -)" = 'B  2 B  9' ] || die "psql 2: READ COMMITTED reads 2, then 9"
  x=$(sc 3); [ "$(printf '%s\n' "$x" | $G '^B  [0-9]' | paste -sd' ' -)" = 'B  2 B  2' ] || die "psql 3: REPEATABLE READ reads 2, then 2"
  x=$(sc 4); [ "$(printf '%s\n' "$x" | $G '^B  [0-9]' | paste -sd' ' -)" = 'B  2 B  3' ] || die "psql 4: a phantom at READ COMMITTED, 2 then 3"
  x=$(sc 5); [ "$(printf '%s\n' "$x" | $G '^B  [0-9]' | paste -sd' ' -)" = 'B  2 B  2' ] || die "psql 5: no phantom at REPEATABLE READ"
  x=$(sc 6); has "$x" 'B  ERROR:  could not serialize access due to concurrent update' "psql 6"; has "$x" 'B  SQLSTATE 40001' "psql 6"
  x=$(sc 7); for l in 'B  ERROR:  could not serialize access due to read/write dependencies among transactions' 'B  DETAIL:  Reason code: Canceled on identification as a pivot, during commit attempt.' 'B  SQLSTATE 40001' 'A  4'; do has "$x" "$l" "psql 7"; done
  x=$(sc 8); [ "$(printf '%s\n' "$x" | sed -n "/^B> update customer/,/^B> commit;/p" | paste -sd'|' -)" = "B> update customer set meals_per_day = 5 where name = 'Ravi';|B  (waiting: no answer yet)|A> commit;|B  (answered: the blocked statement's marker came back)|B> commit;" ] || die "psql 8: B waits (no answer within the bound), A commits, B's answer comes back"
  has "$x" 'B  5' "psql 8: B's update applied after the wait"
  x=$(sc 9); for l in "B> set local lock_timeout = '1s';" 'B  1s' 'B  ERROR:  canceling statement due to lock timeout' 'B  SQLSTATE 55P03' 'B  9'; do has "$x" "$l" "psql 9"; done
  nhas "$x" '(waiting: no answer yet)' "psql 9: the lock_timeout refusal answers within its bound"
  [ "$(printf '%s\n' "$TWO" | $G -cE '^[AB]  \(waiting: no answer yet\)$' || true)" = 1 ] || die "psql: one waiting line, scene 8's"
  has "$TWO" 'sessions closed: A exit 0 · B exit 0' "psql: both sessions closed"
  ! printf '%s\n' "$TWO" | $G -qE '__M[0-9]+__' || die "psql: a marker leaked into the transcript (the reader drifted)"
  echo "  psql: 9 scenes, the three transcripts byte-identical (cmp), the bounds in the header; RU reads 2 twice (no dirty read on PostgreSQL) · RC 2 then 9 · RR 2 then 2 · RC phantom 2 then 3 · RR 2 then 2 · RR lost update refused (could not serialize access due to concurrent update, 40001) · SER write skew refused at commit (read/write dependencies, Canceled on identification as a pivot, 40001), the sum 4 · RC: B waiting, A commits, B answered, 5 · lock_timeout '1s': canceling statement due to lock timeout, 55P03"; }
SPH=""; SPP=""
chk_spring() { local b d said lv l
  vb spring u25sp
  for d in H2 PostgreSQL; do [ $d = H2 ] && b=$VH || b=$VP
    has "$b" '  PROBE Hikari transactionIsolation null · isAutoCommit true' "spring $d: Hikari sets no level"
    l=$(printf '%s\n' "$b" | sed -n 's/^  PROBE result: //p' | paste -sd'|' -)
    sx() { [ $d = H2 ] && printf '%s' "$1" || printf '%s' "$1" | tr 'A-Z' 'a-z'; }
    [ "$l" = "DEFAULT: JDBC getTransactionIsolation 2 · physical connection #1 · the database says $(sx 'READ COMMITTED')|READ_UNCOMMITTED: JDBC getTransactionIsolation 1 · physical connection #1 · the database says $(sx 'READ UNCOMMITTED')|DEFAULT: JDBC getTransactionIsolation 2 · physical connection #1 · the database says $(sx 'READ COMMITTED')|READ_COMMITTED: JDBC getTransactionIsolation 2 · physical connection #1 · the database says $(sx 'READ COMMITTED')|DEFAULT: JDBC getTransactionIsolation 2 · physical connection #1 · the database says $(sx 'READ COMMITTED')|REPEATABLE_READ: JDBC getTransactionIsolation 4 · physical connection #1 · the database says $(sx 'REPEATABLE READ')|DEFAULT: JDBC getTransactionIsolation 2 · physical connection #1 · the database says $(sx 'READ COMMITTED')|SERIALIZABLE: JDBC getTransactionIsolation 8 · physical connection #1 · the database says $(sx 'SERIALIZABLE')|DEFAULT: JDBC getTransactionIsolation 2 · physical connection #1 · the database says $(sx 'READ COMMITTED')" ] || die "spring $d: the nine answers, set per transaction and reset after, on one physical connection: $l"
    for lv in READ_UNCOMMITTED:ru READ_COMMITTED:rc REPEATABLE_READ:rr SERIALIZABLE:ser; do
      has "$b" "  DEBUG org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.Iso25.${lv#*:}]: PROPAGATION_REQUIRED,ISOLATION_${lv%:*}" "spring $d: the manager's line names the level"; done
    [ "$(cnt "$b" '  DEBUG org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.Iso25.def]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT')" = 5 ] || die "spring $d: DEFAULT five times"
  done
  echo "  spring: on H2 and on PostgreSQL alike - Hikari transactionIsolation null; DEFAULT 2 (read committed) · READ_UNCOMMITTED 1 · READ_COMMITTED 2 · REPEATABLE_READ 4 · SERIALIZABLE 8, the database's own answer the same level each time, DEFAULT 2 again after each, physical connection #1 throughout"; }
CXR=""; CXQ=""
chk_context() { local d b r x lv
  vb context u25cx
  for d in H2 PostgreSQL; do [ $d = H2 ] && b=$VH || b=$VP
    for r in 1 2 3; do
      has "$b" "  PROBE context READ_COMMITTED round $r · A (native SQL): first 2, second 9 · B (findById): first 2, second 2, the same instance true · the writer set Ravi to 9 · after: the second connection reads Ravi 9" "context $d READ_COMMITTED round $r: native 2 then 9, findById 2 then 2"
      has "$b" "  PROBE context REPEATABLE_READ round $r · A (native SQL): first 2, second 2 · B (findById): first 2, second 2, the same instance true · the writer set Ravi to 9 · after: the second connection reads Ravi 9" "context $d REPEATABLE_READ round $r: 2 then 2 both ways"
      for lv in READ_COMMITTED REPEATABLE_READ; do
        x=$(printf '%s\n' "$b" | awk -v a="  PROBE >>> context $lv round $r" -v z="  PROBE <<< context $lv round $r" '$0 == a { f = 1 } f { print } $0 == z { f = 0 }')
        # the order, read off the capture: the writer commits between the reader's first and second reads (the latches)
        [ "$(printf '%s\n' "$x" | $G -nE '^  PROBE   (reader: B, the first findById|writer: committed|reader: A, the second native read)$' | cut -d: -f2- | paste -sd'|' -)" = '  PROBE   reader: B, the first findById|  PROBE   writer: committed|  PROBE   reader: A, the second native read' ] || die "context $d $lv round $r: the order - first reads, the writer's commit, the second reads"
        # the second native read reaches the database (1 SQL line); the second findById does not (0) - S4.5
        [ "$(printf '%s\n' "$x" | sed -n '/^  PROBE   reader: A, the second native read$/,/^  PROBE   reader: B, the second findById$/p' | $G -c '^  DEBUG org.hibernate.SQL : ' || true)" = 1 ] || die "context $d $lv round $r: the second native read, one SQL statement"
        [ "$(printf '%s\n' "$x" | sed -n '/^  PROBE   reader: B, the second findById$/,/^  PROBE   reader: B, the second findById returned$/p' | $G -c '^  DEBUG org.hibernate.SQL : ' || true)" = 0 ] || die "context $d $lv round $r: the second findById sent SQL - it must be answered from the persistence context"
        has "$x" "  DEBUG org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.Iso25.readTwice$( [ $lv = READ_COMMITTED ] && echo RC || echo RR)]: PROPAGATION_REQUIRED,ISOLATION_$lv" "context $d $lv: the reader's level"
      done; done; done
  CXR="READ_COMMITTED - A (native SQL) 2 then 9 · B (findById) 2 then 2, 0 SQL statements, the same instance"; CXQ="REPEATABLE_READ - 2 then 2 both ways"
  echo "  context: on H2 and on PostgreSQL, 3 rounds each: $CXR; $CXQ; the second connection reads 9 after"; }
ROH=""; ROP=""; ROPC=""
chk_readonly() { local d b
  vb readonly u25ro
  for d in H2 PostgreSQL; do [ $d = H2 ] && b=$VH || b=$VP
    has "$b" "  PROBE readonly $d · edit · inside: JDBC isReadOnly true · flush mode MANUAL · tx active true · name probe.t.Iso25.roEdit · isCurrentTransactionReadOnly true · Ravi set to 7 on the object · after: the second connection reads Ravi 2" "readonly $d edit: MANUAL, read-only, the change not written"
    has "$b" '  PROBE   inside, before the write: JDBC isReadOnly true · flush mode MANUAL · tx active true · name probe.t.Iso25.roWrite · isCurrentTransactionReadOnly true' "readonly $d write: the three attributes inside the write's own transaction (S4.17)"
    has "$b" '  DEBUG org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.Iso25.roWrite]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly' "readonly $d: the manager's line says readOnly"; done
  ROH=$(printf '%s\n' "$VH" | sed -n 's/^  PROBE readonly H2 · write · //p')
  [ "$ROH" = 'the native update: 1 row, committed · after: the second connection reads Ravi 9' ] || die "readonly H2: the native UPDATE commits under readOnly: ${ROH:-none}"
  ROP=$(printf '%s\n' "$VP" | sed -n 's/^  PROBE readonly PostgreSQL · write · //p')
  [ "$ROP" = 'refused org.postgresql.util.PSQLException (SQLState 25006) · after: the second connection reads Ravi 2' ] || die "readonly PostgreSQL: the native UPDATE refused, 25006: ${ROP:-none}"
  has "$VP" '  PROBE threw: org.hibernate.exception.GenericJDBCException: JDBC exception executing SQL [ERROR: cannot execute UPDATE in a read-only transaction] [update customer set meals_per_day = 9 where id = 1]' "readonly PostgreSQL: the class and message"
  has "$VP" '  PROBE   <- org.postgresql.util.PSQLException: ERROR: cannot execute UPDATE in a read-only transaction' "readonly PostgreSQL: the first cause"
  has "$VP" '  PROBE   SQLState 25006' "readonly PostgreSQL: the SQLState"
  ROPC='org.hibernate.exception.GenericJDBCException <- org.postgresql.util.PSQLException: ERROR: cannot execute UPDATE in a read-only transaction (25006)'
  echo "  readonly: both - JDBC isReadOnly true, flush mode MANUAL, isCurrentTransactionReadOnly true, the edit not written (Ravi 2); the native UPDATE: H2 $ROH · PostgreSQL $ROPC, Ravi 2"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: yes")" = 1 ] || die "xcheck: the harness's script must be Boot's for the anchor's entities, md5 $X09 (R.212) - a mapping moved"
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ' || true)" = 3 ] || die "xcheck: two create table lines and one alter table"
  echo "  xcheck: the harness's script (@EntityScan(\"com.tiffinbox\") alone), md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README's report reads Ravi's meals twice in one transaction and gets two answers. Make both reads agree."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXB=""; EXS=""
chk_exercise() { local EB EZ b ER ES w l
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    Creating new transaction with name [probe.t.ex.Kitchen.setRavi]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT' '    PROBE after both transactions, its own JDBC connection reads: Ravi 9'; do has "$ER" "$l" "exercise: the README runs"; has "$ES" "$l" "exercise: the solution runs"; done
    has "$ER" '    Creating new transaction with name [probe.t.ex.Report.mealsTwice]: PROPAGATION_REQUIRED,ISOLATION_READ_COMMITTED' "exercise broken: READ_COMMITTED"
    has "$ES" '    Creating new transaction with name [probe.t.ex.Report.mealsTwice]: PROPAGATION_REQUIRED,ISOLATION_REPEATABLE_READ' "exercise solved: REPEATABLE_READ"
    EXB=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE the report: //p'); EXS=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE the report: //p')
    [ "$EXB" = "Ravi's meals, read twice in one transaction: 2, then 9 · two answers" ] || die "exercise: the README's run - 2, then 9: ${EXB:-none}"
    [ "$EXS" = "Ravi's meals, read twice in one transaction: 2, then 2 · both reads agree" ] || die "exercise: the solution's run - 2, then 2: ${EXS:-none}"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qxF '    @Transactional(isolation = Isolation.READ_COMMITTED)' harness/src/probe/t/ex/ExApp.java || die "exercise: ExApp ships the report at READ_COMMITTED"
  echo "  exercise: bash and zsh alike - the README as written: $EXB; the solution (one line: isolation = REPEATABLE_READ on the report): $EXS; each file's What it prints = the run; $EXW words"; }
cap anomalies anomalies; chk_anomalies; pub anomalies
cap psql psqlcap; chk_psql; pub psql
cap spring spring; chk_spring; pub spring
cap context context; chk_context; pub context
cap readonly readonly; chk_readonly; pub readonly
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise

# the table, the transcript and the values the video says are the captures', never typed: README.md holds them, composed here
printf '%s\n' "$ATBL" | while IFS= read -r l; do $G -qxF -- "$l" README.md || { echo "  *** README.md's cell table does not hold the capture's row: $l ***" >&3; exit 1; }; done || exit 1
[ "$($G -cE '^\| (H2|PostgreSQL) \| [A-Z_]+ \([1248]\) \| ' README.md || true)" = 40 ] || die "README.md's cell table: forty rows, each the capture's"
echo "  README.md's cell table: its 40 rows = the captures' cells (built by anomalies.py from the 40 cell lines, each with its control)"
RT=$(awk '/^<!-- captured: begin -->$/ { f = 1; next } /^<!-- captured: end -->$/ { f = 0 } f' README.md | sed '1d;$d')
[ "$RT" = "$TWO" ] || die "README.md's psql transcript is not the capture's, byte for byte: $(diff <(printf '%s\n' "$RT") <(printf '%s\n' "$TWO") | head -3 | paste -sd' ' -)"
echo "  README.md's psql transcript = the capture's, byte for byte"
VS="the values the video may say: H2 2.5.250 and PostgreSQL 18.6 (driver 42.7.14), Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - anomalies: 40 cells, mismatches 0; H2 $ACH; PostgreSQL $ACP; the hook, B at READ UNCOMMITTED while A's 9 is uncommitted: H2 reads 9, PostgreSQL reads 2; H2's lost-update refusal: $AH2L, its cause $AH2C (no deadlock victim) · psql: RU 2 and 2 · RC 2 then 9 · RR 2 then 2 · RC phantom 2 then 3 · RR 2 then 2 · could not serialize access due to concurrent update (40001) · could not serialize access due to read/write dependencies among transactions, Canceled on identification as a pivot, during commit attempt. (40001) · (waiting: no answer yet) until A commits · canceling statement due to lock timeout (55P03) · spring: 1/2/4/8 set per transaction, DEFAULT 2 after each, one physical connection, Hikari null · context: $CXR; $CXQ · readonly: MANUAL, isReadOnly true, the edit not written on both; the native UPDATE committed on H2, refused on PostgreSQL ($ROPC) · exercise: 2, then 9 -> 2, then 2"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"

# hygiene: every capture and every file this unit holds - 0 raw password copies
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the password ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log .harness/two-*.out; do [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the password, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGJVM" -gt 0 ] || die "no JVM ran"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task|pool-[0-9]+-thread)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl|Debian' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'SessionImpl\([0-9]|scanning in [0-9]+ ms|Lambda/0x' "$f" || die "$f holds an EntityManager's identity, a lambda's address or a scan time, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE 'pg_backend_pid|backend [0-9]|\[[0-9]+\] (LOG|ERROR)|transaction [0-9]{3,}' "$f" || die "$f holds a PostgreSQL pid or transaction id"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -q . || die "$f holds a URL"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.t' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep|time\.sleep' harness/src harness/two25.py || die "a harness sleeps (S4.18)"
! $G -rqiE 'create table' harness/src harness/two25.py || die "a DDL copy in the harness (RE-MEASURE 3) - the shipped Database creates the tables"
! $G -qE 'readline|fdopen|io\.TextIOWrapper|\.stdout\.read|for [a-z]+ in [a-z.]*stdout' harness/two25.py || die "two25.py reads through a buffered reader - S4.12 needs os.read on the terminal's descriptor"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw password copies: 0 before the mask in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs ($PGJVM PostgreSQL JVMs), 0 in every capture, log and file; 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, pid, unmasked identity, URL or stack frame in any capture; every JVM pinned and under its alarm; no harness sleep, no DDL copy, no buffered psql reader"
# ---- the end: the container, the anchor, the ports -------------------------------------------------------------------------
pgrm
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
echo "  the container: removed (docker rm -f $CN); docker ps -a names no $CN"
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20040-20049 at the end - the container bound 20048 (loopback) and is gone; 20049 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit25: every capture 3/3 and = published; every spoken number asserted; 0 raw password copies; no port bound but 20048 (the container)"
