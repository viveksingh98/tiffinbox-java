#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · The Repository You Do Not Write - this unit's receipts. The course's fifth change to the anchor and Section 3's
# first (brief ⚑1, C1): CustomerEntityRepository (new, tiffinbox-core) extends Spring Data JPA's JpaRepository; TiffinBoxApp
# names its package in @EnableJpaRepositories; CustomerRepository's findAll and add go through it - its SQL strings 5 -> 3 -
# with Database still a constructor argument. Nine captures, each run three times and hashed; a hash that differs from
# receipts.md5 stops the run; every number and string the video says is asserted right after its capture by a check that can
# fail; the demo token is masked, and the checks count 0 raw copies of it in every capture and every log. One database: H2
# (brief ⚑2: 15 is an H2 unit), in each JVM's memory, gone with it.
#   bean      the bean Spring Data builds for the anchor's interface (a harness JVM): its class, the proxy checks, its target, the
#             interfaces, the advices in order (S3.1, R.232); javap of JpaRepository and its parents - the methods it declares,
#             the compiler's bridges, the three it deprecates
#   crud      what each inherited method runs: the SQL between two markers and Statistics for that call alone (R.184), and the
#             JpaTransactionManager's DEBUG lines (S3.2, R.233); rows read back by a second connection
#   ref       getReferenceById: A in a TransactionTemplate; B outside any transaction; A' = A, a fresh JVM (R.1)
#   scan      TiffinBox itself: A after/ - Found 1, ready; B after/ with @EnableJpaRepositories removed (a labelled copy, built
#             under .harness/) - the failure receipt; A' = A; C labelled - before/ plus the interface alone, nothing using it
#   anchor    the anchor's own change: after/ against before/; the string count 5 -> 3 (grep -c prepareStatement); the sentences
#             that state it (S3.19, R.250); then TiffinBox (after/) with the SQL logger on: POST Kavya twice (201, 409),
#             GET /customers/Kavya and a stranger - the SQL each request logs
#   seven     before/'s jar and after/'s, the seven each with the SQL logger on (a fresh JVM each): the seven a guard (R.190);
#             the SQL logger's lines the witness
#   tests     TiffinBox's tests on after/ (the README's line, offline): Surefire's reports, the console's summary beside their sum
#   xcheck    Boot's own DDL script from after/'s jar against the one the owning-side lesson published (its md5): no mapping
#             moved (R.212)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f
# "The previous tree" is before/, the link to ../c7-unit09/after: Section 2's frozen anchor. after/ is this unit's frozen copy of
# ../c7-tiffinbox after the change; unit 16 builds on it. Its equality with ../c7-tiffinbox is printed at the start and the end,
# and a later anchor change makes it a note, never a stop (R.211). Every tree is COPIED under .harness/ and built there, never in
# place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with a fake token (secrets/), listed
# before every start.
# The harness (harness/src, package probe.q, outside com.tiffinbox) is compiled with javac -parameters against after/'s extracted
# jar into .harness/hc. probe.q.Main is a Spring Boot context with no web server (WebApplicationType.NONE: it binds no port) over
# after/'s libraries, @EntityScan and @EnableJpaRepositories on com.tiffinbox - the anchor's entities and the anchor's own
# repository interface; probe.q.Seed builds the shipped Database in code on the run's own H2 database, which seeds it; Hibernate
# writes no schema (ddl-auto none), its statistics are on; Logback (harness/logback.xml) prints Hibernate's SQL logger, its
# HHH000001 line, Spring Data's scan line and, with -Dtx=DEBUG, JpaTransactionManager's lines. It runs from .harness/run. Its JVM
# flags travel as an array, V, its arguments as an array, A (R.193). Every JVM this script starts - the harness's, TiffinBox's,
# the exercise's - runs under an alarm (perl -e 'alarm N; exec ...': macOS has no timeout); an alarm that fires is a failed
# receipt (R.247).
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
# "$Proxy<n>" (R.232: checked by a regex, not by 3/3 - it was the same number in every JVM); an EntityManager's identity
# "SessionImpl(<n><open>)"; Spring Data's scan time "scanning in <n> ms"; H2's generated constraint and index names
# "CONSTRAINT_<n>", "CONSTRAINT_INDEX_<n>". A harness JVM's log is printed whole (every line it prints, trailing spaces dropped);
# a TiffinBox log: the named loggers' lines only.
# Ports (§P, 19940-19949): scan A 19940 · B 19941 · A' 19942 · C 19943 · anchor 19944 · seven before/ 19945 · after/ 19946 ·
# xcheck's Boot run 19947 · 19948 spare · 19949 never bound. Every one is checked free at the start and the end, and so are 18425
# (TiffinBox's default), 8080 and 35729. The harness's JVMs, the tests and the exercise bind none.
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
javap -version 2>&1 | $G -q '^25' || die "javap 25 needed (bean reads JpaRepository's class file with it)"
for t in python3 perl curl rsync lsof unzip mvn md5 cmp /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L before ] && [ "$(readlink before)" = ../c7-unit09/after ] || die "before must be the link to ../c7-unit09/after - the anchor before this change"
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
TOKEN=demo-token-for-the-repository-lesson
[ ${#TOKEN} = 36 ] || die "the demo token must be 36 characters: the captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HS=harness/src/probe/q
HFILES='dur7.py logback.xml shutdown.sh src surefire.py'
SFILES='probe/q/Main.java probe/q/Run.java probe/q/Seed.java probe/q/ex/ExApp.java'
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
PORTS="18425 8080 35729 19940 19941 19942 19943 19944 19945 19946 19947 19948 19949"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc


# ---- the prose gates: no duration word (R.172); English names only (R.215); the claims S3.2 and R.225 refuse ------------------
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
# S3.2 (R.233): a transaction claim is JpaTransactionManager's line, never a sentence about every call - crud shows the inherited
# methods' lines only, and a declared query method logs none (unit 16's capture). A line saying that every (or each, or all)
# repository call or method runs in a transaction is refused in this unit's prose
TX=$($G -niE '(every|each|all)( [a-z]+){0,2} (call|calls|method|methods)( [a-z]+){0,3} (run|runs|is|are|happens?|executes?)( [a-z]+){0,2} (in|inside|within) an? ([a-z]+ )?transaction' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TX" ] || die "a line says every repository call runs in a transaction - S3.2 (R.233) refuses it: crud shows the inherited methods' lines only: $TX"
echo "  S3.2's refused claim (every call in a transaction): 0 lines over README.md and exercise/"
# R.225: a count the video says is derived, never typed - the advice count is len() of bean's printed list, stated once, in the
# values line this script composes; a number of advices or interceptors typed anywhere else in the prose is refused
NUMW='one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|[0-9]+'
TA=$($G -niE "\\b($NUMW) (advices|advice|interceptors)\\b" README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF 'the values the video may say:' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TA" ] || die "a typed advice count - the number is len() of bean's printed list, stated only in the values line (R.225): $TA"
echo "  typed advice counts: 0 (the number is bean's list's length, in the values line only)"
# S3.19 (R.250): the change moves a count - CustomerRepository's SQL strings - so every sentence that states it is rewritten with
# the count grep gives; the shipped sentence "CustomerRepository keeps its SQL strings" (CustomerEntity.java:23-24) is false now
word() { case $1 in 0) echo zero;; 1) echo one;; 2) echo two;; 3) echo three;; 4) echo four;; 5) echo five;; *) echo "$1";; esac; }
SB=$($G -c prepareStatement "before/$CJ/CustomerRepository.java" || true); SA=$($G -c prepareStatement "after/$CJ/CustomerRepository.java" || true)
[ "$SB" = 5 ] || die "before/'s CustomerRepository holds $SB prepareStatement lines - the anchor before this change held 5"
ST=$($G -rn 'CustomerRepository keeps its SQL' after/tiffinbox-core after/tiffinbox-web 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$ST" ] || die "a sentence of the anchor still says CustomerRepository keeps its SQL strings - after this change it keeps $(word "$SA") of $(word "$SB") (S3.19, R.250): $ST"
CE=$(sed -n 23,24p "after/$CJ/CustomerEntity.java" | sed 's/^ *\* *//' | paste -sd' ' -)
printf '%s\n' "$CE" | $G -qF "CustomerRepository keeps $(word "$SA") of its $(word "$SB") SQL strings" || die "CustomerEntity.java:23-24 must state the count grep gives - keeps $(word "$SA") of its $(word "$SB") SQL strings (S3.19, R.250): $CE"
SECT=$(awk '/^## Course 7 · unit 15 /{f=1} f && /^## / && !/unit 15 /{f=0} f' after/README.md)
[ -n "$SECT" ] || die "after/README.md has no Course 7 · unit 15 section"
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
BADS=$(printf '%s\n' "$SL" | $G -v '^$' | $G -viE "\\b($(word "$SA")|$SA)\\b" | cut -c1-200 | head -3 | paste -sd';' - || true)
[ -z "$BADS" ] || die "a sentence about the SQL strings does not state the count grep gives, $(word "$SA") (S3.19, R.250): $BADS"
echo "  S3.19: CustomerRepository's prepareStatement lines before/ $SB, after/ $SA; $(printf '%s\n' "$SL" | $G -c . || true) sentences about the SQL strings in after/'s sources and its README's unit 15 section, each stating $(word "$SA"); the shipped sentence 0"

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
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*\" $HS/Main.java $HS/Run.java $HS/Seed.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../after/$XD/lib/*\" probe.q.Main \"\${A[@]}\"")
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug")
[ "${R_DDL#"$R_RUN "}" = "$DDLO1 $DDLO2" ] && [ "${L_SQL#"$R_RUN "}" = '--logging.level.org.hibernate.SQL=debug' ] || die "the DDL and SQL lines must be the anchor's run line with their options, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
# at DIR PORT 'LINE': the line run from DIR, its port 18431 made PORT - a java line with the JVM's locale pinned, under its alarm
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(exe "$(at .harness/x 19946 "$R_RUN")")" = "cd .harness/x && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19946" ] && [ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "at()/off(): the run lines are not the anchor README's"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures - before/ and after/, each copied and built with the README's package line offline (each runs
# ---- its tree's tests); two labelled copies for scan (B, C), built with the same line and -DskipTests; each jar extracted (the
# ---- anchor's line); the harness compiled ----------------------------------------------------------------------------------
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
# scan B: after/ with the one line @EnableJpaRepositories("com.tiffinbox") taken out of TiffinBoxApp.java (its import stays);
# scan C: before/ plus the interface and the core POM's dependency - nothing injects it, TiffinBoxApp unchanged
copy after .harness/scanb
$G -vxF '@EnableJpaRepositories("com.tiffinbox")' "after/$WJ/TiffinBoxApp.java" > ".harness/scanb/$WJ/TiffinBoxApp.java" || true
copy before .harness/scanc
cp "after/$CJ/CustomerEntityRepository.java" ".harness/scanc/$CJ/"; cp after/tiffinbox-core/pom.xml .harness/scanc/tiffinbox-core/pom.xml
[ "$(diff -r -x secrets after .harness/scanb | $G -c '^[<>]' || true)" -le 1 ] || die "scan B's copy differs from after/ by more than the annotation's line"
[ "$(diff -rq -x secrets before .harness/scanc | sed -E 's#^Files before/(.*) and .*#\1#; s#^Only in [^:]*/(tiffinbox-core[^:]*): (.*)$#\1/\2 (new)#' | paste -sd' ' -)" = "tiffinbox-core/pom.xml $CJ/CustomerEntityRepository.java (new)" ] || die "scan C's copy must be before/ plus the interface and the core POM's dependency, nothing else"
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (before/, the README's package line; its tests ran)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
mbuild "$(off .harness/scanb "$R_PLAIN" package) -DskipTests" .harness/build-scanb.log ".harness/scanb (scan B, labelled: after/ without @EnableJpaRepositories; the README's package line, -DskipTests)"
mbuild "$(off .harness/scanc "$R_PLAIN" package) -DskipTests" .harness/build-scanc.log ".harness/scanc (scan C, labelled: before/ plus the interface, unused; the README's package line, -DskipTests)"
for t in before after scanb scanc; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the builds - README.md, The repository"; done
(eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/q/ex ] || die "the exercise's class was compiled into the harness - it is the exercise's own"
echo "  extracted four jars ($(for t in before after scanb scanc; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: before/after/scan B/scan C) and compiled the harness into .harness/hc"

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
  case " $l " in *':8080 '*|*':35729 '*|*':19949 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19949 - never bound by this script";; esac
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
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' "$TOKEN" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'class: jdk.proxy2.$Proxy128' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_52 INDEX PUBLIC.CONSTRAINT_INDEX_5 ON PUBLIC.CUSTOMER' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'url=jdbc:h2:mem:<uuid> user=SA' '[masked: the 36-character token]' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'class: jdk.proxy2.$Proxy<n>' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_<n> INDEX PUBLIC.CONSTRAINT_INDEX_<n> ON PUBLIC.CUSTOMER')" ] || die "mask: the planted JDK version, generated database name, token, folders, home, identity hash, proxy number, EntityManager identity, scan time and H2's generated names must be masked"
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
HA=('--spring.datasource.url=jdbc:h2:mem:u15;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.hibernate.generate_statistics=true)
# hrun: the harness line (V, A set by the caller), run from .harness/run; it exits by itself (its alarm: 240 s); its exit code in
# HE; its log .harness/h.log
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "$L_H")
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
# javap -v, read: the methods the class file holds, which of them the compiler marked ACC_BRIDGE, and which carry the Deprecated
# attribute - counts and names only (javap -v's header names a path, a date and a checksum: never printed)
cat > .harness/javapv.py <<'PY'
import re, sys
lines = sys.stdin.read().splitlines()
meth = []
for i, l in enumerate(lines):
    if re.match(r"^  \S.*\(.*\).*;$", l) and i + 1 < len(lines) and lines[i + 1].startswith("    descriptor: ("):
        meth.append([l.strip(), False, False])
    elif meth and l.startswith("    flags: ") and "ACC_BRIDGE" in l:
        meth[-1][1] = True
    elif meth and l.strip() == "Deprecated: true":
        meth[-1][2] = True
br = [m[0] for m in meth if m[1]]
print("methods in the class file: %d · marked ACC_BRIDGE (the compiler's bridges): %d · declared (no ACC_BRIDGE): %d" % (len(meth), len(br), len(meth) - len(br)))
for b in br: print("  a bridge: " + b)
for m in meth:
    if m[2]: print("  Deprecated: " + m[0])
PY


# ---- bean: the proxy Spring Data builds for the anchor's interface; JpaRepository read off its class file -------------------
bean() { local JP=".harness/after/$XD/lib" c i
  echo "the bean - one harness JVM: Spring Boot with no web server over after/'s libraries; @EnableJpaRepositories(\"com.tiffinbox\") finds the anchor's own interface, com.tiffinbox.CustomerEntityRepository (after/'s core jar), which declares no method:"
  V=(-Ds=bean); A=("${HA[@]}"); hrun; hview
  echo "JpaRepository, read off its class file - javap, after/'s spring-data-jpa-4.1.2.jar with spring-data-commons-4.1.2.jar beside it:"
  c="javap -cp \"$JP/spring-data-jpa-4.1.2.jar:$JP/spring-data-commons-4.1.2.jar\" org.springframework.data.jpa.repository.JpaRepository"
  echo "\$ $c"; (eval "$c") 2>&1 | sed 's/^/  /'
  echo "\$ ${c/javap /javap -v } | python3 -I .harness/javapv.py"
  (eval "${c/javap /javap -v }") 2>&1 | python3 -I .harness/javapv.py | sed 's/^/  /'
  echo "its parents' first lines, and CrudRepository's findAll - javap, after/'s spring-data-commons-4.1.2.jar:"
  for i in ListCrudRepository CrudRepository ListPagingAndSortingRepository PagingAndSortingRepository query.QueryByExampleExecutor; do
    c="javap -cp \"$JP/spring-data-commons-4.1.2.jar\" org.springframework.data.repository.$i"; echo "\$ $c | grep -E '^public interface |findAll\\(\\);'"
    (eval "$c") 2>&1 | $G -E '^public interface |findAll\(\);' | sed 's/^/  /' || true; done; }

# ---- crud: what each inherited method runs ------------------------------------------------------------------------------------
crud() { echo "the inherited methods, one call each, in order - one harness JVM, JpaTransactionManager at DEBUG (-Dtx=DEBUG):"
  V=(-Ds=crud -Dtx=DEBUG); A=("${HA[@]}"); hrun; hview; }

# ---- ref: getReferenceById inside and outside a transaction - A/B/A' ----------------------------------------------------------
ref() { local v
  for v in A B "A'"; do
    case $v in A|"A'") echo "$v - getReferenceById(1) inside a TransactionTemplate, then getName() (a fresh JVM, -Dtx=DEBUG):" ;;
                     B) echo "B - getReferenceById(1) outside any transaction, then getName() (a fresh JVM, -Dtx=DEBUG):" ;; esac
    V=(-Ds=ref "-Dref=${v%\'}" -Dtx=DEBUG); A=("${HA[@]}"); hrun; hview; done; }

