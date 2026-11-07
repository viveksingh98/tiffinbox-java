#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · @Query: JPQL and Native - this unit's receipts. The course's seventh change to the anchor, Section 3's third and
# last (brief ⚑1, C3): CustomerEntityRepository declares two queries written by hand in JPQL - monthRevenue and pausedDays, each
# coalesce(sum(...), 0) - and CustomerRepository calls them: its SQL strings 2 -> 0. Database leaves CustomerRepository's
# constructor, and @DependsOn("database") keeps the start order that argument gave. after/ is Section 3's frozen anchor. Nine
# captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every number and string the
# video says is asserted right after its capture by a check that can fail; the demo token is masked, and the checks count 0 raw
# copies of it in every capture and every log. One database: H2 (brief ⚑2: 17 is an H2 unit), in each JVM's memory, gone with it.
#   jpql      named parameters (two harness JVMs): @Param binds; without @Param it binds on the build compiled with -parameters
#             and fails at the call on the build without (hc-nop) - class, message, first cause (R.241); javap's
#             MethodParameters read off each build, off the anchor's own classes, and Boot's parent POM's <parameters> line
#   record    a constructor expression (a harness JVM): select new ...Bill(c.name, ...) - the SQL's two columns counted, entity
#             loads 0 from Statistics (S3.8's two witnesses), the whole entity beside it
#   native    native SQL (a harness JVM): the SELECT logged as declared, rows as Object[]; a native Page with no countQuery (the
#             count Spring Data derives from the native text), with one, and with a Sort appended
#   typo      the failure receipt (two harness JVMs): B a JPQL query naming c.nmae - the start stops after the
#             EntityManagerFactory, Hibernate's UnknownPathException read off the chain (S3.9, S3.10); A' the same query with c.name
#   anchor    the anchor's own change: after/ against before/; the string count 2 -> 0 (grep -c prepareStatement); the sentences
#             that state it (S3.19, R.250); start()'s Course 4 Javadoc, read off TiffinBoxServer.java; the compiled class's
#             constructor and annotation (javap); TiffinBox A/B/A'/B' (S3.3, R.234): B = after/ without @DependsOn - the start's
#             trio, exit 1; A = after/ - ready; B' and A' the same trees built again; POST Kavya twice (201, 409 - a guard)
#   seven     before/'s jar and after/'s, the seven each with the SQL logger on (a fresh JVM each): the hash a guard (R.190); the
#             SQL logger's lines during it the witness - the two sums' SELECTs are Hibernate's on after/ alone
#   tests     TiffinBox's tests on after/ (the README's line, offline): Surefire's reports, the console's summary beside their
#             sum, and which test classes mock CustomerRepository (R.190, RED #924)
#   xcheck    Boot's own DDL script from after/'s jar against the one the owning-side lesson published (its md5): no mapping
#             moved (R.212)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f
# "The previous tree" is before/, the link to ../c7-unit16/after: the anchor after Section 3's second change. after/ is this
# unit's frozen copy of ../c7-tiffinbox after the change - Section 3's frozen anchor: units 18-22 link anchor -> ../c7-unit17/after.
# Its equality with ../c7-tiffinbox is printed at the start and the end, and a later anchor change makes it a note, never a stop
# (R.211). Every tree is COPIED under .harness/ and built there, never in place. Every run of TiffinBox starts in a folder under
# .harness/ that holds a config tree with a fake token (secrets/), listed before every start.
# The harness (harness/src, package probe.q, outside com.tiffinbox) is compiled twice against after/'s extracted jar: with javac
# -parameters into .harness/hc, and without it into .harness/hc-nop. probe.q.Main is a Spring Boot context with no web server
# (WebApplicationType.NONE: it binds no port) over after/'s libraries, @EntityScan on com.tiffinbox - the anchor's entities - and
# @EnableJpaRepositories on probe.q.repo, the harness's own interfaces (Jpql, Native); -Dq=bad or -Dq=good adds probe.q.bad or
# probe.q.good (typo); probe.q.Seed builds the shipped Database in code on the run's own H2 database, which seeds it; Hibernate
# writes no schema (ddl-auto none), its statistics are on; Logback (harness/logback.xml) prints Hibernate's SQL logger, its
# HHH000001 line, the EntityManagerFactory's line and Spring Data's scan line. It runs from .harness/run. Its JVM flags travel as
# an array, V, its arguments as an array, A (R.193). Every JVM this script starts - the harness's, TiffinBox's, the exercise's -
# runs under an alarm (perl -e 'alarm N; exec ...': macOS has no timeout); an alarm that fires is a failed receipt (R.247).
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is ../c5-unit11/curlset.sh (the seven, POST
# /shutdown with the token read from its file); harness/shutdown.sh (the CORS lesson's, byte for byte) stops a JVM;
# harness/surefire.py (the testing lesson's, byte for byte) reads Surefire's reports; harness/dur7.py (Course 7's builders'
# duration pattern, byte for byte) gates this unit's prose: it speaks no time (R.172). "$M2" is this unit's own repository, .m2-demo.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it; the test JVM's comes from the POM's argLine.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline build missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. At run time nothing leaves 127.0.0.1: every database is H2 in a JVM's memory. This unit reads no version file: the
# section's dated sweep is the brief's (R.223; _research/spring-boot-metadata-2026-11-07.xml: no 4.1.3).
# Masks (README.md declares each; awk gsub only): the demo token "[masked: the N-character token]"; this folder "…", the folder
# above it "…/..", home "~", your user name "<user>"; " using Java <version>"; an identity hash "@…"; the JDK's proxy class number
# "$Proxy<n>"; an EntityManager's identity "SessionImpl(<n><open>)"; Spring Data's scan time "scanning in <n> ms"; H2's generated
# constraint and index names "CONSTRAINT_<n>", "CONSTRAINT_INDEX_<n>". A harness JVM's log is printed whole (every line it
# prints, trailing spaces dropped); a TiffinBox log: the named loggers' lines, and a failed start's exception chain (the
# exception's line and each "Caused by:" line - no stack frame).
# Ports (§P, 19960-19969): anchor B 19960 · A 19961 · B' 19962 · POSTs 19963 · seven before/ 19964 · after/ 19965 · xcheck's
# Boot run 19966 · A' 19967 · 19968 spare · 19969 never bound. Every one is checked free at the start and the end, and so are
# 18425 (TiffinBox's default), 8080 and 35729. The harness's JVMs, the tests and the exercise bind none.
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
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "probe.q.") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 perl curl rsync lsof unzip mvn md5 cmp /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L before ] && [ "$(readlink before)" = ../c7-unit16/after ] || die "before must be the link to ../c7-unit16/after - the anchor before this change"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
# after/ is this unit's frozen tree; the anchor, ../c7-tiffinbox, equals it until a later unit changes the anchor - a note then,
# never a stop (R.211, the Course 6 form)
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox: empty - after/ = ../c7-tiffinbox"
  else echo "  (after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3; fi; }
