#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Propagation, All Seven - this unit's receipts. No change to the anchor (brief flag 1): anchor/ is the link to
# ../c7-unit17/after. When a transactional method calls another, propagation decides whether they share one transaction, get two,
# or refuse. Six captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every number and
# string the video says is asserted right after its capture by a check that can fail. One database: H2, in each JVM's memory.
# TiffinBox runs only in `import`.
#   grid      21 cells, one harness JVM: the seven inner methods (Inner24, one per propagation) x outer-fails · inner-fails · alone;
#             Outer24.run saves Asha, calls the inner method by name THROUGH THE INNER BEAN'S PROXY, then fails (outer-fails) or
#             catches the inner's failure (inner-fails); alone calls the inner method with no transaction around it; the seed again
#             before every cell; every cell line prints the attribute read off the method (S4.15) and is checked against the brief's
#             table, its manager lines checked per cell (S4.1)
#   alone     the alone column whole, one harness JVM: each refusal's message (MANDATORY's), each method's own print
#   nested    NESTED three ways (brief flag 7): A Boot's JpaTransactionManager as built; B LABELLED -Dnested=true (the flag set on
#             that manager); C LABELLED htm - Spring 7's HibernateTransactionManager (harness-only), H2's JDBC trace on, the
#             savepoint lines quoted by regex
#   import    TiffinBox itself (the failure receipt): A the anchor as shipped, POST /customers/import (Asha, a duplicate Ravi, Dev) on
#             20030; B a LABELLED copy with @Transactional on CustomerImport.importCsv (the class un-finaled) on 20031; A' = A on 20032
#   xcheck    the harness's DDL script (@EntityScan("com.tiffinbox") alone) against the owning-side lesson's published md5 (R.212)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# The anchor is COPIED under .harness/anchor and built there, never in place (its README's package line, offline; its tests run);
# its jar extracted (the anchor's own line). import B is a second copy, .harness/importb, two lines changed (L_B1, L_B2 below) and
# built offline without its tests (L_BUILDB). The harness (harness/src, packages probe.t and probe.x, outside com.tiffinbox) is
# compiled against the anchor's extracted libraries with javac -parameters into .harness/hc. probe.t.Main is a Spring Boot context
# with no web server (WebApplicationType.NONE: it binds no port) over those, @EntityScan and @EnableJpaRepositories on com.tiffinbox
# - the anchor's entities and its own CustomerEntityRepository; probe.t.Seed builds the shipped Database in code on the run's own H2
# database, which seeds it; ddl-auto none. Logback (harness/logback.xml) prints Hibernate's SQL logger and the transaction manager's
# DEBUG lines (S4.1's first witness). The method's own TransactionSynchronizationManager print is the second; the third is the
# second connection: DriverManager on the same jdbc:h2:mem:u24 URL, read after the call returned or threw. probe.x.XMain is
# xcheck's context. Every JVM's flags travel as an array, V, its arguments as an array, A (R.193); every JVM runs under an alarm
# (perl -e 'alarm N; exec ...': macOS has no timeout); an alarm that fires is a failed receipt (R.247). Commands are printed exactly
# as they run: each goes through eval. harness/dur7.py (Course 7's builders' duration pattern, byte for byte) and S4.7's
# duration-meaning family (below, BLUE's s47.py regex) gate this unit's prose: it speaks no time (R.172, R.264). "$M2" is this unit's
# .m2-demo. The locale: every JVM has its locale pinned on its run line (-Duser.language=en -Duser.country=US).
# The network: every Maven run is offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an artifact
# offline is run once more without -o and says so, naming what it fetched. At run time nothing leaves the machine: H2 in memory;
# TiffinBox (import) listens on 127.0.0.1 only and is asked its readiness, one POST and one GET, on the loopback. This unit reads no
# version file: the section's dated sweep is the brief's (R.223; _research/spring-boot-metadata-2026-11-10.xml,
# spring-data-bom-metadata-2026-11-10.xml).
# TiffinBox's token: generated here (the anchor README's own line) into .harness/<tree>/secrets/tiffinbox/shutdown-token, mode 0600,
# never printed, masked in every log; the captures and logs are counted for raw copies (0). TiffinBox is stopped by its pid.
# Masks (README.md declares each; awk gsub only): the token; this folder "…", the folder above "…/..", home "~", your user name
# "<user>"; " using Java <version>"; an identity hash "@…"; an EntityManager's identity "SessionImpl(<n><open>)"; a lambda class's
# address "$$Lambda/<n>"; Spring Data's scan
# time; TiffinBox's generated database name "jdbc:h2:mem:<uuid>"; H2's trace time stamp; a 500's "timestamp".
# Ports (§P, 20030-20039): 20030 import A · 20031 import B · 20032 import A' · 20033-20038 unused (xcheck binds none) · 20039 never
# bound; all ten, 18425 (TiffinBox's default), 8080 and 35729 checked free at the start and the end.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process under it); then
# sweep(): anything of this run still alive in its process group is stopped. After an interrupt a capture's unfinished runs
# (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C; the script exits 130 after an
# interrupt. No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.t.") || index($0, "probe.x.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 perl rsync lsof mvn md5 cmp find curl openssl /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - the token lives under .harness/ only"
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
HFILES='dur7.py logback.xml src'
SFILES='probe/t/H.java probe/t/Htm.java probe/t/Inner24.java probe/t/Main.java probe/t/Nested.java probe/t/Outer24.java probe/t/Run.java probe/t/Seed.java probe/t/ex/ExApp.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20030 20031 20032 20033 20034 20035 20036 20037 20038 20039"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 + S4.7 (R.264, RED #1211): dur7.DUR, and BLUE's duration-meaning family beside it (dur7.py misses five of its lines and is
# not edited by BLUE: the family is this builder's, as the brief's CARRIED says)
cat > .harness/dur.py <<'PY'
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|a|\d+)\s+(?:second|minute|hour)s?|half a second|eventually)\b", re.I)
for t, want in (("forever", 1), ("at once", 1), ("immediately", 1), ("one second", 1), ("a moment", 1), ("3 seconds", 1),
                ("a timeout of one, as configured", 0), ("the second connection reads Ravi", 0), ("another bean", 0)):
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
DN=$(dishes README.md exercise harness/src)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose - the exercise's blocks hold the measured output: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty (exercise compares it with the run, line for line)"
# S4.14 (R.271): the refuted readings this unit could tempt, refused per sentence - "NESTED uses savepoints" UNSCOPED (a sentence that
# names the labelled htm run, HibernateTransactionManager or a label, or that negates, passes: Boot's manager refuses NESTED twice);
# and S4.3's unscoped "an interface means a JDK proxy" (BLUE's s43.py CLAIM and SCOPE). The self-test runs its cases first.
cat > .harness/s414.py <<'PY'
import re, sys
NEST = re.compile(r"\bNESTED\b[^.!?]*\b(?:uses?|used|creates?|created|sets?|takes?|took|is|are|means|gives?|runs? (?:on|with|as))\b[^.!?]*\bsavepoints?\b", re.I)
NSCOPE = re.compile(r"\bhtm\b|HibernateTransactionManager|\blabell?ed\b", re.I)
NEG = re.compile(r"\b(?:not|no|never|none|cannot|refus\w*|without)\b", re.I)
CLAIM = re.compile(r"\binterface\w*\b[^.!?]*\b(?:means?|meant|gets?|got|gives?|gave|is|are|was|becomes?|uses?|used)\b[^.!?]*\b(?:JDK|J-D-K)(?:'s)?\b[^.!?]*\bprox(?:y|ies)\b"
                   r"|\b(?:JDK|J-D-K)(?:'s)?\b[^.!?]*\bprox(?:y|ies)\b[^.!?]*\b(?:for|on|around)\b[^.!?]*\binterface", re.I)