# ---- scan: TiffinBox itself - is the interface found? A/B/A' and C ------------------------------------------------------------
scan() { local v t p
  for v in A:after:19940 B:scanb:19941 "A':after:19942" C:scanc:19943; do
    t=${v#*:}; t=${t%%:*}; p=${v##*:}
    case ${v%%:*} in
      A|"A'") echo "${v%%:*} - after/'s jar (@EnableJpaRepositories(\"com.tiffinbox\") on TiffinBoxApp; CustomerRepository's constructor takes the repository), port $p:" ;;
      B) echo "B - labelled: after/ with the line @EnableJpaRepositories(\"com.tiffinbox\") taken out of TiffinBoxApp.java (.harness/scanb, built with -DskipTests), port $p - the failure receipt:" ;;
      C) echo "C - labelled: before/ plus CustomerEntityRepository.java and the core POM's spring-data-jpa (.harness/scanc, built with -DskipTests) - the interface present, nothing using it, no @EnableJpaRepositories; port $p:" ;; esac
    start "$(at .harness/$t $p "$R_RUN")"
    if [ "${v%%:*}" = B ]; then ended $p .harness/$t; else up $p; ready $p; stop $p .harness/$t; fi
    logtok; tview .harness/run.out; rm -f .harness/run.out; done; }

