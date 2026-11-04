#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Cascades and Orphan Removal - this unit's receipts. No change to the anchor: anchor/ is the link to ../c7-unit09/after,
# the tree Section 2 froze (= ../c7-tiffinbox when this unit was built; compared at the start and the end, a note when they differ,
# never a stop - R.211). Six captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every
# number and string the video says is asserted right after its capture by a check that can fail. One database: H2, in each harness
# JVM's memory, gone with it (brief: 11 is an H2 unit; no container, no TiffinBox JVM, no port bound). Every run below starts from
# Kavya with pauses of 3 and 2 days, on harness tables named apart from the anchor's (S2.7), each step in a fresh JVM (R.196):
#   orphan    her 3-day pause removed from her list: A cascade = ALL, orphanRemoval = true - one DELETE, the row gone; B cascade =
#             {PERSIST, REMOVE} - nothing written, the row still points at Kavya; A' = A again (R.1)
#   remove    Kavya herself removed: A ALL + orphanRemoval and B PERSIST + REMOVE - two pause DELETEs, then hers; C no cascade - the
#             failure receipt: RollbackException <- ConstraintViolationException, the referential-integrity line, nothing deleted
#   replace   A her list replaced by a new ArrayList, orphanRemoval on - Hibernate 7.4's HibernateException, 0 writes; B the same,
#             PERSIST + REMOVE - nothing written, Statistics beside the statement count (S2.3); C her own list emptied, clear() - 2 DELETEs
#   merge     a detached Kavya, a new 7-day pause added, merge(): A cascade = ALL - 3 | 7 | 1; B cascade = PERSIST - 3 | 0 | null, no
#             error; A' = ALL again (R.1, RED #309); what the managed copy holds after merge printed in each (RE-MEASURE 5)
#   xcheck    the harness's DDL for the anchor's CustomerEntity and PauseEntity against Boot's script as the owning-side lesson
#             captured it (its md5, f5956370..., in ../c7-unit09/README.md - R.212, RED #308: this unit binds no port, so it runs no Boot)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f
# The anchor is COPIED under .harness/anchor and built there, never in place (its README's package line, offline; its tests run);
# its jar is extracted (the anchor's own line). The harness (harness/src, package probe.map, outside com.tiffinbox) is compiled with
# javac -parameters against that extracted jar into .harness/hc. probe.map.H builds one EntityManagerFactory per run (Jakarta
# Persistence 3.2's PersistenceConfiguration, Boot's two naming strategies, statistics on, schema generation on that run's
# in-memory database only) over a DataSource wrapped in a proxy that counts the driver calls and keeps what each executeUpdate
# returned. It runs from .harness/run and binds no port. Its JVM flags travel as an array, V, its arguments as an array, A (R.193).
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
# " using Java <version>"; an identity hash "@…"; Hibernate's generated constraint names "FK<hash>" and unique-key names
# "UK<hash>" (hashes of the table and column names, not anyone's code - lower case in the DDL, upper case in H2's messages). A harness JVM's log is printed whole (every line,
# trailing spaces dropped).
# Ports (§P, 19900-19909): none bound. 19909 is checked free at the start and the end, with 19900-19908, 18425 (TiffinBox's
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
# No anchor change: anchor/ is the link to ../c7-unit09/after, the frozen tree this unit reads. It equals ../c7-tiffinbox until a
# later unit changes the anchor - a note then, never a stop (R.211, the Course 6 form)
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit09/after ] || die "anchor must be the link to ../c7-unit09/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): anchor/ = ../c7-unit09/after (frozen); diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit09/after (frozen) - no anchor change in this unit"; fi; }
anchornote start
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
HS=harness/src/probe/map
HFILES='dur7.py logback.xml src'
SFILES='probe/map/H.java probe/map/Main.java probe/map/cascade/Kid.java probe/map/cascade/MergeAllCustomer.java probe/map/cascade/MergeAllPause.java probe/map/cascade/OrphanCustomer.java probe/map/cascade/OrphanPause.java probe/map/cascade/Parent.java probe/map/cascade/PersistCustomer.java probe/map/cascade/PersistPause.java probe/map/cascade/PlainCustomer.java probe/map/cascade/PlainPause.java probe/map/cascade/RemoveCustomer.java probe/map/cascade/RemovePause.java probe/map/ex/ExCustomer.java probe/map/ex/ExPause.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19900 19901 19902 19903 19904 19905 19906 19907 19908 19909"
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
# R.201: the mechanism ("merge did not copy the new pause; PERSIST saved an empty one") may be spoken only because RE-MEASURE 5's
# capture prints it - chk_merge refuses the sentence in this unit's prose when the merge capture does not hold the managed copy's fields
MECH='merge did not copy the new pause; PERSIST saved an empty one'
MECHN=$(cat README.md exercise/README.md exercise/SOLUTION.md | $G -cF -- "$MECH" || true)
echo "  the mechanism sentence: in this unit's prose $MECHN time(s) - spoken only with RE-MEASURE 5's capture (checked after merge, R.201)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/H.java $HS/Main.java $HS/cascade/*.java")
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
    gsub(/FK[0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z]*/, "FK<hash>")
    gsub(/UK[0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z]*/, "UK<hash>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' "Starting probe using Java 25.0.4.1" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'alter table if exists bi_pause add constraint FKm2mc7dy22sku3hjrgease2abs foreign key (customer_id) references bi_customer;' 'alter table if exists t add constraint UKm2mc7dy22sku3hjrgease2abs unique (wallet_id);' 'Referential integrity constraint violation: "FKN4O1XMEYBTE2OGB0AGXTW7569: PUBLIC.PLAIN_PAUSE FOREIGN KEY(CUSTOMER_ID)' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting probe using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'alter table if exists bi_pause add constraint FK<hash> foreign key (customer_id) references bi_customer;' 'alter table if exists t add constraint UK<hash> unique (wallet_id);' 'Referential integrity constraint violation: "FK<hash>: PUBLIC.PLAIN_PAUSE FOREIGN KEY(CUSTOMER_ID)')" ] || die "mask: the planted JDK version, folders, home, identity hash and constraint names (H2's upper-case one too) must be masked"
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