anchornote start
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
WJ=tiffinbox-web/src/main/java/com/tiffinbox/web     # the web module's
SR=tiffinbox-web/target/surefire-reports
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
TOKEN=demo-token-for-query-jpql-and-native
[ ${#TOKEN} = 36 ] || die "the demo token must be 36 characters: the captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HS=harness/src/probe/q
HFILES='dur7.py logback.xml shutdown.sh src surefire.py'
SFILES='probe/q/Main.java probe/q/Run.java probe/q/Seed.java probe/q/Typos.java probe/q/bad/BadJpql.java probe/q/ex/ExApp.java probe/q/good/GoodJpql.java probe/q/repo/Bill.java probe/q/repo/Jpql.java probe/q/repo/Native.java'
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
PORTS="18425 8080 35729 19960 19961 19962 19963 19964 19965 19966 19967 19968 19969"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/hc-nop


# ---- the prose gates: no duration word (R.172); English names only (R.215); the claims S3.2, S3.10, R.225 and the brief refuse
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
# S3.2 (R.233): a transaction claim is JpaTransactionManager's line, never a sentence about every call - tx counts them: the
# inherited findById logs one, a declared (derived) query method logs none. A line saying that every (or each, or all)
# repository call or method runs in a transaction is refused in this unit's prose
TX=$($G -niE '(every|each|all)( [a-z]+){0,2} (call|calls|method|methods)( [a-z]+){0,3} (run|runs|is|are|happens?|executes?)( [a-z]+){0,2} (in|inside|within) an? ([a-z]+ )?transaction' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TX" ] || die "a line says every repository call runs in a transaction - S3.2 (R.233) refuses it: the derived-query lesson's tx capture shows the derived finds log none: $TX"
echo "  S3.2's refused claim (every call in a transaction): 0 lines over README.md and exercise/"
# S3.10 (R.241): an exception is read off the log as its class with its package - never typed from memory. The class Spring
# Data 4.1.2 throws for a misspelt property lives in org.springframework.data.core (typo prints it); the name under the 3.x
# package is not in spring-data-commons-4.1.2.jar, and no version is credited with it (RED #931) - refused anywhere in this
# unit's prose and harness
OLDP='org\.springframework\.data\.mapping\.PropertyReferenceException'
OP=$($G -rnE -- "$OLDP" README.md exercise harness/src 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$OP" ] || die "a line names the exception by the package it does not have on Spring Data JPA 4.1.2 - S3.10 (R.241) reads the class off the log (typo): $OP"
echo "  S3.10's refused class name: 0 lines over README.md, exercise/, harness/src"
# R.225: a count the video says is derived, never typed - the seven's Hibernate SQL lines are counted by seven and stated once,
# in the values line this script composes; a count of SQL lines typed anywhere else in the prose is refused (the brief's own
# figure among them)
NUMW='one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|[0-9]+'
TL=$($G -niE "\\b($NUMW) (org\\.hibernate\\.SQL|Hibernate|Hibernate SQL|Hibernate's SQL|SQL logger|SQL)( logger's| logger)? lines\\b" README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF 'the values the video may say:' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TL" ] || die "a typed count of SQL lines - seven counts them, and only the values line states them (R.225): $TL"
echo "  typed SQL-line counts: 0 (seven's count is in the values line only)"
# the brief's hazard (RE-MEASURE 12): that native SQL is checked at start was never run here - a line saying so is refused
NA=$($G -niE 'native( SQL| queries| query)?( [a-z]+){0,3} (is|are|gets|get) (checked|validated|verified|parsed)( [a-z]+){0,2} at (start|startup)' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$NA" ] || die "a line says native SQL is checked at start - unmeasured here (the brief's RE-MEASURE 12): $NA"
echo "  the unmeasured claim (native SQL checked at start): 0 lines over README.md and exercise/"
# S3.19 (R.250): the change moves a count - CustomerRepository's SQL strings - so every sentence that states it is rewritten with
# the count grep gives; unit 16's sentence "CustomerRepository keeps two of its five SQL strings" (CustomerEntity.java:23-24) is
# false now
word() { case $1 in 0) echo none;; 1) echo one;; 2) echo two;; 3) echo three;; 4) echo four;; 5) echo five;; *) echo "$1";; esac; }
SB=$($G -c prepareStatement "before/$CJ/CustomerRepository.java" || true); SA=$($G -c prepareStatement "after/$CJ/CustomerRepository.java" || true)
[ "$SB" = 2 ] || die "before/'s CustomerRepository holds $SB prepareStatement lines - the anchor before this change held 2"
ST=$($G -rnE 'CustomerRepository keeps (its|two of its|three of its) (five )?SQL' after/tiffinbox-core after/tiffinbox-web 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$ST" ] || die "a sentence of the anchor still says CustomerRepository keeps its SQL strings, or two or three of them - after this change it keeps $(word "$SA") of five (S3.19, R.250): $ST"
CE=$(sed -n 23,24p "after/$CJ/CustomerEntity.java" | sed 's/^ *\* *//' | paste -sd' ' -)
printf '%s\n' "$CE" | $G -qF "CustomerRepository keeps $(word "$SA") of its five SQL strings" || die "CustomerEntity.java:23-24 must state the count grep gives - keeps $(word "$SA") of its five SQL strings (S3.19, R.250): $CE"
SECT=$(awk '/^## Course 7 · unit 17 /{f=1} f && /^## / && !/unit 17 /{f=0} f' after/README.md)
[ -n "$SECT" ] || die "after/README.md has no Course 7 · unit 17 section"
# a sentence is read whole: a file's lines joined (a Javadoc's leading * dropped), split after a full stop
cat > .harness/sent.py <<'PY2'
import re, sys
for f in sys.argv[1:]:
    t = " ".join(re.sub(r"^\s*(/\*\*|\*/|\*|//)?\s*", "", l).strip() for l in open(f, encoding="utf-8"))
    for s in re.split(r"(?<=\.)\s+", t):
        if "SQL string" in s: print("%s: %s" % (f.split("/")[-1], s.strip()))
PY2
printf '%s\n' "$SECT" > .harness/section.md
SL=$(python3 -I -B .harness/sent.py after/$CJ/*.java after/$WJ/*.java .harness/section.md) || die "the sentence reader did not run"
CW=$(word "$SA"); [ "$SA" != 0 ] || CW='none|zero'
BADS=$(printf '%s\n' "$SL" | $G -v '^$' | $G -viE "\\b($CW|$SA)\\b" | cut -c1-200 | head -3 | paste -sd';' - || true)
[ -z "$BADS" ] || die "a sentence about the SQL strings does not state the count grep gives, $(word "$SA") (S3.19, R.250): $BADS"
echo "  S3.19: CustomerRepository's prepareStatement lines before/ $SB, after/ $SA; $(printf '%s\n' "$SL" | $G -c . || true) sentences about the SQL strings in after/'s sources and its README's unit 17 section, each stating $(word "$SA"); unit 16's sentence 0"
# R.224 (RED #934): start()'s Course 4 Javadoc - the sentence the B run proves - is quoted off the file: its two lines, the *
# dropped, joined; a one-line grep of the whole sentence finds it 0 times (it is split over the two lines)
TSJ=$WJ/TiffinBoxServer.java
JS="The container calls this once every constructor argument exists, so the order is its problem now, not a comment's."
TSS=$(sed -n 286,287p "after/$TSJ" | sed 's/^ *\* *//' | paste -sd' ' -)
printf '%s\n' "$TSS" | $G -qF -- "$JS" && [ "$($G -cF -- "$JS" "after/$TSJ" || true)" = 0 ] || die "TiffinBoxServer.java:286-287 must hold start()'s sentence, split over its two lines (R.224): $TSS"
[ "$(sed -n 289,290p "after/$TSJ" | sed 's/^ *//' | paste -sd'|' -)" = '@PostConstruct|void start() throws Exception {' ] || die "TiffinBoxServer.java:286-287's Javadoc must be start()'s - @PostConstruct void start() at 289-290"
echo "  R.224: TiffinBoxServer.java:286-287, joined - start()'s Javadoc holds the sentence; the whole sentence on one line: 0"

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
AL="perl -e 'alarm 240; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*\" $HS/Main.java $HS/Run.java $HS/Seed.java $HS/Typos.java $HS/bad/BadJpql.java $HS/good/GoodJpql.java $HS/repo/Bill.java $HS/repo/Jpql.java $HS/repo/Native.java")
L_JAVAC_NOP=$(mine "javac -d .harness/hc-nop -cp \".harness/after/$XD/lib/*\" $HS/Main.java $HS/Run.java $HS/Seed.java $HS/Typos.java $HS/bad/BadJpql.java $HS/good/GoodJpql.java $HS/repo/Bill.java $HS/repo/Jpql.java $HS/repo/Native.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../after/$XD/lib/*\" probe.q.Main \"\${A[@]}\"")
L_HN=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc-nop:../after/$XD/lib/*\" probe.q.Main \"\${A[@]}\"")
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug")
[ "${R_DDL#"$R_RUN "}" = "$DDLO1 $DDLO2" ] && [ "${L_SQL#"$R_RUN "}" = '--logging.level.org.hibernate.SQL=debug' ] || die "the DDL and SQL lines must be the anchor's run line with their options, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
# at DIR PORT 'LINE': the line run from DIR, its port 18431 made PORT - a java line with the JVM's locale pinned, under its alarm
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(exe "$(at .harness/x 19961 "$R_RUN")")" = "cd .harness/x && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19961" ] && [ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "at()/off(): the run lines are not the anchor README's"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures - before/ and after/, each copied and built with the README's package line offline (each runs
# ---- its tree's tests); anchor B's labelled copy, B' and A' (copies built again), each with the same line and -DskipTests;
# ---- each jar extracted (the anchor's line); the harness compiled twice, with and without -parameters ----------------------------------------------------------------------------------
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
# anchor B: after/ with @DependsOn("database") taken off CustomerRepository - that one line, asserted the only difference;
# A' and B': after/ and B's tree, each copied again and built again (R.1: a fresh build each, RED #921)
copy after .harness/anb
$G -vxF '@DependsOn("database")' "after/$CJ/CustomerRepository.java" > ".harness/anb/$CJ/CustomerRepository.java" || true
ABD=$(diff -r -x secrets after .harness/anb | $G '^[<>]' | paste -sd'|' - || true)
[ "$ABD" = '< @DependsOn("database")' ] || die "anchor B's copy must differ from after/ by CustomerRepository's @DependsOn(\"database\") line, removed, and nothing else: ${ABD:-no difference}"
copy after .harness/ana2; copy .harness/anb .harness/anb2
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (before/, the README's package line; its tests ran)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
mbuild "$(off .harness/anb "$R_PLAIN" package) -DskipTests" .harness/build-anb.log ".harness/anb (anchor B, labelled: after/ without @DependsOn; the README's package line, -DskipTests)"
mbuild "$(off .harness/anb2 "$R_PLAIN" package) -DskipTests" .harness/build-anb2.log ".harness/anb2 (anchor B', B's tree copied again; the same line)"
mbuild "$(off .harness/ana2 "$R_PLAIN" package) -DskipTests" .harness/build-ana2.log ".harness/ana2 (anchor A', after/ copied again; the same line)"
for t in before after anb anb2 ana2; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the builds - README.md, The repository"; done
(eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
(eval "$L_JAVAC_NOP") > .harness/javac-nop.log 2>&1 < /dev/null || die "the harness did not compile without -parameters: $(head -5 .harness/javac-nop.log)"
[ ! -e .harness/hc/probe/q/ex ] && [ ! -e .harness/hc-nop/probe/q/ex ] || die "the exercise's class was compiled into the harness - it is the exercise's own"
echo "  extracted five jars ($(for t in before after anb anb2 ana2; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: before/after/B/B'/A') and compiled the harness twice - into .harness/hc (javac -parameters) and .harness/hc-nop (without)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing}) - every file there is a key (R.158)"
  echo "  secrets/ before the start: $s - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { sec "$(dir "$1")"; echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
listening() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$1"); case " $a " in *":$2 "*) break ;; esac; kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened on $1"; }
  case " $l " in *':8080 '*|*':35729 '*|*':19968 '*|*':19969 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729, 19968 or 19969 - never bound by this script";; esac
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
# ended PORT TREE: a start that should fail by itself - it is waited for (bounded: 240 s, its alarm's), never asked to stop; what it
# did is printed and the capture's check reads it: it ended by itself, never listening, readiness never 200 - or it became ready,
# and then it is stopped like any other start (the check fails on that line)
ended() { local i=0 e=0 c=""
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do
    c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true)
    [ "$c" != 200 ] || break
    sleep 0.25; i=$((i + 1)); done
  if [ "$c" = 200 ]; then echo "  it did not fail: readiness answered 200 on $1"; stop "$1" "$2"; return 0; fi
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the start on $1 was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something listens on $1"
  echo "  it ended by itself: exit $LASTE · listening on $1: 0 · readiness never answered 200"; }
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
    gsub(/\$Proxy[0-9]+/, "$Proxy<n>")
    gsub(/SessionImpl\([0-9]+<open>\)/, "SessionImpl(<n><open>)")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/CONSTRAINT_INDEX_[0-9A-F]+/, "CONSTRAINT_INDEX_<n>"); gsub(/CONSTRAINT_[0-9A-F]+ /, "CONSTRAINT_<n> ")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' "$TOKEN" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'class: jdk.proxy2.$Proxy128' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_52 INDEX PUBLIC.CONSTRAINT_INDEX_5 ON PUBLIC.CUSTOMER' 'Exposing JPA transaction as JDBC [org.springframework.orm.jpa.vendor.HibernateJpaDialect$HibernateConnectionHandle@7c4697fc]' "defined in URL [jar:nested:$U/.harness/anb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar/!BOOT-INF/classes/!/com/tiffinbox/web/CustomerImport.class]" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'url=jdbc:h2:mem:<uuid> user=SA' '[masked: the 36-character token]' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'class: jdk.proxy2.$Proxy<n>' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_<n> INDEX PUBLIC.CONSTRAINT_INDEX_<n> ON PUBLIC.CUSTOMER' 'Exposing JPA transaction as JDBC [org.springframework.orm.jpa.vendor.HibernateJpaDialect$HibernateConnectionHandle@…]' 'defined in URL [jar:nested:…/.harness/anb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar/!BOOT-INF/classes/!/com/tiffinbox/web/CustomerImport.class]')" ] || die "mask: the planted JDK version, generated database name, token, folders, home, identity hash, proxy number, EntityManager identity, scan time, H2's generated names, a connection handle's identity and a jar path under this folder must be masked"
rm -f .harness/p1
# tview FILE: a TiffinBox log, in order - the named loggers' lines (level, logger: message); then the counts
TPAT='org\.hibernate\.orm\.core|org\.hibernate\.SQL|SqlExceptionHelper|TiffinBoxServer|LocalContainerEntityManagerFactoryBean|RepositoryConfigurationDelegate|SpringApplication$|LoggingFailureAnalysisReporter'
# (nosql: Hibernate's SQL lines left out - the requests' own are printed with each request)
tview() { local tp=$TPAT; [ "${2:-}" != nosql ] || tp=${TPAT/org\\.hibernate\\.SQL|/}
  awk -v pat="$tp" '
  function cut(x) { gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); sub(/[ \t]+$/, "", x); return length(x) > 260 ? substr(x, 1, 260) " … (" length(x) - 260 " more characters)" : x }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ {
    s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3)
    if (m ~ /^Starting /) next
    if (m ~ /^Started TiffinBoxServer in /) m = "Started TiffinBoxServer"
    if (lg ~ pat) print "    " $2 " " lg ": " cut(m) }' "$1"
  if $G -qxF 'APPLICATION FAILED TO START' "$1"; then echo "  Boot's failure analysis, as it printed it (from APPLICATION FAILED TO START to its last line):"
    sed -n '/^APPLICATION FAILED TO START$/,/in your configuration\.$/p' "$1" | $G -v '^$' | sed 's/^/    /'; fi
  echo "  its log's lines -$( [ "${2:-}" = nosql ] || echo " org.hibernate.SQL: $($G -cE ' org\.hibernate\.SQL +: ' "$1" || true) ·") WARN: $(lvl WARN "$1") · ERROR: $(lvl ERROR "$1") · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' "$1" || true)"; }
# the harness's arguments: this run's own H2 database (in this JVM's memory, kept while the context lives), the harness's
# Logback file, no schema written, no banner, the anchor's Thymeleaf jar not looking for templates, Hibernate's statistics on
HA=('--spring.datasource.url=jdbc:h2:mem:u17;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.hibernate.generate_statistics=true)
# hrun: the harness line (V, A set by the caller; HL the line - L_H, the build with -parameters, or L_HN), run from .harness/run; it exits by itself (its alarm: 240 s); its exit code in
# HE; its log .harness/h.log
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"
  [ "$(raw "$TOKEN" .harness/h.log)" = 0 ] || die "a harness log held the token"; }
# hview: the harness's whole log (PROBE lines, the named loggers' lines), trailing spaces dropped; then its exit code
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
unpub=""
# cap NAME FUNCTION: three runs, masked, compared; the capture's checks run next; pub NAME then compares it with receipts.md5
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
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
# ---- anchor: the change, the count, the sentences; TiffinBox over HTTP with the SQL logger on - the 409 guard, the by-name witness
lines() { wc -l < .harness/run.out | tr -d ' '; }
settle() { local a b i=0; a=$(lines); while [ $i -lt 20 ]; do sleep 0.25; b=$(lines); [ "$a" = "$b" ] && break; a=$b; i=$((i + 1)); done; }
# req CURLARGS...: one request - its status and body; then the log lines it added: org.hibernate.SQL's, and WARN/ERROR
req() { local n0 n1 c
  n0=$(lines); c="curl -s -o .harness/body -w '%{http_code}' $*"; echo "\$ $c"
  echo "  status $(eval "$c" 2> /dev/null < /dev/null || true) · body: $(awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/body)"
  settle; n1=$(lines); sed -n "$((n0 + 1)),${n1}p" .harness/run.out > .harness/req.log
  echo "  the log lines it added - org.hibernate.SQL: $($G -cE ' org\.hibernate\.SQL +: ' .harness/req.log || true) · WARN: $(lvl WARN .harness/req.log) · ERROR: $(lvl ERROR .harness/req.log):"
  awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); sub(/[ \t]+$/, "", m)
    if ($2 == "WARN" || $2 == "ERROR" || lg ~ /org\.hibernate\.SQL/) print "    " $2 " " lg ": " (length(m) > 260 ? substr(m, 1, 260) " …" : m) }' .harness/req.log; }

# ---- jpql: named parameters - @Param, and the name javac keeps (-parameters) or does not (hc-nop) ----------------------------
POM412="$M2/org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom"
mp() { javap -v -p -cp "$1" "$2" 2>&1 | $G -c '^ *MethodParameters:' || true; }
jpql() { local f
  echo "the anchor's own build - Boot's parent POM (spring-boot-starter-parent-4.1.2.pom, in \$M2), the line that turns javac's -parameters on:"
  echo "  $($G -m1 -oE '<parameters>true</parameters>' "$POM412" || echo 'no such line')"
  echo "  and the anchor's classes it compiled - MethodParameters attributes, javap -v over after/'s jar (tiffinbox-core-1.0.0.jar, extracted):"
  for f in CustomerEntityRepository CustomerRepository; do
    echo "  \$ javap -v -p -cp .harness/after/$XD/lib/tiffinbox-core-1.0.0.jar com.tiffinbox.$f | grep -c '^ *MethodParameters:'"
    echo "    $(mp ".harness/after/$XD/lib/tiffinbox-core-1.0.0.jar" com.tiffinbox.$f)"; done
  echo "the harness's two builds - probe.q.repo.Jpql's MethodParameters attributes:"
  for f in hc hc-nop; do echo "  \$ javap -v -p -cp .harness/$f probe.q.repo.Jpql | grep -c '^ *MethodParameters:'"; echo "    $(mp .harness/$f probe.q.repo.Jpql)"; done
  echo "A - the build with -parameters (.harness/hc), one harness JVM:"
  V=(-Ds=jpql); A=("${HA[@]}"); HL=$L_H; hrun; hview
  echo "B - the build without -parameters (.harness/hc-nop), one harness JVM:"
  V=(-Ds=jpql); A=("${HA[@]}"); HL=$L_HN; hrun; hview; HL=""; }

# ---- record: a constructor expression - the record straight out of the query; the entity beside it ---------------------------
record() { echo "the constructor expression, then the whole entity beside it - one harness JVM (.harness/hc):"
  V=(-Ds=record); A=("${HA[@]}"); HL=$L_H; hrun; hview; HL=""; }

# ---- native: native SQL as written; a native page, its count derived, given; a Sort appended --------------------------------
natives() { echo "native SQL - one harness JVM (.harness/hc):"
  V=(-Ds=native); A=("${HA[@]}"); HL=$L_H; hrun; hview; HL=""; }

# ---- typo: a misspelt field in JPQL - B (the failure receipt), A' the field spelt right ------------------------------------
typo() { local m
  echo "B - -Dq=bad adds probe.q.bad: BadJpql, its query 'select c from CustomerEntity c where c.nmae = :name' (one harness JVM, .harness/hc) - the failure receipt:"
  V=(-Ds=typo -Dq=bad); A=("${HA[@]}"); HL=$L_H; hrun; hview
  echo "A' - -Dq=good adds probe.q.good: GoodJpql, the same query with c.name (one harness JVM, .harness/hc):"
  V=(-Ds=typo -Dq=good); A=("${HA[@]}"); hrun; hview; HL=""
  m="No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'"
  echo "beside it - Spring Data's parser on a misspelt derived name, as the derived-query lesson's README states it (that lesson's typo capture, published $(awk '$1 == "typo" { print $2 }' ../c7-unit16/receipts.md5 2> /dev/null)):"
  echo "  $($G -m1 -oF -- "$m" ../c7-unit16/README.md || echo 'not in that README')"; }

# exc FILE: a failed start's exception chain, as the log printed it - the line after Boot's "Application run failed" and each
# "Caused by:" line (no stack frame, no "... common frames omitted" line)
exc() { awk '/ ERROR [0-9]+ --- \[.*\] o\.s\.boot\.SpringApplication +: Application run failed$/ { f = 1; next }
  f == 1 && NF { print "    " $0; f = 2; next } f == 2 && /^Caused by: / { sub(/[ \t]+$/, ""); print "    " $0 }' "$1"
  echo "  the chain's lines: $(awk '/Application run failed$/ { f = 1; next } f == 1 && NF { n++; f = 2; next } f == 2 && /^Caused by: / { n++ } END { print n + 0 }' "$1") · the log's order - Initialized JPA EntityManagerFactory at line $($G -n -m1 'Initialized JPA EntityManagerFactory' "$1" | cut -d: -f1 || true), Exception encountered during context initialization at line $($G -n -m1 'Exception encountered during context initialization' "$1" | cut -d: -f1 || true), Application run failed at line $($G -n -m1 'Application run failed' "$1" | cut -d: -f1 || true)"; }

# ---- anchor: the change, the count, the sentences, the compiled class; TiffinBox A/B/A'/B' (S3.3); the 409 guard -------------
# jw TREE: CustomerRepository as compiled into TREE's jar (its lib/'s tiffinbox-core-1.0.0.jar, extracted) - javap -v -p
jw() { local o; o=$(javap -v -p -cp ".harness/$1/$XD/lib/tiffinbox-core-1.0.0.jar" com.tiffinbox.CustomerRepository 2>&1)
  echo "  $1/: \$ javap -v -p -cp .harness/$1/$XD/lib/tiffinbox-core-1.0.0.jar com.tiffinbox.CustomerRepository"
  echo "    its constructor: $(printf '%s\n' "$o" | $G -m1 -E '^  public com\.tiffinbox\.CustomerRepository\(' | sed 's/^ *//; s/;$//')"
  echo "    its class annotations naming DependsOn: $(printf '%s\n' "$o" | $G -cE '^ *org\.springframework\.context\.annotation\.DependsOn(\(|$)' || true) · their value: $(printf '%s\n' "$o" | sed -n '/^ *org\.springframework\.context\.annotation\.DependsOn/,/)/p' | $G -oE 'value=\[[^]]*\]' | head -1 || true)"
  echo "    constant-pool references to java.sql.Connection.prepareStatement: $(printf '%s\n' "$o" | $G -cE '^ *#[0-9]+ = InterfaceMethodref .*// java/sql/Connection\.prepareStatement' || true) · to com.tiffinbox.Database: $(printf '%s\n' "$o" | $G -cE '^ *#[0-9]+ = Class .*// com/tiffinbox/Database$' || true)"; }
