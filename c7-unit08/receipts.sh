#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Embeddables and Value Objects - this unit's receipts. No change to the anchor: anchor/ is the link to
# ../c7-unit07/after, the frozen tree this unit reads (= ../c7-tiffinbox when this unit was built; compared at the start and the
# end, a note when they differ, never a stop - R.211). Seven captures, each run three times and hashed; cap() DIES when a hash
# differs from receipts.md5; every number and string the video says is asserted right after its capture by a check that can
# fail. One database: H2, in each harness JVM's memory, gone with it (brief ⚑2: 08 is an H2 unit; no container, no TiffinBox
# JVM, no port bound).
#   ddl       Hibernate's DDL for a customer with one Address embedded (a class): the three columns in the customer's table, no prefix
#   nulls     Ravi with a full address, Meera with none (null), Sunil with an Address of three nulls - persisted; the raw rows by a
#             second connection; each read back by id in the SAME EntityManager (no clear), then in a NEW one (RE-MEASURE 6)
#   record    the same value object as a record (RecAddress): its DDL beside the class's, then the same three reads
#   two       the failure receipt, B/A': B - two Addresses embedded (home, office), no column names given: the EntityManagerFactory
#             refused (MappingException), exit 1, no script written; A' - the office's three columns renamed by @AttributeOverride
#   overrides the A' entity: one row with both addresses, its eight columns as the catalogue gives them, both read back
#   xcheck    the harness's DDL for the anchor's CustomerEntity against Boot's script as the enums lesson captured it (its md5,
#             820b43fc..., in ../c7-unit07/README.md - R.212, RED #308: this unit binds no port, so it runs no Boot)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f
# The anchor is COPIED under .harness/anchor and built there, never in place (its README's package line, offline; its tests run);
# its jar is extracted (the anchor's own line). The harness (harness/src, package probe.map, outside com.tiffinbox) is compiled with
# javac -parameters against that extracted jar into .harness/hc. probe.map.H builds one EntityManagerFactory per run (Jakarta
# Persistence 3.2's PersistenceConfiguration, Boot's two naming strategies, statistics on, schema generation on that run's
# in-memory database only) over a DataSource wrapped in a proxy that counts the driver calls. It runs from .harness/run and binds
# no port. Its JVM flags travel as an array, V, its arguments as an array, A (R.193).
# Commands are printed exactly as they run: each goes through eval. harness/dur7.py (Course 7's builders' duration pattern, byte
# for byte) gates this unit's prose: it speaks no time (R.172). "$M2" is this unit's own repository, .m2-demo.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it; the test JVM's comes from the POM's argLine.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline build missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. At run time nothing leaves the computer: every database is H2 in a JVM's memory. This unit reads no version file:
# unit 06 made the section's dated sweep (R.223).
# Masks (README.md declares each; awk gsub only): this folder "…", the folder above it "…/..", home "~", your user name "<user>";
# " using Java <version>"; an identity hash "@…". A harness JVM's log is printed whole (every line, trailing spaces dropped).
# Ports (§P, 19870-19879): none bound. 19879 is checked free at the start and the end, with 19870-19878, 18425 (TiffinBox's
# default), 8080 and 35729. The anchor's tests (inside its package build) bind what TiffinBox's tests bind; the harness's JVMs
# and the exercise bind none.
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
# then sweep(): anything of this run still alive in its process group - a harness JVM, a Maven, Surefire's fork - is stopped.
# After an interrupt a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a
# second Ctrl-C, and the script still exits 130 after an interrupt (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.map.Main") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 rsync lsof unzip mvn md5 cmp /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - nothing here needs one"
# No anchor change: anchor/ is the link to ../c7-unit07/after, the frozen tree this unit reads. It equals ../c7-tiffinbox until a
# later unit changes the anchor - a note then, never a stop (R.211, the Course 6 form)
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit07/after ] || die "anchor must be the link to ../c7-unit07/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): anchor/ = ../c7-unit07/after (frozen); diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit07/after (frozen) - no anchor change in this unit"; fi; }
anchornote start
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
HS=harness/src/probe/map
HFILES='dur7.py logback.xml src'
SFILES='probe/map/H.java probe/map/Main.java probe/map/embed/AddrCustomer.java probe/map/embed/Address.java probe/map/embed/RecAddress.java probe/map/embed/RecCustomer.java probe/map/embed/TwoAddrCustomer.java probe/map/embed/TwoOverCustomer.java probe/map/ex/ExCustomer.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19870 19871 19872 19873 19874 19875 19876 19877 19878 19879"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run