# ---- anchor: the change, the count, the sentences; TiffinBox's two changed methods over HTTP, the SQL logger on ---------------
lines() { wc -l < .harness/run.out | tr -d ' '; }
settle() { local a b i=0; a=$(lines); while [ $i -lt 20 ]; do sleep 0.25; b=$(lines); [ "$a" = "$b" ] && break; a=$b; i=$((i + 1)); done; }
# req LABEL CURLARGS...: one request on 19944 - its status and body; then the log lines it added: org.hibernate.SQL's, and WARN/ERROR
req() { local n0 n1 c
  n0=$(lines); c="curl -s -o .harness/body -w '%{http_code}' $*"; echo "\$ $c"
  echo "  status $(eval "$c" 2> /dev/null < /dev/null || true) · body: $(awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/body)"
  settle; n1=$(lines); sed -n "$((n0 + 1)),${n1}p" .harness/run.out > .harness/req.log
  echo "  the log lines it added - org.hibernate.SQL: $($G -cE ' org\.hibernate\.SQL +: ' .harness/req.log || true) · WARN: $(lvl WARN .harness/req.log) · ERROR: $(lvl ERROR .harness/req.log):"
  awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); sub(/[ \t]+$/, "", m)
    if ($2 == "WARN" || $2 == "ERROR" || lg ~ /org\.hibernate\.SQL/) print "    " $2 " " lg ": " (length(m) > 260 ? substr(m, 1, 260) " …" : m) }' .harness/req.log; }