anchor() { local f B
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#; s#^Only in after/(.*): (.*)$#  \1/\2 (new)#' | sort
  for f in $CJ/CustomerEntityRepository.java $CJ/CustomerRepository.java $CJ/CustomerEntity.java; do echo "$f:"; cdiff "before/$f" "after/$f"; done
  echo "$CJ/CustomerEntityRepository.java - its code lines (no comments):"
  $G -vE '^ *(/\*\*|\*|\*/)' "after/$CJ/CustomerEntityRepository.java" | $G -v '^$' | sed 's/^/    /'
  echo "the strings - \$ grep -c prepareStatement before/$CJ/CustomerRepository.java after/$CJ/CustomerRepository.java"
  $G -c prepareStatement "before/$CJ/CustomerRepository.java" "after/$CJ/CustomerRepository.java" | sed 's/^/  /' || true
  echo "the sentences that state the count (S3.19) - each sentence with 'SQL string' in after/'s Java sources (a Javadoc read whole), then in after/README.md's unit 17 section (section.md):"
  printf '%s\n' "$SL" | sed 's/^/  /'
  echo "the start's order, in start()'s Javadoc as Course 4 wrote it - $TSJ:286-287, the * dropped, the two lines joined:"
  echo "  $TSS"
  echo "the compiled class - CustomerRepository in each tree's jar:"
  jw before; jw after
  echo "B - labelled: after/ with CustomerRepository's @DependsOn(\"database\") taken off (.harness/anb, built), port 19960 - the failure receipt:"
  start "$(at .harness/anb 19960 "$R_RUN")"; ended 19960 .harness/anb; logtok; tview .harness/run.out
  echo "  the exception, as the log printed it (its line, then each Caused by: line):"; exc .harness/run.out; rm -f .harness/run.out
  echo "A - after/'s jar (@DependsOn(\"database\")), port 19961:"
  start "$(at .harness/after 19961 "$R_RUN")"; up 19961; ready 19961; stop 19961 .harness/after; logtok; tview .harness/run.out; rm -f .harness/run.out
  echo "B' - B's tree copied again and built again (.harness/anb2), port 19962:"
  start "$(at .harness/anb2 19962 "$R_RUN")"; ended 19962 .harness/anb2; logtok; tview .harness/run.out
  echo "  the exception, as the log printed it (its line, then each Caused by: line):"; exc .harness/run.out; rm -f .harness/run.out
  echo "A' - after/ copied again and built again (.harness/ana2), port 19967:"
  start "$(at .harness/ana2 19967 "$R_RUN")"; up 19967; ready 19967; stop 19967 .harness/ana2; logtok; tview .harness/run.out; rm -f .harness/run.out
  B='http://127.0.0.1:19963'
  echo "TiffinBox - after/'s jar, port 19963, its own H2, Hibernate's SQL logger on (the README's line with one option) - the 409 path, a guard:"
  start "$(at .harness/after 19963 "$L_SQL")"; up 19963; ready 19963
  req -H "'Content-Type: application/json'" -d "'{\"name\":\"Kavya\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'" "$B/customers"
  req -H "'Content-Type: application/json'" -d "'{\"name\":\"Kavya\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'" "$B/customers"
  stop 19963 .harness/after; logtok; tview .harness/run.out nosql; rm -f .harness/run.out; }

