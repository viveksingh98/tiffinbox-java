#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Bulk Updates and the Stale Context - this unit's receipts. No change to the anchor (brief ⚑11): anchor/ is the link
# to ../c7-unit17/after, Section 3's frozen anchor. A bulk update - @Modifying @Query("update CustomerEntity c set c.mealsPerDay
# = c.mealsPerDay + 1 where c.mealType = :type") - goes straight to the database; the persistence context is not told. Seven
# captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every number and string the
# video says is asserted right after its capture by a check that can fail. One database: H2, in each JVM's memory, gone with
# it. No TiffinBox runs here.
#   notx      the failure receipt (one harness JVM): B bump(VEG) with no transaction of the caller's - the exception's class,
#             message and first cause (S3.10, RED #914), 0 statements, no transaction created; A bumpTx(VEG) (@Transactional on
#             the method) - a transaction created for it, 1 statement, 2 rows; C bumpNoModifying(VEG) (no @Modifying) in a
#             TransactionTemplate - the exception, its first cause, 0 statements, rolled back
#   stale     S3.13's three witnesses (one harness JVM, one TransactionTemplate): Ravi loaded; bump(VEG); the Ravi object; findById
#             again (no SELECT, the same instance); a second connection before the commit; a native read in the same transaction;
#             em.refresh; the second connection after the commit
#   clear     clearAutomatically (three harness JVMs, the brief's labels): B bump - the stale context; A bumpClear - the object
#             detached, findById runs a SELECT and returns the new value; A' A again
#   flush     the pending change (three harness JVMs: bump, bumpClear, bumpFlush): Meera changed in the object, not flushed, then
#             the bulk update - the statements' ORDER read off the log; the second connection after the commit
#   cascade   what a bulk delete skips (one harness JVM): the anchor's deleteById(Sunil) - his pause, no cascade; the harness's own
#             cascade pair (CCustomer/CPause on c_customer/c_pause): deleteById, a JPQL bulk delete, deleteAll() and
#             deleteAllInBatch() - each on rows this capture seeds itself and prints first (RED #926)
#   xcheck    the harness's DDL script (@EntityScan("com.tiffinbox") alone, scripts.action=create - the cascade pair excluded)
#             against the owning-side lesson's published md5: no mapping moved (R.212, brief ⚑3)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# No anchor change: anchor/ is the link to ../c7-unit17/after. It equals ../c7-tiffinbox until a later unit changes the anchor -
# printed at the start and the end, a note then, never a stop (R.211). The anchor is COPIED under .harness/anchor and built
# there, never in place (its README's package line, offline; its tests run); its jar extracted (the anchor's own line).
# The harness (harness/src, packages probe.q and probe.x, outside com.tiffinbox) is compiled against the anchor's extracted
# libraries with javac -parameters into .harness/hc. probe.q.Main is a Spring Boot context with no web server
# (WebApplicationType.NONE: it binds no port) over those, @EntityScan on com.tiffinbox - the anchor's entities - and on
# probe.q.casc - the harness's own cascade pair, its two tables created by plain JDBC (probe.q.casc.Tables) - and
# @EnableJpaRepositories on probe.q.repo (Customers: the five bulk updates; CCustomers: the pair's deletes); probe.q.Seed builds
# the shipped Database in code on the run's own H2 database, which seeds it; Hibernate writes no schema (ddl-auto none), its
# statistics are on; Logback (harness/logback.xml) prints Hibernate's SQL logger, JpaTransactionManager's DEBUG lines (S3.2),
# its HHH000001 line, the EntityManagerFactory's line and Spring Data's scan line. The second connection is plain JDBC:
# DriverManager on the same jdbc:h2:mem:u22 URL, outside Hibernate and outside Spring's transaction. probe.x.XMain is xcheck's
# context (the anchor's entities alone). Each runs from .harness/run. Its JVM flags travel as an array, V, its arguments as an
# array, A (R.193). Every JVM this script starts - the harness's and the exercise's - runs under an alarm (perl -e 'alarm N;
# exec ...': macOS has no timeout); an alarm that fires is a failed receipt (R.247). Commands are printed exactly as they run:
# each goes through eval. harness/dur7.py (Course 7's builders' duration pattern, byte for byte) gates this unit's prose: it
# speaks no time (R.172). "$M2" is this unit's own repository, .m2-demo.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline build missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. At run time nothing leaves the machine: every database is H2 in a JVM's memory, and no JVM here binds a port. This
# unit reads no version file: the section's dated sweep is the brief's (R.223; _research/spring-boot-metadata-2026-11-07.xml).
# Masks (README.md declares each; awk gsub only): this folder "…", the folder above it "…/..", home "~", your user name "<user>";
# " using Java <version>"; an identity hash "@…"; the JDK's proxy class number "$Proxy<n>"; an EntityManager's identity
# "SessionImpl(<n><open>)"; Spring Data's scan time "scanning in <n> ms"; H2's generated constraint and index names
# "CONSTRAINT_<n>", "CONSTRAINT_INDEX_<n>" (the brief's hazard: the foreign key's name H2 makes up, in the refusal's message). A
# harness JVM's log is printed whole (every line it prints, trailing spaces dropped).
# Ports (§P, 20010-20019): this unit binds none. All ten, and 18425 (TiffinBox's default), 8080 and 35729, are checked free at the
# start and the end; 20019 is the one the brief names "never bound".
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process under it); then
# sweep(): anything of this run still alive in its process group - a harness JVM, a javac, a Maven - is stopped. After an
# interrupt a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second
# Ctrl-C, and the script still exits 130 after an interrupt (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.q.") || index($0, "probe.x.") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 perl rsync lsof mvn md5 cmp find /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - nothing here needs one"
# No anchor change (brief ⚑11): anchor/ is the link to ../c7-unit17/after - Section 3's frozen anchor. It equals ../c7-tiffinbox
# until a later unit changes the anchor - a note then, never a stop (R.211, the Course 6 form)
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
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
HS=harness/src/probe/q
HFILES='dur7.py logback.xml src'
SFILES='probe/q/Main.java probe/q/Run.java probe/q/Seed.java probe/q/casc/CCustomer.java probe/q/casc/CPause.java probe/q/casc/Tables.java probe/q/ex/ExApp.java probe/q/repo/CCustomers.java probe/q/repo/Customers.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20010 20011 20012 20013 20014 20015 20016 20017 20018 20019"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc

