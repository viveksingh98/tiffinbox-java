#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Derived Query Methods - this unit's receipts. The course's sixth change to the anchor and Section 3's second
# (brief ⚑1, C2): CustomerEntityRepository declares one method, Optional<CustomerEntity> findByName(String), whose query Spring
# Data derives from its name; CustomerRepository's findByName goes through it - its SQL strings 3 -> 2 - with Database still a
# constructor argument. Nine captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run;
# every number and string the video says is asserted right after its capture by a check that can fail; the demo token is
# masked, and the checks count 0 raw copies of it in every capture and every log. One database: H2 (brief ⚑2: 16 is an H2
# unit), in each JVM's memory, gone with it.
#   derived   the parser (a harness JVM): one derived method per keyword on the harness's own interface over TiffinBox's
#             CustomerEntity - each call's SQL as Hibernate's SQL logger printed it, Statistics for that call (R.184), what it
#             returned; README.md's keyword table is composed from this capture, never typed
#   tx        no transaction of their own (S3.2, R.233): the finds' JpaTransactionManager lines counted (an inherited findById
#             beside them); A a derived delete marked @Transactional; B the same delete without it - its SELECT, then the
#             exception, its class, message and cause (R.241); A' = A, a fresh JVM (R.1)
#   typo      TiffinBox itself, the failure receipt: B a labelled copy of after/ whose findByName is misspelt findByNmae (the
#             interface and its one caller, built under .harness/) - the start stops after the EntityManagerFactory, the chain
#             read off the log (S3.9, S3.10); A' after/'s jar - ready
#   long      the longest derived method measured: its name read off the interface, its length counted twice (String.length()
#             in the JVM, ${#name} here), its one SELECT
#   anchor    the anchor's own change: after/ against before/; the string count 3 -> 2 (grep -c prepareStatement); the sentences
#             that state it (S3.19, R.250); TiffinBox (after/) POST Kavya twice (201, 409 - a guard); then the witness: the SQL
#             logger during GET /customers/Kavya and a stranger, on before/'s jar and on after/'s
#   seven     before/'s jar and after/'s, the seven each with the SQL logger on (a fresh JVM each): a guard (R.190) - the seven
#             has no by-name route
#   tests     TiffinBox's tests on after/ (the README's line, offline): Surefire's reports, the console's summary beside their sum
#   xcheck    Boot's own DDL script from after/'s jar against the one the owning-side lesson published (its md5): no mapping
#             moved (R.212)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f
# "The previous tree" is before/, the link to ../c7-unit15/after: the anchor after Section 3's first change. after/ is this
# unit's frozen copy of ../c7-tiffinbox after the change; unit 17 builds on it. Its equality with ../c7-tiffinbox is printed at
# the start and the end, and a later anchor change makes it a note, never a stop (R.211). Every tree is COPIED under .harness/
# and built there, never in place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with a
# fake token (secrets/), listed before every start.
# The harness (harness/src, package probe.q, outside com.tiffinbox) is compiled with javac -parameters against after/'s extracted
# jar into .harness/hc. probe.q.Main is a Spring Boot context with no web server (WebApplicationType.NONE: it binds no port) over
# after/'s libraries, @EntityScan on com.tiffinbox - the anchor's entities - and @EnableJpaRepositories on probe.q.repo, the
# harness's own interfaces (Derived; NoTx and WithTx, one derived delete each); probe.q.Seed builds the shipped Database in code
# on the run's own H2 database, which seeds it; Hibernate writes no schema (ddl-auto none), its statistics are on; Logback
# (harness/logback.xml) prints Hibernate's SQL logger, its HHH000001 line, Spring Data's scan line and, with -Dtx=DEBUG,
# JpaTransactionManager's lines. It runs from .harness/run. Its JVM flags travel as an array, V, its arguments as an array, A
# (R.193). Every JVM this script starts - the harness's, TiffinBox's, the exercise's - runs under an alarm (perl -e 'alarm N;
# exec ...': macOS has no timeout); an alarm that fires is a failed receipt (R.247).
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
# Ports (§P, 19950-19959): anchor 19950 · seven before/ 19951 · after/ 19952 · xcheck's Boot run 19953 · by-name before/ 19954 ·
# after/ 19955 · typo B 19956 · A' 19957 · 19958 spare · 19959 never bound. Every one is checked free at the start and the end, and
# so are 18425 (TiffinBox's default), 8080 and 35729. The harness's JVMs, the tests and the exercise bind none.
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
[ -L before ] && [ "$(readlink before)" = ../c7-unit15/after ] || die "before must be the link to ../c7-unit15/after - the anchor before this change"
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
TOKEN=demo-token-for-derived-query-methods
[ ${#TOKEN} = 36 ] || die "the demo token must be 36 characters: the captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HS=harness/src/probe/q
HFILES='dur7.py logback.xml shutdown.sh src surefire.py'
SFILES='probe/q/Main.java probe/q/Run.java probe/q/Seed.java probe/q/ex/ExApp.java probe/q/repo/Derived.java probe/q/repo/NoTx.java probe/q/repo/WithTx.java'
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
PORTS="18425 8080 35729 19950 19951 19952 19953 19954 19955 19956 19957 19958 19959"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc


# ---- the prose gates: no duration word (R.172); English names only (R.215); the claims S3.2, S3.10 and R.225 refuse ----------
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
[ -z "$TX" ] || die "a line says every repository call runs in a transaction - S3.2 (R.233) refuses it: tx shows the derived finds log none: $TX"
echo "  S3.2's refused claim (every call in a transaction): 0 lines over README.md and exercise/"
# S3.10 (R.241): an exception is read off the log as its class with its package - never typed from memory. The class Spring
# Data 4.1.2 throws for a misspelt property lives in org.springframework.data.core (typo prints it); the name under the 3.x
# package is not in spring-data-commons-4.1.2.jar, and no version is credited with it (RED #931) - refused anywhere in this
# unit's prose and harness
OLDP='org\.springframework\.data\.mapping\.PropertyReferenceException'
OP=$($G -rnE -- "$OLDP" README.md exercise harness/src 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$OP" ] || die "a line names the exception by the package it does not have on Spring Data JPA 4.1.2 - S3.10 (R.241) reads the class off the log (typo): $OP"
echo "  S3.10's refused class name: 0 lines over README.md, exercise/, harness/src"
# R.225: a count the video says is derived, never typed - the longest method's length is counted twice by long (String.length()
# and the shell's \${#name}) and stated once, in the values line this script composes; a length in characters or letters typed
# anywhere else in the prose is refused (the demo token's length aside: its lines say token)
NUMW='one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|[0-9]+|[a-z]+ hundred[a-z -]*'
TL=$($G -niE "\\b($NUMW)[- ](character|characters|letter|letters)\\b" README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF 'the values the video may say:' | $G -viF token | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TL" ] || die "a typed length - the longest method's length is counted by long, stated only in the values line (R.225): $TL"
echo "  typed lengths: 0 (the longest method's length is long's count, in the values line only)"
# S3.19 (R.250): the change moves a count - CustomerRepository's SQL strings - so every sentence that states it is rewritten with
# the count grep gives; unit 15's sentence "CustomerRepository keeps three of its five SQL strings" (CustomerEntity.java:23-24) is
# false now
word() { case $1 in 0) echo zero;; 1) echo one;; 2) echo two;; 3) echo three;; 4) echo four;; 5) echo five;; *) echo "$1";; esac; }
SB=$($G -c prepareStatement "before/$CJ/CustomerRepository.java" || true); SA=$($G -c prepareStatement "after/$CJ/CustomerRepository.java" || true)
[ "$SB" = 3 ] || die "before/'s CustomerRepository holds $SB prepareStatement lines - the anchor before this change held 3"
ST=$($G -rnE 'CustomerRepository keeps (its|three of its) (five )?SQL' after/tiffinbox-core after/tiffinbox-web 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$ST" ] || die "a sentence of the anchor still says CustomerRepository keeps its SQL strings, or three of them - after this change it keeps $(word "$SA") of five (S3.19, R.250): $ST"
CE=$(sed -n 23,24p "after/$CJ/CustomerEntity.java" | sed 's/^ *\* *//' | paste -sd' ' -)
printf '%s\n' "$CE" | $G -qF "CustomerRepository keeps $(word "$SA") of its five SQL strings" || die "CustomerEntity.java:23-24 must state the count grep gives - keeps $(word "$SA") of its five SQL strings (S3.19, R.250): $CE"
SECT=$(awk '/^## Course 7 · unit 16 /{f=1} f && /^## / && !/unit 16 /{f=0} f' after/README.md)
[ -n "$SECT" ] || die "after/README.md has no Course 7 · unit 16 section"
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
echo "  S3.19: CustomerRepository's prepareStatement lines before/ $SB, after/ $SA; $(printf '%s\n' "$SL" | $G -c . || true) sentences about the SQL strings in after/'s sources and its README's unit 16 section, each stating $(word "$SA"); unit 15's sentence 0"

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
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*\" $HS/Main.java $HS/Run.java $HS/Seed.java $HS/repo/Derived.java $HS/repo/NoTx.java $HS/repo/WithTx.java")
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
[ "$(exe "$(at .harness/x 19952 "$R_RUN")")" = "cd .harness/x && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19952" ] && [ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "at()/off(): the run lines are not the anchor README's"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures - before/ and after/, each copied and built with the README's package line offline (each runs
# ---- its tree's tests); one labelled copy for typo (B), built with the same line and -DskipTests; each jar extracted (the
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
# typo B: after/ with findByName misspelt findByNmae - the interface's method and its one caller, CustomerRepository's line
# (two lines, asserted the only difference), so the copy compiles and Spring Data meets the misspelt name at start
copy after .harness/typob
sed 's/^    Optional<CustomerEntity> findByName(String name);$/    Optional<CustomerEntity> findByNmae(String name);/' "after/$CJ/CustomerEntityRepository.java" > ".harness/typob/$CJ/CustomerEntityRepository.java"
sed 's/^        return customers\.findByName(name)\.map(CustomerRepository::toRecord);$/        return customers.findByNmae(name).map(CustomerRepository::toRecord);/' "after/$CJ/CustomerRepository.java" > ".harness/typob/$CJ/CustomerRepository.java"
TYD=$(diff -r -x secrets after .harness/typob | $G '^[<>]' | sed 's/^\([<>]\) */\1 /' | paste -sd'|' - || true)
[ "$TYD" = "< Optional<CustomerEntity> findByName(String name);|> Optional<CustomerEntity> findByNmae(String name);|< return customers.findByName(name).map(CustomerRepository::toRecord);|> return customers.findByNmae(name).map(CustomerRepository::toRecord);" ] || die "typo B's copy must differ from after/ by the two findByName lines, misspelt findByNmae, and nothing else: ${TYD:-no difference}"
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (before/, the README's package line; its tests ran)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
mbuild "$(off .harness/typob "$R_PLAIN" package) -DskipTests" .harness/build-typob.log ".harness/typob (typo B, labelled: after/ with findByNmae; the README's package line, -DskipTests)"
for t in before after typob; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the builds - README.md, The repository"; done
(eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/q/ex ] || die "the exercise's class was compiled into the harness - it is the exercise's own"
echo "  extracted three jars ($(for t in before after typob; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: before/after/typo B) and compiled the harness into .harness/hc"

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
  case " $l " in *':8080 '*|*':35729 '*|*':19959 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19959 - never bound by this script";; esac
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
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' "$TOKEN" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'class: jdk.proxy2.$Proxy128' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_52 INDEX PUBLIC.CONSTRAINT_INDEX_5 ON PUBLIC.CUSTOMER' 'Exposing JPA transaction as JDBC [org.springframework.orm.jpa.vendor.HibernateJpaDialect$HibernateConnectionHandle@7c4697fc]' "defined in URL [jar:nested:$U/.harness/typob/tiffinbox-web/target/tiffinbox-web-1.0.0.jar/!BOOT-INF/classes/!/com/tiffinbox/web/CustomerImport.class]" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'url=jdbc:h2:mem:<uuid> user=SA' '[masked: the 36-character token]' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'class: jdk.proxy2.$Proxy<n>' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_<n> INDEX PUBLIC.CONSTRAINT_INDEX_<n> ON PUBLIC.CUSTOMER' 'Exposing JPA transaction as JDBC [org.springframework.orm.jpa.vendor.HibernateJpaDialect$HibernateConnectionHandle@…]' 'defined in URL [jar:nested:…/.harness/typob/tiffinbox-web/target/tiffinbox-web-1.0.0.jar/!BOOT-INF/classes/!/com/tiffinbox/web/CustomerImport.class]')" ] || die "mask: the planted JDK version, generated database name, token, folders, home, identity hash, proxy number, EntityManager identity, scan time, H2's generated names, a connection handle's identity and a jar path under this folder must be masked"
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
HA=('--spring.datasource.url=jdbc:h2:mem:u16;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.hibernate.generate_statistics=true)
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

# ---- derived: the parser - one derived method per keyword, its SQL, what it returned ----------------------------------------
derived() { echo "the derived methods, one call each, in order - one harness JVM; the interface is the harness's own, probe.q.repo.Derived, over after/'s com.tiffinbox.CustomerEntity:"
  V=(-Ds=derived); A=("${HA[@]}"); hrun; hview; }

# ---- tx: no transaction of their own - the finds counted; A/B/A' a derived delete with and without @Transactional -----------
tx() { local v
  for v in A B "A'"; do
    case $v in A|"A'") echo "$v - the finds, then WithTx.deleteByMealType(NON_VEG), the method @Transactional (a fresh JVM, -Dtx=DEBUG):" ;;
                     B) echo "B - the finds, then NoTx.deleteByMealType(NON_VEG), the method without @Transactional (a fresh JVM, -Dtx=DEBUG):" ;; esac
    V=(-Ds=tx "-Dtx.v=${v%\'}" -Dtx=DEBUG); A=("${HA[@]}"); hrun; hview; done; }

# ---- typo: TiffinBox itself - B with findByNmae (the failure receipt), A' after/'s jar ---------------------------------------
# exc FILE: a failed start's exception chain, as the log printed it - the line after Boot's "Application run failed" and each
# "Caused by:" line (no stack frame, no "... common frames omitted" line)
exc() { awk '/ ERROR [0-9]+ --- \[.*\] o\.s\.boot\.SpringApplication +: Application run failed$/ { f = 1; next }
  f == 1 && NF { print "    " $0; f = 2; next } f == 2 && /^Caused by: / { sub(/[ \t]+$/, ""); print "    " $0 }' "$1"
  echo "  the chain's lines: $(awk '/Application run failed$/ { f = 1; next } f == 1 && NF { n++; f = 2; next } f == 2 && /^Caused by: / { n++ } END { print n + 0 }' "$1") · the log's order - Initialized JPA EntityManagerFactory at line $($G -n -m1 'Initialized JPA EntityManagerFactory' "$1" | cut -d: -f1 || true), Exception encountered during context initialization at line $($G -n -m1 'Exception encountered during context initialization' "$1" | cut -d: -f1 || true), Application run failed at line $($G -n -m1 'Application run failed' "$1" | cut -d: -f1 || true)"; }
typo() {
  echo "B - labelled: after/ with findByName misspelt findByNmae - CustomerEntityRepository's method and CustomerRepository's call (.harness/typob, built with -DskipTests), port 19956 - the failure receipt:"
  start "$(at .harness/typob 19956 "$R_RUN")"; ended 19956 .harness/typob; logtok; tview .harness/run.out
  echo "  the exception, as the log printed it (its line, then each Caused by: line):"; exc .harness/run.out; rm -f .harness/run.out
  echo "A' - after/'s jar (findByName), port 19957:"
  start "$(at .harness/after 19957 "$R_RUN")"; up 19957; ready 19957; stop 19957 .harness/after; logtok; tview .harness/run.out; rm -f .harness/run.out; }

# ---- long: the longest derived method measured - its name, its length counted twice, its one SELECT ------------------------
longm() { local n
  echo "the longest method - one harness JVM; its name read off probe.q.repo.Derived by reflection:"
  V=(-Ds=long); A=("${HA[@]}"); hrun; hview
  n=$(sed -n 's/^PROBE the method.s name: //p' .harness/h.log)
  echo "its length, counted here from the line the JVM printed - \${#name}: ${#n} · printf %s \"\$name\" | wc -c: $(printf %s "$n" | wc -c | tr -d ' ')"; }

anchor() { local f B
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#; s#^Only in after/(.*): (.*)$#  \1/\2 (new)#' | sort
  for f in $CJ/CustomerEntityRepository.java $CJ/CustomerRepository.java $CJ/CustomerEntity.java; do echo "$f:"; cdiff "before/$f" "after/$f"; done
  echo "$CJ/CustomerEntityRepository.java - its code lines (no comments):"
  $G -vE '^ *(/\*\*|\*|\*/)' "after/$CJ/CustomerEntityRepository.java" | $G -v '^$' | sed 's/^/    /'
  echo "the strings - \$ grep -c prepareStatement before/$CJ/CustomerRepository.java after/$CJ/CustomerRepository.java"
  $G -c prepareStatement "before/$CJ/CustomerRepository.java" "after/$CJ/CustomerRepository.java" | sed 's/^/  /'
  echo "the sentences that state the count (S3.19) - each sentence with 'SQL string' in after/'s Java sources (a Javadoc read whole), then in after/README.md's unit 16 section (section.md):"
  printf '%s\n' "$SL" | sed 's/^/  /'
  B='http://127.0.0.1:19950'
  echo "TiffinBox - after/'s jar, port 19950, its own H2, Hibernate's SQL logger on (the README's line with one option) - the 409 path, a guard:"
  start "$(at .harness/after 19950 "$L_SQL")"; up 19950; ready 19950
  req -H "'Content-Type: application/json'" -d "'{\"name\":\"Kavya\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'" "$B/customers"
  req -H "'Content-Type: application/json'" -d "'{\"name\":\"Kavya\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'" "$B/customers"
  stop 19950 .harness/after; logtok; tview .harness/run.out nosql; rm -f .harness/run.out
  for f in before:19954 after:19955; do B="http://127.0.0.1:${f#*:}"
    echo "the by-name witness - ${f%:*}/'s jar, port ${f#*:}, a fresh JVM, Hibernate's SQL logger on: Kavya added, then GET /customers/Kavya and a stranger:"
    start "$(at .harness/${f%:*} ${f#*:} "$L_SQL")"; up ${f#*:}; ready ${f#*:}
    req -H "'Content-Type: application/json'" -d "'{\"name\":\"Kavya\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'" "$B/customers"
    req "$B/customers/Kavya"
    req "$B/customers/Omar"
    stop ${f#*:} .harness/${f%:*}; logtok; tview .harness/run.out nosql; rm -f .harness/run.out; done; }

# ---- seven: the H2 regression - both trees' jars, the SQL logger on (a guard, R.190: the seven has no by-name route) ---------
# sqlseg FROM TO: org.hibernate.SQL lines in .harness/run.out's lines FROM..TO
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t p n0 ns
  for t in before:19951 after:19952; do p=${t#*:}; t=${t%:*}
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
  echo "Boot's DDL - after/'s jar with the anchor README's DDL line (a file, never run), port 19953:"
  rm -f .harness/after/hibernate-ddl.sql
  start "$(at .harness/after 19953 "$R_DDL")"; up 19953; ready 19953; stop 19953 .harness/after; logtok
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
DBL='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:u16;DB_CLOSE_DELAY=-1'
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
SELID='select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.id=?'
INS='insert into customer (meal_type,meals_per_day,name,price_per_meal,id) values (?,?,?,?,default)'
TXN='  DEBUG org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [org.springframework.data.jpa.repository.support.SimpleJpaRepository.'
SELC='select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0'
SELN="$SELC where ce1_0.name=?"
# derived: every call one statement (the SQL line and getPrepareStatementCount, R.184); each keyword's mark asserted in the SQL
# Hibernate logged; README.md's keyword table composed from the capture - each row the call, its SQL line, what it returned -
# and compared with the README's rows, which must be exactly these (a typed SQL string is refused)
DROWS=""; DN=0
chk_derived() { local D k lab mark res b sql r
  D=$(cat .r-derived.out); ver derived 1
  has "$D" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 3 JPA repository interfaces.' "derived: the harness's three interfaces found"
  for k in 'findByName("Sunil")^where ce1_0.name=?^Optional[3 | Sunil | 3 | 100 | VEG]' \
      'findByMealTypeAndMealsPerDayGreaterThan(VEG, 1)^where ce1_0.meal_type=? and ce1_0.meals_per_day>?^[Ravi, Sunil]' \
      'findByNameContainingIgnoreCase("r")^where upper(ce1_0.name) like upper(?) escape '"'\\'"'^[Ravi, Meera, Priya]' \
      'findByMealTypeOrderByMealsPerDayDesc(VEG)^where ce1_0.meal_type=? order by ce1_0.meals_per_day desc^[Sunil, Ravi]' \
      'findFirstByOrderByPricePerMealDesc()^order by ce1_0.price_per_meal desc fetch first ? rows only^Optional[Meera]' \
      'findTop3ByOrderByNameAsc()^order by ce1_0.name fetch first ? rows only^[Meera, Priya, Ravi]' \
      'existsByName("Priya")^select ce1_0.id from customer ce1_0 where ce1_0.name=? fetch first ? rows only^true' \
      'countByMealType(VEG)^select count(ce1_0.id) from customer ce1_0 where ce1_0.meal_type=?^2' \
      'findByPausesDaysGreaterThan(1)^from customer ce1_0 left join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>?^[Sunil, Priya]' \
      'findDistinctByPausesDaysGreaterThan(1)^select distinct ce1_0.id^[Sunil, Priya]'; do
    lab=${k%%^*}; mark=${k#*^}; mark=${mark%^*}; res=${k##*^}
    two "$D" "$lab" 1 "derived $lab"
    b=$(call "$D" "$lab"); sql=$(sqll "$b")
    case "$sql" in *"$mark"*) ;; *) die "derived $lab: its SQL must carry $mark - Hibernate logged: $sql" ;; esac
    has "$b" "  PROBE result: $res" "derived $lab: what it returned"
    r="| \`$lab\` | \`$sql\` | \`${res//|/\\|}\` |"; DROWS="$DROWS$r
"; DN=$((DN + 1)); done
  case "$(sqll "$(call "$D" 'existsByName("Priya")')")" in *count*) die "derived: existsBy must not count - it selects an id, the first row only" ;; esac
  case "$(sqll "$(call "$D" 'findByPausesDaysGreaterThan(1)')")" in "select distinct"*) die "derived: the plain path through pauses is not distinct" ;; esac
  # the README's table: the rows after its marker line, to the first line that is not a row, must be these, in this order
  [ "$(awk '/^<!-- derived: the keyword table/ { f = 1; next } f && /^\| `/ { print; next } f && /^\|/ { next } f { exit }' README.md)" = "$(printf '%s' "$DROWS")" ] || die "README.md's keyword table is not derived's - each row is composed from the capture (call | SQL | returned), never typed: $(diff <(awk '/^<!-- derived: the keyword table/ { f = 1; next } f && /^\| `/ { print; next } f && /^\|/ { next } f { exit }' README.md) <(printf '%s' "$DROWS") | $G '^[<>]' | head -2 | cut -c1-200 | paste -sd';' -)"
  echo "  derived: $DN calls, 1 statement each (SQL lines = getPrepareStatementCount); = · and … > · upper(…) like upper(?) escape '\\' · order by … desc · fetch first ? rows only (First, Top3) · existsBy selects an id, fetch first, no count · countBy count(ce1_0.id) · the path through pauses a left join, Distinct select distinct; README.md's table = these $DN rows; H2"; }
TXA=""; TXB=""
chk_tx() { local T A B A2 b l
  T=$(cat .r-tx.out); ver tx 3
  A=$(blk tx 'A - ' 'B - '); B=$(blk tx 'B - ' "A' - "); A2=$(blk tx "A' - " '')
  [ "$A" = "$A2" ] || die "tx A': A re-run prints what A printed (R.1)"
  for b in "$A" "$B"; do
    # S3.2 (R.233): the inherited findById logs its transaction; the derived finds log none - counted between their markers
    two "$b" 'findById(1) - inherited' 1 "tx findById"; [ "$(txl "$b" 'findById(1) - inherited')" = 1 ] || die "tx: the inherited findById logs one 'Creating new transaction' line"
    has "$(call "$b" 'findById(1) - inherited')" "${TXN}findById]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly" "tx: findById's own readOnly transaction"
    for l in 'findByName("Sunil") - derived' 'existsByName("Priya") - derived' 'countByMealType(VEG) - derived'; do
      two "$b" "$l" 1 "tx $l"; [ "$(txl "$b" "$l")" = 0 ] || die "tx $l: a derived find logs no transaction line (S3.2) - it logged $(txl "$b" "$l")"
      [ "$(printf '%s\n' "$(call "$b" "$l")" | $G -c 'JpaTransactionManager' || true)" = 0 ] || die "tx $l: no JpaTransactionManager line at all"; done
    two "$b" 'saveAll(Asha, Dev) - inherited, both NON_VEG' 2 "tx saveAll"
    has "$b" '  PROBE before the delete, read by a second connection - customer (id | name | meal_type): [1 | Ravi | VEG, 2 | Meera | NON_VEG, 3 | Sunil | VEG, 4 | Priya | VEGAN, 5 | Asha | NON_VEG, 6 | Dev | NON_VEG]' "tx: three NON_VEG customers before the delete"; done
  # B: the derived delete without a transaction - its SELECT runs, then the exception: class, message, first cause (R.241, #914)
  l='NoTx.deleteByMealType(NON_VEG) - the method has no @Transactional'
  two "$B" "$l" 1 "tx B"; [ "$(txl "$B" "$l")" = 0 ] || die "tx B: no transaction line"
  [ "$(sqll "$(call "$B" "$l")")" = "$SELC where ce1_0.meal_type=?" ] || die "tx B: the SELECT, and nothing else"
  TXB="org.springframework.dao.InvalidDataAccessApiUsageException: No EntityManager with actual transaction available for current thread - cannot reliably process 'remove' call <- jakarta.persistence.TransactionRequiredException: No EntityManager with actual transaction available for current thread - cannot reliably process 'remove' call"
  for l2 in "  PROBE threw: $TXB" "  PROBE <<< $l · statements (getPrepareStatementCount) 1 · entity loads 3 · inserts 0 · updates 0 · deletes 0" '  PROBE after the delete, read by a second connection - customer (id | name | meal_type): [1 | Ravi | VEG, 2 | Meera | NON_VEG, 3 | Sunil | VEG, 4 | Priya | VEGAN, 5 | Asha | NON_VEG, 6 | Dev | NON_VEG]' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$B" "$l2" "tx B: the SELECT, then InvalidDataAccessApiUsageException <- TransactionRequiredException, nothing deleted"; done
  # A: the same delete, @Transactional - its own transaction; 1 SELECT, then 3 DELETEs, one by one (the SQL log and Statistics, R.184)
  l='WithTx.deleteByMealType(NON_VEG) - the method is @Transactional'
  two "$A" "$l" 4 "tx A"; [ "$(txl "$A" "$l")" = 1 ] || die "tx A: one 'Creating new transaction' line"
  has "$(call "$A" "$l")" "${TXN}deleteByMealType]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT" "tx A: the method's transaction line"
  [ "$(sqll "$(call "$A" "$l")" | paste -sd'|' -)" = "$SELC where ce1_0.meal_type=?|delete from customer where id=?|delete from customer where id=?|delete from customer where id=?" ] || die "tx A: 1 SELECT, then 3 DELETEs"
  for l2 in '  PROBE result: 3' "  PROBE <<< $l · statements (getPrepareStatementCount) 4 · entity loads 3 · inserts 0 · updates 0 · deletes 3" '  PROBE after the delete, read by a second connection - customer (id | name | meal_type): [1 | Ravi | VEG, 3 | Sunil | VEG, 4 | Priya | VEGAN]' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$A" "$l2" "tx A: 1 SELECT + 3 DELETEs, 3 rows gone"; done
  nhas "$A" 'PROBE threw:' "tx A: nothing threw"
  TXA="1 SELECT + 3 DELETEs"
  echo "  tx: the inherited findById 1 transaction line (readOnly); the derived findByName, existsByName, countByMealType 0 each; B without @Transactional - the SELECT, then $TXB, 1 statement, nothing deleted; A @Transactional - its own transaction, $TXA (statements 4, deletes 3), the DELETEs one by one; A' = A; H2"; }
FOUND1='    INFO .s.d.r.c.RepositoryConfigurationDelegate: Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
TYN=""; TYP=""; TYC=""
chk_typo() { local B A2 X t1 t2 o1 o2 o3
  B=$(blk typo 'B - ' "A' - "); A2=$(blk typo "A' - " '')
  for l in '  it ended by itself: exit 1 · listening on 19956: 0 · readiness never answered 200' "$FOUND1" '    INFO j.LocalContainerEntityManagerFactoryBean: Initialized JPA EntityManagerFactory for persistence unit '"'default'" '    ERROR o.s.boot.SpringApplication: Application run failed'; do has "$B" "$l" "typo B: the trio - exit 1, after the EntityManagerFactory, Application run failed"; done
  nhas "$B" 'Started TiffinBoxServer' "typo B: never started"
  # S3.9: a start failure - after Initialized JPA EntityManagerFactory, the context's refusal, then Application run failed (the log's order)
  o1=$(printf '%s\n' "$B" | sed -n -E 's/^  the chain.s lines: [0-9]+ · the log.s order - Initialized JPA EntityManagerFactory at line ([0-9]+), Exception encountered during context initialization at line ([0-9]+), Application run failed at line ([0-9]+)$/\1 \2 \3/p')
  set -- $o1; [ $# = 3 ] && [ "$1" -lt "$2" ] && [ "$2" -lt "$3" ] || die "typo B: the log's order must be Initialized JPA EntityManagerFactory, the context's refusal, Application run failed (S3.9): ${o1:-none}"
  # S3.10 (R.241): the chain read off the log - the top exception's class and message, and its causes, the last two asserted whole
  X=$(printf '%s\n' "$B" | sed -n '/^  the exception, as the log printed it/,/^  the chain.s lines: /p' | $G '^    ' || true)
  t1=$(printf '%s\n' "$X" | sed -n '1p')
  case "$t1" in "    org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name '"*"No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'") ;; *) die "typo B: the top exception - UnsatisfiedDependencyException, Error creating bean with name …, ending No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name': ${t1:0:200}" ;; esac
  [ "$(printf '%s\n' "$X" | tail -2 | paste -sd'|' -)" = "    Caused by: org.springframework.data.repository.query.QueryCreationException: Cannot create query for method [CustomerEntityRepository.findByNmae(java.lang.String)]; No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'|    Caused by: org.springframework.data.core.PropertyReferenceException: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'" ] || die "typo B: the chain must end QueryCreationException <- org.springframework.data.core.PropertyReferenceException, each with its message (S3.10)"
  # the bean names and the constructor parameters, in the order the chain gives them - read off it (R.199, RED #925), never typed
  TYN=$(printf '%s\n' "$t1" | $G -oE "Error creating bean with name '[A-Za-z]+'" | sed -E "s/.*'([A-Za-z]+)'/\\1/" | paste -sd' ' - | sed 's/ / -> /g')
  TYP=$(printf '%s\n' "$t1" | $G -oE 'constructor parameter [0-9]+' | sed 's/constructor parameter //' | paste -sd' ' -)
  [ -n "$TYN" ] && [ "${TYN##* -> }" = customerEntityRepository ] || die "typo B: the chain must end at the repository's bean, customerEntityRepository: ${TYN:-none}"
  TYC=$(printf '%s\n' "$X" | sed -E 's/^    (Caused by: )?([A-Za-z0-9_.$]+): .*/\2/' | paste -sd' ' - | sed 's/ / <- /g')
  for l in "$FOUND1" '    INFO com.tiffinbox.web.TiffinBoxServer: Started TiffinBoxServer' '  exit 0 · listening on 19957 now: 0'; do has "$A2" "$l" "typo A': findByName - Found 1, started"; done
  nhas "$A2" 'Application run failed' "typo A': ready"
  echo "  typo: B findByNmae - exit 1, never listening; after Initialized JPA EntityManagerFactory: the beans $TYN (constructor parameters $TYP), No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'; the chain $TYC; A' findByName - Found 1, started; H2"; }
LEN=""; LPAR=""
chk_long() { local L n j s
  L=$(cat .r-long.out); ver long 1
  n=$(printf '%s\n' "$L" | sed -n 's/^  PROBE the method.s name: //p')
  j=$(printf '%s\n' "$L" | sed -n -E 's/^  PROBE its length \(String\.length\(\)\): ([0-9]+) · its parameters: ([0-9]+)$/\1/p')
  LPAR=$(printf '%s\n' "$L" | sed -n -E 's/^  PROBE its length \(String\.length\(\)\): ([0-9]+) · its parameters: ([0-9]+)$/\2/p')
  s=$(printf '%s\n' "$L" | sed -n -E 's/^its length, counted here from the line the JVM printed - \$\{#name\}: ([0-9]+) · printf %s "\$name" \| wc -c: ([0-9]+)$/\1 \2/p')
  [ -n "$n" ] && [ -n "$j" ] && [ "$s" = "${#n} ${#n}" ] && [ "$j" = "${#n}" ] || die "long: the name's length counted three ways - String.length() ${j:-none}, \${#name} and wc -c (${s:-none}) - must agree with the name printed (${#n})"
  case "$n" in findBy*OrderBy*) ;; *) die "long: the method is a find with an OrderBy: $n" ;; esac
  LEN=$j
  two "$L" 'the longest method (VEG or VEGAN, 1 to 2 meals a day, a price of at most 120, a name starting with "p")' 1 "long"
  [ "$(sqll "$(call "$L" 'the longest method (VEG or VEGAN, 1 to 2 meals a day, a price of at most 120, a name starting with "p")')")" = "$SELC where ce1_0.meal_type in (?,?) and ce1_0.meals_per_day between ? and ? and ce1_0.price_per_meal<=? and upper(ce1_0.name) like upper(?) escape '\\' order by ce1_0.price_per_meal desc,ce1_0.name" ] || die "long: its one SELECT"
  has "$L" '  PROBE result: [Priya]' "long: what it returned"
  echo "  long: $n - $LEN characters by String.length(), \${#name} and wc -c alike, $LPAR parameters, one SELECT; H2"; }