# ---- seven: the H2 regression - both trees' jars, the SQL logger on (a guard, R.190: the seven has no by-name route) ---------
# sqlseg FROM TO: org.hibernate.SQL lines in .harness/run.out's lines FROM..TO
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t p n0 ns
  for t in before:19964 after:19965; do p=${t#*:}; t=${t%:*}
    echo "the seven - $t/'s jar, port $p, a fresh JVM, Hibernate's SQL logger on:"
    start "$(at .harness/$t $p "$L_SQL")"; up $p; ready $p; n0=$(lines)
    echo "\$ \$CURLSET $p .harness/$t/$TF"
    "$CURLSET" $p ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    $G '^POST ' .harness/seven-$t.txt | sed 's/^/  /' || echo "  (no POST line)"
    gone $p
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"
    echo "  its log - Spring Data's scan: $($G -m1 -oE 'Found [0-9]+ JPA repository interfaces?\.' .harness/run.out || echo 'no scan line') · HHH000001: $($G -m1 -oE 'HHH000001: Hibernate ORM core version [^ ]+' .harness/run.out || echo none)"
    ns=$($G -n -m1 'Started TiffinBoxServer in ' .harness/run.out | cut -d: -f1); [ -n "$ns" ] || die "no Started line in the $t run's log"
    echo "  its log's org.hibernate.SQL lines: $($G -cE ' org\.hibernate\.SQL +: ' .harness/run.out || true) in all - before Started TiffinBoxServer (the start): $(sqlseg 1 "$ns") · from there to readiness's 200 (the readiness group's kitchen check): $(sqlseg "$ns" "$n0") · during the seven: $(sqlseg "$((n0 + 1))" '$')"
    echo "  the statements during the seven, each with how often:"
    sed -n "$((n0 + 1)),\$p" .harness/run.out | sed -n -E 's/^.* org\.hibernate\.SQL +: (.*)$/\1/p' | sort | uniq -c | sed -E 's/^ *([0-9]+) (.*)$/    \1 x \2/'
    logtok; done
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
  echo "  in the tests' log - Spring Data's scan lines that say Found 1 JPA repository interface: $($G -c 'Found 1 JPA repository interface\.' .harness/tests.log || true) · Initialized JPA EntityManagerFactory: $($G -c 'Initialized JPA EntityManagerFactory' .harness/tests.log || true)"
  echo "  which test classes run the real CustomerRepository - each test source's @MockitoBean CustomerRepository lines (R.190, RED #924):"
  for c in TiffinBoxWebTest FullStackTest FeedTest; do echo "    $c.java: $($G -c '^ *@MockitoBean CustomerRepository ' .harness/tests/tiffinbox-web/src/test/java/com/tiffinbox/web/$c.java || true)"; done
  echo "  its log's WARN lines: $(lvl WARN .harness/tests.log) · ERROR lines: $(lvl ERROR .harness/tests.log) · the demo token in it and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }

# ---- xcheck: Boot's DDL script from after/'s jar against the owning-side lesson's ---------------------------------------------
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
xcheck() {
  echo "Boot's DDL - after/'s jar with the anchor README's DDL line (a file, never run), port 19966:"
  rm -f .harness/after/hibernate-ddl.sql
  start "$(at .harness/after 19966 "$R_DDL")"; up 19966; ready 19966; stop 19966 .harness/after; logtok
  echo "  .harness/after/hibernate-ddl.sql - every line:"; sed 's/^/    /' .harness/after/hibernate-ddl.sql
  echo "  its md5: $(md5 -q .harness/after/hibernate-ddl.sql) · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times): $X09 · the same: $( [ "$(md5 -q .harness/after/hibernate-ddl.sql)" = "$X09" ] && echo yes || echo no)"
  rm -f .harness/after/hibernate-ddl.sql; }

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
DBL='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:u17;DB_CLOSE_DELAY=-1'
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type): [1 | Ravi | VEG, 2 | Meera | NON_VEG, 3 | Sunil | VEG, 4 | Priya | VEGAN]'
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] || die "$1: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its $2 harness JVMs (R.222, S3.15/R.246)"
  [ "$(cnt "$c" "$DBL")" = "$2" ] && [ "$(cnt "$c" "$SEEDL")" = "$2" ] || die "$1: the database: line, H2 2.5.250, and the shipped seed, in each of its $2 harness JVMs (R.217: this unit speaks for H2 only)"; }