# ---- orphan: her 3-day pause leaves the list - A ALL + orphanRemoval, B PERSIST + REMOVE, A' = A (R.1) ---------------------------
orphan() { rm -f .harness/run/orphan-*.sql
  echo "A - OrphanCustomer (@OneToMany(mappedBy = \"customer\", cascade = CascadeType.ALL, orphanRemoval = true)) and OrphanPause; Kavya's first pause removed from her list:"
  V=(); A=(orphan orphan orphan-a.sql); hrun; hview; script orphan-a.sql
  echo "B - RemoveCustomer (@OneToMany(mappedBy = \"customer\", cascade = {CascadeType.PERSIST, CascadeType.REMOVE})) and RemovePause; the same removal:"
  V=(); A=(orphan remove orphan-b.sql); hrun; hview; script orphan-b.sql
  echo "A' - A again, a fresh JVM:"
  V=(); A=(orphan orphan orphan-a2.sql); hrun; hview
  echo "  the script A' wrote is A's, byte for byte: $(cmp -s .harness/run/orphan-a.sql .harness/run/orphan-a2.sql && echo yes || echo no)"; }

# ---- remove: Kavya herself removed - A ALL + orphanRemoval, B PERSIST + REMOVE, C none (the failure receipt) ------------------------
remove() { local k l
  for k in orphan remove plain; do rm -f .harness/run/remove-$k.sql
    case $k in orphan) l="A - OrphanCustomer (cascade = ALL, orphanRemoval = true)" ;;
               remove) l="B - RemoveCustomer (cascade = {PERSIST, REMOVE})" ;;
               plain) l="C - PlainCustomer (@OneToMany(mappedBy = \"customer\"), no cascade)" ;; esac
    echo "$l; Kavya found and removed - em.remove(customer):"
    V=(); A=(remove $k remove-$k.sql); hrun; hview; script remove-$k.sql; done; }