# ---- the prose gates: no duration word (R.172); English names only (R.215); the placeholders unit 16 shipped; typed values -----
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
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src)"
# the exercise's "What it prints" blocks hold what the run printed (exercise checks it, line for line) - never a placeholder (unit
# 16 shipped EXERCISE-README-OUTPUT and EXERCISE-SOLUTION-OUTPUT under such a heading), never an empty block
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose - the exercise's blocks hold the measured output: $PH"
# wib FILE: the fenced block under the file's "What it prints" line
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty (exercise compares it with the run, line for line)"
# S3.10 (R.241): an exception is read off the log as its class with its package - never typed from memory; the 3.x name of
# Spring Data's property exception is not in spring-data-commons-4.1.2.jar, and no version is credited with it (RED #931)
OLDP='org\.springframework\.data\.mapping\.PropertyReferenceException'
OP=$($G -rnE -- "$OLDP" README.md exercise harness/src 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$OP" ] || die "a line names the exception by the package it does not have on Spring Data JPA 4.1.2 - S3.10 (R.241): $OP"
echo "  S3.10's refused class name: 0 lines over README.md, exercise/, harness/src"
# R.225, R.227: a SQL string this unit shows is the logger's, composed into README.md's values line by this script - a line of
# README.md holding Hibernate's aliases (ce1_0. c1_0. p1_0.) or an SQL statement's head the logger writes (update customer, delete
# from customer, delete from c_customer, delete from c_pause, select meals_per_day) anywhere else is a typed SQL string, refused
SQLRE='ce1_0\.|c1_0\.|p1_0\.|update customer |delete from (customer|c_customer|c_pause)|select meals_per_day'
TS=$($G -nE "$SQLRE" README.md 2> /dev/null | $G -vF 'the values the video may say:' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md outside the values line (R.225, R.227): $TS"
echo "  typed SQL strings: 0 in README.md outside its composed values line"
# R.184, R.225 (RED #926): a statement count is read off a capture - the SQL logger's lines and Statistics - and stated only in
# the values line; a count of statements, SELECTs, DELETEs or UPDATEs typed anywhere else in the prose is refused
NUMW='one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|[0-9]+'
TC=$($G -nE "\\b($NUMW|One|Two|Three|Four|Five|Six|Seven|Eight|Nine|Ten) (more |new |entity |bulk |child |parent )?([Ss]tatements?|SELECTs?|DELETEs?|UPDATEs?|INSERTs?|selects|deletes|updates|inserts)\\b" README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF 'the values the video may say:' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "a typed statement count - each is read off a capture, and only the values line states it (R.184, R.225): $TC"
echo "  typed statement counts: 0 (the captures' counts are in the values line only)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/Main.java $HS/Run.java $HS/Seed.java $HS/casc/CCustomer.java $HS/casc/CPause.java $HS/casc/Tables.java $HS/repo/CCustomers.java $HS/repo/Customers.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*\" probe.q.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures - the anchor copied and built with its README's package line offline (its tests run); its jar
# ---- extracted (the anchor's line); the harness -------------------------------------------------------------------------------
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
# jc COMMAND LOG: a javac, in the background like a build (its pid in mpid: an interrupt stops it), its exit code in JE
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/anchor/
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/, its README's package line; its tests ran)"
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
jc "$L_JAVAC" .harness/javac.log
[ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/q/ex ] || die "the exercise's class was compiled into the harness - it is compiled on its own"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries); the harness compiled into .harness/hc"
# ---- helpers ------------------------------------------------------------------------------------------------------------
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/\$Proxy[0-9]+/, "$Proxy<n>")
    gsub(/SessionImpl\([0-9]+</, "SessionImpl(<n><")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/CONSTRAINT_INDEX_[0-9A-F]+/, "CONSTRAINT_INDEX_<n>"); gsub(/CONSTRAINT_[0-9A-F]+/, "CONSTRAINT_<n>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'class: jdk.proxy2.$Proxy128' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 2 JPA repository interfaces.' '"PUBLIC.CONSTRAINT_52 INDEX PUBLIC.CONSTRAINT_INDEX_5 ON PUBLIC.CUSTOMER' 'violation: "CONSTRAINT_48: PUBLIC.PAUSE FOREIGN KEY(CUSTOMER_ID) · constraint [CONSTRAINT_7E]' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'class: jdk.proxy2.$Proxy<n>' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 2 JPA repository interfaces.' '"PUBLIC.CONSTRAINT_<n> INDEX PUBLIC.CONSTRAINT_INDEX_<n> ON PUBLIC.CUSTOMER' 'violation: "CONSTRAINT_<n>: PUBLIC.PAUSE FOREIGN KEY(CUSTOMER_ID) · constraint [CONSTRAINT_<n>]')" ] || die "mask: the planted JDK version, folders, home, identity hash, proxy number, EntityManager identity, scan time and H2's generated names must be masked"
rm -f .harness/p1
# the harness's arguments: this run's own H2 database (in this JVM's memory, kept while the context lives), the harness's
# Logback file, no schema written, no banner, the anchor's Thymeleaf jar not looking for templates, Hibernate's statistics on
HA=('--spring.datasource.url=jdbc:h2:mem:u22;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.hibernate.generate_statistics=true)
# hrun: the harness line (V, A set by the caller; HL the line - L_H, or L_X for xcheck), run from .harness/run; it exits by
# itself (its alarm: 240 s); its exit code in HE; its log .harness/h.log
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  [ "${HL:-$L_H}" = "$L_X" ] || echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"; }
# hview: the harness's whole log (PROBE lines, the named loggers' lines), trailing spaces dropped; then its exit code
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
unpub=""
# cap NAME FUNCTION: three runs, masked, compared; the capture's checks run next; pub NAME then compares it with receipts.md5
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
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

# ---- the captures --------------------------------------------------------------------------------------------------------
notx() { echo "notx - the failure receipt: B bump(VEG) with no transaction of the caller's, A bumpTx(VEG), C bumpNoModifying(VEG) (one harness JVM, .harness/hc):"
  V=(-Ds=notx); A=("${HA[@]}"); hrun; hview; }
stale() { echo "stale - S3.13's three witnesses, one TransactionTemplate (one harness JVM):"
  V=(-Ds=stale); A=("${HA[@]}"); hrun; hview; }
clear() { echo "B - bump(VEG): the stale context (one harness JVM):"
  V=(-Ds=clear -Dv=B); A=("${HA[@]}"); hrun; hview
  echo "A - bumpClear(VEG), @Modifying(clearAutomatically = true) (one harness JVM):"
  V=(-Ds=clear -Dv=A); A=("${HA[@]}"); hrun; hview
  echo "A' - A again, in a fresh JVM:"
  V=(-Ds=clear -Dv=A); A=("${HA[@]}"); hrun; hview; }
flush() { local v
  for v in bump bumpClear bumpFlush; do echo "the pending change, then $v(VEG) (one harness JVM):"
    V=(-Ds=flush -Dv=$v); A=("${HA[@]}"); hrun; hview; done; }
cascade() { echo "cascade - what a bulk delete skips: the anchor's deleteById, then the harness's cascade pair (one harness JVM):"
  V=(-Ds=cascade); A=("${HA[@]}"); hrun; hview; }
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # ../c7-unit09's published xcheck capture
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
XA=('--spring.datasource.url=jdbc:h2:mem:x22;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed, not the cascade pair), scripts.action=create (a file, never run):"
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
# R.222 and S3.15 (R.246): a version-shaped claim prints its versions in the same capture - Hibernate's own HHH000001 line, the
# harness's getVersionString() line, and Spring Data JPA's version from its jar's manifest - once per harness JVM, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
VERD='  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2'
DBL='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:u22;DB_CLOSE_DELAY=-1'
SEEDT='[1 | Ravi | VEG | 2 | 120, 2 | Meera | NON_VEG | 1 | 150, 3 | Sunil | VEG | 3 | 100, 4 | Priya | VEGAN | 1 | 120]'
SEEDP='[1 | Sunil | 3, 2 | Priya | 2]'
SEEDL="  PROBE seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type | meals_per_day | price_per_meal): $SEEDT"
PAUL="  PROBE pause (id | customer | days), read the same way: $SEEDP"
CPL='  PROBE the cascade pair'"'"'s tables, read the same way: c_customer 0 · c_pause 0'
FOUND2='  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 2 JPA repository interfaces.'
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] || die "$1: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its $2 harness JVMs (R.222, S3.15/R.246)"
  [ "$(cnt "$c" "$DBL")" = "$2" ] && [ "$(cnt "$c" "$SEEDL")" = "$2" ] && [ "$(cnt "$c" "$FOUND2")" = "$2" ] && [ "$(cnt "$c" "$PAUL")" = "$2" ] && [ "$(cnt "$c" "$CPL")" = "$2" ] || die "$1: the database: line, H2 2.5.250, the shipped seed, the empty cascade pair and Spring Data's Found 2, in each of its $2 harness JVMs (R.217: this unit speaks for H2 only)"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = "$2" ] || die "$1: each of its $2 harness JVMs ends by itself, exit 0 (a call failure is not a start failure, S3.9)"; }