# R.184: a statement count has two witnesses from one call - the SQL logger's lines between ">>> label" and "<<< label", and
# Hibernate's Statistics for that call (getPrepareStatementCount, printed on the "<<<" line)
call() { printf '%s\n' "$1" | awk -v a="  PROBE >>> $2" -v b="  PROBE <<< $2 · " 'index($0, a) == 1 && length($0) == length(a) { f = 1 } f { print } f && index($0, b) == 1 { f = 0 }'; }
sqll() { printf '%s\n' "$1" | $G '^  DEBUG org\.hibernate\.SQL : ' | sed 's/^  DEBUG org\.hibernate\.SQL : //' || true; }
two() { local b n p; b=$(call "$1" "$2"); [ -n "$b" ] || die "$4: no call named $2"
  n=$(sqll "$b" | $G -c . || true); p=$(printf '%s\n' "$b" | sed -n 's/^  PROBE <<< .* · statements (getPrepareStatementCount) \([0-9]*\) · .*/\1/p')
  [ "$n" = "$3" ] && [ "$p" = "$3" ] || die "$4: $3 statements - the SQL log's lines ($n) and getPrepareStatementCount() (${p:-none}) both (R.184)"; }
txl() { printf '%s\n' "$(call "$1" "$2")" | $G -c 'JpaTransactionManager : Creating new transaction with name ' || true; }
SELC='select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0'
INS='insert into customer (meal_type,meals_per_day,name,price_per_meal,id) values (?,?,?,?,default)'
# the README's query table: one row per call - the call, the query as its @Query declares it (read off the class by the JVM),
# the SQL Hibernate's logger printed for it, what it returned - composed from jpql, record and native, never typed
QROWS=""; QN=0
qrow() { local r; r="| \`$1\` | \`$2\` | $3 | \`${4//|/\\|}\` |"; QROWS="$QROWS$r
"; QN=$((QN + 1)); }
sqlcode() { printf '%s\n' "$1" | sed 's/.*/`&`/' | paste -sd'+' - | sed 's/+/ then /g'; }
decl() { printf '%s\n' "$1" | sed -n "s/^  PROBE declared $2: //p"; }
# cols SQL: the columns in a SELECT's select list, counted at its top level (S3.8)
cols() { printf '%s\n' "$1" | awk '{ s = $0; sub(/^select /, "", s); i = index(s, " from "); s = substr(s, 1, i - 1); d = 0; n = 1
  for (k = 1; k <= length(s); k++) { c = substr(s, k, 1); if (c == "(") d++; else if (c == ")") d--; else if (c == "," && d == 0) n++ }
  print n }'; }
res() { printf '%s\n' "$1" | sed -n 's/^  PROBE result: //p'; }
loads() { printf '%s\n' "$1" | sed -n 's/^  PROBE <<< .* · entity loads \([0-9]*\) · .*/\1/p'; }
JPA=""; JPN=""; JQB=""; JTMP=""
chk_jpql() { local J A B q l b w
  J=$(cat .r-jpql.out); ver jpql 2
  A=$(blk jpql 'A - ' 'B - '); B=$(blk jpql 'B - ' '')
  has "$J" '  <parameters>true</parameters>' "jpql: Boot's parent POM turns javac's -parameters on for the anchor's build"
  for l in CustomerEntityRepository CustomerRepository; do
    w=$(printf '%s\n' "$J" | awk -v k="  \$ javap -v -p -cp .harness/after/$XD/lib/tiffinbox-core-1.0.0.jar com.tiffinbox.$l | grep -c '^ *MethodParameters:'" 'f { print; exit } index($0, k) == 1 { f = 1 }' | tr -d ' ')
    [ -n "$w" ] && [ "$w" -gt 0 ] || die "jpql: the anchor's com.tiffinbox.$l keeps its parameter names - javap's MethodParameters ($w)"; JTMP="$JTMP $l $w"; done
  JPA=$(printf '%s\n' "$J" | awk "f { print; exit } index(\$0, \"  \$ javap -v -p -cp .harness/hc probe.q.repo.Jpql\") == 1 { f = 1 }" | tr -d ' ')
  JPN=$(printf '%s\n' "$J" | awk "f { print; exit } index(\$0, \"  \$ javap -v -p -cp .harness/hc-nop probe.q.repo.Jpql\") == 1 { f = 1 }" | tr -d ' ')
  [ -n "$JPA" ] && [ "$JPA" -gt 0 ] && [ "$JPN" = 0 ] || die "jpql: MethodParameters - the build with -parameters keeps them (${JPA:-none}), the build without keeps none (${JPN:-none})"
  has "$A" "  PROBE this build's class file keeps withoutParam's parameter names (Parameter.isNamePresent()): true · the names it reads: [type, min]" "jpql A: the -parameters build keeps the names"
  has "$B" "  PROBE this build's class file keeps withoutParam's parameter names (Parameter.isNamePresent()): false · the names it reads: [arg0, arg1]" "jpql B: the build without -parameters keeps none"
  q=$(decl "$A" Jpql.withParam); [ -n "$q" ] && [ "$q" = "$(decl "$A" Jpql.withoutParam)" ] && [ "$q" = "$(decl "$B" Jpql.withParam)" ] || die "jpql: the two methods declare the same JPQL, in both builds"
  case "$q" in *':type'*':min'*) ;; *) die "jpql: the query names its parameters, :type and :min: $q" ;; esac
  for b in "$A" "$B"; do
    l='withParam(VEG, 2) - @Param("type"), @Param("min")'; two "$b" "$l" 1 "jpql $l"
    [ "$(sqll "$(call "$b" "$l")")" = "$SELC where ce1_0.meal_type=? and ce1_0.meals_per_day>=? order by ce1_0.name" ] || die "jpql $l: its SQL"
    has "$(call "$b" "$l")" '  PROBE result: [Ravi, Sunil]' "jpql $l: Ravi and Sunil"; done
  l='withoutParam(VEG, 2) - no @Param'
  two "$A" "$l" 1 "jpql A $l"; [ "$(sqll "$(call "$A" "$l")")" = "$SELC where ce1_0.meal_type=? and ce1_0.meals_per_day>=? order by ce1_0.name" ] || die "jpql A: without @Param, the same SQL"
  has "$(call "$A" "$l")" '  PROBE result: [Ravi, Sunil]' "jpql A: without @Param on the -parameters build it binds"
  # B: without @Param on the build without -parameters - at the call (after its marker, 0 statements, the JVM exit 0: S3.9);
  # the exception's class, message and first cause, each asserted (R.241)
  two "$B" "$l" 0 "jpql B $l"
  JQB=$(printf '%s\n' "$(call "$B" "$l")" | sed -n 's/^  PROBE threw: //p')
  case "$JQB" in "org.springframework.dao.InvalidDataAccessApiUsageException: For queries with named parameters you need to provide names for method parameters; Use @Param for query method parameters, or when on Java 8+ use the javac flag -parameters <- java.lang.IllegalStateException: For queries with named parameters you need to provide names for method parameters; Use @Param for query method parameters, or when on Java 8+ use the javac flag -parameters") ;;
    *) die "jpql B: without @Param on the build without -parameters the call fails - InvalidDataAccessApiUsageException: For queries with named parameters you need to provide names for method parameters; Use @Param ... <- IllegalStateException: ${JQB:-it did not fail}" ;; esac
  for b in "$A" "$B"; do has "$b" "  exit 0 · 'GenerationTarget encountered exception': 0" "jpql: the JVM ends exit 0 - a call failure, not a start failure (S3.9)"; done
  qrow 'withParam(VEG, 2)' "$q" "$(sqlcode "$(sqll "$(call "$A" 'withParam(VEG, 2) - @Param("type"), @Param("min")')")")" '[Ravi, Sunil]'
  echo "  jpql: Boot's parent <parameters>true</parameters>, the anchor's classes keep their names (MethodParameters:$JTMP); Jpql's MethodParameters - hc $JPA, hc-nop $JPN; @Param binds on both; without @Param - the -parameters build binds ([Ravi, Sunil], the same SQL), the build without fails at the call: $JQB, 0 statements, exit 0; H2"; }