BYB=""; BYA=""
# byname BLOCK: each request's status and its Hibernate SQL lines, in order - "STATUS:N ..."
byname() { printf '%s\n' "$1" | sed -n -E 's/^  status ([0-9]+) · .*/\1/p; s/^  the log lines it added - org\.hibernate\.SQL: ([0-9]+) · .*/\1/p' | paste -sd' ' - | sed -E 's/([0-9]+) ([0-9]+)( |$)/\1:\2\3/g'; }
chk_anchor() { local AN GD N0 N1
  AN=$(cat .r-anchor.out); GD=$(blk anchor 'TiffinBox - after' 'the by-name witness - before'); N0=$(blk anchor 'the by-name witness - before' 'the by-name witness - after'); N1=$(blk anchor 'the by-name witness - after' '')
  [ "$(printf '%s\n' "$AN" | sed -n '/^the change - after/,/^tiffinbox-core\/src\/main\/java\/com\/tiffinbox\/CustomerEntityRepository.java:$/p' | $G '^  ' | paste -sd' ' -)" = "  README.md   $CJ/CustomerEntity.java   $CJ/CustomerEntityRepository.java   $CJ/CustomerRepository.java" ] || die "anchor: the change is the README, CustomerEntity.java (its Javadoc), CustomerEntityRepository.java and CustomerRepository.java - nothing else"
  for l in "  before/$CJ/CustomerRepository.java:$SB" "  after/$CJ/CustomerRepository.java:$SA" '    +    Optional<CustomerEntity> findByName(String name);' '    +        return customers.findByName(name).map(CustomerRepository::toRecord);' \
      '    -                 "SELECT name, meals_per_day, price_per_meal, meal_type FROM customer WHERE name = ?")) {' '        Optional<CustomerEntity> findByName(String name);'; do has "$AN" "$l" "anchor: the change"; done
  [ "$SB" = 3 ] && [ "$SA" = 2 ] || die "anchor: CustomerRepository's SQL strings 3 -> 2 (grep -c prepareStatement): $SB -> $SA"
  # the guard: 201, then 409 - the SQLException still unwrapped, two WARN lines, no ERROR
  for l in '  status 201 · body: {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' '  status 409 · body: {"detail":"a customer named Kavya already exists","instance":"/customers","status":409,"title":"Conflict"}' \
      '  the log lines it added - org.hibernate.SQL: 1 · WARN: 0 · ERROR: 0:' '  the log lines it added - org.hibernate.SQL: 1 · WARN: 2 · ERROR: 0:' '    WARN org.hibernate.orm.jdbc.error: HHH000247: ErrorCode: 23505, SQLState: 23505' "  exit 0 · listening on 19950 now: 0"; do has "$GD" "$l" "anchor: the 409 path (a guard)"; done
  # the witness (R.194, RED #917/#932): the SQL logger during GET /customers/Kavya and a stranger - none on before/, the derived
  # query's SELECT on after/
  BYB=$(byname "$N0"); BYA=$(byname "$N1")
  [ "$BYB" = '201:1 200:0 404:0' ] || die "anchor: before/ - POST 201 (1 Hibernate line), GET /customers/Kavya 200 and a stranger 404, 0 Hibernate lines each - JDBC's string: $BYB"
  [ "$BYA" = '201:1 200:1 404:1' ] || die "anchor: after/ - POST 201, GET /customers/Kavya 200 and a stranger 404, one Hibernate line each - the derived findByName: ${BYA:-none}"
  [ "$(cnt "$N1" "    DEBUG org.hibernate.SQL: $SELN")" = 2 ] && [ "$(cnt "$N0" "    DEBUG org.hibernate.SQL: $SELN")" = 0 ] || die "anchor: the by-name SELECT ($SELN) twice on after/, never on before/"
  for b in "$N0" "$N1"; do has "$b" '  status 200 · body: {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' "anchor: Kavya 200"
    [ "$(printf '%s\n' "$b" | $G -c '^  status 404 · body: {"detail":"no customer named Omar"' || true)" = 1 ] || die "anchor: a stranger is 404"; done
  echo "  anchor: the change - CustomerEntityRepository.java (+ findByName), CustomerRepository.java, CustomerEntity.java's Javadoc, the README; the strings $SB -> $SA (grep -c prepareStatement); POST Kavya 201, again 409 (two WARN lines, no ERROR - a guard); the by-name witness - before/ $BYB, after/ $BYA (status:Hibernate lines), the SELECT ... where ce1_0.name=? twice; H2"; }