# R.184: a statement count has two witnesses from one call - the SQL logger's lines between ">>> label" and "<<< label", and
# Hibernate's Statistics for that call (getPrepareStatementCount, printed on the "<<<" line)
call() { printf '%s\n' "$1" | awk -v a="  PROBE >>> $2" -v b="  PROBE <<< $2 · " 'index($0, a) == 1 && length($0) == length(a) { f = 1 } f { print } f && index($0, b) == 1 { f = 0 }'; }
sqll() { printf '%s\n' "$1" | $G -E '^  DEBUG org\.hibernate\.SQL : ' | sed -E 's/^  DEBUG org\.hibernate\.SQL : //' || true; }
two() { local b n p; b=$(call "$1" "$2"); [ -n "$b" ] || die "$4: no call named $2"
  n=$(sqll "$b" | $G -c . || true); p=$(printf '%s\n' "$b" | sed -n 's/^  PROBE <<< .* · statements (getPrepareStatementCount) \([0-9]*\) · .*/\1/p')
  [ "$n" = "$3" ] && [ "$p" = "$3" ] || die "$4: $3 statements - the SQL log's lines ($n) and getPrepareStatementCount() (${p:-none}) both (R.184)"; }
# stn BLOCK LABEL: a call's statement count, read off the log and asserted equal to Statistics' (R.184) - for counts derived, not given
stn() { local b n p; b=$(call "$1" "$2"); [ -n "$b" ] || die "no call named $2"
  n=$(sqll "$b" | $G -c . || true); p=$(printf '%s\n' "$b" | sed -n 's/^  PROBE <<< .* · statements (getPrepareStatementCount) \([0-9]*\) · .*/\1/p')
  [ "$n" = "$p" ] || die "$2: the SQL log's lines ($n) and getPrepareStatementCount() (${p:-none}) disagree (R.184)"; printf '%s\n' "$n"; }
res() { printf '%s\n' "$1" | sed -n 's/^  PROBE result: //p'; }
thr() { printf '%s\n' "$1" | sed -n 's/^  PROBE threw: //p'; }
fca() { printf '%s\n' "$1" | sed -n 's/^  PROBE first cause: //p'; }
thn() { printf '%s\n' "$1" | sed -n 's/^  PROBE then: //p'; }
# S3.2 (R.233): a transaction claim is JpaTransactionManager's DEBUG line, or its absence, counted between two markers
TXP='  DEBUG org.springframework.orm.jpa.JpaTransactionManager : '
txc() { printf '%s\n' "$1" | $G -cF -- "$TXP$2" || true; }
SELC='select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0'
BULKX='update customer ce1_0 set meals_per_day=(ce1_0.meals_per_day+1) where ce1_0.meal_type=?'   # the brief's, measured by the probe
ENTX='update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=? where id=?'
NOTXM='No active transaction for update or delete query'
SELM="Query executed via 'getResultList()' or 'getSingleResult()' must be a 'select' query [update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1 where c.mealType = :type]"
IDAAUE=org.springframework.dao.InvalidDataAccessApiUsageException
# exc WHAT BLOCK CLASS MESSAGE CAUSECLASS CAUSEMESSAGE: S3.10 (R.241, RED #914) - the class, the message and the first cause,
# each read off the log and each asserted (a message alone cannot tell two failures of one class apart)
exc() { local t c; t=$(thr "$2"); c=$(fca "$2")
  [ -n "$t" ] || die "$1: no exception - expected $3"
  [ "${t%%: *}" = "$3" ] || die "$1: the exception's class: ${t%%: *} - expected $3 (S3.10)"
  [ "${t#*: }" = "$4" ] || die "$1: the exception's message: ${t#*: } - expected $4 (S3.10)"
  [ "${c%%: *}" = "$5" ] || die "$1: the first cause's class: ${c%%: *} - expected $5 (S3.10, RED #914)"
  [ "${c#*: }" = "$6" ] || die "$1: the first cause's message: ${c#*: } - expected $6 (S3.10, RED #914)"; }