# ---- replace: A a new list with orphanRemoval, B a new list without it, C clear() with it -----------------------------------------
replace() { local k h l
  for l in "A orphan new" "B remove new" "C orphan clear"; do set -- $l; k=$2; h=$3; rm -f .harness/run/replace-$1.sql
    case $1 in A) echo "A - OrphanCustomer (cascade = ALL, orphanRemoval = true); Kavya's list replaced: setPauses(new ArrayList<>()):" ;;
               B) echo "B - RemoveCustomer (cascade = {PERSIST, REMOVE}, no orphanRemoval); the same replacement:" ;;
               C) echo "C - OrphanCustomer (cascade = ALL, orphanRemoval = true); her own list emptied: getPauses().clear():" ;; esac
    V=(); A=(replace $k $h replace-$1.sql); hrun; hview; done; }

# ---- merge: a detached Kavya, a new 7-day pause - A ALL, B PERSIST only, A' = ALL again (R.1, RED #309), each a fresh JVM ----------
merge() { rm -f .harness/run/merge-*.sql
  echo "A - MergeAllCustomer (@OneToMany(mappedBy = \"customer\", cascade = CascadeType.ALL)) and MergeAllPause; merge() of the detached Kavya:"
  V=(); A=(merge all merge-a.sql); hrun; hview; script merge-a.sql
  echo "B - PersistCustomer (@OneToMany(mappedBy = \"customer\", cascade = CascadeType.PERSIST)) and PersistPause; the same merge():"
  V=(); A=(merge persist merge-b.sql); hrun; hview; script merge-b.sql
  echo "A' - A again, a fresh JVM:"
  V=(); A=(merge all merge-a2.sql); hrun; hview
  echo "  the script A' wrote is A's, byte for byte: $(cmp -s .harness/run/merge-a.sql .harness/run/merge-a2.sql && echo yes || echo no)"; }

# ---- xcheck: the harness's DDL for the anchor's two entities against Boot's, as the owning-side lesson captured it --------------
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # that capture's own published md5 (../c7-unit09/receipts.md5)
$G -qF "$X09" ../c7-unit09/README.md || die "../c7-unit09/README.md no longer states Boot's script md5 $X09 - the number this unit compares with"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
echo "  (terminal only) Boot's script for the anchor's CustomerEntity and PauseEntity: md5 $X09, stated in ../c7-unit09/README.md (its xcheck capture, published $X09CAP)" >&3
BOOT09=""
if [ -f ../c7-unit09/.r-xcheck.out ] && [ "$(md5 -q ../c7-unit09/.r-xcheck.out)" = "$X09CAP" ]; then
  BOOT09=$(sed -n '/^  \.harness\/after\/hibernate-ddl\.sql - every line:$/,/^the harness/p' ../c7-unit09/.r-xcheck.out | sed -n 's/^    //p')
  [ "$(printf '%s\n' "$BOOT09" | wc -l | tr -d ' ')" = 3 ] || die "../c7-unit09/.r-xcheck.out (its published capture, on disk) does not hold Boot's three lines"
  echo "  (terminal only) ../c7-unit09/.r-xcheck.out is on disk (md5 = its published $X09CAP): Boot's three lines read from it (constraint name masked there) - compared line by line after xcheck" >&3
else echo "  (terminal only) ../c7-unit09/.r-xcheck.out is not on disk (a clone: captures are not committed) - the md5 is the comparison" >&3; fi
xcheck() { rm -f .harness/run/xcheck.sql
  echo "the harness's DDL - its own EntityManagerFactory over com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity (from the anchor's jar), a file, never run:"
  V=(); A=(xcheck xcheck.sql); hrun; hview; script xcheck.sql
  echo "  md5 of .harness/run/xcheck.sql: $(md5 -q .harness/run/xcheck.sql)"
  echo "  Boot's script for these entities, as the owning-side lesson's xcheck captured it (Boot 4.1.2, the anchor's jar): md5 $X09"
  echo "  the same, byte for byte (md5): $( [ "$(md5 -q .harness/run/xcheck.sql)" = "$X09" ] && echo yes || echo no)"; }

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
# what a block's SQL logger says between two of its PROBE markers
sqln() { printf '%s\n' "$1" | sed -n "/^  PROBE $2/,/^  PROBE $3/p" | $G -cE "^  DEBUG org\.hibernate\.SQL : $4" || true; }
# R.184 / S2.3: the action's statements both ways - the SQL logger's lines from "the action" to the statistics line, and
# getPrepareStatementCount() - and the driver's prepareStatement beside them
stm() { local W=$1 n=$2 want=$3 s
  s=$(sqln "$W" 'the action' 'statistics' '')
  [ "$s" = "$want" ] && printf '%s\n' "$W" | $G -qF -- "  PROBE statistics: statements prepared (getPrepareStatementCount) $want |" \
    && printf '%s\n' "$W" | $G -qF -- "  PROBE jdbc: prepareStatement $want |" || die "$n: $want statements - the SQL log's lines ($s) and getPrepareStatementCount() and the driver's prepareStatement, all three (R.184)"; }