S466=466c20ed7e0d5439cb052f32ce09de1b
SQB=""; SQA=""
chk_seven() { local SV b a
  SV=$(cat .r-seven.out); b=$(blk seven 'the seven - before' 'the seven - after'); a=$(blk seven 'the seven - after' '')
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] || die "seven: $S466 on both trees (a guard)"
  has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: 0 lines differ"
  SQB=$(printf '%s\n' "$b" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  SQA=$(printf '%s\n' "$a" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  [ -n "$SQB" ] && [ "$SQB" = "$SQA" ] || die "seven: the seven has no by-name route - the SQL logger's lines are the same on both trees (${SQB:-none} / ${SQA:-none})"
  for x in "$b" "$a"; do has "$x" '  its log - Spring Data'"'"'s scan: Found 1 JPA repository interface. · HHH000001: HHH000001: Hibernate ORM core version 7.4.13.Final' "seven: Found 1"; done
  echo "  seven: $S466 on before/ and after/, 0 lines differ; Hibernate's SQL lines in the log ${SQB%% *} -> ${SQA%% *} (during the seven ${SQB#* } -> ${SQA#* }) - a guard both, the seven has no by-name route; Found 1 both"; }
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
EXQ="Your turn: the README's repository has a method the application cannot start with. Read the error, and fix the method's name."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXT1="    PROBE threw: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'kitchen' defined in probe.q.ex.ExApp: Unsatisfied dependency expressed through method 'kitchen' parameter 0: Error creating bean with name 'customers' defined in probe.q.ex.Customers defined in @EnableJpaRepositories declared on DataJpaRepositoriesRegistrar.EnableJpaRepositoriesConfiguration: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'"
EXT2="    PROBE caused by: org.springframework.data.repository.query.QueryCreationException: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'"
EXT3="    PROBE caused by: org.springframework.data.core.PropertyReferenceException: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'"
EXS=""
chk_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 1' '    Found 1 JPA repository interface.' "$EXT1" "$EXT3"; do has "$ER" "$l" "exercise: the README - refused at start, the chain (class, message, causes)"; done
    [ "$(printf '%s\n' "$ER" | $G '^    PROBE caused by: ' | tail -2 | paste -sd'|' -)" = "$EXT2|$EXT3" ] || die "exercise: the README's chain must end QueryCreationException <- PropertyReferenceException (S3.10)"
    nhas "$ER" 'PROBE Sunil' "exercise: the README never reaches the runner"
    EXS=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE Sunil: //p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' "    PROBE Sunil: Optional[3|Sunil|3|100|VEG]"; do has "$ES" "$l" "exercise: the solution - Found 1, the derived findByName answers"; done
    nhas "$ES" 'PROBE threw' "exercise: the solution starts"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qF 'findByNmae(String name);' harness/src/probe/q/ex/ExApp.java && ! $G -qF 'findByName' harness/src/probe/q/ex/ExApp.java || die "exercise: ExApp ships with findByNmae, never findByName"
  echo "  exercise: bash and zsh alike - the README as written: exit 1, Found 1, Error creating bean with name 'customers' ... No property 'nmae' ..., the chain ending QueryCreationException <- PropertyReferenceException; the solution (one line: the copy's findByNmae made findByName): exit 0, Sunil: $EXS; $EXW words"; }