NB=""; NBC=""; NAT=""; NAR=""; NC=""; NCC=""; NAN=""; NAT2=""
chk_notx() { local N B A C l
  N=$(cat .r-notx.out)
  l="B: bump(VEG) - no transaction of the caller's"; B=$(call "$N" "$l")
  exc "notx B" "$B" "$IDAAUE" "$NOTXM" jakarta.persistence.TransactionRequiredException "$NOTXM"
  two "$N" "$l" 0 "notx B"
  [ "$(txc "$B" 'Creating new transaction')" = 0 ] && [ "$(printf '%s\n' "$B" | $G -cF -- "$TXP" || true)" = 0 ] || die "notx B: no transaction is created, joined or rolled back for a declared query method - JpaTransactionManager says nothing between the markers (S3.2)"
  NB=$(thr "$B"); NBC=$(fca "$B")
  has "$N" "  PROBE after B: $SEEDT" "notx B: nothing changed - the second connection reads the seed"
  l="A: bumpTx(VEG) - @Transactional on the method"; A=$(call "$N" "$l"); two "$N" "$l" 1 "notx A"
  [ "$(sqll "$A")" = "$BULKX" ] || die "notx A: the bulk update's SQL: $(sqll "$A")"
  NAT=$(printf '%s\n' "$A" | sed -n "s/^$TXP"'Creating new transaction with name \[\(.*\)\]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT$/\1/p')
  [ "$NAT" = org.springframework.data.jpa.repository.support.SimpleJpaRepository.bumpTx ] && [ "$(txc "$A" 'Creating new transaction')" = 1 ] && [ "$(txc "$A" 'Initiating transaction commit')" = 1 ] || die "notx A: one transaction created for bumpTx, and committed (S3.2): ${NAT:-none}"
  NAR=$(res "$A"); [ "$NAR" = '2 rows updated' ] || die "notx A: the update changed the two vegetarian customers: $NAR"
  has "$N" '  PROBE after A: [1 | Ravi | VEG | 3 | 120, 2 | Meera | NON_VEG | 1 | 150, 3 | Sunil | VEG | 4 | 100, 4 | Priya | VEGAN | 1 | 120]' "notx A: Ravi and Sunil one more meal a day"
  l="C: bumpNoModifying(VEG) - @Query without @Modifying, in a TransactionTemplate"; C=$(call "$N" "$l"); two "$N" "$l" 0 "notx C"
  exc "notx C" "$C" "$IDAAUE" "$SELM" java.lang.IllegalStateException "$SELM"
  [ "$(txc "$C" 'Creating new transaction with name [null]')" = 1 ] && [ "$(txc "$C" 'Initiating transaction rollback')" = 1 ] && [ "$(txc "$C" 'Initiating transaction commit')" = 0 ] || die "notx C: the TransactionTemplate's transaction created, then rolled back (S3.2)"
  NC=$(thr "$C"); NCC=$(fca "$C"); NAN=$(thn "$C" | head -1)
  has "$N" '  PROBE after C: [1 | Ravi | VEG | 3 | 120, 2 | Meera | NON_VEG | 1 | 150, 3 | Sunil | VEG | 4 | 100, 4 | Priya | VEGAN | 1 | 120]' "notx C: rolled back - nothing changed since A"
  ver notx 1
  # the two failures share a class: only the message and the first cause tell them apart (RED #914)
  [ "${NB%%: *}" = "${NC%%: *}" ] && [ "${NB#*: }" != "${NC#*: }" ] && [ "${NBC%%: *}" != "${NCC%%: *}" ] || die "notx: B and C - one class, two messages, two first causes"
  echo "  notx: B bump(VEG), no caller's transaction - ${NB%%: *}: ${NB#*: } <- first cause ${NBC%%: *} (the same message), 0 statements, JpaTransactionManager silent; A bumpTx - Creating new transaction with name [$NAT], 1 statement, $NAR; C bumpNoModifying - ${NC%%: *} <- ${NCC%%: *}, 0 statements, rolled back"; }