RCOL=""; RLOAD=""; RN=""; ECOL=""; ELOAD=""
chk_record() { local R l q s
  R=$(cat .r-record.out); ver record 1
  q=$(decl "$R" Jpql.bills); case "$q" in 'select new probe.q.repo.Bill(c.name, c.mealsPerDay * c.pricePerMeal * 30) from CustomerEntity c order by c.name') ;; *) die "record: the constructor expression, as declared: $q" ;; esac
  l='bills() - select new probe.q.repo.Bill(...)'; two "$R" "$l" 1 "record bills"
  s=$(sqll "$(call "$R" "$l")"); [ "$s" = 'select ce1_0.name,((ce1_0.meals_per_day*ce1_0.price_per_meal)*30) from customer ce1_0 order by ce1_0.name' ] || die "record: its SQL - the name and the bill's expression: $s"
  RCOL=$(cols "$s"); RLOAD=$(loads "$(call "$R" "$l")"); RN=$(res "$(call "$R" "$l")" | $G -oF 'Bill[' | wc -l | tr -d ' ')
  [ "$RCOL" = 2 ] && [ "$RLOAD" = 0 ] && [ "$RN" = 4 ] || die "record: S3.8's two witnesses - the select list's columns ($RCOL) 2, Statistics' entity loads ($RLOAD) 0 - and four records ($RN)"
  has "$(call "$R" "$l")" '  PROBE result: [Bill[name=Meera, bill=4500], Bill[name=Priya, bill=3600], Bill[name=Ravi, bill=7200], Bill[name=Sunil, bill=9000]]' "record: the four bills"
  qrow 'bills()' "$q" "$(sqlcode "$s")" "$(res "$(call "$R" "$l")")"
  l='everyone() - select c'; two "$R" "$l" 1 "record everyone"; s=$(sqll "$(call "$R" "$l")")
  [ "$s" = "$SELC order by ce1_0.name" ] || die "record: the entity's SQL"
  ECOL=$(cols "$s"); ELOAD=$(loads "$(call "$R" "$l")"); [ "$ECOL" = 5 ] && [ "$ELOAD" = 4 ] || die "record: the entity beside it - 5 columns ($ECOL), 4 entity loads ($ELOAD)"
  qrow 'everyone()' "$(decl "$R" Jpql.everyone)" "$(sqlcode "$s")" "$(res "$(call "$R" "$l")")"
  echo "  record: select new ...Bill(...) - $RCOL columns in its SELECT, entity loads $RLOAD, $RN records; select c beside it - $ECOL columns, entity loads $ELOAD; H2"; }
NTOT=""
chk_native() { local N l d dc s
  N=$(cat .r-native.out); ver native 1
  d=$(decl "$N" 'Native.byType (nativeQuery = true)'); [ -n "$d" ] || die "native: byType's declared SQL"
  l='byType("VEG")'; two "$N" "$l" 1 "native byType"; s=$(sqll "$(call "$N" "$l")")
  [ "$s" = "${d//:type/?}" ] || die "native: the SQL Hibernate logged must be the declared text as written, its :type sent as ? - declared: $d · logged: $s"
  has "$(call "$N" "$l")" '  PROBE result: [[Ravi, 2], [Sunil, 3]] · each row a Object[] of 2' "native: rows as Object[]"
  [ "$(loads "$(call "$N" "$l")")" = 0 ] || die "native: rows, no entity"
  qrow 'byType("VEG")' "$d" "$(sqlcode "$s")" "$(res "$(call "$N" "$l")")"
  d=$(decl "$N" 'Native.pageNoCount (nativeQuery = true)'); dc=$(decl "$N" 'Native.pageWithCount countQuery')
  [ "$d" = "$(decl "$N" 'Native.pageWithCount (nativeQuery = true)')" ] && [ -n "$dc" ] || die "native: the two page methods declare the same SELECT, one with a countQuery"
  # no countQuery: Spring Data derives the count from the native text - select count(1) and the text from its FROM on
  l='pageNoCount(1, PageRequest.of(0, 2)) - no countQuery'; two "$N" "$l" 2 "native $l"; s=$(sqll "$(call "$N" "$l")")
  [ "$(printf '%s\n' "$s" | paste -sd'|' -)" = "${d//:min/?} fetch first ? rows only|select count(1) $(dd=${d#SELECT \* }; printf '%s' "${dd//:min/?}")" ] && [ "$(printf '%s\n' "$s" | sed -n 2p)" = "select count(1) FROM customer WHERE meals_per_day >= ?" ] || die "native $l: the page's SELECT, then the count Spring Data derives from the native text: $(printf '%s\n' "$s" | paste -sd'|' -)"
  NTOT=$(res "$(call "$N" "$l")"); [ "$NTOT" = 'total 4 · pages 2 · rows on page 0: 2 (no order by: the rows themselves not printed, S3.7)' ] || die "native: total 4, 2 pages"
  qrow 'pageNoCount(1, PageRequest.of(0, 2))' "$d" "$(sqlcode "$s")" "$NTOT"
  l='pageWithCount(1, PageRequest.of(0, 2)) - countQuery given'; two "$N" "$l" 2 "native $l"; s=$(sqll "$(call "$N" "$l")")
  [ "$(printf '%s\n' "$s" | paste -sd'|' -)" = "${d//:min/?} fetch first ? rows only|${dc//:min/?}" ] || die "native $l: the page's SELECT, then the countQuery given"
  [ "$(res "$(call "$N" "$l")")" = "$NTOT" ] || die "native: the given count answers the same"
  qrow 'pageWithCount(1, PageRequest.of(0, 2))' "$d · countQuery $dc" "$(sqlcode "$s")" "$(res "$(call "$N" "$l")")"
  l='pageNoCount(1, PageRequest.of(0, 2, Sort.by("name"))) - a Sort'; two "$N" "$l" 2 "native $l"; s=$(sqll "$(call "$N" "$l")")
  [ "$(printf '%s\n' "$s" | sed -n 1p)" = "${d//:min/?} order by name asc fetch first ? rows only" ] || die "native: the Sort appended - order by name asc"
  has "$(call "$N" "$l")" '  PROBE result: total 4 · pages 2 · rows on page 0: 2 · [Meera, Priya]' "native: the sorted page"
  qrow 'pageNoCount(1, PageRequest.of(0, 2, Sort.by("name")))' "$d" "$(sqlcode "$s")" "$(res "$(call "$N" "$l")")"
  # the README's table: the rows after its marker line, to the first line that is not a row, must be these, in this order
  [ "$(awk '/^<!-- queries: the query table/ { f = 1; next } f && /^\| `/ { print; next } f && /^\|/ { next } f { exit }' README.md)" = "$(printf '%s' "$QROWS")" ] || die "README.md's query table is not the captures' - each row is composed from jpql, record and native (call | declared | SQL | returned), never typed: $(diff <(awk '/^<!-- queries: the query table/ { f = 1; next } f && /^\| `/ { print; next } f && /^\|/ { next } f { exit }' README.md) <(printf '%s' "$QROWS") | $G '^[<>]' | head -2 | cut -c1-200 | paste -sd';' -)"
  echo "  native: SELECT ... logged as declared, :type sent as ?, rows Object[]; a native Page with no countQuery - Spring Data's select count(1) FROM ..., with one - the given count, total 4 both; a Sort - order by name asc; README.md's table = these $QN rows; H2"; }
TYC=""; TYQ=""; TYU=""
chk_typo() { local T B A2 X t1 o
  T=$(cat .r-typo.out); B=$(blk typo 'B - ' "A' - "); A2=$(blk typo "A' - " 'beside it')
  [ "$(cnt "$T" "$VERL")" = 2 ] && [ "$(cnt "$T" "$VERH")" = 2 ] && [ "$(cnt "$T" "$VERD")" = 2 ] || die "typo: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its 2 harness JVMs (R.222, S3.15/R.246)"
  for l in "  exit 1 · 'GenerationTarget encountered exception': 0" '  INFO  org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean : Initialized JPA EntityManagerFactory for persistence unit '"'default'" '  ERROR org.springframework.boot.SpringApplication : Application run failed'; do has "$B" "$l" "typo B: the start stops - exit 1, after the EntityManagerFactory, Application run failed"; done
  nhas "$B" 'PROBE database:' "typo B: never reached the runner"; nhas "$B" 'Did you mean' "typo B: Hibernate's message suggests nothing"
  # S3.9: a start failure - the log's order: the EntityManagerFactory, the context's refusal, Application run failed, then the chain
  o=$(printf '%s\n' "$B" | awk '/Initialized JPA EntityManagerFactory/ && !a { a = NR } /Exception encountered during context initialization/ && !b { b = NR } /Application run failed/ && !c { c = NR } /PROBE the start failed: / && !d { d = NR } END { print a + 0, b + 0, c + 0, d + 0 }')
  set -- $o; [ "$1" -gt 0 ] && [ "$1" -lt "$2" ] && [ "$2" -lt "$3" ] && [ "$3" -lt "$4" ] || die "typo B: the log's order must be Initialized JPA EntityManagerFactory, the context's refusal, Application run failed (S3.9): $o"
  # S3.10 (R.241): the chain - the top exception's class and message, each cause's class and message
  X=$(printf '%s\n' "$B" | $G -E '^  PROBE (the start failed|caused by): ' || true)
  t1=$(printf '%s\n' "$X" | sed -n 1p)
  TYQ="Query validation failed for 'select c from CustomerEntity c where c.nmae = :name'"
  case "$t1" in "  PROBE the start failed: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'badJpql' "*": $TYQ") ;; *) die "typo B: the top exception - BeanCreationException: Error creating bean with name 'badJpql' ... $TYQ: ${t1:0:200}" ;; esac
  has "$X" "  PROBE caused by: org.springframework.data.repository.query.QueryCreationException: $TYQ" "typo B: QueryCreationException, Query validation failed"
  TYU="Could not resolve attribute 'nmae' of 'com.tiffinbox.CustomerEntity'"
  [ "$(printf '%s\n' "$X" | $G -c "^  PROBE caused by: org\\.hibernate\\.query\\.sqm\\.UnknownPathException: $TYU " || true)" = 1 ] || die "typo B: a cause org.hibernate.query.sqm.UnknownPathException: $TYU (S3.10)"
  TYC=$(printf '%s\n' "$X" | sed -E 's/^  PROBE (the start failed|caused by): ([A-Za-z0-9_.$]+): .*/\2/' | paste -sd' ' - | sed 's/ / <- /g')
  for l in "  exit 0 · 'GenerationTarget encountered exception': 0" '  PROBE result: Optional[Sunil]'; do has "$A2" "$l" "typo A': c.name - the context starts, the query answers"; done
  two "$A2" 'GoodJpql.byName("Sunil")' 1 "typo A'"; [ "$(sqll "$(call "$A2" 'GoodJpql.byName("Sunil")')")" = "$SELC where ce1_0.name=?" ] || die "typo A': its SQL"
  [ "$(awk '$1 == "typo" { print $2 }' ../c7-unit16/receipts.md5)" = 4810ffd6c152c27361c8256d1c5ff3e1 ] || die "typo: the derived-query lesson's typo capture is published as 4810ffd6…"
  has "$T" "  No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'" "typo: the derived-query lesson's message, beside this one, read off its README"
  echo "  typo: B c.nmae - exit 1, after Initialized JPA EntityManagerFactory: $TYQ, the chain $TYC, $TYU, no suggestion; A' c.name - ready, Optional[Sunil]; beside it the derived-query lesson's Did you mean 'name'; H2"; }