# ---- duration words: none - this unit speaks no time (R.172); and English names only (R.215) ---------------------------------
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
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, over README.md, exercise/, harness/src)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/H.java $HS/Main.java $HS/embed/*.java")
L_H=$(mine "java $JL -Dlogback.configurationFile=../../harness/logback.xml \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*\" probe.map.Main \"\${A[@]}\"")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures - the anchor copied and built with its README's package line offline (its tests run); its jar
# ---- extracted (the anchor's line); the harness compiled against it ---------------------------------------------------------
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
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/anchor/
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/, its README's package line; its tests ran)"
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the build - README.md, The repository"; done
(eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/map/ex ] || die "the exercise's class was compiled into the harness - it is the exercise's own"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries) and compiled the harness into .harness/hc"

# ---- helpers ------------------------------------------------------------------------------------------------------------
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
pv() { echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; }
# hrun: the harness line (V, A set by the caller), run from .harness/run; it exits by itself (bounded: 240 s); its exit code in
# HE; its log .harness/h.log
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "$L_H")
  pv; echo "\$ A=($(printf '%s ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 240 s"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log; }
# hview: the harness's whole log (PROBE lines, Hibernate's INFO core lines and the SQL logger's lines), trailing spaces dropped;
# then its exit code
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
script() { echo "  the script it wrote, .harness/run/$1 - every line:"; if [ -f ".harness/run/$1" ]; then sed 's/^/    /' ".harness/run/$1"; else echo "    (none: no such file)"; fi; }
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' "Starting probe using Java 25.0.4.1" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting probe using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…')" ] || die "mask: the planted JDK version, folders, home and identity hash must be masked"
rm -f .harness/p1
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }


# ---- ddl: one Address embedded in a customer ----------------------------------------------------------------------------------
ddl() { rm -f .harness/run/ddl.sql
  echo "Hibernate's DDL for AddrCustomer (probe.map.embed: an @Embedded Address - line1, city, @Column(length = 6) pincode), a script written and run on the throwaway database:"
  V=(-Dsql=WARN); A=(ddl ddl.sql embed.AddrCustomer); hrun; hview; script ddl.sql; }

# ---- nulls: a full address, none, and an Address of three nulls - the same EntityManager, then a new one ------------------------
nulls() { echo "AddrCustomer - Ravi, Meera, Sunil persisted in one transaction, the SQL logger at DEBUG:"
  V=(); A=(nulls embed.AddrCustomer); hrun; hview; }

# ---- record: the value object as a record ------------------------------------------------------------------------------------
record() { rm -f .harness/run/rec.sql
  echo "Hibernate's DDL for RecCustomer (an @Embedded RecAddress - the record RecAddress(String line1, String city, @Column(length = 6) String pincode)), a script written and run:"
  V=(-Dsql=WARN); A=(ddl rec.sql embed.RecCustomer); hrun; hview; script rec.sql
  echo "RecCustomer - the same three customers, the same two reads:"
  V=(); A=(nulls embed.RecCustomer); hrun; hview; }

# ---- two: the failure receipt - B, two Addresses and no column names; A', the office's columns renamed --------------------------
two() { rm -f .harness/run/two-b.sql .harness/run/two-a.sql
  echo "B - TwoAddrCustomer (an @Embedded Address home, an @Embedded Address office, no column names given), a script asked for:"
  V=(); A=(ddl two-b.sql embed.TwoAddrCustomer); hrun; hview; script two-b.sql
  echo "  the trio: exit $HE · $($G -m1 '^PROBE   Caused by org.hibernate.MappingException: ' .harness/h.log | sed 's/^PROBE   Caused by //' || echo 'no MappingException printed') · the EntityManagerFactory built: $($G -q 'the EntityManagerFactory was built' .harness/h.log && echo yes || echo no) · SQL lines: $($G -c ' org\.hibernate\.SQL : ' .harness/h.log || true)"
  echo "A' - TwoOverCustomer (the same, the office with three @AttributeOverride: office_line1, office_city, office_pincode), a script asked for:"
  V=(); A=(ddl two-a.sql embed.TwoOverCustomer); hrun; hview; script two-a.sql; }

# ---- overrides: one row, both addresses ------------------------------------------------------------------------------------
overrides() { echo "TwoOverCustomer - Ravi with a home in Pune and an office in Kolkata, persisted; the table by a second connection; read back:"
  V=(); A=(two); hrun; hview; }

# ---- xcheck: the harness's DDL for the anchor's CustomerEntity against Boot's, as the enums lesson captured it --------------------
X07=820b43fcc96665c2d457212a156204eb                # Boot's script for this CustomerEntity, as ../c7-unit07's xcheck captured it (R.212)
X07CAP=74ea6be752b9be0b775e7abe1f3b907a             # that capture's own published md5 (../c7-unit07/receipts.md5)
$G -qF "$X07" ../c7-unit07/README.md || die "../c7-unit07/README.md no longer states Boot's script md5 $X07 - the number this unit compares with"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit07/receipts.md5)" = "$X07CAP" ] || die "../c7-unit07/receipts.md5's xcheck is not $X07CAP - the capture that holds Boot's script"
echo "  (terminal only) Boot's script for the anchor's CustomerEntity: md5 $X07, stated in ../c7-unit07/README.md (its xcheck capture, published $X07CAP)" >&3
if [ -f ../c7-unit07/.r-xcheck.out ] && [ "$(md5 -q ../c7-unit07/.r-xcheck.out)" = "$X07CAP" ]; then
  sed -n '/^  \.harness\/after\/hibernate-ddl\.sql - every line:$/,/^the harness/p' ../c7-unit07/.r-xcheck.out | sed -n 's/^    //p' > .harness/boot07.sql
  [ "$(md5 -q .harness/boot07.sql)" = "$X07" ] || die "../c7-unit07/.r-xcheck.out (its published capture, on disk) holds a Boot script whose md5 is not $X07"
  echo "  (terminal only) ../c7-unit07/.r-xcheck.out is on disk (md5 = its published $X07CAP): Boot's script read from it, md5 $X07" >&3
else echo "  (terminal only) ../c7-unit07/.r-xcheck.out is not on disk (a clone: captures are not committed) - the md5 is the comparison" >&3; fi
xcheck() { rm -f .harness/run/xcheck.sql
  echo "the harness's DDL - its own EntityManagerFactory over com.tiffinbox.CustomerEntity (from the anchor's jar), a file, never run:"
  V=(); A=(xcheck xcheck.sql); hrun; hview; script xcheck.sql
  echo "  md5 of .harness/run/xcheck.sql: $(md5 -q .harness/run/xcheck.sql)"
  echo "  Boot's script for this entity, as the enums lesson's xcheck captured it (Boot 4.1.2, the anchor's jar): md5 $X07"
  echo "  the same, byte for byte (md5): $( [ "$(md5 -q .harness/run/xcheck.sql)" = "$X07" ] && echo yes || echo no)"; }


# ---- exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 240 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the classes it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | paste -sd' ' -) · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$setup" | $G -c .)" = "$(printf '%s\n' "$sol" | $G -c .)" ] || die "SOLUTION.md's block must have the README's lines, one changed"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | $G -qF -- '"${V[@]}"' && printf '%s\n' "$setup" | $G -qE '^V=\(' || die "exercise/README.md must pass its options as an array, V (R.164, R.193)"
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


# ---- the captures, each followed by the checks of what the video says from it ------------------------------------------------
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# R.222: a version-shaped claim prints its version in the same capture - Hibernate's own HHH000001 line (its core logger at INFO)
# and the harness's org.hibernate.Version.getVersionString() line, once per harness JVM, read off the log, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
DBL='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:'
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] || die "$1: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its $2 harness JVMs (R.222)"
  [ "$(printf '%s\n' "$c" | $G -cF -- "$DBL")" = "$2" ] || die "$1: the database: line, H2 2.5.250, in each of its $2 harness JVMs (R.217: this unit speaks for H2 only)"; }
# "the embeddable's three columns sit in the customer's own table - no table of their own, no prefix"
DDLA='    create table addr_customer (pincode varchar(6), id bigint generated by default as identity, city varchar(255), line1 varchar(255), name varchar(255), primary key (id));'
chk_ddl() { local D; D=$(cat .r-ddl.out); ver ddl 1
  has "$D" "$DDLA" "ddl: the three columns in addr_customer"
  [ "$(printf '%s\n' "$D" | $G -c '^    create ')" = 1 ] || die "ddl: one create statement - no table for the Address"
  nhas "$D" 'create table address' "ddl: no table for the Address"
  has "$D" "  exit 0 · 'GenerationTarget encountered exception': 0" "ddl: exit 0"
  echo "  ddl: one table, addr_customer - line1, city, pincode varchar(6) beside id and name; no address table, no prefix; H2"; }
# the hook: "an Address with nothing in it goes in as three NULLs and comes back as null" - from a NEW EntityManager (RE-MEASURE 6);
# in the same EntityManager the object persisted is handed back as it was, three nulls and all
NRAW='[1 | Ravi | 12 MG Road | Pune | 411001, 2 | Meera | null | null | null, 3 | Sunil | null | null | null]'
nchk() { local W=$1 n=$2 a=$3 t=$4
  for l in "  PROBE persisted: [Ravi=$a[line1=12 MG Road, city=Pune, pincode=411001], Meera=null, Sunil=$a[line1=null, city=null, pincode=null]]" \
      "  PROBE $t raw, read by a second connection: $NRAW" \
      "  PROBE read in the same EntityManager (no clear) - find by id: [Ravi=$a[line1=12 MG Road, city=Pune, pincode=411001], Meera=null, Sunil=$a[line1=null, city=null, pincode=null]] | the objects persisted: yes" \
      "  PROBE read in a new EntityManager - find by id: [Ravi=$a[line1=12 MG Road, city=Pune, pincode=411001], Meera=null, Sunil=null] | the objects persisted: no" \
      "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$W" "$l" "$n"; done
  # the reads' SQL: the same EntityManager's three finds send nothing (its persistence context answers); the new one's send three selects
  [ "$(printf '%s\n' "$W" | sed -n '/read in the same EntityManager/,/read in a new EntityManager/p' | $G -c " org\.hibernate\.SQL : select ")" = 3 ] \
    && [ "$(printf '%s\n' "$W" | sed -n '/after commit/,/read in the same EntityManager/p' | $G -c ' org\.hibernate\.SQL : ')" = 0 ] || die "$n: the same EntityManager's reads send no SQL, the new one's three selects"
  [ "$(printf '%s\n' "$W" | $G -c " org\.hibernate\.SQL : insert into $t ")" = 3 ] || die "$n: three inserts"; }
chk_nulls() { local N; N=$(cat .r-nulls.out); ver nulls 1
  nchk "$N" nulls Address addr_customer
  echo "  nulls: rows 1 | Ravi | 12 MG Road | Pune | 411001 · 2 | Meera | null x3 · 3 | Sunil | null x3; the same EntityManager hands back Sunil's Address[line1=null, city=null, pincode=null] (the object persisted, 0 SQL); a new EntityManager reads Sunil=null, Meera=null (3 selects) - the table cannot tell no address from an empty one; Hibernate 7.4.13.Final, H2"; }
# "a record maps the same: byte-identical DDL, the same three reads"
chk_record() { local R D; R=$(cat .r-record.out); ver record 2
  D=$(printf '%s\n' "$R" | $G '^    create table rec_customer ' | sed 's/^    create table rec_customer /    create table addr_customer /')
  [ "$D" = "$DDLA" ] || die "record: RecCustomer's DDL is AddrCustomer's, byte for byte, but for the table's name"
  nchk "$(blk record 'RecCustomer - the same' '')" record RecAddress rec_customer
  echo "  record: RecCustomer's DDL = AddrCustomer's but for the table's name; the same rows; the same reads (Sunil's RecAddress[null x3] in the same EntityManager, null in a new one)"; }
# the failure receipt: "two addresses, no column names - Hibernate refuses to start: MappingException, Column 'city' is duplicated;
# no script written" (exit 1, the exception, no EntityManagerFactory, 0 SQL); A': the override is the fix
MEX="org.hibernate.MappingException: Column 'city' is duplicated in mapping for entity 'probe.map.embed.TwoAddrCustomer' (use '@Column(insertable=false, updatable=false)' when mapping multiple properties to the same column)"
DDLO="    create table two_over_customer (office_pincode varchar(6), pincode varchar(6), id bigint generated by default as identity, city varchar(255), line1 varchar(255), name varchar(255), office_city varchar(255), office_line1 varchar(255), primary key (id));"
chk_two() { local T B A2; T=$(cat .r-two.out); ver two 2
  B=$(blk two 'B - ' "A' - "); A2=$(blk two "A' - " '')
  has "$B" "  the trio: exit 1 · $MEX · the EntityManagerFactory built: no · SQL lines: 0" "two B: the trio - exit 1, the MappingException, no EntityManagerFactory, 0 SQL"
  for l in '  PROBE EXCEPTION jakarta.persistence.PersistenceException: Unable to build Hibernate SessionFactory  [persistence unit: u08ddl]' \
      '  PROBE the script two-b.sql exists: no' '    (none: no such file)'; do has "$B" "$l" "two B: refused, no script written"; done
  for l in "$DDLO" '  PROBE the script two-a.sql exists: yes' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$A2" "$l" "two A': the overrides"; done
  echo "  two: B exit 1 - PersistenceException: Unable to build Hibernate SessionFactory <- MappingException: Column 'city' is duplicated in mapping for entity '...TwoAddrCustomer' (its hint: @Column(insertable=false, updatable=false)); no EntityManagerFactory, 0 SQL, no script; A' (three @AttributeOverride) exit 0, office_line1/office_city/office_pincode varchar(6)"; }
chk_overrides() { local O; O=$(cat .r-overrides.out); ver overrides 1
  for l in "  PROBE two_over_customer's columns, as the catalogue gives them (8): [office_pincode, pincode, id, city, line1, name, office_city, office_line1]" \
      "  PROBE two_over_customer's rows, read by a second connection (1): [700016 | 411001 | 1 | Pune | 12 MG Road | Ravi | Kolkata | 4 Park Street]" \
      '  PROBE read in a new EntityManager: home=Address[line1=12 MG Road, city=Pune, pincode=411001] | office=Address[line1=4 Park Street, city=Kolkata, pincode=700016]' \
      '  DEBUG org.hibernate.SQL : insert into two_over_customer (city,line1,pincode,name,office_city,office_line1,office_pincode,id) values (?,?,?,?,?,?,?,default)' \
      "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$O" "$l" "overrides"; done
  echo "  overrides: one row, eight columns (id, name, home's line1/city/pincode, office_line1/office_city/office_pincode); one insert; both addresses read back in a new EntityManager"; }
# R.212 (RED #308): the harness's script for the anchor's entity = Boot's as unit 07 captured it, by md5
chk_xcheck() { local XC; XC=$(cat .r-xcheck.out); ver xcheck 1
  has "$XC" "    create table customer (meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, name varchar(60) not null unique, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id));" "xcheck: the one line"
  has "$XC" "  md5 of .harness/run/xcheck.sql: $X07" "xcheck: the harness's script is Boot's as the enums lesson captured it ($X07)"
  has "$XC" '  the same, byte for byte (md5): yes' "xcheck: the same"
  echo "  xcheck: the harness's DDL for the anchor's CustomerEntity, md5 $X07 = Boot's script as unit 07 captured it (R.212)"; }
EXQ="Your turn: the README embeds two addresses and Hibernate refuses to start. Give the second one its own column names."
chk_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    exit 1' '    PROBE EXCEPTION jakarta.persistence.PersistenceException: Unable to build Hibernate SessionFactory  [persistence unit: u08ex]' \
        "    PROBE   Caused by org.hibernate.MappingException: Column 'city' is duplicated in mapping for entity 'probe.map.ex.ExCustomer' (use '@Column(insertable=false, updatable=false)' when mapping multiple properties to the same column)"; do has "$ER" "$l" "exercise: the README - Hibernate refuses to start"; done
    nhas "$ER" "ex_customer's" "exercise: the README writes no row"
    for l in '    exit 0' "    PROBE ex_customer's columns, as the catalogue gives them (8): [office_pincode, pincode, id, city, line1, name, office_city, office_line1]" \
        "    PROBE ex_customer's rows, read by a second connection (1): [700016 | 411001 | 1 | Pune | 12 MG Road | Ravi | Kolkata | 4 Park Street]"; do has "$ES" "$l" "exercise: the solution - one row, eight columns"; done
    nhas "$ES" 'EXCEPTION' "exercise: the solution starts"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" = 20 ] || die "exercise: the spoken line is 20 words (R.203)"
  [ "$($G -c '@AttributeOverride' harness/src/probe/map/ex/ExCustomer.java || true)" = 0 ] || die "exercise: ExCustomer ships with no @AttributeOverride"
  echo "  exercise: bash and zsh alike - the README as written: exit 1, MappingException Column 'city' is duplicated (ExCustomer), no row; the solution (one line: three @AttributeOverride on office): exit 0, one row, eight columns; 20 words"; }
cap ddl ddl; chk_ddl
cap nulls nulls; chk_nulls
cap record record; chk_record
cap two two; chk_two
cap overrides overrides; chk_overrides
cap xcheck xcheck; chk_xcheck
cap exercise exercise; chk_exercise

# hygiene: every capture and every file this unit holds
[ "$LOGS" -gt 0 ] || die "no harness log was read"
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a Surefire booter path, a time or Boot's seconds"
  ! $G -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE '(127\.0\.0\.1:|port )[0-9]+' "$f" || die "$f holds a port - this unit binds none"
  ! $G -qE '[0-9]+\.[0-9]+ ms' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -qE 'https?://' || die "$f runs a command with a URL - this unit makes no request"; done
for f in .r-*.out; do ! $G -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.map' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
# R.213: SQL keywords are never a name here (the harness's tables and columns)
! $G -rqiwE '(class|record|String|Long|Address|RecAddress) +(order|offset|user|value|key)\b' harness/src || die "a harness entity or field is named after an SQL keyword (R.213)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory"
echo "  hygiene: $(ls .r-*.out | wc -l | tr -d ' ') captures and $LOGS harness logs; 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, port or stack frame in any capture; every JVM pinned; no kill by name; no bare wait; options as arrays; no H2 file; no dish name"

# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19870-19879 at the end; none bound by this unit"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit08: every capture 3/3 and = published; every spoken number asserted; no port bound"