SLD=""; SB=""; SBR=""; SOB=""; SAG=""; SAGN=""; SC1=""; SNAT=""; SNATQ=""; SNATN=""; SREF=""; SREFN=""; SC2=""; SBN=""
chk_stale() { local T l b
  T=$(cat .r-stale.out)
  [ "$(txc "$T" 'Creating new transaction with name [null]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT')" = 1 ] && [ "$(txc "$T" 'Creating new transaction')" = 1 ] || die "stale: one transaction - the TransactionTemplate's - created; nothing else creates one (S3.2)"
  l='findById(1)'; two "$T" "$l" 1 "stale findById"; b=$(call "$T" "$l"); SLD=$(res "$b")
  [ "$(sqll "$b")" = "$SELC where ce1_0.id=?" ] && [ "$SLD" = 'id 1 · Ravi · mealsPerDay 2' ] && [ "$(txc "$b" 'Participating in existing transaction')" = 1 ] || die "stale: Ravi loaded by one SELECT, in the caller's transaction: $SLD"
  l='bump(VEG)'; two "$T" "$l" 1 "stale bump"; b=$(call "$T" "$l"); SB=$(sqll "$b"); SBR=$(res "$b"); SBN=$(stn "$T" "$l")
  [ "$SB" = "$BULKX" ] && [ "$SBR" = '2 rows updated' ] || die "stale: the bulk update - its SQL and the rows it changed: $SB · $SBR"
  [ "$(printf '%s\n' "$b" | $G -cF -- "$TXP" || true)" = 0 ] || die "stale: the declared bulk method creates and joins nothing - JpaTransactionManager silent between its markers (S3.2, READ FIRST 3)"
  l='the Ravi object'; two "$T" "$l" 0 "stale object"; SOB=$(res "$(call "$T" "$l")")
  [ "$SOB" = 'mealsPerDay 2 · em.contains(ravi) true' ] || die "stale: the loaded object still says the old value and is still managed (witness 1, S3.13): $SOB"
  l='findById(1) again'; two "$T" "$l" 0 "stale findById again"; SAG=$(res "$(call "$T" "$l")"); SAGN=0
  [ "$SAG" = 'mealsPerDay 2 · same instance true' ] || die "stale: findById hands back the same stale object, no SELECT: $SAG"
  l='a second connection, before the commit'; two "$T" "$l" 0 "stale second connection"; SC1=$(res "$(call "$T" "$l")")
  [ "$SC1" = 'the second connection reads 1 | Ravi | VEG | 2 | 120' ] || die "stale: the second connection before the commit reads the committed value: $SC1"
  l='a native read in this transaction: em.createNativeQuery("select meals_per_day from customer where id = ?").setParameter(1, 1L)'
  two "$T" "$l" 1 "stale native read"; b=$(call "$T" "$l"); SNAT=$(res "$b"); SNATQ=$(sqll "$b")
  [ "$SNATQ" = 'select meals_per_day from customer where id = ?' ] && [ "$SNAT" = 'meals_per_day 3' ] || die "stale: the native read in the same transaction sees the update (witness 2, S3.13): $SNATQ · $SNAT"
  l='em.refresh(ravi)'; two "$T" "$l" 1 "stale refresh"; b=$(call "$T" "$l"); SREF=$(res "$b")
  [ "$(sqll "$b")" = "$SELC where ce1_0.id=?" ] && [ "$SREF" = 'mealsPerDay 3' ] || die "stale: refresh - one SELECT, the new value: $SREF"
  l='a second connection, after the commit'; two "$T" "$l" 0 "stale after commit"; SC2=$(res "$(call "$T" "$l")")
  [ "$SC2" = 'the second connection reads 1 | Ravi | VEG | 3 | 120' ] || die "stale: the second connection after the commit (witness 3, S3.13): $SC2"
  # S3.13: the three witnesses read together - the object against the native read, the native read against the committed row
  [ "${SOB#mealsPerDay }" != "${SOB}" ] && [ "${SOB%% ·*}" != "mealsPerDay ${SNAT#meals_per_day }" ] && [ "$(printf '%s\n' "$SC2" | awk -F' [|] ' '{ print $4 }')" = "${SNAT#meals_per_day }" ] || die "stale: S3.13 - the object must disagree with the native read, and the native read agree with the second connection after the commit"
  [ "$(txc "$T" 'Initiating transaction commit')" = 1 ] || die "stale: the TransactionTemplate's transaction committed (S3.2)"
  ver stale 1
  has "$T" '  PROBE after the commit, every customer: [1 | Ravi | VEG | 3 | 120, 2 | Meera | NON_VEG | 1 | 150, 3 | Sunil | VEG | 4 | 100, 4 | Priya | VEGAN | 1 | 120]' "stale: the two vegetarian customers changed, the others not"
  echo "  stale: findById(1) - $SLD; bump(VEG) - $SB, $SBR; the object - $SOB; findById again - $SAG, statements $SAGN; before the commit - $SC1; the native read in the transaction - $SNAT; refresh - $SREF; after the commit - $SC2"; }
CBO=""; CBA=""; CAO=""; CAA=""; CAS=""; CAN=""
chk_clear() { local B A1 A2 x
  ver clear 3
  B=$(blk clear 'B - ' 'A - '); A1=$(blk clear 'A - ' "A' - "); A2=$(blk clear "A' - " '')
  two "$B" 'bump(VEG)' 1 "clear B"; [ "$(sqll "$(call "$B" 'bump(VEG)')")" = "$BULKX" ] || die "clear B: the bulk update"
  two "$B" 'findById(1) again' 0 "clear B findById again"
  CBO=$(res "$(call "$B" 'the Ravi object')"); CBA=$(res "$(call "$B" 'findById(1) again')")
  [ "$CBO" = 'mealsPerDay 2 · em.contains(ravi) true' ] && [ "$CBA" = 'mealsPerDay 2 · same instance true' ] || die "clear B: bump - the stale context: $CBO · $CBA"
  for x in "$A1" "$A2"; do two "$x" 'bumpClear(VEG)' 1 "clear A/A'"; [ "$(sqll "$(call "$x" 'bumpClear(VEG)')")" = "$BULKX" ] || die "clear A: the same bulk update"
    two "$x" 'findById(1) again' 1 "clear A/A' findById again"
    [ "$(sqll "$(call "$x" 'findById(1) again')")" = "$SELC where ce1_0.id=?" ] || die "clear A: findById runs a SELECT"
    [ "$(res "$(call "$x" 'the Ravi object')")" = 'mealsPerDay 2 · em.contains(ravi) false' ] && [ "$(res "$(call "$x" 'findById(1) again')")" = 'mealsPerDay 3 · same instance false' ] || die "clear A/A': bumpClear - the object detached, still the old value; findById a new instance, the new value"; done
  [ "$(printf '%s\n' "$A1" | sed 1d)" = "$(printf '%s\n' "$A2" | sed 1d)" ] || die "clear A': A again prints what A printed (R.1)"
  CAO=$(res "$(call "$A1" 'the Ravi object')"); CAA=$(res "$(call "$A1" 'findById(1) again')"); CAS=$(sqll "$(call "$A1" 'findById(1) again')"); CAN=1
  echo "  clear: B bump - the object $CBO, findById again $CBA (0 statements); A and A' bumpClear - the object $CAO, findById again $CAN statement ($CAS), $CAA"; }
