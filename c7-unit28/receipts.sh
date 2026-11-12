#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Pessimistic Locking and Deadlocks - this unit's receipts. No change to the anchor (brief flag 1): anchor/ is the link
# to ../c7-unit27/after, Section 4's frozen anchor (= ../c7-tiffinbox). A pessimistic lock takes the row before anyone else can: the
# next transaction waits, gives up after its timeout, or skips the row; two transactions taking two rows in opposite orders wait for
# each other until the database refuses one. Seven captures, each run three times and hashed; a hash that differs from
# receipts.md5 stops the run; every number and string the video says is asserted right after its capture by a check that can fail.
# Two databases (brief flag 2): H2 2.5.250 in each JVM's memory, and PostgreSQL 18.6 in ONE container this script starts from the
# pinned image and removes. TiffinBox itself never runs here.
#   locks      each lock mode and hint alone, one statement each (H2, PostgreSQL): the SQL Hibernate sends, read off its logger, built
#              into the README's table by locks.py; PESSIMISTIC_FORCE_INCREMENT on 27's versioned CustomerEntity; no transaction
#   wait       T1 holds Ravi's row lock; T2 asks for Ravi four ways - lock.timeout 0, lock.timeout 1000, lock.timeout -2, plain - each
#              refusal's chain and SQLState (S4.8); the plain ask: T2's blocked state witnessed by the second connection BEFORE T1 is
#              released (S4.18), the order derived from the one log's sequence (H2, PostgreSQL)
#   txtimeout  @Transactional(timeout = 1): an idle wait past the deadline, then a statement (H2, PostgreSQL); on PostgreSQL also one
#              statement that outlasts it
#   deadlock   the failure receipt: T1 locks Ravi then Meera, T2 Meera then Ravi, T2's second ask after a configured gap of 300; the
#              victim of every round counted by the threw lines per thread, deadlock_timeout and the gap beside it; PostgreSQL's
#              server lines by docker logs --since, masked; then LABELLED: the gap 1500, and on PostgreSQL log_lock_waits = on for
#              that run's own database only (alter database ... set, S4.11)
#   order      the fix: both lock Ravi first - T2 seen blocked, T1 released, both commit (H2, PostgreSQL)
#   xcheck     the harness's DDL script (@EntityScan("com.tiffinbox") alone) against the version lesson's filed script (R.252)
#   exercise   exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#              shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# The anchor is COPIED under .harness/anchor and built there, never in place (its README's package line, offline; its tests run);
# its jar extracted (the anchor's own line). The harness (harness/src, packages probe.t and probe.x, outside com.tiffinbox) is
# compiled against the anchor's extracted libraries with javac -parameters into .harness/hc. probe.t.Main is a Spring Boot context
# with no web server (WebApplicationType.NONE: it binds no port), @EntityScan on com.tiffinbox, @EnableJpaRepositories on
# com.tiffinbox and probe.t.repo - the anchor's own CustomerEntityRepository and the harness's locking repository; probe.t.Seed builds
# the shipped Database in code on the run's own database, which seeds it; ddl-auto none. The PostgreSQL driver (42.7.14) is on every
# harness JVM's class path from this unit's .m2-demo (the anchor's lib/ has none). Logback (harness/logback.xml) writes through the
# harness's own appender (probe.t.Buf): while two threads run it keeps their lines in the one order it received them and the
# scenario prints them thread by thread, deriving the order between the threads from that sequence (S4.18). No harness class
# sleeps (a grep below): every order is a latch's; the two configured pauses (the deadlock's gap, txtimeout's idle wait) are a latch
# nobody counts down, awaited for the configured value. Every JVM's flags travel as an array, V, its arguments as an array, A
# (R.193); every JVM runs under an alarm (perl -e 'alarm N; exec ...': macOS has no timeout); an alarm that fires is a failed
# receipt (R.247). Commands are printed exactly as they run: each goes through eval.
# harness/dur7.py (Course 7's builders' duration pattern, byte for byte) and S4.7's duration-meaning family (below, as unit 27
# carries it) gate this unit's prose: it speaks no time (R.172, R.264); timeout = 1, wait 1, lock_timeout = 1000, deadlock_timeout
# 1s and the gap are quoted as configured text. "$M2" is this unit's .m2-demo. Every JVM has its locale pinned on its run line.
# The network: every Maven run is offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an artifact
# offline is run once more without -o and says so, naming what it fetched. docker run never pulls (--pull never): the image must be
# on this machine (docker image inspect, before anything starts). At run time nothing leaves the machine: H2 in memory; PostgreSQL
# on 127.0.0.1:20078 only, asked by the harness's JDBC and by docker exec / docker logs. This unit reads no version file: the
# section's dated sweep is the brief's (R.223; _research/spring-boot-metadata-2026-11-10.xml, spring-data-bom-metadata-2026-11-10.xml).
# PostgreSQL's password (R.214): generated here into .harness/secrets/pgpw, mode 0600, read by the container (POSTGRES_PASSWORD_FILE,
# a read-only bind mount) and by the harness (-Dpg.pwfile: the URL is built inside the JVM, every printed URL cut before its "?");
# never on a command line, never printed. Every capture's raw output is counted for raw copies BEFORE the mask (0) and after (0); the
# mask is self-tested with it planted. Per-database settings (S4.11): one - `alter database <the labelled run's own database> set
# log_lock_waits = on`, for that run only; this script holds no server-wide setting statement (a grep below).
# Masks (README.md declares each; awk gsub only): the password "<pw>"; this folder "…", the folder above "…/..", home "~", your
# user name "<user>"; " using Java <version>"; an identity hash "@…"; an EntityManager's identity "SessionImpl(<n><open>)"; Spring
# Data's scan figure; the deadline's date "<date>"; H2's transaction numbers "<n>"; a PostgreSQL transaction id "<xid>"; a pid the
# harness did not label "<pid>"; a measured figure with its unit "<masked>"; the harness's PIDMAP lines (the pids, for the server's
# log) taken out. The harness itself writes a PostgreSQL backend's pid as the label of the thread that printed it ("<pid of T1>").
# Ports (§P, 20070-20079): 20078 the container (127.0.0.1 only) · 20070-20077 unused (the harness JVMs bind none) · 20079 never
# bound; all ten checked free at the start and the end.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u28-pg
DLGAP=300; DLR=3; DLGAP2=1500                        # the deadlock's configured gap and rounds; the labelled run's gap (brief ⚑9)
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process under it); then
# sweep(): anything of this run still alive in its process group is stopped; then the container, if this script created it
# (CSTARTED), is removed (docker rm -f, pgrm). After an interrupt a capture's unfinished runs (.r-NAME.1-3) go too; after a failed
# check they stay. The clean-up ignores a second Ctrl-C; the script exits 130 after an interrupt. No wait is bare.
pid=""; mpid=""; xpid=""; CSTARTED=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.t.") || index($0, "probe.x.") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "surefirebooter") || index($0, "docker exec c7u28-pg") || index($0, "docker logs")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 perl rsync lsof mvn md5 cmp find docker /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - the password lives under .harness/ only"
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit27/after ] || die "anchor must be the link to ../c7-unit27/after - this unit changes nothing in it"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
# R.211: anchor/ equals ../c7-tiffinbox (Section 4's frozen anchor) until a later course changes the anchor - a note then, never a stop
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): anchor/ = ../c7-unit27/after (Section 4's frozen anchor); diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit27/after (Section 4's frozen anchor) - no anchor change in this unit"; fi; }
anchornote start
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted
HS=harness/src/probe/t
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
HFILES='dur7.py logback.xml src'
SFILES='probe/t/Buf.java probe/t/H.java probe/t/Lock28.java probe/t/Main.java probe/t/Run.java probe/t/Seed.java probe/t/ex/ExApp.java probe/t/repo/Locks.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
X27=9cf92b8cae3abfd0f1c0706bfe7a4373                # Boot's script for 27's two entities - ../c7-unit27/xcheck.sql, filed there (R.252, RED #1209)
[ -f ../c7-unit27/xcheck.sql ] && [ "$(md5 -q ../c7-unit27/xcheck.sql)" = "$X27" ] || die "../c7-unit27/xcheck.sql must be the version lesson's filed script, md5 $X27"
[ "$($G -c "$X27" ../c7-unit27/README.md || true)" -gt 0 ] || die "../c7-unit27/README.md must name $X27 - the version lesson's DDL md5"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="20070 20071 20072 20073 20074 20075 20076 20077 20078 20079"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
docker image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - docker pull it once (this script never pulls)"
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it yourself: docker rm -f $CN"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets
echo "  the image: $IMG is on this machine (docker image inspect; never pulled)"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 + S4.7 (R.264, RED #1211): dur7.DUR, and BLUE's duration-meaning family beside it - unit 27's gate, carried as is (its two
# exempt sentences are not in this unit's prose; the exemption is harmless here - README, For RED)
cat > .harness/dur.py <<'PY'
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|a|\d+)\s+(?:second|minute|hour)s?|half a second|eventually)\b", re.I)
for t, want in (("forever", 1), ("at once", 1), ("immediately", 1), ("one second", 1), ("a moment", 1), ("3 seconds", 1),
                ("a timeout of one, as configured", 0), ("the second connection reads Ravi", 0), ("another bean", 0),
                ("deadlock_timeout 1s, as configured", 0), ("T1 asks for its second row", 0)):
    assert bool(m.DUR.search(t) or FAM.search(t)) == bool(want), t