SCOPE = re.compile(r"\bplain Spring\b|\bwithout (?:Spring )?Boot\b|\bCourse (?:4|four)\b|proxy[-. ]target[-. ]class|\bthe (?:labelled )?flag\b", re.I)
def bad(s):
    return (NEST.search(s) and not NSCOPE.search(s) and not NEG.search(s)) or (CLAIM.search(s) and not SCOPE.search(s))
cases = [("NESTED uses savepoints.", True), ("With NESTED, Spring sets a savepoint and rolls back to it.", True),
         ("NESTED is a savepoint inside the outer transaction.", True), ("An interface means a JDK proxy.", True),
         ("On the labelled htm run, NESTED uses savepoints: SAVEPOINT_1, then ROLLBACK TO SAVEPOINT.", False),
         ("NESTED needs savepoints, and this manager has none to offer.", False),
         ("On Boot's manager NESTED is refused before any savepoint is set.", False),
         ("Spring 7's HibernateTransactionManager runs NESTED with a savepoint.", False),
         ("In plain Spring an interface meant the JDK's proxy.", False), ("REQUIRES_NEW suspends the outer transaction.", False)]
m = sum(bool(bad(t)) != w for t, w in cases)
assert m == 0, "s414 self-test: %d mismatches" % m
n = 0
for p in sys.argv[1:]:
    t = open(p, encoding="utf-8").read().replace("\n", " ")
    for s in re.split(r"(?<=[.!?])\s+", t):
        if bad(s):
            n += 1; print("  %s: %s  <- S4.14: NESTED uses savepoints, unscoped (Boot's manager refuses it) / S4.3: interface means JDK proxy, unscoped" % (p, s.strip()[:160]))