# the rows by a second connection AFTER the action (the block's last rows line), and the read in a new EntityManager
after() { printf '%s\n' "$1" | sed -n '/^  PROBE the action/,$p' | $G -F -- ', read by a second connection (id | name): ' | tail -1; }
rowsis() { [ "$(after "$1")" = "  PROBE $3_customer, read by a second connection (id | name): $4 | $3_pause (id | days | customer_id): $5" ] || die "$2: after the action, expected $3_customer $4 and $3_pause $5 by a second connection - read: $(after "$1")"; }
SEED='[1 | 3 | 1, 2 | 2 | 1]'
seeded() { has "$1" "  PROBE $3_customer, read by a second connection (id | name): [1 | Kavya] | $3_pause (id | days | customer_id): $SEED" "$2: Kavya and her pauses of 3 and 2 days before the action"; }
PDDL() { printf '    create table %s_pause (days integer not null, customer_id bigint, id bigint generated by default as identity, primary key (id));' "$1"; }
ok0() { has "$1" "  exit 0 · 'GenerationTarget encountered exception': 0" "$2: exit 0"; nhas "$1" 'PROBE EXCEPTION' "$2: no exception"; }
# orphan A (and A'): the 3-day pause gone - one DELETE that returned 1; the 2-day pause left
orA() { local W=$1 n=$2
  seeded "$W" "$n" orphan
  has "$W" '  PROBE jdbc: executeUpdate returned, in order (1):' "$n: one write"
  has "$W" '  PROBE   returned 1 <- delete from orphan_pause where id=?' "$n: delete from orphan_pause where id=? - it returned 1"
  [ "$(sqln "$W" 'after getPauses' 'after commit' 'delete from orphan_pause where id=\?$')" = 1 ] || die "$n: the DELETE comes at the commit, after the list changed"
  rowsis "$W" "$n" orphan '[1 | Kavya]' '[2 | 2 | 1]'
  has "$W" "  PROBE read in a new EntityManager: Kavya's pauses (days) [2]" "$n: a new EntityManager reads [2]"
  stm "$W" "$n" 3
  has "$W" '  PROBE statistics: statements prepared (getPrepareStatementCount) 3 | entity inserts 0 | entity updates (getEntityUpdateCount) 0 | collection recreates 0 | collection updates 1 | collection removes 0 | entity deletes 1' "$n: Statistics"
  ok0 "$W" "$n"; }