C13 = "One transaction covers one database; a second system that must hear about the same change can fail after the commit."
assert FAM.search(C13) and not FAM.search(("x " + C13 + " y").replace(C13, ""))
EXL = "the README edits Ravi twice at once, and one edit disappears without an error. Make the losing edit fail loudly."
assert FAM.search(EXL) and not FAM.search(("x " + EXL + " y").replace(EXL, ""))
n = f = 0
for p in sys.argv[2:]:
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        l = l.replace(C13, "").replace(EXL, "")
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
DN=$(dishes README.md exercise harness/src)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose - the exercise's blocks hold the measured output: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty (exercise compares it with the run, line for line)"
# S4.8 (R.265) and S4.14 (R.271), ⚑9: the refuted readings this unit could tempt, refused per sentence; README.md's captured blocks
# and its values line are left out (the receipt compares them with the captures below). The self-test first.
cat > .harness/s28.py <<'PY'
import re, sys
NEG = re.compile(r"\b(?:not|no|never|none|cannot|can't|refus\w*|without|neither|nor)\b", re.I)
PLE = re.compile(r"Pessimistic\s*Lock\s*Exception", re.I)
CHEAP = re.compile(r"\bcheap(?:er|est)?\b[^.!?]*\btransaction|\bchooses?\b[^.!?]*\b(?:cheap|smaller|younger|older)", re.I)
ALWAYS = re.compile(r"\b(?:later|second|last|first|earlier)\s+waiter\s+is\s+always\b|\balways\b[^.!?]*\bvictim\b|\bvictim\b[^.!?]*\balways\b", re.I)
SHARED = re.compile(r"\bshared?\s+lock\b[^.!?]*\bH2\b|\bH2\b[^.!?]*\bshared?\s+lock\b|\bH2\b[^.!?]*\bfor share\b", re.I)
VICT = re.compile(r"\bvictim\b|\bkill(?:s|ed)?\b|\brefuses?\b[^.!?]*\b(?:T1|T2|first waiter|later waiter)", re.I)
PG = re.compile(r"\bPostgre(?:SQL|s)\b", re.I); GAP = re.compile(r"\bgap\b|\bdeadlock_timeout\b|\bas configured\b", re.I)
SYS = re.compile(r"\bALTER\s+SYSTEM\b", re.I)
def why(s):
    if PLE.search(s): return "S4.8: a refused name (the waits' class is Spring's CannotAcquireLockException, as captured)"
    if CHEAP.search(s) and not NEG.search(s): return "S4.8: the database chooses the cheaper transaction (no capture says so)"
    if ALWAYS.search(s) and not NEG.search(s): return "S4.14: the victim is always one waiter (the design decides - the gap, deadlock_timeout)"
    if SHARED.search(s) and not NEG.search(s): return "S4.14: a shared lock on H2 (H2's PESSIMISTIC_READ is for update)"
    if VICT.search(s) and PG.search(s) and not GAP.search(s) and not NEG.search(s): return "⚑9: a PostgreSQL victim claim not scoped to the gap"
    if SYS.search(s) and not NEG.search(s): return "S4.11: a server-wide setting (per-database settings only)"
    return None
cases = [("The wait throws PessimisticLockException.", True), ("PostgreSQL chooses the cheaper transaction.", True),
         ("The later waiter is always the victim.", True), ("H2 takes a shared lock for PESSIMISTIC_READ.", True),
         ("PostgreSQL kills the first waiter.", True), ("Set it with ALTER " + "SYSTEM.", True),
         ("With a configured gap of 300, PostgreSQL's victim is T1 in every round.", False),
         ("H2's PESSIMISTIC_READ is for update, the same as PESSIMISTIC_WRITE.", False),
         ("No capture says which transaction is cheaper.", False), ("The second connection reads Ravi 2.", False),
         ("H2 refuses T2 in every round, the one whose request closes the cycle.", False)]
m = sum(bool(why(t)) != w for t, w in cases)
assert m == 0, "s28 self-test: %d mismatches" % m
n = 0
for p in sys.argv[1:]:
    t = open(p, encoding="utf-8").read()
    t = re.sub(r"<!-- captured: [a-z]+ begin -->.*?<!-- captured: [a-z]+ end -->", " ", t, flags=re.S)
    t = re.sub(r"<!-- values: begin -->.*?<!-- values: end -->", " ", t, flags=re.S)
    for s in re.split(r"(?<=[.!?])\s+", t.replace("\n", " ")):
        w = why(s)
        if w:
            n += 1; print("  %s: %s  <- %s" % (p, s.strip()[:160], w))