print("S4.14/S4.3 refused sentences: %d (self-test: %d cases, 0 mismatches)" % (n, len(cases)))
PY
SW=$(python3 -I -B .harness/s414.py $PROSE) || die "S4.14's gate did not run (or its self-test failed)"
printf '%s\n' "$SW" | tail -1 | $G -q '^S4.14/S4.3 refused sentences: 0 ' || die "S4.14 / S4.3: $(printf '%s\n' "$SW" | $G '<-' | head -3 | paste -sd';' -)"
echo "  $(printf '%s\n' "$SW" | tail -1) over README.md, exercise/"
# R.225: a SQL string this unit shows is the logger's - a line of README.md holding the INSERT's head, Hibernate's alias or the
# count's SELECT is a typed SQL string, refused
SQLRE='insert into customer|ce1_0\.|select count\(\*\) from customer'
TS=$($G -nE "$SQLRE" README.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md (R.225): $TS"
echo "  typed SQL strings: 0 in README.md"
# the htm run is LABELLED in README.md (brief flag 7): its own line, whole
HTML='**The `htm` run is LABELLED:** Spring 7'"'"'s `org.springframework.orm.jpa.hibernate.HibernateTransactionManager`, swapped in by the harness'"'"'s profile `htm` only - not TiffinBox'"'"'s manager, not Boot'"'"'s, never adopted (brief flag 7, CARRIED).'
$G -qxF -- "$HTML" README.md || die "README.md must declare the htm label in its own line: $HTML"
echo "  the htm label: declared in README.md (its line, whole)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_IMPORT=$(readme 'curl -s -w '"' %{http_code}\\n'"' -F "file=@customers.csv;type=text/csv" http://127.0.0.1:18431/customers/import')
R_GET=$(readme 'curl -s -w '"' %{http_code}\\n'"' http://127.0.0.1:18431/customers')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
CIF=tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerImport.java
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/H.java $HS/Htm.java $HS/Inner24.java $HS/Main.java $HS/Nested.java $HS/Outer24.java $HS/Run.java $HS/Seed.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*\" probe.t.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_B1=$(mine "perl -pi -e 's/^final class CustomerImport \\{\$/class CustomerImport {/' .harness/importb/$CIF")
L_B2=$(mine "perl -pi -e 's/^(    \\@PostMapping\\(path = \"\\/customers\\/import\")/    \\@org.springframework.transaction.annotation.Transactional\\n\$1/' .harness/importb/$CIF")
L_BUILDB=$(mine 'cd .harness/importb && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
[ "$(exe "$(at .harness/anchor 20030 "$R_RUN")")" = "cd .harness/anchor && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20030" ] || die "at(): the run line is not the anchor README's"
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
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar org/springframework/spring-orm/7.0.10/spring-orm-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
# import B: a second copy, two lines changed (L_B1 un-finals the class, L_B2 adds the annotation), built without its tests
rsync -a --exclude target --exclude secrets .harness/anchor/ .harness/importb/
(eval "$L_B1") && (eval "$L_B2") || die "L_B1 or L_B2 did not run"
BD=$(diff .harness/anchor/$CIF .harness/importb/$CIF | $G -E '^[<>]' | paste -sd'|' - || true)
[ "$BD" = '< final class CustomerImport {|> class CustomerImport {|>     @org.springframework.transaction.annotation.Transactional' ] || die "import B: the copy must differ from the anchor by the class un-finaled and the annotation added above importCsv: ${BD:-no difference}"
[ -z "$(diff -rq -x target .harness/anchor .harness/importb | $G -v "CustomerImport.java" || true)" ] || die "import B: the copy differs elsewhere"
[ "$(awk '/@org.springframework.transaction.annotation.Transactional/ { getline a; getline b; print a "|" b }' .harness/importb/$CIF)" = '    @PostMapping(path = "/customers/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)|    Map<String, Object> importCsv(@RequestPart("file") MultipartFile file) throws IOException, SQLException {' ] || die "import B: the annotation is not on importCsv"
mbuild "$L_BUILDB" .harness/build-importb.log ".harness/importb (the copy, two lines changed; -DskipTests)"
(cd .harness/importb && eval "$R_EXTRACT") > .harness/extract-b.log 2>&1 < /dev/null || die "the extract of importb failed"
for t in anchor importb; do (cd .harness/$t && eval "$R_TOKEN") || die "the token for $t was not written"
  [ "$(stat -f '%Lp' .harness/$t/secrets/tiffinbox/shutdown-token)" = 600 ] || die "the token's file must be mode 0600"; done
TOKEN=$(head -n 1 .harness/anchor/secrets/tiffinbox/shutdown-token); TOKENB=$(head -n 1 .harness/importb/secrets/tiffinbox/shutdown-token)
[ ${#TOKEN} = 32 ] && [ ${#TOKENB} = 32 ] || die "a generated token is not 32 characters"
echo "  the two tokens: generated (openssl rand -hex 16), each in its tree's secrets/tiffinbox/shutdown-token, mode 0600, never printed"
jc "$L_JAVAC" .harness/javac.log
[ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/t/ex ] || die "the exercise's class was compiled into the harness - it is compiled on its own"
NL=$(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ')
echo "  extracted the anchor's jar ($NL libraries); the harness compiled into .harness/hc"
# the import's file: the brief's three rows - Asha, a duplicate Ravi (the seed has a Ravi), Dev - under the anchor README's file name
printf '%s\n' 'name,mealsPerDay,pricePerMeal,mealType' 'Asha,1,100,VEG' 'Ravi,2,120,VEG' 'Dev,2,110,VEGAN' > .harness/customers.csv
# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v t="$TOKEN" -v tb="$TOKENB" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); TB = lit(tb); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the token]"); gsub(TB, "[masked: the token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/jdbc:h2:mem:[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f-]+/, "jdbc:h2:mem:<uuid>")
    gsub(/SessionImpl\([0-9]+</, "SessionImpl(<n><")
    gsub(/\$\$Lambda\/0x[0-9a-f]+/, "$$Lambda/<n>")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"<time>\"")
    gsub(/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9][.0-9]*[+-][0-9][0-9]:[0-9][0-9] /, "<time> ")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' "token $TOKEN and $TOKENB" 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' '2026-11-11 15:47:44.230686+01:00 jdbc[3]: ' '{"timestamp":"2026-11-11T16:07:00.140Z","status":500}' 'JDBC [x.HibernateTransactionManager$$Lambda/0x000003ff01b8a310@5d9576a0]' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' 'token [masked: the token] and [masked: the token]' 'url=jdbc:h2:mem:<uuid> user=SA' '<time> jdbc[3]: ' '{"timestamp":"<time>","status":500}' 'JDBC [x.HibernateTransactionManager$$Lambda/<n>@…]')" ] || die "mask: the planted JDK version, folders, home, identity hash, EntityManager identity, scan time, the two tokens, a generated database name, H2's trace time stamp, a 500's timestamp and a lambda class's address must be masked"
rm -f .harness/p1
# the harness's arguments: this run's own H2 database (in this JVM's memory, kept while the context lives), the harness's Logback
# file, no schema written, no banner, the anchor's Thymeleaf jar not looking for templates
HA=('--spring.datasource.url=jdbc:h2:mem:u24;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
# nested C (LABELLED htm): H2's own JDBC trace on (the harness URL only), Boot's pool held to one connection, the profile htm
HT=('--spring.datasource.url=jdbc:h2:mem:u24;DB_CLOSE_DELAY=-1;TRACE_LEVEL_SYSTEM_OUT=3' --spring.datasource.hikari.maximum-pool-size=1 --spring.profiles.active=htm --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
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
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
# tview: the htm run's log - every line but H2's trace; of the trace's statement lines (those that start /*) between a cell's markers
# only those that match SPRE, printed "(H2 trace) ..."; the others counted per cell (R.205)
SPRE='setSavepoint\("SAVEPOINT_[0-9]+"\);$|^/\*SQL \*/SAVEPOINT \\"SAVEPOINT_[0-9]+\\";$|^/\*SQL \*/ROLLBACK TO SAVEPOINT \\"SAVEPOINT_[0-9]+\\";$|^/\*\*/conn[0-9]+\.rollback\(sp[0-9]+\);$|^/\*\*/conn[0-9]+\.releaseSavepoint\(savepoint\);$'
tview() { SRE="$SPRE" awk '
  BEGIN { re = ENVIRON["SRE"] }
  function tr(l) { return l ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:/ || l ~ /^\/\*/ }
  { sub(/[ \t]+$/, "") }
  /^PROBE >>> / { inm = 1; other = 0; print "  " $0; next }
  /^PROBE <<< / { inm = 0; print "  (H2 trace) the other statement lines in this cell: " other; print "  " $0; next }
  inm && /^\/\*/ { if ($0 ~ re) print "  (H2 trace) " $0; else other++; next }
  tr($0) { next }
  { print "  " $0 }' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    echo "$(raw "$TOKEN" .harness/cap.raw) $(raw "$TOKENB" .harness/cap.raw)" > ".harness/raw-$nm.$i"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# ---- TiffinBox (import): started from its tree, readiness polled, asked, stopped by its pid ------------------------------------
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing})"
  echo "  secrets/ before the start: $s (mode $(stat -f '%Lp' "$1/secrets/$s")) - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { [ "$(listeners "$2")" = 0 ] || die "something listens on $2 before the start"; sec "$(dir "$1")"; echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2>&1 < /dev/null & pid=$!; }
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
# ask(): the anchor README's two curl lines, the port replaced, --noproxy put in (the loopback), run from .harness where the
# brief's three-row file is, as customers.csv
ask() { local c1 c2
  c1=$(printf '%s\n' "$R_IMPORT" | sed "s#http://127.0.0.1:18431#http://127.0.0.1:$1#; s#^curl -s #curl -s --noproxy '*' #")
  c2=$(printf '%s\n' "$R_GET" | sed "s#http://127.0.0.1:18431#http://127.0.0.1:$1#; s#^curl -s #curl -s --noproxy '*' #")
  echo "  the file, .harness/customers.csv: $(paste -sd'|' .harness/customers.csv)"
  echo "\$ cd .harness && $c1"; echo "  -> $(cd .harness && eval "$c1" 2> /dev/null)"
  echo "\$ $c2"; echo "  -> $(eval "$c2" 2> /dev/null | sed -E 's/"pricePerMeal":[0-9]+,//g; s/"mealsPerDay":[0-9]+,//g')"; }
lvl() { $G -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
logtok() { local t; t=$(raw "$TOKEN" .harness/run.out); t=$((t + $(raw "$TOKENB" .harness/run.out))); LOGS=$((LOGS + 1)); genw .harness/run.out; [ "$t" = 0 ] || die "a TiffinBox log held the token ($t)"; echo "  its log: the token 0 times"; }
TPAT='org\.hibernate\.orm\.core|TiffinBoxServer|SpringApplication$'
lview() { awk -v pat="$TPAT" '
  function cut(x) { gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); sub(/[ \t]+$/, "", x); return length(x) > 260 ? substr(x, 1, 260) " … (" length(x) - 260 " more characters)" : x }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ {
    s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3)
    if (m ~ /^Starting /) next
    if (m ~ /^Started TiffinBoxServer in /) m = "Started TiffinBoxServer"
    if (lg ~ pat) print "    " $2 " " lg ": " cut(m)
    if (m ~ /^HHH000247: ErrorCode: /) print "    " $2 " " lg ": " m
    if (m ~ /threw exception \[Request processing failed: /) { sub(/^.*threw exception \[Request processing failed: /, "", m); sub(/\] with root cause$/, "", m); print "    the request failed: " m } }' "$1"
  echo "  its log's lines - WARN: $(lvl WARN "$1") · ERROR: $(lvl ERROR "$1") · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' "$1" || true)"; }

# ---- the captures --------------------------------------------------------------------------------------------------------
grid() { echo "grid - every cell, one harness JVM, Boot's transaction manager as built (the anchor's 91 libraries):"; V=(-Ds=grid); A=("${HA[@]}"); hrun; hview; }
alone() { echo "alone - the seven inner methods with no transaction around them, one harness JVM:"; V=(-Ds=alone); A=("${HA[@]}"); hrun; hview; }
nested() { echo "A - NESTED on Boot's JpaTransactionManager as built (one harness JVM):"
  V=(-Ds=nested); A=("${HA[@]}"); hrun; hview
  echo "B - LABELLED -Dnested=true: the same manager, nestedTransactionAllowed set to true (one harness JVM):"
  V=(-Ds=nested -Dnested=true); A=("${HA[@]}"); hrun; hview
  echo "C - LABELLED htm: Spring 7's HibernateTransactionManager, nested allowed (the harness's profile htm), H2's JDBC trace on (;TRACE_LEVEL_SYSTEM_OUT=3 on the harness URL only), Boot's pool one connection (one harness JVM):"
  V=(-Ds=nested); A=("${HT[@]}"); hrun; tview; }
import() { echo "A - the anchor as shipped (.harness/anchor), port 20030:"
  start "$(at .harness/anchor 20030 "$R_RUN")" 20030; up 20030; ready 20030; ask 20030; stopit 20030; logtok; lview .harness/run.out; rm -f .harness/run.out
  echo "B - LABELLED: .harness/importb, the copy with CustomerImport un-finaled and @Transactional on its importCsv, port 20031 - the failure receipt:"
  start "$(at .harness/importb 20031 "$R_RUN")" 20031; up 20031; ready 20031; ask 20031; stopit 20031; logtok; lview .harness/run.out; rm -f .harness/run.out
  echo "A' - the anchor as shipped again, port 20032:"
  start "$(at .harness/anchor 20032 "$R_RUN")" 20032; up 20032; ready 20032; ask 20032; stopit 20032; logtok; lview .harness/run.out; rm -f .harness/run.out; }
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # ../c7-unit09's published xcheck capture
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
XA=('--spring.datasource.url=jdbc:h2:mem:x24;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
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
DBL='  PROBE database: H2 2.5.250 | url jdbc:h2:mem:u24;DB_CLOSE_DELAY=-1'
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); the second connection reads: customer rows 4 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya]'
FOUND1='  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
PVL='  PROBE Propagation.values().length: 7 [REQUIRED, SUPPORTS, MANDATORY, REQUIRES_NEW, NOT_SUPPORTED, NEVER, NESTED]'
ver() { local c; c=$1
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] && [ "$(cnt "$c" "$VERF")" = "$2" ] || die "$3: the version lines - getVersionString(), Hibernate's HHH000001, Spring Data JPA's 4.1.2 and Spring Framework's 7.0.10 - once in each of its $2 harness JVMs (S4.13)"
  [ "$(cnt "$c" "${4:-$DBL}")" = "$2" ] && [ "$(cnt "$c" "$SEEDL")" = "$2" ] && [ "$(cnt "$c" "$FOUND1")" = "$2" ] && [ "$(cnt "$c" "$PVL")" = "$2" ] || die "$3: the database: line (H2 2.5.250), the shipped seed read by the second connection, Spring Data's Found 1 and Propagation.values() - in each of its $2 harness JVMs"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = "$2" ] || die "$3: each of its $2 harness JVMs ends by itself, exit 0"; }
TXP='  DEBUG org.springframework.orm.jpa.JpaTransactionManager : '
HTP='  DEBUG org.springframework.orm.jpa.hibernate.HibernateTransactionManager : '
# the cell checker (S4.15, S4.1, R.226): reads one capture's cells; checks the attribute read off each method, the verdict against
# the brief's table (the expected column below - the receipt's check, never the README's text), the manager's signature lines in
# each cell's own block, the second connection's one read after the call, a refused cell printing no rows; prints the table rows
# README.md must hold, the derived outcome count, and "mismatches N"; exits 1 on any mismatch
cat > .harness/cells.py <<'PY'
import re, sys
cap, want = sys.argv[1], sys.argv[2]       # want: grid | alone | nestedA
TXP = "  DEBUG org.springframework.orm.jpa.JpaTransactionManager : "
ATTR = {"required": "PROPAGATION_REQUIRED", "requiresNew": "PROPAGATION_REQUIRES_NEW", "nested": "PROPAGATION_NESTED",
        "supports": "PROPAGATION_SUPPORTS", "notSupported": "PROPAGATION_NOT_SUPPORTED", "mandatory": "PROPAGATION_MANDATORY",
        "never": "PROPAGATION_NEVER"}
NAME = {"required": "REQUIRED", "requiresNew": "REQUIRES_NEW", "nested": "NESTED", "supports": "SUPPORTS",
        "notSupported": "NOT_SUPPORTED", "mandatory": "MANDATORY", "never": "NEVER"}
G = "Asha gone · Dev gone · outer threw Boom"; U = "Asha gone · Dev gone · outer threw UnexpectedRollbackException"
NT = "refused NestedTransactionNotSupportedException"; IT = "refused IllegalTransactionStateException"
EXP = {"required": [G, U, "Dev gone"], "requiresNew": ["Asha gone · Dev KEPT · outer threw Boom", "Asha KEPT · Dev gone · outer returned", "Dev gone"],
       "nested": [NT, NT, "Dev gone"], "supports": [G, U, "Dev KEPT"],
       "notSupported": ["Asha gone · Dev KEPT · outer threw Boom", "Asha KEPT · Dev KEPT · outer returned", "Dev KEPT"],
       "mandatory": [G, U, IT], "never": [IT, IT, "Dev KEPT"]}
OUTER = "Creating new transaction with name [probe.t.Outer24.run]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT"
SAVE = "Creating new transaction with name [org.springframework.data.jpa.repository.support.SimpleJpaRepository.save]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT"
PART = "Participating in existing transaction"; MARK = "Participating transaction failed - marking existing transaction as rollback-only"
SUSN = "Suspending current transaction, creating new transaction with name [probe.t.Inner24.requiresNew]"; RES = "Resuming suspended transaction after completion of inner transaction"
RB = "Initiating transaction rollback"; CM = "Initiating transaction commit"
def own(m): return "Creating new transaction with name [probe.t.Inner24.%s]: %s,ISOLATION_DEFAULT" % (m, ATTR[m])
# each cell's manager lines that must be in its block (+) and must not (-)
SIG = {("required", "outer-fails"): ([OUTER, PART, RB], [MARK]), ("required", "inner-fails"): ([OUTER, MARK, CM], [RB]), ("required", "alone"): ([own("required"), RB], [OUTER]),
       ("requiresNew", "outer-fails"): ([OUTER, SUSN, RES, RB], [MARK]), ("requiresNew", "inner-fails"): ([OUTER, SUSN, RES, CM], [MARK]), ("requiresNew", "alone"): ([own("requiresNew"), RB], [OUTER]),
       ("nested", "outer-fails"): ([OUTER, RB], ["Creating nested transaction"]), ("nested", "inner-fails"): ([OUTER, CM], ["Creating nested transaction"]), ("nested", "alone"): ([own("nested"), RB], [OUTER]),
       ("supports", "outer-fails"): ([OUTER, PART, RB], [MARK, "Suspending"]), ("supports", "inner-fails"): ([OUTER, MARK, CM], ["Suspending"]), ("supports", "alone"): ([SAVE, CM], [own("supports"), OUTER]),
       ("notSupported", "outer-fails"): ([OUTER, "Suspending current transaction", SAVE, RES, RB], [MARK]), ("notSupported", "inner-fails"): ([OUTER, "Suspending current transaction", SAVE, RES, CM], [MARK]), ("notSupported", "alone"): ([SAVE, CM], [OUTER, own("notSupported")]),
       ("mandatory", "outer-fails"): ([OUTER, PART, RB], [MARK]), ("mandatory", "inner-fails"): ([OUTER, MARK, CM], []), ("mandatory", "alone"): ([], ["Creating new transaction"]),
       ("never", "outer-fails"): ([OUTER, RB], [SAVE]), ("never", "inner-fails"): ([OUTER, CM], [SAVE]), ("never", "alone"): ([SAVE, CM], [OUTER, own("never")])}
MODES = {"grid": ["outer-fails", "inner-fails", "alone"], "alone": ["alone"], "nestedA": ["outer-fails", "inner-fails", "alone"]}[want]
METHODS = ["nested"] if want == "nestedA" else ["required", "requiresNew", "nested", "supports", "notSupported", "mandatory", "never"]
L = [l.rstrip("\n") for l in open(cap, encoding="utf-8")]
bad = []; cells = {}; order = []
for i, l in enumerate(L):
    m = re.match(r"^  PROBE cell (\w+) · attribute (\S+) · ([a-z-]+) · (.+)$", l)
    if not m: continue
    meth, attr, mode, got = m.groups(); order.append((meth, mode)); cells[(meth, mode)] = (attr, got)
    a = L.index("  PROBE >>> cell %s · %s" % (meth, mode)); b = L.index("  PROBE <<< cell %s · %s" % (meth, mode))
    blk = L[a:b + 1]
    if not (a < i < b): bad.append("%s %s: the cell line outside its block" % (meth, mode))
    if attr.split(",")[0] != ATTR.get(meth): bad.append("%s attribute %s expected %s" % (meth, attr, ATTR.get(meth)))
    k = MODES.index(mode) if want != "alone" else 2
    exp = EXP[meth][["outer-fails", "inner-fails", "alone"].index(mode)]
    if got != exp: bad.append("%s %s: got [%s] expected [%s]" % (meth, mode, got, exp))
    if got.startswith("refused") and ("Asha" in got or "Dev" in got or "rows" in got): bad.append("%s %s: a refused cell prints rows (S4.15): %s" % (meth, mode, got))
    afters = [j for j, x in enumerate(blk) if x.startswith("  PROBE after: the second connection reads ")]
    mgr = [j for j, x in enumerate(blk) if x.startswith(TXP)]
    if len(afters) != 1 or (mgr and afters[0] < mgr[-1]): bad.append("%s %s: one read by the second connection, after the manager's last line (S4.1)" % (meth, mode))
    lines = [x[len(TXP):] for x in blk if x.startswith(TXP)]
    plus, minus = SIG[(meth, mode)]
    for s in plus:
        if not any(x == s or x.startswith(s) for x in lines): bad.append("%s %s: no manager line %s" % (meth, mode, s))
    for s in minus:
        if any(x.startswith(s) for x in lines): bad.append("%s %s: an unexpected manager line %s" % (meth, mode, s))
want_cells = [(m, md) for m in METHODS for md in MODES]
if order != want_cells: bad.append("the cells: %d in the order %s, expected %d" % (len(order), order[:3], len(want_cells)))
for x in bad: print("  mismatch: " + x)
if want == "grid" and not bad:
    for m in METHODS:
        a = cells[(m, "outer-fails")][0]
        print("| %s | `%s` | %s | %s | %s |" % (NAME[m], a, cells[(m, "outer-fails")][1], cells[(m, "inner-fails")][1], cells[(m, "alone")][1]))
    rows = lambda g: " · ".join(g.split(" · ")[:2])
    pairs = []
    for m in METHODS:
        o, i = cells[(m, "outer-fails")][1], cells[(m, "inner-fails")][1]
        if o.startswith("refused") or i.startswith("refused"): continue
        p = rows(o) + " / " + rows(i)
        if p not in pairs: pairs.append(p)
    unref = [NAME[m] for m in METHODS if not (cells[(m, "outer-fails")][1].startswith("refused") or cells[(m, "inner-fails")][1].startswith("refused"))]
    print("OUTCOMES %d among %d unrefused propagations (%s): %s" % (len(pairs), len(unref), ", ".join(unref), " | ".join(pairs)))
print("cells %d · mismatches %d" % (len(order), len(bad)))
sys.exit(1 if bad else 0)
PY
GTBL=""; GOUT=""; GN=""; GREF=""; GNEV=""; GNT1=""
chk_grid() { local C o
  C=$(cat .r-grid.out); ver "$C" 1 grid
  has "$C" '  PROBE transaction manager transactionManager · org.springframework.orm.jpa.JpaTransactionManager · nestedTransactionAllowed as built: false' "grid: Boot's manager, nestedTransactionAllowed as built: false"
  o=$(python3 -I -B .harness/cells.py .r-grid.out grid) || die "grid: $(printf '%s\n' "$o" | $G -E 'mismatch|^cells' | head -4 | paste -sd';' -)"
  # the number of cells: len() of the cell lines, and 7 propagations: Propagation.values().length, both read, never typed
  GN=$(printf '%s\n' "$C" | $G -c '^  PROBE cell ' || true); [ "$GN" = 21 ] && [ "$(printf '%s\n' "$o" | tail -1)" = 'cells 21 · mismatches 0' ] || die "grid: 21 cell lines (len), mismatches 0: $GN"
  GTBL=$(printf '%s\n' "$o" | $G '^| ' || true); [ "$(printf '%s\n' "$GTBL" | $G -c . || true)" = 7 ] || die "grid: the table's seven rows"
  GOUT=$(printf '%s\n' "$o" | sed -n 's/^OUTCOMES //p'); [ "${GOUT%% *}" = 3 ] || die "grid: the row outcomes among the unrefused cells, derived: $GOUT"
  # the refusals' messages in the grid's own chains
  GNT1=$(printf '%s\n' "$C" | sed -n 's/^  PROBE   outer caught: \(org.springframework.transaction.NestedTransactionNotSupportedException: .*\) · tx active true · name probe.t.Outer24.run · readOnly false$/\1/p' | head -1)
  [ "$GNT1" = "org.springframework.transaction.NestedTransactionNotSupportedException: Transaction manager does not allow nested transactions by default - specify 'nestedTransactionAllowed' property with value 'true'" ] || die "grid: NESTED's refusal on Boot's manager, the first message: ${GNT1:-none}"
  GNEV=$(printf '%s\n' "$C" | sed -n 's/^  PROBE   outer caught: \(org.springframework.transaction.IllegalTransactionStateException: .*\) · tx active true · name probe.t.Outer24.run · readOnly false$/\1/p' | head -1)
  [ "$GNEV" = "org.springframework.transaction.IllegalTransactionStateException: Existing transaction found for transaction marked with propagation 'never'" ] || die "grid: NEVER's refusal inside a transaction: ${GNEV:-none}"
  # the hook: REQUIRED inner-fails - the outer caught the inner's failure, returned normally, and the commit threw
  o=$(awk '$0 == "  PROBE >>> cell required · inner-fails" { f = 1 } f { print } $0 == "  PROBE <<< cell required · inner-fails" { f = 0 }' .r-grid.out)
  has "$o" '  PROBE   outer caught: probe.t.H$Boom: inner REQUIRED failed after the save of Dev · tx active true · name probe.t.Outer24.run · readOnly false' "grid hook: the outer caught the inner's failure"
  has "$o" '  PROBE threw: org.springframework.transaction.UnexpectedRollbackException: Transaction silently rolled back because it has been marked as rollback-only' "grid hook: the commit refused"
  has "$o" '  PROBE after: the second connection reads customer rows 4 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya]' "grid hook: Asha gone, Dev gone"
  echo "  grid: $GN cells (len), mismatches 0 against the brief's table, the attribute read off each method, each cell's manager lines; row outcomes among the unrefused cells (derived): $GOUT; NESTED on Boot's manager: $GNT1; NEVER inside: $GNEV"; }
ALM=""; ALN=""; ALR=""; ALS=""
chk_alone() { local C o
  C=$(cat .r-alone.out); ver "$C" 1 alone
  o=$(python3 -I -B .harness/cells.py .r-alone.out alone) || die "alone: $(printf '%s\n' "$o" | $G -E 'mismatch|^cells' | head -4 | paste -sd';' -)"
  [ "$(printf '%s\n' "$o" | tail -1)" = 'cells 7 · mismatches 0' ] || die "alone: 7 cells"
  # the alone column = the grid's alone column, cell for cell
  [ "$(printf '%s\n' "$C" | $G '^  PROBE cell .* · alone · ')" = "$($G '^  PROBE cell .* · alone · ' .r-grid.out)" ] || die "alone: its cells are not the grid's alone column"
  ALR=$(printf '%s\n' "$C" | sed -n 's/^  PROBE cell required · attribute [^ ]* · alone · //p'); ALS=$(printf '%s\n' "$C" | sed -n 's/^  PROBE cell supports · attribute [^ ]* · alone · //p')
  [ "$ALR" = 'Dev gone' ] && [ "$ALS" = 'Dev KEPT' ] || die "alone: REQUIRED Dev gone · SUPPORTS Dev KEPT (the slide that tells them apart): $ALR / $ALS"
  has "$C" '  PROBE   inside inner SUPPORTS: tx active false · name probe.t.Inner24.supports · readOnly false' "alone: SUPPORTS runs with no transaction"
  ALM=$(printf '%s\n' "$C" | awk '$0 == "  PROBE >>> cell mandatory · alone" { f = 1 } f && /^  PROBE threw: / { sub(/^  PROBE threw: /, ""); print; exit }')
  [ "$ALM" = "org.springframework.transaction.IllegalTransactionStateException: No existing transaction found for transaction marked with propagation 'mandatory'" ] || die "alone: MANDATORY's refusal: ${ALM:-none}"
  nhas "$(awk '$0 == "  PROBE >>> cell mandatory · alone" { f = 1 } f { print } $0 == "  PROBE <<< cell mandatory · alone" { f = 0 }' .r-alone.out)" 'inside inner MANDATORY' "alone: MANDATORY's body never ran"
  has "$C" '  PROBE   inside inner NEVER: tx active false · name probe.t.Inner24.never · readOnly false' "alone: NEVER runs"
  ALN=$(printf '%s\n' "$C" | sed -n 's/^  PROBE cell never · attribute [^ ]* · alone · //p'); [ "$ALN" = 'Dev KEPT' ] || die "alone: NEVER alone, Dev committed by save's own transaction: $ALN"
  [ "$(printf '%s\n' "$C" | sed -n 's/^  PROBE cell nested · attribute [^ ]* · alone · //p')" = "$ALR" ] || die "alone: NESTED alone = REQUIRED alone"
  echo "  alone: REQUIRED $ALR · SUPPORTS $ALS · MANDATORY $ALM · NEVER runs, $ALN · NESTED = REQUIRED ($ALR)"; }
NA1=""; NB1=""; NB2=""; NC1=""; NCO=""; NCI=""; NSP=""
chk_nested() { local C A1 B1 C1 x o
  C=$(cat .r-nested.out)
  A1=$(blk nested 'A - ' 'B - '); B1=$(blk nested 'B - LABELLED' 'C - LABELLED'); C1=$(blk nested 'C - LABELLED htm' '')
  [ -n "$B1" ] && [ -n "$C1" ] || die "nested: B and C must each be LABELLED in the capture's own header (brief flag 7)"
  ver "$A1" 1 "nested A"; ver "$B1" 1 "nested B"; ver "$C1" 1 "nested C" '  PROBE database: H2 2.5.250 | url jdbc:h2:mem:u24;DB_CLOSE_DELAY=-1;TRACE_LEVEL_SYSTEM_OUT=3'
  # A: Boot's manager, the flag as built, the first refusal
  printf '%s\n' "$A1" > .harness/na.out; o=$(python3 -I -B .harness/cells.py .harness/na.out nestedA) || die "nested A: $(printf '%s\n' "$o" | $G mismatch | head -3 | paste -sd';' -)"
  has "$A1" '  PROBE transaction manager transactionManager · org.springframework.orm.jpa.JpaTransactionManager · nestedTransactionAllowed as built: false' "nested A: as built, false"
  NA1=$(printf '%s\n' "$A1" | awk '$0 == "  PROBE >>> cell nested · outer-fails" { f = 1 } f && /^  PROBE threw: / { sub(/^  PROBE threw: /, ""); print; exit }')
  [ "$NA1" = "org.springframework.transaction.NestedTransactionNotSupportedException: Transaction manager does not allow nested transactions by default - specify 'nestedTransactionAllowed' property with value 'true'" ] || die "nested A: the first message: ${NA1:-none}"
  [ "$NA1" = "$GNT1" ] || die "nested A: the grid's NESTED refusal is the same message"
  # B: the flag set - a nested transaction is created, then the dialect refuses
  has "$B1" '  PROBE LABELLED -Dnested=true: transaction manager transactionManager · nestedTransactionAllowed set: true' "nested B: the flag set, labelled by the JVM itself"
  x=$(printf '%s\n' "$B1" | awk '$0 == "  PROBE >>> cell nested · outer-fails" { f = 1 } f { print } $0 == "  PROBE <<< cell nested · outer-fails" { f = 0 }')
  NB1=$(printf '%s\n' "$x" | sed -n "s/^${TXP}Creating nested transaction with name \[\(.*\)\]$/\1/p"); [ "$NB1" = probe.t.Inner24.nested ] || die "nested B: Creating nested transaction with name [probe.t.Inner24.nested]: ${NB1:-none}"
  NB2=$(printf '%s\n' "$x" | sed -n 's/^  PROBE threw: //p'); [ "$NB2" = "org.springframework.transaction.NestedTransactionNotSupportedException: JpaDialect does not support savepoints - check your JPA provider's capabilities" ] || die "nested B: the second message: ${NB2:-none}"
  [ "$(printf '%s\n' "$x" | $G -n "Creating nested transaction" | cut -d: -f1)" -lt "$(printf '%s\n' "$x" | $G -n '^  PROBE threw: ' | cut -d: -f1)" ] || die "nested B: the nested transaction is created first, then refused"
  [ "$(printf '%s\n' "$B1" | sed -n -E 's/^  PROBE cell nested · attribute [^ ]* · (outer-fails|inner-fails) · //p' | paste -sd'|' -)" = 'refused NestedTransactionNotSupportedException|refused NestedTransactionNotSupportedException' ] || die "nested B: both in-transaction cells refused"
  # C: LABELLED htm - the manager's bean and the profile printed by the JVM; the cells; the savepoint lines from H2's trace
  has "$C1" '  PROBE transaction manager bean: transactionManager · org.springframework.orm.jpa.hibernate.HibernateTransactionManager' "nested C: the labelled manager"
  has "$C1" '  PROBE spring.profiles.active as this context read it: htm' "nested C: the profile htm"
  NC1=$(printf '%s\n' "$C1" | sed -n 's/^  PROBE transaction manager transactionManager · \(org.springframework.orm.jpa.hibernate.HibernateTransactionManager · nestedTransactionAllowed as built: true\)$/\1/p'); [ -n "$NC1" ] || die "nested C: HibernateTransactionManager, nested allowed"
  [ "$(printf '%s\n' "$C1" | $G -cF -- "$TXP" || true)" = 0 ] || die "nested C: no JpaTransactionManager line in the htm run"
  NCO=$(printf '%s\n' "$C1" | sed -n 's/^  PROBE cell nested · attribute PROPAGATION_NESTED,ISOLATION_DEFAULT · outer-fails · //p'); NCI=$(printf '%s\n' "$C1" | sed -n 's/^  PROBE cell nested · attribute PROPAGATION_NESTED,ISOLATION_DEFAULT · inner-fails · //p')
  [ "$NCO" = 'Asha gone · Dev gone · outer threw Boom' ] && [ "$NCI" = 'Asha KEPT · Dev gone · outer returned' ] || die "nested C: outer-fails gone·gone, inner-fails KEPT·gone: $NCO / $NCI"
  x=$(printf '%s\n' "$C1" | awk '$0 == "  PROBE >>> cell nested · inner-fails" { f = 1 } f { print } $0 == "  PROBE <<< cell nested · inner-fails" { f = 0 }')
  for l in "${HTP}Creating nested transaction with name [probe.t.Inner24.nested]" '  (H2 trace) /**/Savepoint sp1 = conn0.setSavepoint("SAVEPOINT_1");' '  (H2 trace) /*SQL */SAVEPOINT \"SAVEPOINT_1\";' "${HTP}Rolling back transaction to savepoint" '  (H2 trace) /*SQL */ROLLBACK TO SAVEPOINT \"SAVEPOINT_1\";' '  (H2 trace) /**/conn0.releaseSavepoint(savepoint);' "${HTP}Initiating transaction commit"; do has "$x" "$l" "nested C inner-fails (the savepoint lines, S4.15)"; done
  [ "$(printf '%s\n' "$x" | $G -n 'setSavepoint' | cut -d: -f1)" -lt "$(printf '%s\n' "$x" | $G -n 'ROLLBACK TO SAVEPOINT' | cut -d: -f1)" ] || die "nested C: the savepoint set before it is rolled back to"
  x=$(printf '%s\n' "$C1" | awk '$0 == "  PROBE >>> cell nested · outer-fails" { f = 1 } f { print } $0 == "  PROBE <<< cell nested · outer-fails" { f = 0 }')
  for l in "${HTP}Creating nested transaction with name [probe.t.Inner24.nested]" '  (H2 trace) /*SQL */SAVEPOINT \"SAVEPOINT_1\";' "${HTP}Releasing transaction savepoint" "${HTP}Initiating transaction rollback"; do has "$x" "$l" "nested C outer-fails"; done
  nhas "$x" 'ROLLBACK TO SAVEPOINT' "nested C outer-fails: the savepoint is released, the whole transaction rolled back"
  NSP=$(printf '%s\n' "$C1" | awk '$0 == "  PROBE >>> cell nested · inner-fails" { f = 1 } f && /^  \(H2 trace\) \// { sub(/^  \(H2 trace\) /, ""); printf "%s%s", (n++ ? " · " : ""), $0 } $0 == "  PROBE <<< cell nested · inner-fails" { f = 0 }')
  echo "  nested: A (Boot's manager, as built false) $NA1 · B (LABELLED, the flag set) Creating nested transaction with name [$NB1] then $NB2 · C (LABELLED htm, $NC1) outer-fails $NCO · inner-fails $NCI · the trace: $NSP"; }
IA=""; IAG=""; IB=""; IBG=""; IBX=""
chk_import() { local A1 B A2 c o
  A1=$(blk import 'A - ' 'B - '); B=$(blk import 'B - LABELLED' "A' - "); A2=$(blk import "A' - " '')
  [ -n "$B" ] || die "import B must be LABELLED in its header"
  for c in "$A1:20030" "$B:20031" "$A2:20032"; do o=${c%:*}
    has "$o" "  listens on: 127.0.0.1:${c##*:}" "import: TiffinBox on loopback ${c##*:}"; has "$o" '  GET /actuator/health/readiness -> 200' "import: ready"
    has "$o" '    INFO com.tiffinbox.web.TiffinBoxServer: Started TiffinBoxServer' "import: started"; has "$o" "  stopped by its pid (SIGTERM): exit 143 · listening on ${c##*:} now: 0" "import: stopped"
    has "$o" '  its log: the token 0 times' "import: no token in the log"; done
  [ "$(printf '%s\n' "$A1" | sed 's/2003[02]/<port>/g')" = "$(printf '%s\n' "$A2" | sed 's/2003[02]/<port>/g')" ] || die "import A': A again prints what A printed, but its port"
  IA=$(printf '%s\n' "$A1" | awk '/^\$ cd \.harness && curl / { getline; sub(/^  -> /, ""); print; exit }')
  [ "$IA" = '{"file":"customers.csv","added":2,"refused":{"line 3":"a customer named Ravi already exists"}} 200' ] || die "import A: 200, added 2, line 3 refused: $IA"
  IAG=$(printf '%s\n' "$A1" | awk '/^\$ curl / { getline; sub(/^  -> /, ""); print; exit }' | $G -oE '"name":"[A-Za-z]+"' | sed 's/"name":"//; s/"$//' | paste -sd' ' -)
  [ "$IAG" = 'Asha Dev Meera Priya Ravi Sunil' ] || die "import A: the read after the call - Asha and Dev stored: $IAG"
  has "$A1" '  its log'"'"'s lines - WARN: 2 · ERROR: 0 · '"'"'GenerationTarget encountered exception'"'"': 0' "import A: the duplicate's two WARN lines, no ERROR"
  IB=$(printf '%s\n' "$B" | awk '/^\$ cd \.harness && curl / { getline; sub(/^  -> /, ""); print; exit }')
  [ "${IB##* }" = 500 ] || die "import B: 500 (the failure receipt): ${IB:-none}"
  printf '%s\n' "$IB" | $G -qF '"status":500,"error":"Internal Server Error","path":"/customers/import"' || die "import B: Spring's 500 body: $IB"
  IBX=$(printf '%s\n' "$B" | sed -n 's/^    the request failed: //p'); [ "$IBX" = 'org.springframework.transaction.UnexpectedRollbackException: Transaction silently rolled back because it has been marked as rollback-only' ] || die "import B: the exception the server logged: ${IBX:-none}"
  IBG=$(printf '%s\n' "$B" | awk '/^\$ curl / { getline; sub(/^  -> /, ""); print; exit }' | $G -oE '"name":"[A-Za-z]+"' | sed 's/"name":"//; s/"$//' | paste -sd' ' -)
  [ "$IBG" = 'Meera Priya Ravi Sunil' ] || die "import B: the read after the call - the four seeded rows only: $IBG"
  has "$B" '  its log'"'"'s lines - WARN: 2 · ERROR: 1 · '"'"'GenerationTarget encountered exception'"'"': 0' "import B: the duplicate's two WARN lines, one ERROR"
  echo "  import: A and A' - $IA, then GET /customers: $IAG; B (LABELLED: CustomerImport un-finaled, @Transactional on importCsv) - ${IB##* }, the server logged $IBX, then GET /customers: $IBG"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: yes")" = 1 ] || die "xcheck: the harness's script must be Boot's for the anchor's entities, md5 $X09 (R.212) - a mapping moved"
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ' || true)" = 3 ] || die "xcheck: two create table lines and one alter table"
  echo "  xcheck: the harness's script (@EntityScan(\"com.tiffinbox\") alone), md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README's import catches one refused row and loses every row it stored. Keep the good rows."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXBT=""; EXBR=""; EXST=""; EXSR=""
chk_exercise() { local EB EZ b ER ES w l
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    Creating new transaction with name [probe.t.ex.Importer.importRows]'; do has "$ER" "$l" "exercise: the README runs"; has "$ES" "$l" "exercise: the solution runs"; done
    # S4.16: the end states first - broken: the runtime refusal caught, the commit refused, the seed's four rows; solved: added 2, Asha and Dev kept
    EXBT=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE importRows(\[Asha, Ravi, Dev\]) threw: //p'); EXBR=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE after the call, its own JDBC connection reads: //p')
    [ "$EXBT" = 'org.springframework.transaction.UnexpectedRollbackException: Transaction silently rolled back because it has been marked as rollback-only' ] && [ "$EXBR" = 'customer rows 4 · Asha gone · Dev gone' ] || die "exercise: the README's run ends in UnexpectedRollbackException and the seed's four rows (S4.16): ${EXBT:-none} / ${EXBR:-none}"
    has "$ER" '    Participating transaction failed - marking existing transaction as rollback-only' "exercise broken: the refused row marks the import's transaction"
    EXST=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE importRows(\[Asha, Ravi, Dev\]) returned: //p'); EXSR=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE after the call, its own JDBC connection reads: //p')
    [ "$EXST" = 'added 2 · refused Ravi (23505)' ] && [ "$EXSR" = 'customer rows 6 · Asha kept · Dev kept' ] || die "exercise: the solution's end state - added 2 · refused Ravi (23505), Asha and Dev kept (S4.16): ${EXST:-none} / ${EXSR:-none}"
    [ "$(printf '%s\n' "$ES" | $G -cxF '    Suspending current transaction, creating new transaction with name [probe.t.ex.Rows.addRow]' || true)" = 3 ] || die "exercise solved: one new transaction per row, three"
    [ "$EXBR" != "$EXSR" ] || die "exercise: broken and solved must differ - by the rows, never only the exit code"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qxF '    public void addRow(String name) {' harness/src/probe/t/ex/ExApp.java || die "exercise: ExApp ships addRow without the annotation"
  echo "  exercise: bash and zsh alike - the README as written: threw $EXBT, $EXBR; the solution (one line: REQUIRES_NEW on addRow): $EXST, $EXSR; each file's What it prints = the run; $EXW words"; }
cap grid grid; chk_grid; pub grid
cap alone alone; chk_alone; pub alone
cap nested nested; chk_nested; pub nested
cap import import; chk_import; pub import
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise

# the table and the values the video says are the captures', never typed: README.md holds them, composed here from the checks' reads
printf '%s\n' "$GTBL" | while IFS= read -r l; do $G -qxF -- "$l" README.md || { echo "  *** README.md's grid table does not hold the capture's row: $l ***" >&3; exit 1; }; done || exit 1
[ "$($G -c '^| [A-Z_]* | `PROPAGATION_' README.md || true)" = 7 ] || die "README.md's grid table: seven rows, each the capture's"
echo "  README.md's grid table: its seven rows = the capture's cells (built by cells.py from the 21 cell lines)"
VS="the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - grid: $GN cells, 7 propagations (Propagation.values().length), mismatches 0; the row outcomes among the unrefused cells: $GOUT · the hook (REQUIRED, inner-fails): the outer caught the inner's failure and returned; the commit threw org.springframework.transaction.UnexpectedRollbackException: Transaction silently rolled back because it has been marked as rollback-only; Asha gone, Dev gone · alone: REQUIRED $ALR · SUPPORTS $ALS · MANDATORY $ALM · NEVER $ALN · NESTED = REQUIRED · NEVER inside a transaction: $GNEV · nested: Boot's manager $NA1 · LABELLED flag set: Creating nested transaction with name [$NB1], then $NB2 · LABELLED htm: outer-fails $NCO, inner-fails $NCI; $NSP · import A: $IA; after: $IAG · import B (LABELLED): ${IB##* }, $IBX; after: $IBG · xcheck: $X09 · exercise: $EXBT, $EXBR -> REQUIRES_NEW on the per-row method: $EXST, $EXSR ($EXW words)"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"

# hygiene: every capture and every file this unit holds - 0 raw tokens
for f in .harness/raw-*; do [ "$(cat "$f")" = '0 0' ] || die "a capture's raw output held a token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] && [ "$(raw "$TOKENB" "$f")" = 0 ] || die "$f holds a token, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] || die "no JVM ran"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE 'SessionImpl\([0-9]|scanning in [0-9]+ ms|Lambda/0x' "$f" || die "$f holds an EntityManager's identity, a lambda's address or a scan time, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:2003[0-2]' || die "$f holds a URL (only TiffinBox's own loopback ports 20030-20032 may appear: the import's curl lines)"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.t' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep' harness/src || die "a harness sleeps (S4.18)"
# the hazard (brief): the dispatch is Outer24's, through the inner bean's proxy - no method of Inner24 calls another of its own
! $G -nE '\b(this\.)?(required|requiresNew|nested|supports|notSupported|mandatory|never)\(' harness/src/probe/t/Inner24.java | $G -v 'public void ' > /dev/null || die "Inner24 calls one of its own propagation methods - the dispatch must come through the proxy, from Outer24"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw token copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, unmasked identity or generated name, URL or stack frame in any capture; every JVM pinned and under its alarm; no kill by name; no bare wait; no sleep in the harness; no self-dispatch in Inner24; no H2 file"
# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 20030-20039 at the end - TiffinBox bound 20030, 20031, 20032 and stopped; 20039 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit24: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens; no port bound but 20030-20032"