chk_orphan() { local O OA OB OA2; O=$(cat .r-orphan.out); ver orphan 3
  OA=$(blk orphan 'A - ' 'B - '); OB=$(blk orphan 'B - ' "A' - "); OA2=$(blk orphan "A' - " '')
  # B first - the plant's named check speaks first: nothing written, the row still points at Kavya
  seeded "$OB" "orphan B" remove
  has "$OB" '  PROBE jdbc: executeUpdate returned, in order (0):' "orphan B (PERSIST + REMOVE): nothing written - 0 writes"
  rowsis "$OB" "orphan B" remove '[1 | Kavya]' "$SEED"
  has "$OB" "  PROBE read in a new EntityManager: Kavya's pauses (days) [3, 2]" "orphan B: a new EntityManager still reads [3, 2] - the row points at Kavya"
  stm "$OB" "orphan B" 2; ok0 "$OB" "orphan B"
  orA "$OA" "orphan A"; orA "$OA2" "orphan A'"
  has "$O" "  the script A' wrote is A's, byte for byte: yes" "orphan: A' = A"
  for l in '    create table orphan_customer (id bigint generated by default as identity, name varchar(255), primary key (id));' "$(PDDL orphan)" \
      '    alter table if exists orphan_pause add constraint FK<hash> foreign key (customer_id) references orphan_customer;'; do has "$OA" "$l" "orphan A: the DDL"; done
  has "$OB" "$(PDDL remove)" "orphan B: the DDL"
  echo "  orphan: Kavya's 3-day pause removed from her list - A ALL + orphanRemoval: delete from orphan_pause where id=? (returned 1), [2 | 2 | 1] left, 3 statements (SQL lines = getPrepareStatementCount = prepareStatement), entity deletes 1 · B PERSIST + REMOVE: 0 writes, [1 | 3 | 1, 2 | 2 | 1] - the row still points at Kavya, a new EntityManager reads [3, 2] · A' = A; H2"; }
reA() { local W=$1 n=$2 t=$3
  seeded "$W" "$n" $t
  has "$W" '  PROBE jdbc: executeUpdate returned, in order (3):' "$n: three writes"
  [ "$(printf '%s\n' "$W" | $G -E '^  PROBE   returned ' | paste -sd'|' -)" = "  PROBE   returned 1 <- delete from ${t}_pause where id=?|  PROBE   returned 1 <- delete from ${t}_pause where id=?|  PROBE   returned 1 <- delete from ${t}_customer where id=?" ] || die "$n: two pause DELETEs, then the customer's, each returned 1"
  rowsis "$W" "$n" $t '[]' '[]'
  has "$W" '  PROBE read in a new EntityManager: no Kavya' "$n: no Kavya"
  stm "$W" "$n" 5
  has "$W" '  PROBE statistics: statements prepared (getPrepareStatementCount) 5 | entity inserts 0 | entity updates (getEntityUpdateCount) 0 | collection recreates 0 | collection updates 0 | collection removes 1 | entity deletes 3' "$n: Statistics"
  ok0 "$W" "$n"; }
FKLINE='Referential integrity constraint violation: "FK<hash>: PUBLIC.PLAIN_PAUSE FOREIGN KEY(CUSTOMER_ID) REFERENCES PUBLIC.PLAIN_CUSTOMER(ID) (CAST(1 AS BIGINT))"; SQL statement:'
chk_remove() { local RA RB RC; ver remove 3
  RA=$(blk remove 'A - ' 'B - '); RB=$(blk remove 'B - ' 'C - '); RC=$(blk remove 'C - ' '')
  reA "$RA" "remove A (ALL + orphanRemoval)" orphan; reA "$RB" "remove B (PERSIST + REMOVE)" remove
  # C - the failure receipt: the trio - exit 1, the exception and its cause, nothing deleted
  seeded "$RC" "remove C" plain
  has "$RC" "  PROBE EXCEPTION jakarta.persistence.RollbackException: Error while committing the transaction [could not execute statement [$FKLINE" "remove C: RollbackException: Error while committing the transaction"
  has "$RC" "  PROBE   Caused by org.hibernate.exception.ConstraintViolationException: could not execute statement [$FKLINE" "remove C: <- ConstraintViolationException"
  has "$RC" "  WARN  org.hibernate.orm.jdbc.error : $FKLINE" "remove C: the referential-integrity line, the FK name masked"
  has "$RC" '  DEBUG org.hibernate.SQL : delete from plain_customer where id=?' "remove C: the customer's DELETE, the one refused"
  has "$RC" '  PROBE jdbc: executeUpdate returned, in order (0):' "remove C: nothing deleted"
  has "$RC" '  PROBE jdbc: prepareStatement 2 | executeUpdate 1 | addBatch 0 | executeBatch 0 | executeQuery 1 | execute 0' "remove C: one executeUpdate called, refused"
  rowsis "$RC" "remove C" plain '[1 | Kavya]' "$SEED"
  has "$RC" "  PROBE read in a new EntityManager: Kavya's pauses (days) [3, 2]" "remove C: Kavya and both pauses still there"
  stm "$RC" "remove C" 2
  has "$RC" "  exit 1 · 'GenerationTarget encountered exception': 0" "remove C: exit 1"
  nhas "$(printf '%s\n' "$RC" | sed -n '/^  PROBE the action/,$p')" 'PROBE after commit' "remove C: the commit did not finish"
  echo "  remove: em.remove(Kavya) - A ALL + orphanRemoval and B PERSIST + REMOVE alike: 2 x delete from <t>_pause, then the customer's (each returned 1), 5 statements, entity deletes 3, no rows left · C no cascade: exit 1 - RollbackException: Error while committing the transaction <- ConstraintViolationException (Referential integrity constraint violation: \"FK<hash>: PUBLIC.PLAIN_PAUSE FOREIGN KEY(CUSTOMER_ID) ...\"), 0 rows deleted, Kavya and [3, 2] still there; H2"; }