FMODE=""; FSC=""; FST=""; FENT=""; FBULK=""; FC2=""
chk_flush() { local v b x c st prev="" ctn
  ver flush 3
  for v in bump bumpClear bumpFlush; do
    b=$(blk flush "the pending change, then $v(VEG)" 'the pending change, then ')
    has "$b" '  PROBE the flush mode, in the transaction (EntityManager.getFlushMode()): AUTO' "flush $v: the flush mode"
    has "$b" '  PROBE meera.setMealsPerDay(3) - the object changed, no flush, no save; the second connection reads 2 | Meera | NON_VEG | 1 | 150' "flush $v: Meera changed in the object only"
    two "$b" "$v(VEG)" 2 "flush $v"; x=$(call "$b" "$v(VEG)")
    # the ORDER: the entity's UPDATE first, the bulk statement second - read off the log, line by line
    [ "$(sqll "$x" | sed -n 1p)" = "$ENTX" ] && [ "$(sqll "$x" | sed -n 2p)" = "$BULKX" ] || die "flush $v: the pending change's UPDATE runs BEFORE the bulk statement - read off the log: $(sqll "$x" | paste -sd'|' -)"
    printf '%s\n' "$x" | $G -qE '^  PROBE <<< .* · entity updates 1 · ' || die "flush $v: Statistics counts one entity update"
    [ "$(res "$x")" = '2 rows updated' ] || die "flush $v: the bulk update's rows"
    case $v in bumpClear) ctn=false ;; *) ctn=true ;; esac
    [ "$(res "$(call "$b" 'the Meera object')")" = "mealsPerDay 3 · em.contains(meera) $ctn" ] || die "flush $v: the Meera object after the bulk update"
    [ "$(res "$(call "$b" 'a second connection, after the commit')")" = 'the second connection reads 2 | Meera | NON_VEG | 3 | 150' ] || die "flush $v: the change is in the database after the commit - not lost (READ FIRST 9)"
    st=$(sqll "$x" | paste -sd'|' -); [ -z "$prev" ] || [ "$st" = "$prev" ] || die "flush: bump, bumpClear and bumpFlush ran the same statements in the same order"; prev=$st; done
  FMODE=AUTO; FENT=$ENTX; FBULK=$BULKX; FC2='the second connection reads 2 | Meera | NON_VEG | 3 | 150'
  FSC="Hibernate $(printf '%s\n' "$VERL" | sed 's/.*: //'), flush mode $FMODE"
  # the claims this capture contradicts (READ FIRST 9, the brief's flush beat): never said in this unit's prose
  local bad; bad=$($G -niE 'clearAutomatically[^.]{0,40}(loses|lose|lost|drops|discards|throws away|forgets)|flushAutomatically[^.]{0,30}(is |was )?(useless|redundant|pointless|never needed|does nothing)' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vE '"(clearAutomatically|flushAutomatically)[^"]*"' | cut -c1-160 | head -3 | paste -sd';' - || true)
  [ -z "$bad" ] || die "a line of the prose says what flush contradicts - on $FSC the pending change's UPDATE ran before the bulk statement under bump, bumpClear and bumpFlush alike: $bad"
  echo "  flush: $FSC - under bump, bumpClear and bumpFlush alike: $FENT, then $FBULK; Meera after the commit - $FC2"; }