anchor() { local f B='http://127.0.0.1:19944'
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#; s#^Only in after/(.*): (.*)$#  \1/\2 (new)#' | sort
  for f in tiffinbox-core/pom.xml $CJ/CustomerRepository.java $CJ/CustomerEntity.java $WJ/TiffinBoxApp.java; do echo "$f:"; cdiff "before/$f" "after/$f"; done
  echo "$CJ/CustomerEntityRepository.java (new) - its code lines (no comments):"
  $G -vE '^ *(/\*\*|\*|\*/)' "after/$CJ/CustomerEntityRepository.java" | $G -v '^$' | sed 's/^/    /'
  echo "the strings - \$ grep -c prepareStatement before/$CJ/CustomerRepository.java after/$CJ/CustomerRepository.java"
  $G -c prepareStatement "before/$CJ/CustomerRepository.java" "after/$CJ/CustomerRepository.java" | sed 's/^/  /'
  echo "the sentences that state the count (S3.19) - each sentence with 'SQL string' in after/'s Java sources (a Javadoc read whole), then in after/README.md's unit 15 section (section.md):"
  printf '%s\n' "$SL" | sed 's/^/  /' 
  echo "TiffinBox - after/'s jar, port 19944, its own H2, Hibernate's SQL logger on (the README's line with one option):"
  start "$(at .harness/after 19944 "$L_SQL")"; up 19944; ready 19944
  req -H "'Content-Type: application/json'" -d "'{\"name\":\"Kavya\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'" "$B/customers"
  req -H "'Content-Type: application/json'" -d "'{\"name\":\"Kavya\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'" "$B/customers"
  req "$B/customers/Kavya"
  req "$B/customers/Omar"
  stop 19944 .harness/after; logtok; tview .harness/run.out nosql; rm -f .harness/run.out; }