HEX='A collection with orphan deletion was no longer referenced by the owning entity instance: probe.map.cascade.OrphanCustomer.pauses'
chk_replace() { local PA PB PC; ver replace 3
  PA=$(blk replace 'A - ' 'B - '); PB=$(blk replace 'B - ' 'C - '); PC=$(blk replace 'C - ' '')
  # A first - 7.4's words, quoted from the capture
  has "$PA" "  PROBE EXCEPTION jakarta.persistence.RollbackException: Error while committing the transaction [$HEX]" "replace A (a new list, orphanRemoval): the RollbackException with 7.4's words"
  has "$PA" "  PROBE   Caused by org.hibernate.HibernateException: $HEX" "replace A: <- HibernateException"
  has "$PA" '  PROBE jdbc: executeUpdate returned, in order (0):' "replace A: 0 writes"
  rowsis "$PA" "replace A" orphan '[1 | Kavya]' "$SEED"
  stm "$PA" "replace A" 2
  has "$PA" "  exit 1 · 'GenerationTarget encountered exception': 0" "replace A: exit 1"
  # B - nothing written; Statistics counts an entity update and a collection recreate + remove, the driver ran no UPDATE (S2.3)
  has "$PB" '  PROBE jdbc: executeUpdate returned, in order (0):' "replace B (a new list, no orphanRemoval): nothing written"
  has "$PB" '  PROBE statistics: statements prepared (getPrepareStatementCount) 2 | entity inserts 0 | entity updates (getEntityUpdateCount) 1 | collection recreates 1 | collection updates 0 | collection removes 1 | entity deletes 0' "replace B: Statistics - entity updates 1, collection recreates 1, collection removes 1"
  [ "$(sqln "$PB" 'the action' 'statistics' '(update|delete|insert) ')" = 0 ] || die "replace B: 0 UPDATE, DELETE or INSERT statements"
  stm "$PB" "replace B" 2
  rowsis "$PB" "replace B" remove '[1 | Kavya]' "$SEED"; ok0 "$PB" "replace B"
  # C - her own list emptied: two DELETEs
  has "$PC" '  PROBE jdbc: executeUpdate returned, in order (2):' "replace C (clear()): two writes"
  [ "$(cnt "$PC" '  PROBE   returned 1 <- delete from orphan_pause where id=?')" = 2 ] || die "replace C: two DELETEs, each returned 1"
  rowsis "$PC" "replace C" orphan '[1 | Kavya]' '[]'
  has "$PC" "  PROBE read in a new EntityManager: Kavya's pauses (days) []" "replace C: Kavya stays, no pauses"
  stm "$PC" "replace C" 4; ok0 "$PC" "replace C"
  echo "  replace: A setPauses(new ArrayList<>()) with orphanRemoval: exit 1 - RollbackException [$HEX] <- org.hibernate.HibernateException, 0 writes, 2 statements · B the same, PERSIST + REMOVE: nothing written, 2 statements, 0 UPDATE/DELETE - Statistics entity updates 1, collection recreates 1, collection removes 1 · C clear() with orphanRemoval: 2 x delete from orphan_pause (each returned 1), Kavya stays; H2"; }