CE=""; CEC=""; CET=""; CES=""; C2S=""; C2B=""; C2A=""; C3S=""; C3A=""; C3B=""; CFB=""; CFA=""; CFN=""; CFSEL=""; CFDEL=""; CFPS=""; CFPD=""; CFCD=""; CF2S=""; CF2A=""; CF2B=""; CEH=""; C3H=""
LE="E: deleteById(3) - Sunil, TiffinBox's CustomerEntity: his pause holds a foreign key to him, and pauses has no cascade"
L3='E3: bulkDelete("Ravi") - delete from CCustomer c where c.name = :n, in a TransactionTemplate'
DIVE=org.springframework.dao.DataIntegrityViolationException
HCVE=org.hibernate.exception.ConstraintViolationException
H2CVE=org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException
chk_cascade() { local K b c x n
  K=$(cat .r-cascade.out); ver cascade 1
  # E: the anchor's deleteById - no cascade on pauses: the FK refusal, rolled back, Sunil kept
  CES=$(stn "$K" "$LE"); b=$(call "$K" "$LE")
  [ "$(sqll "$b" | sed -n 1p)" = "$SELC where ce1_0.id=?" ] && [ "$(sqll "$b" | sed -n 2p)" = 'delete from customer where id=?' ] && [ "$CES" = 2 ] || die "cascade E: deleteById - one SELECT, then the DELETE: $(sqll "$b" | paste -sd'|' -)"
  CE=$(thr "$b"); CEC=$(fca "$b"); CET=$(thn "$b" | head -1)
  [ "${CE%%: *}" = "$DIVE" ] && [ "${CEC%%: *}" = "$HCVE" ] && [ "${CET%%: *}" = "$H2CVE" ] || die "cascade E: $DIVE <- $HCVE <- $H2CVE (S3.10): ${CE%%: *} <- ${CEC%%: *} <- ${CET%%: *}"
  CEH='Referential integrity constraint violation: "CONSTRAINT_<n>: PUBLIC.PAUSE FOREIGN KEY(CUSTOMER_ID) REFERENCES PUBLIC.CUSTOMER(ID) (CAST(3 AS BIGINT))"'
  case "${CET#*: }" in "$CEH; SQL statement: ⏎ delete from customer where id=? [23503-250]") ;; *) die "cascade E: H2's message, its generated constraint name masked (the brief's hazard): ${CET#*: }" ;; esac
  [ "$(txc "$b" 'Creating new transaction with name [org.springframework.data.jpa.repository.support.SimpleJpaRepository.deleteById]')" = 1 ] && [ "$(txc "$b" 'Initiating transaction rollback after commit exception')" = 1 ] || die "cascade E: deleteById's own transaction, rolled back after the commit failed (S3.2)"
  has "$K" "  PROBE after E, customer: $SEEDT · pause: $SEEDP" "cascade E: Sunil and his pause kept"
  # E2: the cascade pair by entity - children first
  has "$K" '  PROBE the pair seeded through cc.save (Kavya, two pauses; the cascade inserts them), read back: c_customer 1 · c_pause 2' "cascade E2: the pair seeded"
  C2B='c_customer 1 · c_pause 2'
  x=$(sed -n 's/^  PROBE >>> \(E2: deleteById([0-9]*) - Kavya, the cascade pair.s customer\)$/\1/p' .r-cascade.out)
  [ -n "$x" ] || die "cascade E2: no call"; C2S=$(stn "$K" "$x"); b=$(call "$K" "$x")
  [ "$(sqll "$b" | paste -sd'|' -)" = 'select c1_0.id,c1_0.name from c_customer c1_0 where c1_0.id=?|select p1_0.customer_id,p1_0.id,p1_0.days from c_pause p1_0 where p1_0.customer_id=?|delete from c_pause where id=?|delete from c_pause where id=?|delete from c_customer where id=?' ] || die "cascade E2: deleteById on the pair - the customer, its pauses, each pause deleted, then the customer: $(sqll "$b" | paste -sd'|' -)"
  C2A=$(sed -n 's/^  PROBE after E2: //p' .r-cascade.out); [ "$C2A" = 'c_customer 0 · c_pause 0' ] || die "cascade E2: rows read back: $C2A"
  # E3: the JPQL bulk delete - no cascade: the FK refusal, rolled back, pauses kept
  has "$K" '  PROBE the pair seeded through cc.save (Ravi, two pauses), read back: c_customer 1 · c_pause 2' "cascade E3: the pair seeded"
  C3B='c_customer 1 · c_pause 2'
  two "$K" "$L3" 1 "cascade E3"; b=$(call "$K" "$L3"); C3S=$(sqll "$b")
  [ "$C3S" = 'delete from c_customer c1_0 where c1_0.name=?' ] || die "cascade E3: the bulk delete's SQL: $C3S"
  c=$(thr "$b"); x=$(fca "$b"); n=$(thn "$b" | head -1)
  [ "${c%%: *}" = "$DIVE" ] && [ "${x%%: *}" = "$HCVE" ] && [ "${n%%: *}" = "$H2CVE" ] || die "cascade E3: the FK refusal's chain (S3.10)"
  C3H='Referential integrity constraint violation: "CONSTRAINT_<n>: PUBLIC.C_PAUSE FOREIGN KEY(CUSTOMER_ID) REFERENCES PUBLIC.C_CUSTOMER(ID) (CAST(2 AS BIGINT))"'
  case "${n#*: }" in "$C3H; SQL statement: ⏎ delete from c_customer c1_0 where c1_0.name=? [23503-250]") ;; *) die "cascade E3: H2's message, masked: ${n#*: }" ;; esac
  [ "$(txc "$b" 'Initiating transaction rollback')" = 1 ] || die "cascade E3: rolled back (S3.2)"
  C3A=$(sed -n 's/^  PROBE after E3: //p' .r-cascade.out); [ "$C3A" = "$C3B" ] || die "cascade E3: the pauses kept: $C3A"
  # F: deleteAll() on rows it seeds itself (RED #926) - printed before: 3 and 3
  CFB=$(sed -n 's/^  PROBE F: a fresh state - .*; read back: //p' .r-cascade.out)
  [ "$CFB" = 'c_customer 3 · c_pause 3' ] || die "cascade F: deleteAll() runs on the rows its own step seeded, printed first: c_customer 3 · c_pause 3 (RED #926): ${CFB:-none}"
  CFN=$(stn "$K" 'F: deleteAll()'); b=$(call "$K" 'F: deleteAll()')
  CFSEL=$(sqll "$b" | $G -c '^select ' || true); CFDEL=$(sqll "$b" | $G -c '^delete ' || true)
  CFPS=$(sqll "$b" | $G -cxF 'select p1_0.customer_id,p1_0.id,p1_0.days from c_pause p1_0 where p1_0.customer_id=?' || true)
  CFPD=$(sqll "$b" | $G -cxF 'delete from c_pause where id=?' || true); CFCD=$(sqll "$b" | $G -cxF 'delete from c_customer where id=?' || true)
  local nc np; nc=$(printf '%s\n' "$CFB" | sed 's/^c_customer \([0-9]*\) · .*/\1/'); np=$(printf '%s\n' "$CFB" | sed 's/.* c_pause \([0-9]*\)$/\1/')
  [ "$(sqll "$b" | sed -n 1p)" = 'select c1_0.id,c1_0.name from c_customer c1_0' ] && [ "$CFPS" = "$nc" ] && [ "$CFSEL" = $((1 + nc)) ] && [ "$CFPD" = "$np" ] && [ "$CFCD" = "$nc" ] && [ "$CFDEL" = $((np + nc)) ] && [ "$CFN" = $((CFSEL + CFDEL)) ] || die "cascade F: deleteAll() - one SELECT of every customer, one SELECT of pauses per customer, then every pause and every customer deleted one by one: $(sqll "$b" | sort | uniq -c | paste -sd';' -)"
  CFA=$(sed -n 's/^  PROBE after F: //p' .r-cascade.out); [ "$CFA" = 'c_customer 0 · c_pause 0' ] || die "cascade F: rows read back: $CFA"
  # F2: deleteAllInBatch() on a fresh seeded state - one bulk statement, the FK refusal, rows kept
  CF2B=$(sed -n 's/^  PROBE F2: a fresh state, seeded the same way; read back: //p' .r-cascade.out)
  [ "$CF2B" = 'c_customer 3 · c_pause 3' ] || die "cascade F2: a fresh state, 3 and 3: ${CF2B:-none}"
  two "$K" 'F2: deleteAllInBatch()' 1 "cascade F2"; b=$(call "$K" 'F2: deleteAllInBatch()'); CF2S=$(sqll "$b")
  [ "$CF2S" = 'delete from c_customer c1_0' ] || die "cascade F2: one bulk delete: $CF2S"
  c=$(thr "$b"); x=$(fca "$b"); [ "${c%%: *}" = "$DIVE" ] && [ "${x%%: *}" = "$HCVE" ] || die "cascade F2: the FK refusal"
  CF2A=$(sed -n 's/^  PROBE after F2: //p' .r-cascade.out); [ "$CF2A" = "$CF2B" ] || die "cascade F2: rows kept: $CF2A"
  echo "  cascade: E deleteById(3) - $CES statements, ${CE%%: *} <- ${CEC%%: *} <- ${CET%%: *}, rolled back, Sunil kept; E2 deleteById on the pair - $C2S statements ($C2B -> $C2A); E3 bulkDelete - $C3S, refused, $C3A kept; F deleteAll() on $CFB - $CFSEL SELECTs + $CFDEL DELETEs = $CFN, $CFA; F2 deleteAllInBatch() on $CF2B - $CF2S, refused, $CF2A kept"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: yes")" = 1 ] || die "xcheck: the harness's script must be Boot's for the anchor's entities, md5 $X09 (R.212) - a mapping moved"
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ' || true)" = 3 ] || die "xcheck: two create table lines and one alter table"
  ! printf '%s\n' "$XC" | $G -q 'c_customer\|c_pause' || die "xcheck: the cascade pair is not the anchor's - it must not be in the script"
  echo "  xcheck: the harness's script (@EntityScan(\"com.tiffinbox\") alone), md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README raises everyone's meals with one update and then reads Ravi's old number. Make the next read come from the database."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXB=""; EXBN=""; EXS=""; EXSN=""; EXU=""