print("S4.8/S4.14/S4.11/flag-9 refused sentences: %d (self-test: %d cases, 0 mismatches)" % (n, len(cases)))
PY
SW=$(python3 -I -B .harness/s28.py $PROSE) || die "the S4.8/S4.14 gate did not run (or its self-test failed)"
printf '%s\n' "$SW" | tail -1 | $G -q '^S4.8/S4.14/S4.11/flag-9 refused sentences: 0 ' || die "S4.8 / S4.14 / S4.11 / ⚑9: $(printf '%s\n' "$SW" | $G '<-' | head -3 | paste -sd';' -)"
echo "  $(printf '%s\n' "$SW" | tail -1) over README.md, exercise/"
# R.225: a SQL string this unit shows is a capture's - outside README.md's captured blocks and its values line, a line holding a
# statement's piece is a typed SQL string, refused
SQLRE='for update|for no key update|for share of|skip locked|nowait|set local lock_timeout|current_setting\(|update customer set|ce1_0\.|select pg_|pg_stat_activity\.|blocker_id'
TS=$(awk '/<!-- (captured: [a-z]+ begin|values: begin) -->/ { f = 1 } !f { print NR ": " $0 } /<!-- (captured: [a-z]+ end|values: end) -->/ { f = 0 }' README.md | $G -iE "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md (R.225): $TS"
echo "  typed SQL strings: 0 in README.md outside its captured blocks and its values line"
ASY='alter'' system'; ! $G -rniE "$ASY" receipts.sh harness | $G -vE '^receipts.sh:[0-9]+: *#' | $G -vF 'SYS = re.compile' > /dev/null || die "S4.11: a server-wide setting statement ($ASY) in this script or the harness - per-database settings only"
SLP='Thread''\.sleep|time\.sleep|TimeUnit\.[A-Z]+\.sleep|LockSupport\.park'; ! $G -rqE "$SLP" harness/src || die "a harness class sleeps (S4.18): $($G -rnE "$SLP" harness/src | head -2 | paste -sd';' -)"
echo "  server-wide setting statements: 0 in this script and the harness (S4.11) · sleeps in harness/src: 0 (S4.18)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/Buf.java $HS/H.java $HS/Lock28.java $HS/Main.java $HS/Run.java $HS/Seed.java $HS/repo/Locks.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*:../../.m2-demo/$PGJ\" probe.t.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_RUN=$(mine "docker run -d --pull never --name $CN -p 127.0.0.1:20078:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_SET=$(mine "docker exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"alter database \$DB set log_lock_waits = on\"")
L_LOGS=$(mine "docker logs --since \"\$ST\" $CN")
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
[ "$DP" = '5432/tcp -> 127.0.0.1:20078' ] || die "docker port: the container must publish 5432 on 127.0.0.1:20078 alone: $DP"
[ "$(listeners 20078)" -ge 1 ] || die "nothing listens on 20078 after the container started"
echo "  the container: $CN from $IMG (--pull never); docker port: $DP; user sa, the password generated into .harness/secrets/pgpw (24 characters, mode 0600, never printed); pg_isready after $i tries (cap 120)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0; PGJVM=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v pw="$PW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { W = lit(pw); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  /^ *PIDMAP round / { next }
  { gsub(W, "<pw>"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/SessionImpl\([0-9]+</, "SessionImpl(<n><")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/deadline was [A-Z][a-z][a-z] [A-Z][a-z][a-z] [ 0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] [A-Z]+ [0-9][0-9][0-9][0-9]/, "deadline was <date>")
    gsub(/[Tt]ransaction [0-9]+\([0-9]+\)/, "transaction <n>(<n>)")
    gsub(/Transaction [0-9]+ /, "Transaction <n> ")
    gsub(/ tx [0-9]+/, " tx <n>")
    gsub(/transaction [0-9]+/, "transaction <xid>")
    gsub(/interval [0-9]+ ms/, "interval <masked>"); gsub(/after [0-9]+(\.[0-9]+)? ms/, "after <masked>")
    gsub(/[Pp]rocess [0-9]+/, "process <pid>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 2 JPA repository interfaces.' "url jdbc:postgresql://127.0.0.1:20078/u28lk?user=sa&password=$PW" 'Transaction timed out: deadline was Thu Nov 12 08:03:36 CET 2026' 'Transaction 2 has been chosen as a deadlock victim; modified by transaction 1(113) OPEN' 'is locked by tx 1 and can not be updated by tx 2 within allocated time interval 1000 ms. [2.5.250/101]' 'Process 287 waits for ShareLock on transaction 860' 'still waiting for ShareLock on transaction 934 after 1002.787 ms' 'PIDMAP round 1 T1 287 T2 288' 'Process <pid of T1> waits' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 2 JPA repository interfaces.' 'url jdbc:postgresql://127.0.0.1:20078/u28lk?user=sa&password=<pw>' 'Transaction timed out: deadline was <date>' 'Transaction <n> has been chosen as a deadlock victim; modified by transaction <n>(<n>) OPEN' 'is locked by tx <n> and can not be updated by tx <n> within allocated time interval <masked>. [2.5.250/101]' 'process <pid> waits for ShareLock on transaction <xid>' 'still waiting for ShareLock on transaction <xid> after <masked>' 'Process <pid of T1> waits')" ] || die "mask: the planted JDK version, folders, home, identity hash, EntityManager identity, scan figure, password, deadline date, H2 transaction numbers, a PostgreSQL xid and pid, the measured figures and the PIDMAP line must be masked: $(diff <(mask < .harness/p1) - < /dev/null | head -3 | paste -sd' ' -)"
[ "$(mask < .harness/p1 | raw "$PW")" = 0 ] || die "mask: a raw copy of the password survived its self-test"
rm -f .harness/p1
echo "  the mask's self-test: the password planted, raw password copies after mask: 0; the deadline's date, H2's transaction numbers, a xid, a pid, the measured figures, a PIDMAP line - each masked"
# the harness's arguments: no schema written, no banner, Thymeleaf not looking for templates; H2: this JVM's own database; PostgreSQL:
# the URL built by Main from -Dpg.db and -Dpg.pwfile (no password on the command line)
HQ=(--logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
HA=('--spring.datasource.url=jdbc:h2:mem:u28;DB_CLOSE_DELAY=-1' "${HQ[@]}")
# pgdb NAME: a fresh PostgreSQL database (dropped with force if it is there, created) - printed, its exit asserted
pgdb() { DB=$1; echo "\$ DB=$DB"; echo "\$ $L_DB"
  (eval "$L_DB") > .harness/psql.log 2>&1 < /dev/null || die "psql could not make the database $DB: $(tail -2 .harness/psql.log)"
  echo "  exit 0 · a fresh database $DB"; }
# pgset: the labelled run's one per-database setting (S4.11), on the database pgdb made last
pgset() { echo "\$ $L_SET"
  (eval "$L_SET") > .harness/psql.log 2>&1 < /dev/null || die "psql could not set log_lock_waits on $DB: $(tail -2 .harness/psql.log)"
  echo "  exit 0 · log_lock_waits = on for the database $DB alone"; }
HE=""
hrun() { local c i=0 e=0 n
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  if [ "${HL:-$L_H}" != "$L_X" ]; then echo "\$ V=($(printf '%q ' "${V[@]}" | sed 's/ $//'))"; fi
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  n=$(raw "$PW" .harness/h.log); [ "$n" = 0 ] || die "a harness JVM printed the password ($n raw copies before any mask) - R.214"
  case " ${V[*]:-} " in *" -Dpg.db="*) PGJVM=$((PGJVM + 1)); echo "  raw password copies in its log: $n (before the mask; the URL is printed cut before its ?)" ;; esac
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"; }
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
# srv: PostgreSQL's own lines for the JVM that just ran - docker logs since the stamp taken before it, the records of that JVM's two
# backends only (their pids from its PIDMAP lines), split by the rounds' markers (raise log from the second connection), each pid
# written as the label of the thread that printed it, every transaction id and measured figure masked (srv.py, below; S4.11)
ST=""
srv() { local i=0
  echo "\$ $L_LOGS     # ST: a stamp taken before the JVM started (the stamp is not printed)"
  while :; do (eval "$L_LOGS") > .harness/srv.raw 2>&1 < /dev/null || die "docker logs failed"
    $G -q 'LOG:  u28 marker: end$' .harness/srv.raw && break; i=$((i + 1)); [ $i -lt 40 ] || die "the server's log does not hold the run's end marker (40 tries, 0.25 apart)"; sleep 0.25; done
  [ "$(raw "$PW" .harness/srv.raw)" = 0 ] || die "the server's log holds the password, raw"
  python3 -I -B .harness/srv.py .harness/srv.raw .harness/h.log || die "srv.py: $(python3 -I -B .harness/srv.py .harness/srv.raw .harness/h.log 2>&1 | tail -2 | paste -sd' ' -)"; }
stamp() { ST=$(date -u -v-2S +%Y-%m-%dT%H:%M:%SZ); }
unpub=""; CAPRUN=0
cap() { local nm=$1 i; shift
  for i in 1 2 3; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    echo "$(raw "$PW" .harness/cap.raw)" > ".harness/raw-$nm.$i"
    mask < .harness/cap.raw > ".r-$nm.$i"
    if [ "$(type -t "pre_$nm")" = function ]; then "pre_$nm" ".r-$nm.$i" "$i"; fi; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot, Maven or image, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# both NAME DBNAME: the scenario on H2, then on its own fresh PostgreSQL database
both() { echo "H2 - one harness JVM, -Ds=$1, this JVM's own H2 database:"; V=(-Ds=$1); A=("${HA[@]}"); hrun; hview
  echo "PostgreSQL - a fresh database, then one harness JVM, -Ds=$1:"; pgdb "$2"
  V=(-Ds=$1 -Dpg.db=$2 -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}"); hrun; hview; }
cat > .harness/srv.py <<'PY'
import re, sys
raw, jvm = sys.argv[1], sys.argv[2]
pm = {}
for l in open(jvm, encoding="utf-8", errors="replace"):
    m = re.match(r"^PIDMAP round (\d+) T1 (\d+) T2 (\d+)$", l.strip())
    if m: pm["round " + m.group(1)] = {m.group(2): "T1", m.group(3): "T2"}
if not pm: sys.exit("no PIDMAP line in the JVM's log")
REC = re.compile(r"^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d\.\d+ UTC \[(\d+)\] ([A-Z]+):  (.*)$")
recs = []; cur = None
for l in open(raw, encoding="utf-8", errors="replace"):
    l = l.rstrip("\n"); m = REC.match(l)
    if m: cur = [m.group(1), m.group(2), [m.group(3)]]; recs.append(cur)
    elif l.startswith("\t") and cur is not None: cur[2].append(l[1:])
    else: cur = None
def lab(s, mp):
    s = re.sub(r"([Pp]rocess )(\d+)", lambda x: x.group(1) + ("<pid of %s>" % mp[x.group(2)] if x.group(2) in mp else "<pid>"), s)
    s = re.sub(r"(holding the lock: )(\d+)", lambda x: x.group(1) + ("<pid of %s>" % mp[x.group(2)] if x.group(2) in mp else "<pid>"), s)
    s = re.sub(r"(Wait queue: )([\d, ]*)", lambda x: x.group(1) + ", ".join("<pid of %s>" % mp.get(y.strip(), "?") for y in x.group(2).split(",") if y.strip()), s)
    s = re.sub(r"(transaction )(\d+)", r"\1<xid>", s)
    s = re.sub(r"after \d+(\.\d+)? ms", "after <masked>", s)
    return s
rnd = None; vic = {}; n = 0; seen = set()
for p, lvl, lines in recs:
    if lvl == "LOG" and lines[0].startswith("u28 marker: "):
        rnd = lines[0][len("u28 marker: "):]; seen.add(rnd); print("  server: the marker %s (raise log, the second connection)" % rnd); continue
    if rnd not in pm: continue
    mp = pm[rnd]
    if p not in mp: continue
    for i, x in enumerate(lines):
        print("  server %s [%s] %s%s" % (rnd, mp[p], (lvl + ":  ") if i == 0 else "        ", lab(x, mp))); n += 1
    if lvl == "ERROR" and lines[0] == "deadlock detected": vic.setdefault(rnd, []).append(mp[p])
for r in sorted(pm):
    if r not in seen: sys.exit("no marker for " + r)
    v = vic.get(r, [])
    print("  server %s: ERROR:  deadlock detected came from %d backend(s): %s - the backend of %s (its pid, printed by pg_backend_pid() inside its transaction)" % (r, len(v), " ".join(v) or "none", " and ".join(v) or "none"))
print("  server: %d lines of the JVM's two backends, %d rounds" % (n, len(pm)))
PY

# ---- the captures --------------------------------------------------------------------------------------------------------
locks() { echo "locks - each lock mode and hint alone, one statement each, through the harness's @Transactional methods:"; both locks u28lk; }
waitcap() { echo "wait - T1 holds Ravi's row lock; T2 asks for Ravi four ways (two threads, latches):"; both wait u28wt; }
txtimeout() { echo "txtimeout - @Transactional(timeout = 1), configured:"; both txtimeout u28tt; }
deadlock() {
  echo "deadlock - T1 locks Ravi, then Meera; T2 locks Meera, then Ravi; T2's second ask after a configured gap (two threads, latches):"
  echo "H2 - gap $DLGAP, $DLR rounds - one harness JVM, this JVM's own H2 database:"; V=(-Ds=deadlock -Dgap=$DLGAP -Drounds=$DLR); A=("${HA[@]}"); hrun; hview
  echo "PostgreSQL - gap $DLGAP, $DLR rounds - a fresh database, then one harness JVM:"; pgdb u28dl; stamp
  V=(-Ds=deadlock -Dgap=$DLGAP -Drounds=$DLR -Dpg.db=u28dl -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}"); hrun; hview; srv
  echo "H2 - LABELLED gap $DLGAP2, $DLR rounds - one harness JVM, this JVM's own H2 database:"
  V=(-Ds=deadlock -Dgap=$DLGAP2 -Drounds=$DLR "-Dlabel=gap $DLGAP2 (configured)"); A=("${HA[@]}"); hrun; hview
  echo "PostgreSQL - LABELLED gap $DLGAP2, $DLR rounds, log_lock_waits = on for this run's database alone - a fresh database, its setting, then one harness JVM:"; pgdb u28dlw; pgset; stamp
  V=(-Ds=deadlock -Dgap=$DLGAP2 -Drounds=$DLR "-Dlabel=gap $DLGAP2 (configured) and log_lock_waits = on (alter database u28dlw set, this database alone)" -Dpg.db=u28dlw -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}"); hrun; hview; srv; }
order() { echo "order - both lock Ravi first, then Meera (two threads, latches):"; both order u28or; }
xcheck() {
  echo "the harness's DDL - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  V=(); A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  echo "  .harness/run/hibernate-ddl.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/run/hibernate-ddl.sql
  echo "  its md5: $(md5 -q .harness/run/hibernate-ddl.sql) · the version lesson's filed script (its xcheck.sql): $(md5 -q ../c7-unit27/xcheck.sql) · cmp: $(cmp -s .harness/run/hibernate-ddl.sql ../c7-unit27/xcheck.sql && echo 'the same, byte for byte' || echo differ)"
  rm -f .harness/run/hibernate-ddl.sql; }
XA=('--spring.datasource.url=jdbc:h2:mem:x28;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
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
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' "$1"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# S4.13 (R.270): Framework's version in the same capture beside HHH000001 and Spring Data's - once per harness JVM, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
VERD='  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2'
VERF='  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10'
DBH='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:u28;DB_CLOSE_DELAY=-1 | JDBC driver H2 JDBC Driver 2.5.250 (2026-08-29)'
dbp() { printf '  PROBE database: PostgreSQL 18.6 | url jdbc:postgresql://127.0.0.1:20078/%s | JDBC driver PostgreSQL JDBC Driver 42.7.14\n' "$1"; }
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); the second connection reads: customer rows 4 [1 Ravi 2 v0, 2 Meera 1 v0, 3 Sunil 3 v0, 4 Priya 1 v0]'
FOUND2='  INFO  [main] org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 2 JPA repository interfaces.'
SEEDV='Ravi 2 (version 0), Meera 1 (version 0)'
ver() { local c; c=$1
  [ "$(cnt "$c" "$VERL")" = 1 ] && [ "$(cnt "$c" "$VERH")" = 1 ] && [ "$(cnt "$c" "$VERD")" = 1 ] && [ "$(cnt "$c" "$VERF")" = 1 ] || die "$2: the version lines - getVersionString(), Hibernate's HHH000001, Spring Data JPA's 4.1.2 and Spring Framework's 7.0.10 - once in its harness JVM (S4.13)"
  [ "$(cnt "$c" "$3")" = 1 ] && [ "$(cnt "$c" "$SEEDL")" = 1 ] && [ "$(cnt "$c" "$FOUND2")" = 1 ] || die "$2: the database: line ($(printf '%s' "$3" | sed 's/^  PROBE database: //; s/ |.*//')), the shipped seed read by the second connection and Spring Data's Found 2"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = 1 ] || die "$2: its harness JVM ends by itself, exit 0"
  nhas "$c" 'a line of another thread' "$2: a line of a thread the scenario did not start"; }
# vb FILE NAME DBNAME: the H2 block and the PostgreSQL block of a two-database capture, each checked by ver()
VH=""; VP=""
vb() { VH=$(blk "$1" 'H2 - ' 'PostgreSQL - '); VP=$(blk "$1" 'PostgreSQL - ' '')
  ver "$VH" "$2 H2" "$DBH"; ver "$VP" "$2 PostgreSQL" "$(dbp "$3")"
  has "$VP" '  raw password copies in its log: 0 (before the mask; the URL is printed cut before its ?)' "$2 PostgreSQL: the password"; }
# chain.py FILE FROM TO HEAD: the chain a PROBE "HEAD: " line starts inside the block FROM..TO - its classes (with their packages),
# the top message, the JDBC exception's line, the last cause's line, the SQLState (S4.8), and how many such chains the block holds
cat > .harness/chain.py <<'PY'
import sys
f, a, b, head = sys.argv[1:5]
L = [l.rstrip("\n") for l in open(f, encoding="utf-8")]
try: i0 = next(i for i, l in enumerate(L) if l.strip() == a.strip())
except StopIteration: sys.exit("no block " + a)
blk = []
for l in L[i0 + 1:]:
    if l.strip() == b.strip(): break
    blk.append(l.strip())
heads = [i for i, l in enumerate(blk) if l.startswith("PROBE " + head + ": ")]
print("CHAINS %d" % len(heads))
if not heads: sys.exit(0)
i = heads[0]; top = blk[i][len("PROBE " + head + ": "):]
cls = [top.split(":")[0]]; msgs = [top]; st = "none"
for l in blk[i + 1:]:
    if l.startswith("PROBE   <- "): x = l[len("PROBE   <- "):]; cls.append(x.split(":")[0]); msgs.append(x)
    elif l.startswith("PROBE   SQLState "): st = l.split()[-1]; break
    else: break
print("CLASSES " + " <- ".join(cls))
print("TOP " + msgs[0])
jd = [m for m in msgs if m.startswith(("org.postgresql.", "org.h2.jdbc."))]
print("JDBC " + (jd[0] if jd else "none"))
print("LAST " + msgs[-1])
print("STATE " + st)
PY
chainof() { python3 -I -B .harness/chain.py "$@" || die "chain.py: $*"; }
cv() { printf '%s\n' "$1" | sed -n "s/^$2 //p"; }
# locks.py FILE: the lock-SQL table of [S4 §8] built from Hibernate's SQL lines between each step's markers, per database; the
# brief's expected forms checked (the receipt's check, never the README's text); prints the rows README.md must hold
cat > .harness/locks.py <<'PY'
import sys
f = sys.argv[1]
L = [l.rstrip("\n") for l in open(f, encoding="utf-8")]
STEPS = ["PESSIMISTIC_WRITE", "PESSIMISTIC_READ", "EntityManager.find with PESSIMISTIC_WRITE", "PESSIMISTIC_WRITE, lock.timeout 0",
         "PESSIMISTIC_WRITE, lock.timeout 1000", "PESSIMISTIC_WRITE, lock.timeout -2", "PESSIMISTIC_FORCE_INCREMENT", "PESSIMISTIC_WRITE without a transaction"]
SEL = "select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 where "
def part(db):
    a = L.index("H2 - one harness JVM, -Ds=locks, this JVM's own H2 database:" if db == "H2" else "PostgreSQL - a fresh database, then one harness JVM, -Ds=locks:")
    return L[a:] if db == "PostgreSQL" else L[a:L.index("PostgreSQL - a fresh database, then one harness JVM, -Ds=locks:")]
out = {}; bad = []; res = {}
for db in ("H2", "PostgreSQL"):
    P = part(db)
    for s in STEPS:
        try: i = P.index("  PROBE >>> locks · " + s); j = P.index("  PROBE <<< locks · " + s)
        except ValueError: bad.append("%s %s: no block" % (db, s)); continue
        sql = [l.split("org.hibernate.SQL : ", 1)[1] for l in P[i:j] if "DEBUG [main] org.hibernate.SQL : " in l]
        cells = []
        for q in sql:
            if q.startswith(SEL): cells.append("`… where " + q[len(SEL):] + "`")
            else: cells.append("`" + q + "`")
        out[(db, s)] = " · ".join(cells) if cells else "no statement sent"
        res[(db, s)] = [l[len("  PROBE "):] for l in P[i:j] if l.startswith(("  PROBE result: ", "  PROBE threw: ", "  PROBE   <- ", "  PROBE after: "))]
EXP = {("H2", "PESSIMISTIC_WRITE"): "`… where ce1_0.id=? for update`", ("PostgreSQL", "PESSIMISTIC_WRITE"): "`… where ce1_0.id=? for no key update of ce1_0`",
       ("H2", "PESSIMISTIC_READ"): "`… where ce1_0.id=? for update`", ("PostgreSQL", "PESSIMISTIC_READ"): "`… where ce1_0.id=? for share of ce1_0`",
       ("H2", "PESSIMISTIC_WRITE, lock.timeout 0"): "`… where ce1_0.id=? for update nowait`", ("PostgreSQL", "PESSIMISTIC_WRITE, lock.timeout 0"): "`… where ce1_0.id=? for no key update of ce1_0 nowait`",
       ("H2", "PESSIMISTIC_WRITE, lock.timeout 1000"): "`… where ce1_0.id=? for update wait 1`",
       ("PostgreSQL", "PESSIMISTIC_WRITE, lock.timeout 1000"): "`select current_setting('lock_timeout', true)` · `set local lock_timeout = 1000` · `… where ce1_0.id=? for no key update of ce1_0` · `set local lock_timeout = 0`",
       ("H2", "PESSIMISTIC_WRITE, lock.timeout -2"): "`… where ce1_0.meal_type=? order by ce1_0.id fetch first ? rows only for update skip locked`",
       ("PostgreSQL", "PESSIMISTIC_WRITE, lock.timeout -2"): "`… where ce1_0.meal_type=? order by ce1_0.id fetch first ? rows only for no key update of ce1_0 skip locked`",
       ("H2", "PESSIMISTIC_FORCE_INCREMENT"): "`… where ce1_0.id=? for update` · `update customer set version=? where id=? and version=?`",
       ("PostgreSQL", "PESSIMISTIC_FORCE_INCREMENT"): "`… where ce1_0.id=? for no key update of ce1_0` · `update customer set version=? where id=? and version=?`",
       ("H2", "PESSIMISTIC_WRITE without a transaction"): "no statement sent", ("PostgreSQL", "PESSIMISTIC_WRITE without a transaction"): "no statement sent"}
EXP[("H2", "EntityManager.find with PESSIMISTIC_WRITE")] = EXP[("H2", "PESSIMISTIC_WRITE")]; EXP[("PostgreSQL", "EntityManager.find with PESSIMISTIC_WRITE")] = EXP[("PostgreSQL", "PESSIMISTIC_WRITE")]
for k, v in EXP.items():
    if out.get(k) != v: bad.append("%s %s: %s - the brief's [S4 §8] says %s" % (k[0], k[1], out.get(k), v))
for db in ("H2", "PostgreSQL"):
    for s in STEPS:
        r = res.get((db, s), [])
        want = {"PESSIMISTIC_WRITE, lock.timeout -2": "result: [Ravi, Sunil]", "PESSIMISTIC_FORCE_INCREMENT": "result: Ravi · the loaded object's version 1",
                "PESSIMISTIC_WRITE without a transaction": "threw: org.springframework.dao.InvalidDataAccessApiUsageException: No active transaction"}.get(s, "result: Ravi")
        if want not in r: bad.append("%s %s: expected %s, got %s" % (db, s, want, r[:1]))
        aft = "after: the second connection reads " + ("Ravi 2 (version 1), Meera 1 (version 0)" if s == "PESSIMISTIC_FORCE_INCREMENT" else "Ravi 2 (version 0), Meera 1 (version 0)")
        if aft not in r: bad.append("%s %s: expected %s" % (db, s, aft))
    if "  <- jakarta.persistence.TransactionRequiredException: No active transaction" not in res.get((db, STEPS[-1]), []): bad.append("%s: the no-transaction cause" % db)
for x in bad: print("  mismatch: " + x)
if not bad:
    for s in STEPS: print("| %s | %s | %s |" % (s, out[("H2", s)], out[("PostgreSQL", s)]))
print("steps %d · mismatches %d" % (len(STEPS), len(bad)))
sys.exit(1 if bad else 0)
PY
LTBL=""; SELV=""
chk_locks() { local o
  vb .r-locks.out locks u28lk
  o=$(python3 -I -B .harness/locks.py .r-locks.out) || die "locks: $(printf '%s\n' "$o" | $G -E 'mismatch|^steps' | head -4 | paste -sd';' -)"
  [ "$(printf '%s\n' "$o" | tail -1)" = 'steps 8 · mismatches 0' ] || die "locks: 8 steps"
  LTBL=$(printf '%s\n' '| the lock mode, the hint (a harness method, alone) | H2 2.5.250 | PostgreSQL 18.6 |' '|---|---|---|' "$(printf '%s\n' "$o" | $G '^| ')")
  # RE-MEASURE 5: the anchor's CustomerEntity is 27's - every SELECT list carries ce1_0.version; one whole line shown
  SELV=$(printf '%s\n' "$VH" | sed -n '/^  PROBE >>> locks · PESSIMISTIC_WRITE$/,/^  PROBE <<< locks · PESSIMISTIC_WRITE$/p' | sed -n 's/^  DEBUG \[main\] org.hibernate.SQL : //p')
  [ "$SELV" = 'select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 where ce1_0.id=? for update' ] || die "locks: the SELECT line with ce1_0.version (RE-MEASURE 5): ${SELV:-none}"
  [ "$($G -c 'org.hibernate.SQL : select ce1_0.id' .r-locks.out || true)" = "$($G 'org.hibernate.SQL : select ce1_0.id' .r-locks.out | $G -c 'ce1_0.price_per_meal,ce1_0.version from customer' || true)" ] || die "locks: a SELECT without ce1_0.version"
  for d in H2 PostgreSQL; do [ $d = H2 ] && b=$VH || b=$VP
    has "$b" '  DEBUG [main] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.Lock28.force]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT' "locks $d: the force step through the proxy"; done
  echo "  locks: 8 steps on each database, the SQL read off Hibernate's logger = the brief's [S4 §8], mismatches 0; every SELECT list carries ce1_0.version (RE-MEASURE 5); FORCE_INCREMENT: the version UPDATE, Ravi version 1 after; no transaction: InvalidDataAccessApiUsageException <- TransactionRequiredException: No active transaction"; }
WNOH=""; WNOP=""; WTOH=""; WTOP=""; WWIH=""; WWIP=""
chk_wait() { local d b o how
  vb .r-wait.out wait u28wt
  for d in H2 PostgreSQL; do [ $d = H2 ] && b=$VH || b=$VP
    printf '%s\n' "$b" > .harness/w.blk
    for how in nowait timeout; do
      o=$(chainof .harness/w.blk "  PROBE >>> wait · $how" "  PROBE <<< wait · $how" "T2 threw")
      [ "$(cv "$o" CHAINS)" = 1 ] || die "wait $d $how: one T2 chain"
      if [ $d = H2 ]; then
        [ "$(cv "$o" CLASSES)" = 'org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockTimeoutException <- org.h2.jdbc.JdbcSQLTimeoutException <- org.h2.mvstore.MVStoreException' ] || die "wait H2 $how: the classes (S4.8): $(cv "$o" CLASSES)"
        cv "$o" JDBC | $G -q '^org.h2.jdbc.JdbcSQLTimeoutException: Timeout trying to lock table "CUSTOMER"; SQL statement: ⏎ select ' || die "wait H2 $how: the JDBC message"
        [ "$(cv "$o" STATE)" = HYT00 ] || die "wait H2 $how: SQLState HYT00"
        cv "$o" LAST | $G -qE "is locked by tx <n> and can not be updated by tx <n> within allocated time interval <masked>" || die "wait H2 $how: the last cause"
      else
        [ "$(cv "$o" CLASSES)" = 'org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockTimeoutException <- org.postgresql.util.PSQLException' ] || die "wait PostgreSQL $how: the classes (S4.8): $(cv "$o" CLASSES)"
        [ "$(cv "$o" STATE)" = 55P03 ] || die "wait PostgreSQL $how: SQLState 55P03"; fi
      [ $how = nowait ] && { [ $d = H2 ] && WNOH=$(cv "$o" CLASSES) || WNOP="$(cv "$o" CLASSES) · $(cv "$o" JDBC)"; }
      [ $how = timeout ] && { [ $d = H2 ] && WTOH=$(cv "$o" CLASSES) || WTOP="$(cv "$o" JDBC)"; }
      has "$b" "  PROBE wait · $how · T1 committed · T2 threw $( [ $d = H2 ] && echo 'org.h2.jdbc.JdbcSQLTimeoutException (SQLState HYT00)' || echo 'org.postgresql.util.PSQLException (SQLState 55P03)') · after: the second connection reads $SEEDV" "wait $d $how: the outcome"; done
    o=$(chainof .harness/w.blk "  PROBE >>> wait · nowait" "  PROBE <<< wait · nowait" "T2 threw")
    [ $d = PostgreSQL ] && { [ "$(cv "$o" JDBC)" = 'org.postgresql.util.PSQLException: ERROR: could not obtain lock on row in relation "customer"' ] || die "wait PostgreSQL nowait: the message: $(cv "$o" JDBC)"; }
    o=$(chainof .harness/w.blk "  PROBE >>> wait · timeout" "  PROBE <<< wait · timeout" "T2 threw")
    [ $d = PostgreSQL ] && { [ "$(cv "$o" JDBC)" = 'org.postgresql.util.PSQLException: ERROR: canceling statement due to lock timeout ⏎   Where: while locking tuple (0,1) in relation "customer"' ] || die "wait PostgreSQL timeout: the message: $(cv "$o" JDBC)"; }
    has "$b" "  PROBE wait · skip · T1 committed · T2 got [Sunil] · after: the second connection reads $SEEDV" "wait $d skip: T2 gets the unlocked row"
    # S4.18: the plain ask - T2's blocked state witnessed before T1's release, the order derived from the one log
    if [ $d = H2 ]; then WWIH=$(printf '%s\n' "$b" | sed -n 's/^      PROBE \(witness, before T1 is released .*\)$/\1/p'); [ "$WWIH" = "witness, before T1 is released (the second connection, information_schema.sessions, T2's session): BLOCKER_ID = T1's session" ] || die "wait H2 plain: T2's blocked state, witnessed (S4.18): ${WWIH:-none}"
    else WWIP=$(printf '%s\n' "$b" | sed -n 's/^      PROBE \(witness, before T1 is released .*\)$/\1/p'); [ "$WWIP" = "witness, before T1 is released (the second connection, pg_stat_activity, T2's backend pid): wait_event_type Lock · wait_event transactionid · pg_blocking_pids: T1's backend" ] || die "wait PostgreSQL plain: T2's blocked state, witnessed (S4.18): ${WWIP:-none}"; fi
    has "$b" "  PROBE wait · plain · the order, read off the one log: T2's blocked state witnessed before T1's commit began yes · T1's Initiating transaction commit before T2's SELECT returned yes" "wait $d plain: the order (S4.18)"
    has "$b" "  PROBE wait · plain · T1 committed · T2 got Ravi · after: the second connection reads $SEEDV" "wait $d plain: T2 gets Ravi after T1's commit"
    for how in nowait timeout skip plain; do
      x=$(printf '%s\n' "$b" | sed -n "/^  PROBE >>> wait · $how\$/,/^  PROBE <<< wait · $how\$/p")
      has "$x" "      DEBUG [T1] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.Lock28.hold]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT" "wait $d $how: T1's manager line, on T1's thread"
      has "$x" "      DEBUG [T2] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.Lock28.ask]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT" "wait $d $how: T2's manager line, on T2's thread"
      [ $how = plain ] || [ $how = skip ] || has "$x" "      DEBUG [T2] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction rollback" "wait $d $how: T2 rolled back"; done; done
  echo "  wait: on H2 and on PostgreSQL - lock.timeout 0: H2 HYT00 ($WNOH) · PostgreSQL 55P03 ($WNOP); lock.timeout 1000: H2 HYT00 · PostgreSQL 55P03 ($WTOP); -2: T2 gets [Sunil]; plain: $WWIH / $WWIP, then T1's commit, then T2's SELECT returns Ravi"; }
TTH=""; TTL=""
chk_txtimeout() { local d b o
  vb .r-txtimeout.out txtimeout u28tt
  for d in H2 PostgreSQL; do [ $d = H2 ] && b=$VH || b=$VP
    has "$b" '  DEBUG [main] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.Lock28.deadline]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,timeout_1' "txtimeout $d: the manager's line names the configured timeout"
    has "$b" "  PROBE after an idle wait of 1500 (configured; a latch nobody counts down), the next statement:" "txtimeout $d: the idle wait, as configured"
    printf '%s\n' "$b" > .harness/t.blk
    o=$(chainof .harness/t.blk "  PROBE >>> txtimeout · the deadline" "  PROBE <<< txtimeout · the deadline" threw)
    [ "$(cv "$o" CLASSES)" = org.springframework.transaction.TransactionTimedOutException ] && [ "$(cv "$o" TOP)" = 'org.springframework.transaction.TransactionTimedOutException: Transaction timed out: deadline was <date>' ] && [ "$(cv "$o" STATE)" = none ] || die "txtimeout $d: TransactionTimedOutException: Transaction timed out: deadline was <date>, no cause: $(cv "$o" TOP)"
    has "$b" "  PROBE after: the second connection reads $SEEDV" "txtimeout $d: the row after"; done
  TTH='org.springframework.transaction.TransactionTimedOutException: Transaction timed out: deadline was <date>'
  o=$(chainof .harness/t.blk "  PROBE >>> txtimeout · one long statement" "  PROBE <<< txtimeout · one long statement" threw)
  [ "$(cv "$o" CLASSES)" = 'jakarta.persistence.PersistenceException <- org.hibernate.QueryTimeoutException <- org.postgresql.util.PSQLException' ] && [ "$(cv "$o" JDBC)" = 'org.postgresql.util.PSQLException: ERROR: canceling statement due to user request' ] && [ "$(cv "$o" STATE)" = 57014 ] || die "txtimeout PostgreSQL: the long statement's chain (S4.8): $(cv "$o" CLASSES) · $(cv "$o" JDBC) · $(cv "$o" STATE)"
  has "$VP" '  DEBUG [main] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.Lock28.longStatement]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,timeout_1' "txtimeout PostgreSQL: the long statement's transaction"
  nhas "$VH" 'one long statement' "txtimeout H2: the long statement is PostgreSQL's beat"
  TTL="$(cv "$o" CLASSES) · ERROR: canceling statement due to user request (57014)"
  echo "  txtimeout: both - $TTH, before the next statement; PostgreSQL's long statement: $TTL - Spring translates neither"; }
# vict.py FILE FROM TO: the victims of every round inside a block, counted by the threw lines per thread (len, never typed), beside
# what the harness printed; prints "VICTIMS T1 T1 T1" and the per-round lines
cat > .harness/vict.py <<'PY'
import re, sys
f, a, b = sys.argv[1:4]
L = [l.rstrip("\n") for l in open(f, encoding="utf-8")]
i0 = L.index(a); blk = []
for l in L[i0 + 1:]:
    if b and l.startswith(b): break
    blk.append(l)
out = []; bad = []
rounds = sorted({int(m.group(1)) for l in blk for m in [re.match(r"^  PROBE >>> deadlock · round (\d+)$", l)] if m})
for r in rounds:
    x = blk[blk.index("  PROBE >>> deadlock · round %d" % r):blk.index("  PROBE <<< deadlock · round %d" % r) + 1]
    t1 = len([l for l in x if l.startswith("      PROBE T1 threw: ")]); t2 = len([l for l in x if l.startswith("      PROBE T2 threw: ")])
    v = "T1" if (t1, t2) == (1, 0) else "T2" if (t1, t2) == (0, 1) else "threw %d/%d" % (t1, t2)
    said = [l for l in x if l.startswith("  PROBE round %d · the victim: " % r)]
    if not said or not said[0].startswith("  PROBE round %d · the victim: %s · " % (r, v)): bad.append("round %d: the threw lines say %s, the harness printed %s" % (r, v, said[:1]))
    out.append(v)
for x in bad: print("  mismatch: " + x)
print("VICTIMS " + " ".join(out))
PY
victims() { python3 -I -B .harness/vict.py "$@" | sed -n 's/^VICTIMS //p'; }
# pre_wait: run right after each of the three runs, before their md5s are compared (S4.18): T2's plain ask seen blocked by the
# second connection before T1's release, and the order derived from the one log - on both databases; a plain ask that never
# waits (the plant: no @Lock on it) fails here, not as a drift
pre_wait() { local a b c
  a=$($G -cxF "      PROBE witness, before T1 is released (the second connection, information_schema.sessions, T2's session): BLOCKER_ID = T1's session" "$1" || true)
  b=$($G -cxF "      PROBE witness, before T1 is released (the second connection, pg_stat_activity, T2's backend pid): wait_event_type Lock · wait_event transactionid · pg_blocking_pids: T1's backend" "$1" || true)
  c=$($G -cxF "  PROBE wait · plain · the order, read off the one log: T2's blocked state witnessed before T1's commit began yes · T1's Initiating transaction commit before T2's SELECT returned yes" "$1" || true)
  [ "$a $b $c" = '1 1 2' ] || die "wait run $2: T2's plain ask must be seen blocked by the second connection before T1's release, on both databases (S4.18): $($G -e 'PROBE witness' -e 'wait · plain · the order' "$1" | sed 's/^ *PROBE //' | paste -sd';' -)"; }
# pre_deadlock: run right after each of the three runs, before their md5s are compared - the victims of every round (S4.6, RED
# #1208): PostgreSQL T1, H2 T2 at the gap; a plant's gap of 0 fails here, with its per-round victims printed
pre_deadlock() { local h p
  h=$(victims "$1" "H2 - gap $DLGAP, $DLR rounds - one harness JVM, this JVM's own H2 database:" "PostgreSQL - gap $DLGAP")
  p=$(victims "$1" "PostgreSQL - gap $DLGAP, $DLR rounds - a fresh database, then one harness JVM:" "H2 - LABELLED")
  [ "$h" = "$(printf 'T2 %.0s' $(seq 1 $DLR) | sed 's/ $//')" ] && [ "$p" = "$(printf 'T1 %.0s' $(seq 1 $DLR) | sed 's/ $//')" ] || die "deadlock run $2: the victims per round at the configured gap $DLGAP (deadlock_timeout 1s, $DLR rounds) - H2: ${h:-none} · PostgreSQL: ${p:-none} - expected T2 in every H2 round and T1 in every PostgreSQL round (S4.6, ⚑9, RED #1208)"; }
# the H2 deadlock chain's check (S4.8, RED #1205): class, message, first cause, 40001 - and the MVStoreException cause line that
# names a deadlock victim, PRESENT; 25's lost-update chain (no victim line) fails it
h2dl() { local o
  o=$(chainof "$1" "$2" "$3" "${5:-T2 threw}")
  cv "$o" JDBC | $G -q '^org.h2.jdbc.JdbcSQLTransactionRollbackException: Deadlock detected. The current transaction was rolled back. Details: "CUSTOMER"; SQL statement: ⏎ ' || die "deadlock H2 ($4): the message"
  [ "$(cv "$o" STATE)" = 40001 ] || die "deadlock H2 ($4): SQLState 40001"
  cv "$o" LAST | $G -q '^org.h2.mvstore.MVStoreException: Transaction <n> has been chosen as a deadlock victim\. Details: ' || die "deadlock H2 ($4): the MVStoreException cause line naming a deadlock victim is ABSENT (S4.8, RED #1205): $(cv "$o" LAST | cut -c1-120)"
  [ "$(cv "$o" CLASSES)" = 'org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockAcquisitionException <- org.h2.jdbc.JdbcSQLTransactionRollbackException <- org.h2.mvstore.MVStoreException' ] || die "deadlock H2 ($4): the classes (S4.8): $(cv "$o" CLASSES)"
  H2DLC=$(cv "$o" LAST | sed 's/\. Details: .*$/./'); }
H2DLC=""; DLPC=""; DLPD=""; DLPT=""; DLSRV=""; DLSRVW=""; DLTO=""; DLVH=""; DLVP=""; DLVHW=""; DLVPW=""
chk_deadlock() { local b o r v d x
  DH1="H2 - gap $DLGAP, $DLR rounds - one harness JVM, this JVM's own H2 database:"
  DP1="PostgreSQL - gap $DLGAP, $DLR rounds - a fresh database, then one harness JVM:"
  DH2="H2 - LABELLED gap $DLGAP2, $DLR rounds - one harness JVM, this JVM's own H2 database:"
  DP2="PostgreSQL - LABELLED gap $DLGAP2, $DLR rounds, log_lock_waits = on for this run's database alone - a fresh database, its setting, then one harness JVM:"
  b=$(blk .r-deadlock.out "$DH1" "$DP1"); ver "$b" "deadlock H2 gap $DLGAP" "$DBH"
  b=$(blk .r-deadlock.out "$DP1" "$DH2"); ver "$b" "deadlock PostgreSQL gap $DLGAP" "$(dbp u28dl)"; has "$b" '  raw password copies in its log: 0 (before the mask; the URL is printed cut before its ?)' "deadlock: the password"
  b=$(blk .r-deadlock.out "$DH2" "$DP2"); ver "$b" "deadlock H2 gap $DLGAP2" "$DBH"
  b=$(blk .r-deadlock.out "$DP2" ""); ver "$b" "deadlock PostgreSQL gap $DLGAP2" "$(dbp u28dlw)"; has "$b" '  raw password copies in its log: 0 (before the mask; the URL is printed cut before its ?)' "deadlock: the password"
  DLVH=$(victims .r-deadlock.out "H2 - gap $DLGAP, $DLR rounds - one harness JVM, this JVM's own H2 database:" "PostgreSQL - gap $DLGAP")
  DLVP=$(victims .r-deadlock.out "PostgreSQL - gap $DLGAP, $DLR rounds - a fresh database, then one harness JVM:" "H2 - LABELLED")
  DLVHW=$(victims .r-deadlock.out "H2 - LABELLED gap $DLGAP2, $DLR rounds - one harness JVM, this JVM's own H2 database:" "PostgreSQL - LABELLED")
  DLVPW=$(victims .r-deadlock.out "PostgreSQL - LABELLED gap $DLGAP2, $DLR rounds, log_lock_waits = on for this run's database alone - a fresh database, its setting, then one harness JVM:" "")
  [ "$DLVH" = 'T2 T2 T2' ] && [ "$DLVP" = 'T1 T1 T1' ] && [ "$DLVHW" = 'T2 T2 T2' ] && [ "$DLVPW" = 'T2 T2 T2' ] || die "deadlock: the victims (len of the threw lines per thread): H2 gap $DLGAP $DLVH · PostgreSQL gap $DLGAP $DLVP · H2 gap $DLGAP2 $DLVHW · PostgreSQL gap $DLGAP2 $DLVPW"
  b=$(blk .r-deadlock.out "PostgreSQL - gap $DLGAP, " "H2 - LABELLED")
  has "$b" '  PROBE configured, read by show: deadlock_timeout 1s · log_lock_waits off · lock_timeout 0' "deadlock PostgreSQL: the configured values, read by show"
  for r in 1 2 3; do has "$b" "  PROBE round $r · the victim: T1 · deadlock_timeout 1s · the configured gap $DLGAP" "deadlock PostgreSQL round $r: the victim beside deadlock_timeout and the gap (⚑9)"
    has "$b" "  PROBE round $r · T1 rolled back · T2 committed · the asks, read off the one log: T1 asked for its second row before T2 yes" "deadlock PostgreSQL round $r: the survivor commits"
    has "$b" "  PROBE round $r · after: the second connection reads $SEEDV" "deadlock PostgreSQL round $r: the seed unchanged"
    has "$b" "  server round $r: ERROR:  deadlock detected came from 1 backend(s): T1 - the backend of T1 (its pid, printed by pg_backend_pid() inside its transaction)" "deadlock PostgreSQL round $r: the server's victim, matched to T1's pid (S4.11)"
    has "$b" "  server round $r [T1] ERROR:  deadlock detected" "deadlock PostgreSQL round $r: the server's ERROR line"
    has "$b" "  server round $r [T1] DETAIL:  Process <pid of T1> waits for ShareLock on transaction <xid>; blocked by process <pid of T2>." "deadlock PostgreSQL round $r: the server's DETAIL line"
    has "$b" "  server round $r [T1]         Process <pid of T2> waits for ShareLock on transaction <xid>; blocked by process <pid of T1>." "deadlock PostgreSQL round $r: the cycle's second line"
    has "$b" "  server round $r [T1] CONTEXT:  while locking tuple (0,2) in relation \"customer\"" "deadlock PostgreSQL round $r: the server's CONTEXT line"; done
  printf '%s\n' "$b" > .harness/d.blk
  o=$(chainof .harness/d.blk "  PROBE >>> deadlock · round 1" "  PROBE <<< deadlock · round 1" "T1 threw")
  [ "$(cv "$o" CLASSES)" = 'org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockAcquisitionException <- org.postgresql.util.PSQLException' ] && [ "$(cv "$o" STATE)" = 40P01 ] || die "deadlock PostgreSQL: the chain and 40P01 (S4.8): $(cv "$o" CLASSES) $(cv "$o" STATE)"
  [ "$(cv "$o" JDBC)" = 'org.postgresql.util.PSQLException: ERROR: deadlock detected ⏎   Detail: Process <pid of T1> waits for ShareLock on transaction <xid>; blocked by process <pid of T2>. ⏎ Process <pid of T2> waits for ShareLock on transaction <xid>; blocked by process <pid of T1>. ⏎   Hint: See server log for query details. ⏎   Where: while locking tuple (0,2) in relation "customer"' ] || die "deadlock PostgreSQL: the JDBC message: $(cv "$o" JDBC)"
  DLPC="$(cv "$o" CLASSES) (40P01)"
  DLSRV=$(printf '%s\n' "$b" | sed -n -E 's/^  server round 1 \[T1\] (ERROR|DETAIL|CONTEXT):  /\1:  /p' | sed -n '1,3p')
  b=$(blk .r-deadlock.out "H2 - gap $DLGAP, " "PostgreSQL - gap")
  has "$b" "  PROBE configured, read by lock_timeout(): H2's lock timeout 2000" "deadlock H2: H2's lock timeout, as configured"
  printf '%s\n' "$b" > .harness/d.blk
  for r in 1 2 3; do h2dl .harness/d.blk "  PROBE >>> deadlock · round $r" "  PROBE <<< deadlock · round $r" "gap $DLGAP round $r"
    has "$b" "  PROBE round $r · T1 committed · T2 rolled back · the asks, read off the one log: T1 asked for its second row before T2 yes" "deadlock H2 round $r: the survivor commits"
    has "$b" "  PROBE round $r · after: the second connection reads $SEEDV" "deadlock H2 round $r: the seed unchanged"; done
  b=$(blk .r-deadlock.out "H2 - LABELLED" "PostgreSQL - LABELLED")
  has "$b" "  PROBE LABELLED RUN: gap $DLGAP2 (configured)" "deadlock H2 labelled: the label line"
  printf '%s\n' "$b" > .harness/d.blk; h2dl .harness/d.blk "  PROBE >>> deadlock · round 1" "  PROBE <<< deadlock · round 1" "gap $DLGAP2 round 1"
  b=$(blk .r-deadlock.out "PostgreSQL - LABELLED" "")
  has "$b" "  PROBE LABELLED RUN: gap $DLGAP2 (configured) and log_lock_waits = on (alter database u28dlw set, this database alone)" "deadlock PostgreSQL labelled: the label line"
  has "$b" '  PROBE configured, read by show: deadlock_timeout 1s · log_lock_waits on · lock_timeout 0' "deadlock PostgreSQL labelled: log_lock_waits on inside the JVM (S4.11)"
  has "$b" "  exit 0 · log_lock_waits = on for the database u28dlw alone" "deadlock PostgreSQL labelled: the per-database setting"
  for r in 1 2 3; do has "$b" "  PROBE round $r · the victim: T2 · deadlock_timeout 1s · the configured gap $DLGAP2" "deadlock PostgreSQL labelled round $r: the victim beside deadlock_timeout and the gap"
    has "$b" "  server round $r: ERROR:  deadlock detected came from 1 backend(s): T2 - the backend of T2 (its pid, printed by pg_backend_pid() inside its transaction)" "deadlock PostgreSQL labelled round $r: the server's victim T2"
    has "$b" "  server round $r [T1] LOG:  process <pid of T1> still waiting for ShareLock on transaction <xid> after <masked>" "deadlock PostgreSQL labelled round $r: T1 still waiting (log_lock_waits)"
    has "$b" "  server round $r [T2] LOG:  process <pid of T2> detected deadlock while waiting for ShareLock on transaction <xid> after <masked>" "deadlock PostgreSQL labelled round $r: T2 detected deadlock while waiting"
    has "$b" "  server round $r [T2] ERROR:  deadlock detected" "deadlock PostgreSQL labelled round $r: the ERROR from T2's backend"
    has "$b" "  PROBE round $r · after: the second connection reads $SEEDV" "deadlock PostgreSQL labelled round $r: the seed unchanged"; done
  DLSRVW=$(printf '%s\n' "$b" | sed -n -E 's/^  server round 1 \[(T[12])\] (LOG|ERROR):  /[\1] \2:  /p' | $G -E 'still waiting|detected deadlock while|deadlock detected$' | sed -n '1,3p')
  ! $G -qiE "$ASY" .r-deadlock.out || die "deadlock: a server-wide setting in the capture (S4.11)"
  [ "$($G -c 'alter database' .r-deadlock.out || true)" = 2 ] || die "deadlock: the one per-database setting, printed once (and its label)"
  echo "  deadlock: the victims, counted by the threw lines per thread - gap $DLGAP: H2 $DLVH, PostgreSQL $DLVP (deadlock_timeout 1s); labelled gap $DLGAP2: H2 $DLVHW, PostgreSQL $DLVPW; H2's cause line present every round ($H2DLC); PostgreSQL: $DLPC; the server's lines matched to the threads' pids"; }
ODH=""; ODP=""
chk_order() { local d b r
  vb .r-order.out order u28or
  for d in H2 PostgreSQL; do [ $d = H2 ] && b=$VH || b=$VP
    for r in 1 2 3; do
      has "$b" "  PROBE round $r · T1 committed · T2 committed · the order, read off the one log: T2 seen blocked before T1's commit began yes · T2's first lock returned after T1's Initiating transaction commit yes" "order $d round $r: both commit, in the order read off the log"
      has "$b" "  PROBE round $r · after: the second connection reads $SEEDV" "order $d round $r: the rows after"; done
    [ "$($G -c 'PROBE T[12] threw' <<< "$b" || true)" = 0 ] || die "order $d: a thread threw"
    [ "$(printf '%s\n' "$b" | $G -c "^      PROBE witness, before T1 is released" || true)" = 3 ] || die "order $d: T2's blocked state witnessed in every round"; done
  ODH=$(printf '%s\n' "$VH" | sed -n 's/^  PROBE round 1 · //p' | head -1); ODP=$(printf '%s\n' "$VP" | sed -n 's/^  PROBE round 1 · //p' | head -1)
  echo "  order: on H2 and on PostgreSQL, 3 rounds each: $ODH"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  [main] org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X27 · the version lesson's filed script (its xcheck.sql): $X27 · cmp: the same, byte for byte")" = 1 ] || die "xcheck: the harness's script must be the version lesson's, md5 $X27, byte for byte (R.252) - a mapping moved"
  has "$XC" "    create table customer (meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, version bigint not null, name varchar(60) not null unique, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id));" "xcheck: the customer table with its version column"
  echo "  xcheck: the harness's script (@EntityScan(\"com.tiffinbox\") alone), md5 $X27 = the version lesson's filed script, byte for byte - no mapping moved since"; }
EXQ="Your turn: the README's two transactions lock Ravi and Meera in opposite orders, and one is killed. Lock them in one order."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXB=""; EXS=""
chk_exercise() { local EB EZ b ER ES w l
  EB=$(blk .r-exercise.out "in bash" "in zsh"); EZ=$(blk .r-exercise.out "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    PROBE T1: locked Ravi, then Meera, committed' '    PROBE after both, its own JDBC connection reads: Ravi 2, Meera 1'; do has "$ER" "$l" "exercise: the README runs"; has "$ES" "$l" "exercise: the solution runs"; done
    EXB=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE T2: //p'); EXS=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE T2: //p')
    [ "$EXB" = 'threw org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockAcquisitionException <- org.h2.jdbc.JdbcSQLTransactionRollbackException <- org.h2.mvstore.MVStoreException · the last cause says: Transaction <n> has been chosen as a deadlock victim' ] || die "exercise: the README's run - T2 refused as the deadlock's victim: ${EXB:-none}"
    [ "$EXS" = 'locked Ravi, then Meera, committed' ] || die "exercise: the solution's run - T2 locks in the same order and commits: ${EXS:-none}"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qF 'out[1] = kitchen.lockBoth("Meera", "Ravi", t2First, null);' harness/src/probe/t/ex/ExApp.java || die "exercise: ExApp ships T2 locking Meera first"
  echo "  exercise: bash and zsh alike - the README as written: T2 $EXB; the solution (one line: T2 locks Ravi, then Meera): T2 $EXS; Ravi 2, Meera 1 after both; each file's What it prints = the run; $EXW words"; }
cap locks locks; chk_locks; pub locks
cap wait waitcap; chk_wait; pub wait
cap txtimeout txtimeout; chk_txtimeout; pub txtimeout
cap deadlock deadlock; chk_deadlock; pub deadlock
cap order order; chk_order; pub order
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise

# the table, the server's lines and the values the video says are the captures', never typed: README.md holds them, composed here
cblk() { awk -v n="$1" '$0 == "<!-- captured: " n " begin -->" { f = 1; next } $0 == "<!-- captured: " n " end -->" { f = 0 } f' README.md; }
[ "$(cblk locks)" = "$LTBL" ] || die "README.md's lock-SQL table is not the capture's (built by locks.py): $(diff <(cblk locks) <(printf '%s\n' "$LTBL") | head -3 | paste -sd' ' -)"
SRVB=$(printf '%s\n' '```' "PostgreSQL, gap $DLGAP, round 1 - the victim T1's backend:" "$DLSRV" "PostgreSQL, LABELLED gap $DLGAP2 and log_lock_waits = on, round 1:" "$DLSRVW" '```')
[ "$(cblk server)" = "$SRVB" ] || die "README.md's server lines are not the capture's: $(diff <(cblk server) <(printf '%s\n' "$SRVB") | head -3 | paste -sd' ' -)"
echo "  README.md's lock-SQL table (8 rows, built by locks.py) and its server lines = the captures'"
VS="the values the video may say: H2 2.5.250 and PostgreSQL 18.6 (driver 42.7.14), Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - locks: the SELECT carries ce1_0.version ($SELV); PESSIMISTIC_WRITE H2 for update, PostgreSQL for no key update of ce1_0; PESSIMISTIC_READ H2 for update, PostgreSQL for share of ce1_0; lock.timeout 0 nowait; 1000 H2 wait 1, PostgreSQL set local lock_timeout = 1000 around the SELECT, then set local lock_timeout = 0; -2 skip locked; PESSIMISTIC_FORCE_INCREMENT update customer set version=? where id=? and version=?, Ravi version 0 -> 1; no transaction org.springframework.dao.InvalidDataAccessApiUsageException <- jakarta.persistence.TransactionRequiredException: No active transaction · wait (T1 holds Ravi): lock.timeout 0 H2 $WNOH (HYT00), PostgreSQL $WNOP (55P03); lock.timeout 1000 H2 HYT00, PostgreSQL ERROR: canceling statement due to lock timeout (55P03); -2 T2 gets [Sunil]; plain: H2 $WWIH; PostgreSQL $WWIP; then T1's commit, then T2's SELECT returns Ravi · txtimeout (timeout = 1, configured): $TTH on both; PostgreSQL's long statement $TTL · deadlock (deadlock_timeout 1s): gap $DLGAP PostgreSQL victim $DLVP, H2 victim $DLVH; labelled gap $DLGAP2 PostgreSQL victim $DLVPW, H2 victim $DLVHW; PostgreSQL $DLPC; H2 org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockAcquisitionException <- org.h2.jdbc.JdbcSQLTransactionRollbackException (Deadlock detected. The current transaction was rolled back., 40001) <- $H2DLC; the survivor commits, the second connection reads Ravi 2, Meera 1 · order: both lock Ravi first - $ODH · xcheck: $X27, the same hash as in the lesson called Optimistic Locking with At-Version · exercise: T2 threw (the deadlock's victim) -> locked Ravi, then Meera, committed ($EXW words)"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"

# hygiene: every capture and every file this unit holds - 0 raw password copies
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the password ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log .harness/srv.raw; do [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the password, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGJVM" -gt 0 ] || die "no JVM ran"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]|"timestamp":"?[0-9]|(exec|handler|task|pool-[0-9]+-thread|worker)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl|Debian' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'SessionImpl\([0-9]|scanning in [0-9]+ ms|Lambda/0x' "$f" || die "$f holds an EntityManager's identity, a lambda's address or a scan figure, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b' "$f" || die "$f holds a millisecond figure (R.207, S4.7: <masked>)"
  ! $G -qE '[Pp]rocess [0-9]|\[[0-9]+\] (LOG|ERROR|DETAIL)|transaction [0-9]{2,}|Transaction [0-9]|tx [0-9]|PIDMAP|deadline was [A-Z]' "$f" || die "$f holds a PostgreSQL pid or transaction id, an H2 transaction number, a PIDMAP line or the deadline's date"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -q . || die "$f holds a URL"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.t' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqiE 'create table' harness/src || die "a DDL copy in the harness - the shipped Database creates the tables"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw password copies: 0 before the mask in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs ($PGJVM PostgreSQL JVMs), 0 in every capture, log, the server's log and every file; 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, pid, transaction id, unmasked identity, URL or stack frame in any capture; every JVM pinned and under its alarm; no kill by name, no bare wait; no sleep in the harness; no H2 file outside .harness"
# ---- the end: the container, the anchor, the ports -------------------------------------------------------------------------
pgrm
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
echo "  the container: removed (docker rm -f $CN); docker ps -a names no $CN"
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20070-20079 at the end - the container bound 20078 (loopback) and is gone; 20079 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit28: every capture 3/3 and = published; every spoken number asserted; 0 raw password copies; no port bound but 20078 (the container)"