TRIO=""; JWB=""; JWA=""
chk_anchor() { local AN B1 A1 B2 A2 GD x t1 o
  AN=$(cat .r-anchor.out); B1=$(blk anchor 'B - ' 'A - '); A1=$(blk anchor 'A - ' "B' - "); B2=$(blk anchor "B' - " "A' - "); A2=$(blk anchor "A' - " 'TiffinBox - after'); GD=$(blk anchor 'TiffinBox - after' '')
  [ "$(printf '%s\n' "$AN" | sed -n '/^the change - after/,/^tiffinbox-core\/src\/main\/java\/com\/tiffinbox\/CustomerEntityRepository.java:$/p' | $G '^  ' | paste -sd' ' -)" = "  README.md   $CJ/CustomerEntity.java   $CJ/CustomerEntityRepository.java   $CJ/CustomerRepository.java" ] || die "anchor: the change is the README, CustomerEntity.java (its Javadoc), CustomerEntityRepository.java and CustomerRepository.java - nothing else"
  for l in "  before/$CJ/CustomerRepository.java:$SB" "  after/$CJ/CustomerRepository.java:$SA" '    +@DependsOn("database")' '    -    public CustomerRepository(Database db, CustomerEntityRepository customers) {' '    +    public CustomerRepository(CustomerEntityRepository customers) {' \
      '    +    @Query("select coalesce(sum(c.mealsPerDay * c.pricePerMeal * 30), 0) from CustomerEntity c")' '    +    @Query("select coalesce(sum(p.days), 0) from PauseEntity p")' '    +        return Math.toIntExact(customers.monthRevenue());' '    +        return Math.toIntExact(customers.pausedDays());' "  $TSS"; do has "$AN" "$l" "anchor: the change"; done
  [ "$SB" = 2 ] && [ "$SA" = 0 ] || die "anchor: CustomerRepository's SQL strings 2 -> 0 (grep -c prepareStatement): $SB -> $SA"
  # the compiled class (javap over each tree's jar): before/ takes Database and calls prepareStatement; after/ takes the repository
  # alone, names Database nowhere, and carries @DependsOn(value=["database"])
  for l in '    its constructor: public com.tiffinbox.CustomerRepository(com.tiffinbox.Database, com.tiffinbox.CustomerEntityRepository)' '    its class annotations naming DependsOn: 0 · their value: ' '    constant-pool references to java.sql.Connection.prepareStatement: 1 · to com.tiffinbox.Database: 1'; do has "$(printf '%s\n' "$AN" | sed -n '/^  before\/: \$ javap/,/^  after\/: \$ javap/p')" "$l" "anchor: before/'s jar - the class as unit 16 left it"; done
  for l in '    its constructor: public com.tiffinbox.CustomerRepository(com.tiffinbox.CustomerEntityRepository)' '    its class annotations naming DependsOn: 1 · their value: value=["database"]' '    constant-pool references to java.sql.Connection.prepareStatement: 0 · to com.tiffinbox.Database: 0'; do has "$(printf '%s\n' "$AN" | sed -n '/^  after\/: \$ javap/,/^B - /p')" "$l" "anchor: after/'s jar - no Database, no prepareStatement, @DependsOn(\"database\") (the witness a hash cannot be)"; done
  JWB='(Database, CustomerEntityRepository), prepareStatement 1, @DependsOn 0'; JWA='(CustomerEntityRepository), prepareStatement 0, @DependsOn value=["database"]'
  # S3.3 (R.234): B - without @DependsOn - the start's trio, exit 1; B' = B; A - with it - ready; A' = A (R.1, RED #921)
  for x in "$B1" "$B2"; do
    printf '%s\n' "$x" | $G -qE '^  it ended by itself: exit 1 · listening on 1996[02]: 0 · readiness never answered 200$' || die "anchor B/B': without @DependsOn the start fails by itself, exit 1, never listening"
    nhas "$x" 'Started TiffinBoxServer' "anchor B/B': never started"
    t1=$(printf '%s\n' "$x" | sed -n '/^  the exception, as the log printed it/,/^  the chain.s lines: /p' | $G '^    ' | sed -n 1p)
    case "$t1" in "    org.springframework.beans.factory.UnsatisfiedDependencyException: "*"Error creating bean with name 'tiffinBoxServer': Invocation of init method failed"*|"    org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer'"*"Invocation of init method failed"*) ;; *) die "anchor B: the top exception - Error creating bean with name 'tiffinBoxServer': Invocation of init method failed: ${t1:0:220}" ;; esac
    [ "$(printf '%s\n' "$x" | $G -cE '^    Caused by: org\.h2\.jdbc\.JdbcSQLSyntaxErrorException: Table "CUSTOMER" not found \(this database is empty\);' || true)" = 1 ] || die "anchor B: the first cause - org.h2.jdbc.JdbcSQLSyntaxErrorException: Table \"CUSTOMER\" not found (this database is empty)"
    o=$(printf '%s\n' "$x" | sed -n -E 's/^  the chain.s lines: [0-9]+ · the log.s order - Initialized JPA EntityManagerFactory at line ([0-9]+), Exception encountered during context initialization at line ([0-9]+), Application run failed at line ([0-9]+)$/\1 \2 \3/p')
    set -- $o; [ $# = 3 ] && [ "$1" -lt "$2" ] && [ "$2" -lt "$3" ] || die "anchor B: the log's order - Initialized JPA EntityManagerFactory, the context's refusal, Application run failed (S3.9): ${o:-none}"; done
  [ "$(printf '%s\n' "$B1" | sed -E '1d; s/1996[02]/<port>/g; s#\.harness/anb2?#.harness/<B>#g')" = "$(printf '%s\n' "$B2" | sed -E '1d; s/1996[02]/<port>/g; s#\.harness/anb2?#.harness/<B>#g')" ] || die "anchor B': B's tree built again prints what B printed (R.1)"
  [ "$(printf '%s\n' "$B1" | $G '^    Caused by: ' | sed -E 's/^    Caused by: ([A-Za-z0-9_.]+): .*/\1/' | paste -sd' ' -)" = 'org.springframework.dao.InvalidDataAccessResourceUsageException org.hibernate.exception.SQLGrammarException org.h2.jdbc.JdbcSQLSyntaxErrorException' ] || die "anchor B: the causes - Spring's InvalidDataAccessResourceUsageException first, then Hibernate's SQLGrammarException, then H2's JdbcSQLSyntaxErrorException"
  TRIO="$(printf '%s\n' "$t1" | sed -E 's/^    ([A-Za-z0-9_.]+): .*/\1/'): Error creating bean with name 'tiffinBoxServer': Invocation of init method failed <- org.springframework.dao.InvalidDataAccessResourceUsageException <- org.hibernate.exception.SQLGrammarException <- $(printf '%s\n' "$B1" | $G -m1 -oE 'Caused by: org\.h2\.jdbc\.JdbcSQLSyntaxErrorException: Table "CUSTOMER" not found \(this database is empty\)' | sed 's/^Caused by: //')"
  for x in "$A1" "$A2"; do for l in '    INFO com.tiffinbox.web.TiffinBoxServer: Started TiffinBoxServer' '    INFO .s.d.r.c.RepositoryConfigurationDelegate: Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'; do has "$x" "$l" "anchor A/A': with @DependsOn - started"; done
    printf '%s\n' "$x" | $G -qE '^  exit 0 · listening on 1996[17] now: 0$' || die "anchor A/A': stopped by POST /shutdown, exit 0"
    nhas "$x" 'Application run failed' "anchor A/A': ready"; done
  [ "$(printf '%s\n' "$A1" | sed '1d; s/1996[17]/<port>/g; s#\.harness/a[a-z0-9]*#.harness/<A>#g')" = "$(printf '%s\n' "$A2" | sed '1d; s/1996[17]/<port>/g; s#\.harness/a[a-z0-9]*#.harness/<A>#g')" ] || die "anchor A': after/ built again prints what A printed (R.1)"
  # the guard: 201, then 409 - the SQLException still unwrapped, two WARN lines, no ERROR
  for l in '  status 201 · body: {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' '  status 409 · body: {"detail":"a customer named Kavya already exists","instance":"/customers","status":409,"title":"Conflict"}' \
      '  the log lines it added - org.hibernate.SQL: 1 · WARN: 0 · ERROR: 0:' '  the log lines it added - org.hibernate.SQL: 1 · WARN: 2 · ERROR: 0:' '    WARN org.hibernate.orm.jdbc.error: HHH000247: ErrorCode: 23505, SQLState: 23505' "    DEBUG org.hibernate.SQL: $INS" "  exit 0 · listening on 19963 now: 0"; do has "$GD" "$l" "anchor: the 409 path (a guard)"; done
  echo "  anchor: the change - CustomerEntityRepository.java (+ two @Query), CustomerRepository.java (no SQL, no Database, @DependsOn), CustomerEntity.java's Javadoc, the README; the strings $SB -> $SA; the jar's CustomerRepository before/ $JWB, after/ $JWA; B and B' - $TRIO, exit 1; A and A' - started; POST Kavya 201, again 409 (a guard); start()'s Javadoc read off the file; H2"; }