REM5B='  PROBE   her last pause: days 0 | customer null | id null | the detached new pause itself: false | em.contains: false'
mgA() { local W=$1 n=$2
  rowsis "$W" "$n" merge_all '[1 | Kavya]' '[1 | 3 | 1, 2 | 2 | 1, 3 | 7 | 1]'
  seeded "$W" "$n" merge_all
  has "$W" '  DEBUG org.hibernate.SQL : select mac1_0.id,mac1_0.name,p1_0.customer_id,p1_0.id,p1_0.days from merge_all_customer mac1_0 left join merge_all_pause p1_0 on mac1_0.id=p1_0.customer_id where mac1_0.id=?' "$n: merge's select ... left join"
  has "$W" '  PROBE   returned 1 <- insert into merge_all_pause (customer_id,days,id) values (?,?,default)' "$n: insert into merge_all_pause (customer_id,days,id) - returned 1"
  has "$W" '  PROBE   her last pause: days 7 | customer the managed Kavya | id 3 | the detached new pause itself: false | em.contains: true' "$n: the managed copy's new pause - 7 days, the managed Kavya"
  has "$W" "  PROBE read in a new EntityManager: Kavya's pauses (days) [3, 2, 7]" "$n: a new EntityManager reads [3, 2, 7]"
  stm "$W" "$n" 2; ok0 "$W" "$n"; }
chk_merge() { local M MA MB MA2; M=$(cat .r-merge.out); ver merge 3
  MA=$(blk merge 'A - ' 'B - '); MB=$(blk merge 'B - ' "A' - "); MA2=$(blk merge "A' - " '')
  # B - the hook first: 3 | 0 | null, no error
  rowsis "$MB" "merge B (PERSIST only): the hook 3 | 0 | null" persist '[1 | Kavya]' '[1 | 3 | 1, 2 | 2 | 1, 3 | 0 | null]'
  # then R.201: the mechanism sentence is in the prose only if RE-MEASURE 5's capture prints the managed copy's fields
  if [ "$MECHN" != 0 ]; then printf '%s\n' "$MB" | $G -qxF -- "$REM5B" || die "the mechanism sentence ('$MECH') is in this unit's prose, but merge B's capture does not print the managed copy's fields (RE-MEASURE 5, R.201) - cut the sentence or capture it"; fi
  seeded "$MB" "merge B" persist
  has "$MB" '  PROBE   returned 1 <- insert into persist_pause (customer_id,days,id) values (?,?,default)' "merge B: one INSERT"
  has "$MB" "  PROBE read in a new EntityManager: Kavya's pauses (days) [3, 2]" "merge B: the new row is not Kavya's"
  has "$MB" "$REM5B" "merge B: the managed copy's new pause - days 0, customer null, not the detached object (RE-MEASURE 5)"
  has "$MB" '  PROBE   the detached new pause: days 7 | customer the detached Kavya | id null | em.contains: false' "merge B: the detached pause keeps its 7 days, never managed"
  [ "$(sqln "$MB" 'before commit' 'after commit' 'insert into persist_pause ')" = 1 ] && [ "$(sqln "$MB" 'the action' 'after merge' 'insert ')" = 0 ] || die "merge B: the INSERT at the commit, not at merge()"
  stm "$MB" "merge B" 5; ok0 "$MB" "merge B"; nhas "$MB" '  WARN ' "merge B: no WARN"
  mgA "$MA" "merge A (ALL)"; mgA "$MA2" "merge A' (ALL again, a fresh JVM)"
  has "$M" "  the script A' wrote is A's, byte for byte: yes" "merge: A' = A"
  has "$MB" "$(PDDL persist)" "merge B: customer_id nullable (Hibernate's default)"
  echo "  merge: a detached Kavya + a new 7-day pause - A ALL: select ... left join, insert (customer_id,days,id), the row 3 | 7 | 1 · B PERSIST only: the row 3 | 0 | null, no error, no WARN; the managed copy after merge holds days 0 | customer null, not the detached pause (RE-MEASURE 5), its INSERT at the commit · A' = A from a fresh JVM: 3 | 7 | 1; H2"; }