cap derived derived; chk_derived; pub derived
cap tx tx; chk_tx; pub tx
cap typo typo; chk_typo; pub typo
cap long longm; chk_long; pub long
cap anchor anchor; chk_anchor; pub anchor
cap seven seven7; chk_seven; pub seven
cap tests tests; chk_tests; pub tests
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# the values the video says are the captures', never typed: README.md states them in one line, composed here from what the checks read
VS="the values the video may say: the keyword table, $DN calls - 1 statement each, README.md's rows composed from derived · derived finds log 0 transaction lines, the inherited findById 1 · a derived delete without @Transactional: its SELECT, then $TXB · with @Transactional: $TXA · findByNmae: the beans $TYN (constructor parameters $TYP), the chain $TYC · the longest method $LEN characters, $LPAR parameters, one SELECT · strings $SB -> $SA · by-name GETs' Hibernate lines before/ $BYB, after/ $BYA (status:lines) · POST 201, again 409 · Hibernate SQL lines in the seven's log ${SQB%% *} -> ${SQA%% *} · tests 18 · the seven $S466 · Boot's DDL $X09 · the exercise's solution: Sunil $EXS"
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
for f in .r-*.out; do a=$($G -cE '^\$ cd \.harness/(before|after|typob) && ' "$f" || true); b=$($G -cxF "  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else" "$f" || true)
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
echo "  ports: nothing listens on 18425, 8080, 35729 or 19950-19959 at the end; 19958 and 19959 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit16: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens; no port bound but 19950-19957"