# ---- seven: the H2 regression - both trees' jars, the SQL logger on (the seven a guard, R.190; the SQL lines the witness) -------
# sqlseg FROM TO: org.hibernate.SQL lines in .harness/run.out's lines FROM..TO
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t p n0 ns
  for t in before:19945 after:19946; do p=${t#*:}; t=${t%:*}
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
  echo "  its log's WARN lines: $(lvl WARN .harness/tests.log) · ERROR lines: $(lvl ERROR .harness/tests.log) · the demo token in it and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }

# ---- xcheck: Boot's DDL script from after/'s jar against the owning-side lesson's ---------------------------------------------
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
xcheck() {
  echo "Boot's DDL - after/'s jar with the anchor README's DDL line (a file, never run), port 19947:"
  rm -f .harness/after/hibernate-ddl.sql
  start "$(at .harness/after 19947 "$R_DDL")"; up 19947; ready 19947; stop 19947 .harness/after; logtok
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
DBL='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:u15;DB_CLOSE_DELAY=-1'
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name): [1 | Ravi, 2 | Meera, 3 | Sunil, 4 | Priya]'
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
SELID='select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.id=?'
INS='insert into customer (meal_type,meals_per_day,name,price_per_meal,id) values (?,?,?,?,default)'
TXN='  DEBUG org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [org.springframework.data.jpa.repository.support.SimpleJpaRepository.'
ADV=""; ADV3=""; JDECL=""; JBR=""; JDEP=""
chk_bean() { local B n
  B=$(cat .r-bean.out); ver bean 1
  # S3.1 (R.232): the proxy's number is masked, and the mask is checked by a regex - $Proxy<n> there, no $Proxy and a digit
  # (3/3 cannot catch an unmasked number: it was the same in every JVM, RED #911)
  printf '%s\n' "$B" | $G -qF 'jdk.proxy2.$Proxy<n>' && ! $G -qE '\$Proxy[0-9]' .r-bean.out || die "bean: the JDK proxy's class must print as jdk.proxy2.\$Proxy<n> - its number masked (S3.1, R.232): $($G -oE 'jdk\.proxy[0-9]*\.\$Proxy[^ ]*' .r-bean.out | head -1)"
  for l in '  PROBE the interface: com.tiffinbox.CustomerEntityRepository · methods it declares itself (getDeclaredMethods): 0' '  PROBE bean names of that type: [customerEntityRepository]' \
      '  PROBE the bean'"'"'s class: jdk.proxy2.$Proxy<n>' '  PROBE java.lang.reflect.Proxy.isProxyClass: true · AopUtils.isJdkDynamicProxy: true' \
      '  PROBE its target (Advised.getTargetSource().getTarget()): org.springframework.data.jpa.repository.support.SimpleJpaRepository' \
      '  PROBE interface it implements: com.tiffinbox.CustomerEntityRepository' "  exit 0 · 'GenerationTarget encountered exception': 0" \
      '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'; do has "$B" "$l" "bean"; done
  # R.225: the advice count is len() of the printed list - the lines numbered 1..n, in order, nothing typed
  ADV=$(printf '%s\n' "$B" | $G -cE '^  PROBE advice [0-9]+: ' || true)
  [ "$ADV" -gt 0 ] && [ "$(printf '%s\n' "$B" | sed -n -E 's/^  PROBE advice ([0-9]+): .*/\1/p' | paste -sd' ' -)" = "$(seq 1 "$ADV" | paste -sd' ' -)" ] || die "bean: the advices are printed numbered 1..n, in order"
  ADV3=$(printf '%s\n' "$B" | sed -n -E 's/^  PROBE advice 3: (.*)$/\1/p')
  [ "$ADV3" = org.springframework.transaction.interceptor.TransactionInterceptor ] || die "bean: the third advice is the TransactionInterceptor (the hook) - it printed: ${ADV3:-none}"
  two "$B" "findById(1) through the bean" 1 "bean"
  # javap: the three parents, the methods the class file declares (no ACC_BRIDGE) and its bridges; the three deprecated; CrudRepository's Iterable
  has "$B" '  public interface org.springframework.data.jpa.repository.JpaRepository<T, ID> extends org.springframework.data.repository.ListCrudRepository<T, ID>, org.springframework.data.repository.ListPagingAndSortingRepository<T, ID>, org.springframework.data.repository.query.QueryByExampleExecutor<T> {' "bean: JpaRepository's three parents"
  n=$(printf '%s\n' "$B" | sed -n '/^  public interface org\.springframework\.data\.jpa\.repository\.JpaRepository</,/^  }$/p' | $G -cE '^    public .*\);$' || true)
  JDECL=$(printf '%s\n' "$B" | sed -n -E 's/^  methods in the class file: ([0-9]+) · marked ACC_BRIDGE \(the compiler.s bridges\): ([0-9]+) · declared \(no ACC_BRIDGE\): ([0-9]+)$/\3/p')
  JBR=$(printf '%s\n' "$B" | sed -n -E 's/^  methods in the class file: ([0-9]+) · marked ACC_BRIDGE \(the compiler.s bridges\): ([0-9]+) · declared \(no ACC_BRIDGE\): ([0-9]+)$/\2/p')
  [ -n "$JDECL" ] && [ -n "$JBR" ] && [ "$((JDECL + JBR))" = "$n" ] || die "bean: javap -v's methods (declared ${JDECL:-?} + bridges ${JBR:-?}) must be the $n method lines plain javap prints"
  [ "$(printf '%s\n' "$B" | $G -c '^    a bridge: ' || true)" = "$JBR" ] || die "bean: each bridge named"
  JDEP=$(printf '%s\n' "$B" | sed -n -E 's/^    Deprecated: .* ([A-Za-z]+)\(.*$/\1/p' | paste -sd' ' -)
  [ "$JDEP" = 'deleteInBatch getOne getById' ] || die "bean: the three methods JpaRepository deprecates - deleteInBatch, getOne, getById - read off the class file: ${JDEP:-none}"
  has "$B" '    public abstract java.lang.Iterable<T> findAll();' "bean: CrudRepository's findAll() returns an Iterable"
  has "$B" '    public abstract java.util.List<T> findAll();' "bean: ListCrudRepository's findAll() returns a List"
  echo "  bean: com.tiffinbox.CustomerEntityRepository (0 methods of its own) -> bean customerEntityRepository, class jdk.proxy2.\$Proxy<n> (masked, the regex check), a JDK proxy, target SimpleJpaRepository; $ADV advices (the list's length), the third $ADV3; JpaRepository extends ListCrudRepository, ListPagingAndSortingRepository, QueryByExampleExecutor - $JDECL methods declared, $JBR compiler bridges (ACC_BRIDGE), deprecated $JDEP; CrudRepository.findAll() an Iterable; Hibernate 7.4.13.Final, Spring Data JPA 4.1.2, H2"; }
chk_crud() { local C k
  C=$(cat .r-crud.out); ver crud 1
  for k in 'findById(1):1:findById]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly' 'findAll():1:findAll]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly' 'count():1:count]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly' 'existsById(1):1:existsById]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly' \
      'save(a new Kavya):1:save]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT' "findById(Kavya's id) - her copy, detached once the call returns:1:findById]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly" \
      'save(the detached copy, mealsPerDay 3):2:save]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT' "deleteById(Kavya's id):2:deleteById]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT" 'deleteById(99) - no such row:1:deleteById]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT' 'saveAll(Asha, Dev, Nina):3:saveAll]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT'; do
    set -- "${k%%:*}" "$(printf '%s\n' "$k" | cut -d: -f2)" "${k#*:*:}"
    two "$C" "$1" "$2" "crud $1"
    # S3.2 (R.233): one transaction per call, its line JpaTransactionManager's - readOnly for the reads, none for the writes
    [ "$(txl "$C" "$1")" = 1 ] || die "crud $1: one 'Creating new transaction' line (S3.2)"
    has "$(call "$C" "$1")" "$TXN$3" "crud $1: its transaction line (S3.2, R.233)"; done
  [ "$(sqll "$(call "$C" 'findById(1)')")" = "$SELID" ] && [ "$(sqll "$(call "$C" 'count()')")" = 'select count(*) from customer ce1_0' ] && [ "$(sqll "$(call "$C" 'existsById(1)')")" = 'select count(*) from customer ce1_0 where ce1_0.id=?' ] || die "crud: findById's SELECT, count's and existsById's count(*)"
  [ "$(sqll "$(call "$C" 'save(a new Kavya)')")" = "$INS" ] || die "crud: save(new) is one INSERT"
  [ "$(sqll "$(call "$C" 'save(the detached copy, mealsPerDay 3)')" | paste -sd'|' -)" = "$SELID|update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=? where id=?" ] || die "crud: save(detached) is a SELECT, then an UPDATE"
  [ "$(sqll "$(call "$C" "deleteById(Kavya's id)")" | paste -sd'|' -)" = "$SELID|delete from customer where id=?" ] && [ "$(sqll "$(call "$C" 'deleteById(99) - no such row')")" = "$SELID" ] || die "crud: deleteById is a SELECT then a DELETE; deleteById(99) the SELECT only"
  [ "$(sqll "$(call "$C" 'saveAll(Asha, Dev, Nina)')" | $G -cxF "$INS" || true)" = 3 ] || die "crud: saveAll is 3 INSERTs"
  for l in '  PROBE before save(): id null' '  PROBE after save(): id 5 · same instance true' '  PROBE result: read by a second connection (id | name | meals_per_day): 5 | Kavya | 2' '  PROBE after save(): same instance false' \
      '  PROBE result: read by a second connection (id | name | meals_per_day): 5 | Kavya | 3' '  PROBE result: read by a second connection: no row 5' '  PROBE result: returned, no exception' \
      '  PROBE <<< save(the detached copy, mealsPerDay 3) · statements (getPrepareStatementCount) 2 · entity loads 1 · inserts 0 · updates 1 · deletes 0' \
      '  PROBE after the calls, read by a second connection - customer (id | name): [1 | Ravi, 2 | Meera, 3 | Sunil, 4 | Priya, 6 | Asha, 7 | Dev, 8 | Nina]' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$C" "$l" "crud"; done
  nhas "$C" 'PROBE threw:' "crud: no call threw"
  echo "  crud: findById, findAll, count, existsById - 1 statement each (SQL lines = getPrepareStatementCount), each in its own readOnly transaction; save(new) 1 INSERT, id null -> 5, same instance true; findById(5) 1; save(detached) 2 - SELECT + UPDATE, same instance false, 5 | Kavya | 3; deleteById 2 - SELECT + DELETE; deleteById(99) 1 - the SELECT, no exception; saveAll 3 INSERTs in one transaction; the writes' transactions not readOnly; H2"; }
REFCL='  PROBE the reference'"'"'s class: com.tiffinbox.CustomerEntity$HibernateProxy'
chk_ref() { local R A B A2 b
  R=$(cat .r-ref.out); ver ref 3
  A=$(blk ref 'A - ' 'B - '); B=$(blk ref 'B - ' "A' - "); A2=$(blk ref "A' - " '')
  [ "$A" = "$A2" ] || die "ref A': A re-run prints what A printed (R.1)"
  b=$(call "$A" 'getReferenceById(1) in a TransactionTemplate, then getName()')
  [ "$(printf '%s\n' "$b" | sed '/^  PROBE before getName()$/,$d' | $G -c 'org\.hibernate\.SQL' || true)" = 0 ] && [ "$(printf '%s\n' "$b" | sed -n '/^  PROBE before getName()$/,/^  PROBE after getName(): /p' | $G -cxF "  DEBUG org.hibernate.SQL : $SELID" || true)" = 1 ] || die "ref A: no SQL until before getName(), then one SELECT"
  two "$A" 'getReferenceById(1) in a TransactionTemplate, then getName()' 1 "ref A"
  for l in "$REFCL" '  PROBE after getName(): Ravi' '  DEBUG org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [null]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT' '  DEBUG org.springframework.orm.jpa.JpaTransactionManager : Participating in existing transaction'; do has "$A" "$l" "ref A"; done
  two "$B" 'getReferenceById(1) outside any transaction, then getName()' 0 "ref B"
  # R.241: the exception's class with its package, its message - asserted whole; it has no cause
  for l in "$REFCL" '  PROBE threw: org.hibernate.LazyInitializationException: Could not initialize proxy [com.tiffinbox.CustomerEntity#1] - no session' "${TXN}getReferenceById]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly" "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$B" "$l" "ref B: LazyInitializationException, 0 statements"; done
  [ "$(printf '%s\n' "$B" | sed -n '/Closing JPA EntityManager after transaction/,$p' | $G -c '^  PROBE before getName()$' || true)" = 1 ] || die "ref B: the repository's transaction closed before getName() (the log's order)"
  echo "  ref: A in a TransactionTemplate - CustomerEntity\$HibernateProxy, no SQL until getName(), then 1 SELECT, Ravi; B outside - getReferenceById's own readOnly transaction ends first, then org.hibernate.LazyInitializationException: Could not initialize proxy [com.tiffinbox.CustomerEntity#1] - no session, 0 statements; A' = A; H2"; }
TRIO1='    APPLICATION FAILED TO START'
TRIO2="    Parameter 1 of constructor in com.tiffinbox.CustomerRepository required a bean of type 'com.tiffinbox.CustomerEntityRepository' that could not be found."
TRIO3="    Consider defining a bean of type 'com.tiffinbox.CustomerEntityRepository' in your configuration."
FOUND1='    INFO .s.d.r.c.RepositoryConfigurationDelegate: Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
FOUND0='    INFO .s.d.r.c.RepositoryConfigurationDelegate: Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.'
chk_scan() { local A B A2 C b
  A=$(blk scan 'A - ' 'B - '); B=$(blk scan 'B - ' "A' - "); A2=$(blk scan "A' - " 'C - '); C=$(blk scan 'C - ' '')
  for b in "$A" "$A2"; do for l in "$FOUND1" '    INFO com.tiffinbox.web.TiffinBoxServer: Started TiffinBoxServer' '    INFO org.hibernate.orm.core: HHH000001: Hibernate ORM core version 7.4.13.Final'; do has "$b" "$l" "scan A/A': Found 1, started"; done; nhas "$b" 'APPLICATION FAILED' "scan A/A'"; done
  [ "$(printf '%s\n' "$A" | sed 's/1994[02]/19940/g')" = "$(printf '%s\n' "$A2" | sed 's/1994[02]/19940/g')" ] || die "scan A': A re-run prints what A printed, its port aside (R.1)"
  # the failure receipt - the trio: exit 1, never ready, Boot's failure analysis naming the constructor and the missing bean
  for l in '  it ended by itself: exit 1 · listening on 19941: 0 · readiness never answered 200' "$FOUND0" "$TRIO1" "$TRIO2" "$TRIO3"; do has "$B" "$l" "scan B: the trio - exit 1, Found 0, the analyzer's lines"; done
  nhas "$B" 'Started TiffinBoxServer' "scan B: never started"
  for l in "$FOUND0" '    INFO com.tiffinbox.web.TiffinBoxServer: Started TiffinBoxServer' '  exit 0 · listening on 19943 now: 0'; do has "$C" "$l" "scan C: the interface unused - Found 0, and it starts"; done
  nhas "$C" 'APPLICATION FAILED' "scan C: silent"
  echo "  scan: A after/ - Found 1 JPA repository interface., started; B without @EnableJpaRepositories - exit 1, Found 0, APPLICATION FAILED TO START, Parameter 1 of constructor in com.tiffinbox.CustomerRepository required a bean of type 'com.tiffinbox.CustomerEntityRepository' that could not be found.; A' = A; C the interface unused - Found 0, starts, silent; H2"; }
chk_anchor() { local AN T
  AN=$(cat .r-anchor.out); T=$(blk anchor 'TiffinBox - after' '')
  [ "$(printf '%s\n' "$AN" | sed -n '/^the change - after/,/^tiffinbox-core\/pom.xml:$/p' | $G '^  ' | paste -sd' ' -)" = "  README.md   tiffinbox-core/pom.xml   $CJ/CustomerEntity.java   $CJ/CustomerEntityRepository.java (new)   $CJ/CustomerRepository.java   $WJ/TiffinBoxApp.java" ] || die "anchor: the change is the README, CustomerEntity.java (its Javadoc), CustomerEntityRepository.java (new), CustomerRepository.java, the core POM and TiffinBoxApp.java - nothing else"
  for l in "  before/$CJ/CustomerRepository.java:$SB" "  after/$CJ/CustomerRepository.java:$SA" '    public interface CustomerEntityRepository extends JpaRepository<CustomerEntity, Long> {' '    +@EnableJpaRepositories("com.tiffinbox")' \
      '    +        return customers.findAll(Sort.by("name")).stream().map(CustomerRepository::toRecord).toList();' '    +            customers.save(new CustomerEntity(customer.name(), customer.mealsPerDay(), customer.pricePerMeal(),' '    +            if (e.getMostSpecificCause() instanceof SQLException refused) {' \
      '    +    public CustomerRepository(Database db, CustomerEntityRepository customers) {'; do has "$AN" "$l" "anchor: the change"; done
  [ "$SB" = 5 ] && [ "$SA" = 3 ] || die "anchor: CustomerRepository's SQL strings 5 -> 3 (grep -c prepareStatement): $SB -> $SA"
  # the HTTP side: 201 then 409 (the SQLException unwrapped), one Hibernate INSERT each; by-name GETs - CustomerRepository's own
  # string - 0 Hibernate lines (unit 16's "before", RED #932)
  for l in '  status 201 · body: {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' '  status 409 · body: {"detail":"a customer named Kavya already exists","instance":"/customers","status":409,"title":"Conflict"}' \
      '  the log lines it added - org.hibernate.SQL: 1 · WARN: 0 · ERROR: 0:' '  the log lines it added - org.hibernate.SQL: 1 · WARN: 2 · ERROR: 0:' '    WARN org.hibernate.orm.jdbc.error: HHH000247: ErrorCode: 23505, SQLState: 23505' \
      '  status 200 · body: {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' "  exit 0 · listening on 19944 now: 0" "$FOUND1"; do has "$T" "$l" "anchor: TiffinBox's POSTs and GETs"; done
  [ "$(cnt "$T" "    DEBUG org.hibernate.SQL: $INS")" = 2 ] || die "anchor: each POST one Hibernate INSERT"
  [ "$(printf '%s\n' "$T" | $G -c '^  status 404 · body: {"detail":"no customer named Omar"' || true)" = 1 ] || die "anchor: a stranger is 404"
  [ "$(cnt "$T" '  the log lines it added - org.hibernate.SQL: 0 · WARN: 0 · ERROR: 0:')" = 2 ] || die "anchor: GET /customers/Kavya and a stranger - 0 Hibernate lines each (CustomerRepository's own string)"
  echo "  anchor: the change - CustomerEntityRepository.java (new), CustomerRepository.java, TiffinBoxApp.java, the core POM, CustomerEntity.java's Javadoc, the README; the strings $SB -> $SA (grep -c prepareStatement); POST Kavya 201 (1 Hibernate INSERT), again 409 (1 INSERT, HHH000247 ErrorCode 23505 - two WARN lines, no ERROR); GET /customers/Kavya 200 and a stranger 404 - 0 Hibernate lines each; H2"; }
S466=466c20ed7e0d5439cb052f32ce09de1b
SQB=""; SQA=""
chk_seven() { local SV b a
  SV=$(cat .r-seven.out); b=$(blk seven 'the seven - before' 'the seven - after'); a=$(blk seven 'the seven - after' '')
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] || die "seven: $S466 on both trees (a guard)"
  has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: 0 lines differ"
  # the witness (R.190, R.194): the SQL logger's lines during the seven - 0 on before/, the reads findAll makes on after/
  SQB=$(printf '%s\n' "$b" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  SQA=$(printf '%s\n' "$a" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  [ "$SQB" = '0 0' ] || die "seven: before/'s log - 0 Hibernate SQL lines, in all and during the seven (${SQB:-none})"
  [ "${SQA%% *}" = 4 ] && [ "${SQA#* }" -gt 0 ] || die "seven: after/'s log - 4 Hibernate SQL lines in all, and more than 0 during the seven (${SQA:-none})"
  [ "$(printf '%s\n' "$a" | sed -n '/^  the statements during the seven/,$p' | $G '^    [0-9]' | sed 's/^    [0-9]* x //' | sort -u)" = 'select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 order by ce1_0.name' ] || die "seven: during the seven, after/'s only statement is findAll(Sort.by(name))'s"
  has "$b" '  its log - Spring Data'"'"'s scan: Found 0 JPA repository interfaces. · HHH000001: HHH000001: Hibernate ORM core version 7.4.13.Final' "seven: before/ Found 0"
  has "$a" '  its log - Spring Data'"'"'s scan: Found 1 JPA repository interface. · HHH000001: HHH000001: Hibernate ORM core version 7.4.13.Final' "seven: after/ Found 1"
  echo "  seven: $S466 on before/ and after/, 0 lines differ (a guard); Hibernate's SQL lines in the log ${SQB%% *} -> ${SQA%% *} (during the seven ${SQB#* } -> ${SQA#* }, each findAll(Sort.by(name))'s ... order by ce1_0.name) - the witness; Found 0 -> Found 1"; }
chk_tests() { local TS l
  TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" '  exit 0 · BUILD SUCCESS · offline: yes' \
      "  in the tests' log - Spring Data's scan lines that say Found 1 JPA repository interface: 2 · Initialized JPA EntityManagerFactory: 2"; do has "$TS" "$l" "tests"; done
  echo "  tests: 18 (14/3/1) from the reports, the console the same; 2 contexts found the repository (a guard, R.190; C7-4)"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  [ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] && [ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = 9072c6f11c8c8e713c997b58d3a79d74 ] || die "xcheck: ../c7-unit09/README.md must name $X09, and its receipts.md5 its xcheck 9072c6f1… (R.212)"
  has "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md) times): $X09 · the same: yes" "xcheck: Boot's script = the owning-side lesson's, md5 $X09"
  ! printf '%s\n' "$XC" | $G -qE 'FK[0-9a-z]{10,}' || true
  echo "  xcheck: Boot's script from after/'s jar, md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README adds a repository to TiffinBox's core and the application refuses to start. Tell Spring Data where to look."
EXT="    Parameter 0 of method kitchen in probe.q.ex.ExApp required a bean of type 'com.tiffinbox.CustomerEntityRepository' that could not be found."
chk_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 1' '    Found 0 JPA repository interfaces.' '    APPLICATION FAILED TO START' "$EXT" "    Consider defining a bean of type 'com.tiffinbox.CustomerEntityRepository' in your configuration."; do has "$ER" "$l" "exercise: the README - refused at start, the analyzer's lines"; done
    nhas "$ER" 'PROBE ready' "exercise: the README never ready"
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    PROBE ready: the kitchen has its CustomerEntityRepository - target SimpleJpaRepository'; do has "$ES" "$l" "exercise: the solution - Found 1, ready"; done
    nhas "$ES" 'APPLICATION FAILED' "exercise: the solution starts"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" = 22 ] || die "exercise: the spoken line is 22 words (R.203)"
  $G -qxF '@EntityScan("com.tiffinbox")' harness/src/probe/q/ex/ExApp.java && ! $G -qE '^@EnableJpaRepositories' harness/src/probe/q/ex/ExApp.java || die "exercise: ExApp ships with @EntityScan and without @EnableJpaRepositories"
  echo "  exercise: bash and zsh alike - the README as written: exit 1, Found 0, APPLICATION FAILED TO START, Parameter 0 of method kitchen ... could not be found.; the solution (one line: @EnableJpaRepositories(\"com.tiffinbox\") beside @EntityScan): exit 0, Found 1, ready; 22 words"; }
cap bean bean; chk_bean; pub bean
cap crud crud; chk_crud; pub crud
cap ref ref; chk_ref; pub ref
cap scan scan; chk_scan; pub scan
cap anchor anchor; chk_anchor; pub anchor
cap seven seven7; chk_seven; pub seven
cap tests tests; chk_tests; pub tests
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# the values the video says are the captures', never typed: README.md states them in one line, composed here from what the checks read
VS="the values the video may say: $ADV advices, the third $ADV3 · target SimpleJpaRepository · JpaRepository declares $JDECL methods (+ $JBR compiler bridges), deprecates $JDEP · strings $SB -> $SA · Hibernate SQL lines in the seven's log ${SQB%% *} -> ${SQA%% *} (during the seven ${SQB#* } -> ${SQA#* }) · POST 201, again 409 · by-name GETs 0 Hibernate lines · tests 18 · the seven $S466 · Boot's DDL $X09"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1)"
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
for f in .r-*.out; do a=$($G -cE '^\$ cd \.harness/(before|after|scanb|scanc) && ' "$f" || true); b=$($G -cxF "  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else" "$f" || true)
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
echo "  ports: nothing listens on 18425, 8080, 35729 or 19940-19949 at the end; 19948 and 19949 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit15: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens; no port bound but 19940-19947"