# R.212 (RED #308): the harness's script for the anchor's two entities = Boot's as unit 09 captured it, by md5
chk_xcheck() { local XC l; XC=$(cat .r-xcheck.out); ver xcheck 1
  has "$XC" "  md5 of .harness/run/xcheck.sql: $X09" "xcheck: the harness's script is Boot's as the owning-side lesson captured it ($X09)"
  has "$XC" '  the same, byte for byte (md5): yes' "xcheck: the same"
  [ "$(printf '%s\n' "$XC" | sed -n '/xcheck.sql - every line:$/,/^  md5 of/p' | $G -c '^    ')" = 3 ] || die "xcheck: three lines"
  if [ -n "$BOOT09" ]; then printf '%s\n' "$BOOT09" | while IFS= read -r l; do has "$XC" "    $l" "xcheck: Boot's line as ../c7-unit09/.r-xcheck.out holds it"; done; fi
  echo "  xcheck: the harness's DDL for the anchor's CustomerEntity and PauseEntity, md5 $X09 = Boot's script as unit 09 captured it (R.212)"; }
EXQ="Your turn: the README empties Kavya's pauses by handing her a new list, and the commit fails. Empty the list she already has."
EXH='A collection with orphan deletion was no longer referenced by the owning entity instance: probe.map.ex.ExCustomer.pauses'
chk_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    exit 1' "    PROBE EXCEPTION jakarta.persistence.RollbackException: Error while committing the transaction [$EXH]" "    PROBE   Caused by org.hibernate.HibernateException: $EXH" \
        "    PROBE Kavya's pauses emptied - executeUpdate calls: 0" '    PROBE ex_pause, read by a second connection: 2 rows'; do has "$ER" "$l" "exercise: the README - a new list, the commit fails, 0 writes"; done
    for l in '    exit 0' "    PROBE Kavya's pauses emptied - executeUpdate calls: 2" '    PROBE ex_pause, read by a second connection: 0 rows'; do has "$ES" "$l" "exercise: the solution - clear(), two DELETEs"; done
    [ "$(cnt "$ES" '    PROBE   returned 1 <- delete from ex_pause where id=?')" = 2 ] || die "exercise: the solution - two DELETEs, each returned 1"
    nhas "$ES" 'EXCEPTION' "exercise: the solution throws nothing"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" = 23 ] || die "exercise: the spoken line is 23 words (R.203)"
  $G -qxF '        pauses = new ArrayList<>();' harness/src/probe/map/ex/ExCustomer.java || die "exercise: ExCustomer ships emptyPauses() as a new list"
  echo "  exercise: bash and zsh alike - the README as written (a new list): exit 1, RollbackException <- HibernateException [$EXH], executeUpdate calls 0, 2 rows; the solution (one line: clear()): exit 0, 2 DELETEs each returned 1, 0 rows; 23 words"; }
cap orphan orphan; chk_orphan
cap remove remove; chk_remove
cap replace replace; chk_replace
cap merge merge; chk_merge
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
  ! $G -qE 'FK[0-9A-Za-z]{11,}' "$f" || die "$f holds a constraint name, unmasked"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -qE 'https?://' || die "$f runs a command with a URL - this unit makes no request"; done
for f in .r-*.out; do ! $G -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.map' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
# R.213: SQL keywords are never a name here (the harness's tables and columns)
! $G -rqiwE '(class|record|String|Long|int|List|Kid|Parent|ExPause|ExCustomer) +(order|offset|user|value|key)\b' harness/src/probe/map/cascade harness/src/probe/map/ex || die "a harness entity or field is named after an SQL keyword (R.213; the entities, not the SQL the harness sends)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory"
echo "  hygiene: $(ls .r-*.out | wc -l | tr -d ' ') captures and $LOGS harness logs; 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, port or stack frame in any capture; every JVM pinned; no kill by name; no bare wait; options as arrays; no H2 file; no dish name"

# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19900-19909 at the end; none bound by this unit"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit11: every capture 3/3 and = published; every spoken number asserted; no port bound"