S466=466c20ed7e0d5439cb052f32ce09de1b
SQB=""; SQA=""; SUMB=""; SUMA=""
REVS='select coalesce(sum(((ce1_0.meals_per_day*ce1_0.price_per_meal)*30)),0) from customer ce1_0'
PAUS='select coalesce(sum(pe1_0.days),0) from pause pe1_0'
chk_seven() { local SV b a
  SV=$(cat .r-seven.out); b=$(blk seven 'the seven - before' 'the seven - after'); a=$(blk seven 'the seven - after' '')
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] || die "seven: $S466 on both trees (a guard)"
  has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: 0 lines differ"
  SQB=$(printf '%s\n' "$b" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  SQA=$(printf '%s\n' "$a" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  [ -n "$SQB" ] && [ -n "$SQA" ] || die "seven: the SQL logger's counts"
  # the witness (R.194): the two sums' SELECTs are Hibernate's on after/ - none on before/ (the JDBC strings answered)
  SUMB=$(printf '%s\n' "$b" | awk -v r="$REVS" -v p="$PAUS" '{ sub(/^    [0-9]+ x /, "") } $0 == r || $0 == p { n++ } END { print n + 0 }')
  SUMA=$(printf '%s\n' "$a" | awk -v r="$REVS" -v p="$PAUS" '{ sub(/^    [0-9]+ x /, "") } $0 == r || $0 == p { n++ } END { print n + 0 }')
  [ "$SUMB" = 0 ] && [ "$SUMA" = 2 ] || die "seven: the witness - the two sums' SELECTs during the seven: before/ none ($SUMB), after/ both ($SUMA)"
  [ "${SQA#* }" -gt "${SQB#* }" ] || die "seven: Hibernate's lines during the seven must grow from before/ to after/ (${SQB#* } -> ${SQA#* })"
  for x in "$b" "$a"; do has "$x" '  its log - Spring Data'"'"'s scan: Found 1 JPA repository interface. · HHH000001: HHH000001: Hibernate ORM core version 7.4.13.Final' "seven: Found 1"; done
  echo "  seven: $S466 on before/ and after/, 0 lines differ (a guard); Hibernate's SQL lines in the log ${SQB%% *} -> ${SQA%% *}, during the seven ${SQB#* } -> ${SQA#* }; the two sums' SELECTs during it before/ $SUMB, after/ $SUMA (the witness); Found 1 both"; }
REAL=""
chk_tests() { local TS l
  TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" '  exit 0 · BUILD SUCCESS · offline: yes' \
      "  in the tests' log - Spring Data's scan lines that say Found 1 JPA repository interface: 2 · Initialized JPA EntityManagerFactory: 2" \
      '    TiffinBoxWebTest.java: 1' '    FullStackTest.java: 1' '    FeedTest.java: 0'; do has "$TS" "$l" "tests"; done
  REAL='FeedTest (1 test; TiffinBoxWebTest and FullStackTest mock CustomerRepository)'
  echo "  tests: 18 (14/3/1) from the reports, the console the same; the real CustomerRepository in $REAL; 2 contexts found the repository (a guard, R.190; C7-4)"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  [ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] && [ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = 9072c6f11c8c8e713c997b58d3a79d74 ] || die "xcheck: ../c7-unit09/README.md must name $X09, and its receipts.md5 its xcheck 9072c6f1… (R.212)"
  has "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md) times): $X09 · the same: yes" "xcheck: Boot's script = the owning-side lesson's, md5 $X09"
  ! printf '%s\n' "$XC" | $G -qE 'FK[0-9a-z]{10,}' || true
  echo "  xcheck: Boot's script from after/'s jar, md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README's query names its parameter, and this build cannot tell which argument it is. Make the name reach the query."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXS=""
chk_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 1' '    Found 1 JPA repository interface.'; do has "$ER" "$l" "exercise: the README - the call fails"; done
    # the same failure jpql B shows: the class, its message, its first cause (R.241) - read here off the exercise's own chain
    [ "$(printf '%s\n' "$ER" | $G -E '^    PROBE (threw|caused by): ' | paste -sd'|' -)" = "    PROBE threw: ${JQB% <- *}|    PROBE caused by: ${JQB#* <- }" ] || die "exercise: the README's run must fail with jpql B's exception and its cause, nothing else - $JQB"
    nhas "$ER" 'PROBE VEG customers' "exercise: the README never gets its rows"
    EXS=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE VEG customers: //p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    PROBE VEG customers: [Ravi, Sunil]'; do has "$ES" "$l" "exercise: the solution - @Param(\"type\"), the two VEG customers"; done
    nhas "$ES" 'PROBE threw' "exercise: the solution runs"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qF 'List<CustomerEntity> byType(MealType type);' harness/src/probe/q/ex/ExApp.java && ! $G -qF '@Param("type")' harness/src/probe/q/ex/ExApp.java || die "exercise: ExApp ships without @Param on byType"
  ! printf '%s\n' "$(block exercise/README.md)" | $G -qF -- '-parameters' || die "exercise: the README's build is compiled without -parameters"
  EXN=$(printf '%s\n' "$EXS" | tr -d '[]' | tr ',' '\n' | $G -c . || true)
  echo "  exercise: bash and zsh alike - the README as written (no @Param, javac without -parameters): exit 1, Found 1, the call's ${JQB% <- *}; the solution (one line: @Param(\"type\")): exit 0, VEG customers $EXS ($EXN rows); $EXW words"; }
cap jpql jpql; chk_jpql; pub jpql
cap record record; chk_record; pub record
cap native natives; chk_native; pub native
cap typo typo; chk_typo; pub typo
cap anchor anchor; chk_anchor; pub anchor
cap seven seven7; chk_seven; pub seven
cap tests tests; chk_tests; pub tests
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# the values the video says are the captures', never typed: README.md states them in one line, composed here from what the checks read
VS="the values the video may say: the query table, $QN calls, README.md's rows composed from jpql, record and native · without @Param on a build without -parameters, at the call: $JQB · MethodParameters - the anchor's classes$JTMP, the harness built with -parameters $JPA, without 0 · the record: $RCOL columns, entity loads $RLOAD, $RN records (the entity: $ECOL columns, $ELOAD loads) · a native page with no countQuery: select count(1) FROM customer WHERE meals_per_day >= ? · c.nmae at start: the chain $TYC, $TYU · strings $SB -> $SA · the jar's CustomerRepository before/ $JWB, after/ $JWA · B without @DependsOn: $TRIO · POST 201, again 409 · Hibernate SQL lines in the seven's log ${SQB%% *} -> ${SQA%% *}, during the seven ${SQB#* } -> ${SQA#* }, the two sums' SELECTs during it $SUMB -> $SUMA · tests 18, the real CustomerRepository in $REAL · the seven $S466 · Boot's DDL $X09 · the exercise's solution: VEG customers $EXS"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"

# hygiene: every raw capture run and every file this unit holds - 0 raw tokens
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$LOGS" -gt 0 ] || die "a token count never ran"
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  # a line quoted from the anchor's own files (a diff's -/+ lines, a code line, a sentence S3.19 reads) may name the unit that wrote it
  ! $G -vE '^(  (README\.md|tiffinbox-core/[^ :]+|[A-Za-z]+\.(java|md)):[0-9 ]*|    [-+ ]|the sentences that state)' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a Surefire booter path, a time or Boot's seconds"
  ! $G -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE '\$Proxy[0-9]|SessionImpl\([0-9]|scanning in [0-9]+ ms|CONSTRAINT_[0-9]' "$f" || die "$f holds a proxy number, an EntityManager's identity, a scan time or an H2 constraint name, unmasked"
  ! $G -qE '(127\.0\.0\.1:|port )(49|5[0-9]|6[0-5])[0-9][0-9][0-9]([^0-9]|$)' "$f" || die "$f holds a random port (R.147)"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE 'Last modified|SHA-256 checksum|Classfile ' "$f" || die "$f holds javap -v's header (a date, a checksum, a path)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -oE 'https?://[^ '"'"']+' | $G -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
# every JVM: its locale pinned on its java line (S6.1), and under its alarm (R.247)
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -v '^ *\$ javap ' | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
for f in .r-*.out; do a=$($G -cE '^\$ cd \.harness/(before|after|anb|anb2|ana2) && ' "$f" || true); b=$($G -cxF "  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else" "$f" || true)
  [ "$a" = "$b" ] || die "$f: $a starts, $b secrets/ listings (R.158)"; done
K1='pki''ll'; K2='kill''all'; for f in receipts.sh harness/shutdown.sh; do ! $G -v '^ *#' "$f" | $G -qwE "$K1|$K2" || die "$f names $K1 or $K2 - every process is stopped by its pid"; done
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.q' after/tiffinbox-web after/tiffinbox-core || die "after/'s code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory (R.195)"
echo "  hygiene: 0 raw tokens in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, unmasked proxy number, identity or generated name, random port, javap header or stack frame in any capture; every JVM pinned and under its alarm; every start's secrets/ listed; no kill by name; no bare wait; options as arrays; no H2 file; no dish name"

# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19960-19969 at the end; 19968 and 19969 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit17: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens; no port bound but 19960-19967"