chk_exercise() { local EB EZ b ER ES w
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    PROBE Ravi before the update: mealsPerDay 2'; do has "$ER" "$l" "exercise: the README runs"; has "$ES" "$l" "exercise: the solution runs"; done
    EXU=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE the update changed \([0-9]*\) rows$/\1/p')
    [ -n "$EXU" ] && [ "$(printf '%s\n' "$ES" | sed -n 's/^    PROBE the update changed \([0-9]*\) rows$/\1/p')" = "$EXU" ] || die "exercise: the update's row count, the same in both runs"
    # broken = stale's findById again: the old value, no statement; solved = clear A's: one statement, the new value
    EXB=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE findById(1) after the update: mealsPerDay \([0-9]*\) · statements it ran: [0-9]*$/\1/p')
    EXBN=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE findById(1) after the update: mealsPerDay [0-9]* · statements it ran: \([0-9]*\)$/\1/p')
    [ -n "$EXB" ] && [ "mealsPerDay $EXB · same instance true" = "$SAG" ] && [ "$EXBN" = "$SAGN" ] || die "exercise: the README's read is stale's findById again ($SAG, $SAGN statements): ${EXB:-none} · ${EXBN:-none}"
    EXS=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE findById(1) after the update: mealsPerDay \([0-9]*\) · statements it ran: [0-9]*$/\1/p')
    EXSN=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE findById(1) after the update: mealsPerDay [0-9]* · statements it ran: \([0-9]*\)$/\1/p')
    [ -n "$EXS" ] && [ "mealsPerDay $EXS · same instance false" = "$CAA" ] && [ "$EXSN" = "$CAN" ] || die "exercise: the solution's read is clear A's findById again ($CAA, $CAN statement): ${EXS:-none} · ${EXSN:-none}"
    [ "$EXB" != "$EXS" ] && [ "$EXBN" != "$EXSN" ] || die "exercise: broken and solved must differ - by the value read and the statement it ran, never the exit code"
    nhas "$b" 'PROBE threw' "exercise: neither run fails - the stale read is silent"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  # each file's "What it prints" block is what the run printed, line for line (never a placeholder: unit 16 shipped two)
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qxF '    @Modifying' harness/src/probe/q/ex/ExApp.java && ! $G -qF 'clearAutomatically' harness/src/probe/q/ex/ExApp.java || die "exercise: ExApp ships the plain @Modifying - the stale read"
  echo "  exercise: bash and zsh alike - the README as written (@Modifying): exit 0, the update changed $EXU rows, findById(1) - mealsPerDay $EXB, $EXBN statements (= stale's); the solution (one line: @Modifying(clearAutomatically = true)): exit 0, mealsPerDay $EXS, $EXSN statement (= clear A's); each file's What it prints = the run; $EXW words"; }
cap notx notx; chk_notx; pub notx
cap stale stale; chk_stale; pub stale
cap clear clear; chk_clear; pub clear
cap flush flush; chk_flush; pub flush
cap cascade cascade; chk_cascade; pub cascade
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise

# the values the video says are the captures', never typed: README.md states them in one line, composed here from what the checks read
VS="the values the video may say: notx, on Spring Data JPA 4.1.2 - B bump(VEG) with no transaction of the caller's: ${NB%%: *}: ${NB#*: } <- first cause ${NBC%%: *}: ${NBC#*: }; 0 statements; JpaTransactionManager: no line · A bumpTx(VEG): Creating new transaction with name [$NAT]; $BULKX; 1 statement; $NAR · C bumpNoModifying(VEG): ${NC%%: *}: ${NC#*: } <- first cause ${NCC%%: *}; 0 statements; rolled back · stale (one transaction): findById(1) -> $SLD · bump(VEG) -> $SB -> $SBR ($SBN statement) · the Ravi object -> $SOB · findById(1) again -> $SAG ($SAGN statements) · before the commit, $SC1 · the native read in the same transaction ($SNATQ) -> $SNAT · em.refresh -> $SREF · after the commit, $SC2 · clear: B bump -> $CBO; findById again $CBA · A bumpClear -> $CAO; findById again ($CAN statement: $CAS) -> $CAA · flush, $FSC: Meera changed in the object, then bump, bumpClear and bumpFlush alike ran $FENT, then $FBULK; after the commit, $FC2 · cascade: deleteById(3) (Sunil, no cascade) -> $CES statements, ${CE%%: *} <- ${CEC%%: *} <- ${CET%%: *}, $CEH, rolled back, Sunil kept · the pair: deleteById -> $C2S statements, $C2B -> $C2A · the JPQL bulk delete -> $C3S -> ${CE%%: *}, rolled back, $C3A kept · deleteAll() on $CFB -> $CFSEL SELECTs then $CFDEL DELETEs ($CFPD c_pause, $CFCD c_customer) = $CFN statements · deleteAllInBatch() on $CF2B -> $CF2S -> ${CE%%: *}, $CF2A kept · xcheck: $X09 · exercise: @Modifying -> mealsPerDay $EXB ($EXBN statements); @Modifying(clearAutomatically = true) -> mealsPerDay $EXS ($EXSN statement) ($EXW words)"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"

# hygiene: every capture and every file this unit holds
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] || die "no harness JVM ran"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE '\$Proxy[0-9]|SessionImpl\([0-9]|scanning in [0-9]+ ms|CONSTRAINT_[0-9A-F]' "$f" || die "$f holds a proxy number, an EntityManager's identity, a scan time or an H2 constraint name, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE 'Last modified|SHA-256 checksum|Classfile ' "$f" || die "$f holds javap -v's header (a date, a checksum, a path)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'https?://' "$f" || die "$f holds a URL"; done
# every JVM: its locale pinned on its java line (S6.1), and under its alarm (R.247)
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -v '^ *\$ javap ' | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.q' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory (R.195)"
echo "  hygiene: $(ls .r-*.out | wc -l | tr -d ' ') captures, $LOGS harness JVM logs; 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, unmasked proxy number, identity or generated name, URL, javap header or stack frame in any capture; every JVM pinned and under its alarm; no H2 file"
# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 20010-20019 at the end - this unit bound none; 20019 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit22: every capture 3/3 and = published; every spoken number asserted; no port bound"
