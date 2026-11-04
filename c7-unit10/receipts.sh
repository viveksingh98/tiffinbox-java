#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · @OneToOne and @ManyToMany - this unit's receipts. No change to the anchor: anchor/ is the link to ../c7-unit09/after,
# the tree Section 2 froze (= ../c7-tiffinbox when this unit was built; compared at the start and the end, a note when they differ,
# never a stop - R.211). Five captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every
# number and string the video says is asserted right after its capture by a check that can fail. One database: H2, in each harness
# JVM's memory, gone with it (brief ⚑2: 10 is an H2 unit; no container, no TiffinBox JVM, no port bound).
#   one       a customer and his wallet, one-to-one, both sides LAZY: the owning side's DDL (wallet_id bigint unique); A - find the
#             customer: one SELECT, isLoaded false, the wallet a Hibernate proxy; B - find the wallet (mappedBy): two SELECTs, the
#             customer loaded, its own class (no proxy) - both witnesses, isLoaded AND the class, asserted (RED #323)
#   many      Ravi's three favourite meals (Platter, Salad, Soup), then Salad removed: A a List (a bag) - the DELETE that returned 3
#             and two INSERTs; B a Set - one DELETE that returned 1; C a List with @OrderColumn - a DELETE and an UPDATE; each with
#             its DDL, the join table by a second connection before (3 rows) and after (2), and what each executeUpdate returned (RED #321)
#   middle    the entity in the middle: Subscription (customer, meal, mealsPerDay, since) - its DDL, three INSERTs, the row
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
# "UK<hash>" (hashes of the table and column names, not anyone's code). A harness JVM's log is printed whole (every line,
# trailing spaces dropped).
# Ports (§P, 19890-19899): none bound. 19899 is checked free at the start and the end, with 19890-19898, 18425 (TiffinBox's
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
SFILES='probe/map/H.java probe/map/Main.java probe/map/ex/ExFan.java probe/map/ex/ExMeal.java probe/map/many/ListFan.java probe/map/many/Meal.java probe/map/many/OrderedFan.java probe/map/many/SetFan.java probe/map/middle/SubCustomer.java probe/map/middle/Subscription.java probe/map/one/Wallet.java probe/map/one/WalletCustomer.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19890 19891 19892 19893 19894 19895 19896 19897 19898 19899"
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
# R.201: "with bytecode enhancement it can wait" is NOT measured here (no enhancement plugin in the seed; the brief's CARRIED) - a line
# of this unit's prose that names enhancement must say, in that line, that it is not measured; and no capture names it (chk_one)
EN=$($G -niE 'enhanc' README.md exercise/README.md exercise/SOLUTION.md | $G -viF 'not measured' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$EN" ] || die "a line names bytecode enhancement without 'not measured' in it (R.201 - it is not measured here): $EN"
echo "  bytecode enhancement: every line of README.md and exercise/ that names it says 'not measured' in it (R.201)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/H.java $HS/Main.java $HS/one/*.java $HS/many/*.java $HS/middle/*.java")
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
    gsub(/FK[0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z]*/, "FK<hash>")
    gsub(/UK[0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z]*/, "UK<hash>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' "Starting probe using Java 25.0.4.1" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'alter table if exists bi_pause add constraint FKm2mc7dy22sku3hjrgease2abs foreign key (customer_id) references bi_customer;' 'alter table if exists t add constraint UKm2mc7dy22sku3hjrgease2abs unique (wallet_id);' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting probe using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'alter table if exists bi_pause add constraint FK<hash> foreign key (customer_id) references bi_customer;' 'alter table if exists t add constraint UK<hash> unique (wallet_id);')" ] || die "mask: the planted JDK version, folders, home, identity hash and constraint names must be masked"
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



# ---- one: a customer and his wallet, one-to-one - A the owning side, B the inverse side -------------------------------------
one() { rm -f .harness/run/one-a.sql .harness/run/one-b.sql
  echo "A - WalletCustomer (the owning side: @OneToOne(fetch = LAZY) @JoinColumn(name = \"wallet_id\") Wallet wallet) and Wallet (@OneToOne(mappedBy = \"wallet\", fetch = LAZY)); find the customer:"
  V=(); A=(one owner one-a.sql); hrun; hview; script one-a.sql
  echo "B - the same two entities; find the wallet - the inverse side, fetch = LAZY written on it:"
  V=(); A=(one inverse one-b.sql); hrun; hview
  echo "  the script B wrote is A's, byte for byte: $(cmp -s .harness/run/one-a.sql .harness/run/one-b.sql && echo yes || echo no)"; }

# ---- many: three favourite meals, Salad removed - A a List, B a Set, C a List with @OrderColumn --------------------------------
many() { local k l
  for k in list set ordered; do rm -f .harness/run/$k.sql
    case $k in list) l="A - ListFan: @ManyToMany List<Meal> favourites (no @OrderColumn)" ;;
                set) l="B - SetFan: @ManyToMany Set<Meal> favourites" ;;
                ordered) l="C - OrderedFan: @ManyToMany @OrderColumn List<Meal> favourites" ;; esac
    echo "$l; Ravi's three favourites, then Salad removed in a new transaction:"
    V=(); A=(many $k $k.sql); hrun; hview; script $k.sql; done; }

# ---- middle: the entity in the middle ------------------------------------------------------------------------------------------
middle() { rm -f .harness/run/middle.sql
  echo "Subscription (@ManyToOne(optional = false) SubCustomer customer, @ManyToOne(optional = false) Meal meal, int mealsPerDay, LocalDate since):"
  V=(); A=(middle middle.sql); hrun; hview; script middle.sql; }

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
# what a block's SQL logger and counters say, between two of its PROBE markers
sqln() { printf '%s\n' "$1" | sed -n "/^  PROBE $2/,/^  PROBE $3/p" | $G -cE "^  DEBUG org\.hibernate\.SQL : $4" || true; }
# R.184: a statement count both ways - the SQL logger's lines and getPrepareStatementCount() - and the driver's prepareStatement beside them
stm() { local W=$1 n=$2 want=$3 a=$4 b=$5 s
  s=$(sqln "$W" "$a" "$b" '')
  [ "$s" = "$want" ] && printf '%s\n' "$W" | $G -qF -- "  PROBE statistics: statements prepared (getPrepareStatementCount) $want |" \
    && printf '%s\n' "$W" | $G -qF -- "  PROBE jdbc: prepareStatement $want |" || die "$n: $want statements - the SQL log's lines ($s) and getPrepareStatementCount() and the driver's prepareStatement, all three (R.184)"; }
# the one-to-one: "the unique is what makes it one-to-one"; A - one SELECT, the wallet NOT loaded, a proxy; B - two SELECTs, the
# customer loaded, its own class. The lazy witness is BOTH isLoaded (the persistence unit's own answer) AND the class (RED #323):
# lazy() takes the isLoaded line and the class line; a check of the class alone cannot tell a proxy that was initialized from one
# that was not (the plant in README.md, "Planted faults")
OWNDDL='    create table wallet_customer (id bigint generated by default as identity, wallet_id bigint unique, name varchar(255), primary key (id));'
lazy() { has "$1" '  PROBE isLoaded(customer, "wallet") (emf.getPersistenceUnitUtil()): false' "one A: the wallet not loaded - isLoaded false (the witness for lazy)"
  has "$1" '  PROBE the wallet'"'"'s class: probe.map.one.Wallet$HibernateProxy' "one A: the wallet a Hibernate proxy"; }
chk_one() { local O OA OB; O=$(cat .r-one.out); ver one 2
  OA=$(blk one 'A - ' 'B - '); OB=$(blk one 'B - ' '')
  for l in "$OWNDDL" '    create table wallet (balance integer not null, id bigint generated by default as identity, primary key (id));' \
      '    alter table if exists wallet_customer add constraint FK<hash> foreign key (wallet_id) references wallet;'; do has "$OA" "$l" "one: the owning side's DDL"; done
  has "$O" '  the script B wrote is A'"'"'s, byte for byte: yes' "one: one schema for A and B"
  for b in "$OA" "$OB"; do has "$b" '  PROBE wallet_customer, read by a second connection (id | name | wallet_id): [1 | Ravi | 1] | wallet (id | balance): [1 | 500]' "one: Ravi and his wallet"
    has "$b" "  exit 0 · 'GenerationTarget encountered exception': 0" "one: exit 0"; done
  # A: the owning side - lazy first (both witnesses), then one SELECT, of wallet_customer only
  lazy "$OA"
  stm "$OA" "one A (find the customer)" 1 'A - the owning side' 'after find'
  [ "$(sqln "$OA" 'A - the owning side' 'after find' 'select .* from wallet_customer wc1_0 where wc1_0\.id=\?$')" = 1 ] || die "one A: the SELECT is wallet_customer's, by id"
  # B: the inverse side - two SELECTs: the wallet, then at once the customer that points at it; loaded, no proxy
  stm "$OB" "one B (find the wallet)" 2 'B - the inverse side' 'after find'
  has "$OB" '  DEBUG org.hibernate.SQL : select w1_0.id,w1_0.balance from wallet w1_0 where w1_0.id=?' "one B: the wallet's SELECT"
  has "$OB" '  DEBUG org.hibernate.SQL : select wc1_0.id,wc1_0.name,wc1_0.wallet_id from wallet_customer wc1_0 where wc1_0.wallet_id=?' "one B: the customer's SELECT, by wallet_id"
  [ "$(printf '%s\n' "$OB" | $G -n -E 'from wallet w1_0|from wallet_customer wc1_0 where wc1_0.wallet_id|PROBE after find' | cut -d: -f1 | paste -sd' ' - | awk '{ print ($1 < $2 && $2 < $3) }')" = 1 ] || die "one B: the wallet's SELECT, then the customer's, both inside find()"
  has "$OB" '  PROBE isLoaded(wallet, "customer") (emf.getPersistenceUnitUtil()): true' "one B: the customer loaded - isLoaded true"
  has "$OB" "  PROBE the customer's class: probe.map.one.WalletCustomer" "one B: the customer's own class, no proxy"
  ! printf '%s\n' "$O" | $G -qiE 'enhanc' || die "one: bytecode enhancement is not measured here (R.201) - no capture names it"
  echo "  one: the owning side's DDL wallet_id bigint unique (+ FK); A find(customer) - 1 statement (1 SQL line = getPrepareStatementCount 1), isLoaded(customer, \"wallet\") false, the wallet probe.map.one.Wallet\$HibernateProxy · B find(wallet), fetch = LAZY on the mappedBy side - 2 statements: the wallet, then select ... from wallet_customer where wallet_id=? inside find(); isLoaded true, class WalletCustomer (no proxy); Hibernate 7.4.13.Final, H2"; }
# the many-to-many: the hook. A List (a bag): Salad removed -> a DELETE that RETURNED 3 (every row of Ravi's) and two INSERTs - "all
# three rows" only from executeUpdate's own return value (RED #321), the join table 3 rows -> 2 by a second connection; a Set: one
# DELETE that returned 1; @OrderColumn: a DELETE and an UPDATE. Statistics: collection updates 1 for all three (S2.3, R.208)
mk() { local W0=$1 W n=$2 t=$3 F="$3, read by a second connection (3 rows)"; shift 3
  W=$(printf '%s\n' "$W0" | sed -n "/^  PROBE $F/,\$p")                 # from the join table's first read on: the removal's transaction
  has "$W" "  PROBE jdbc: executeUpdate returned, in order ($4):" "$n: $4 writes after the removal (the driver's executeUpdate calls, each listed with what it returned)"
  has "$W" "  PROBE $t, read by a second connection (3 rows): $1" "$n: three rows before"
  has "$W" "  PROBE $t, read by a second connection (2 rows): $2" "$n: two rows after"
  has "$W" '  PROBE read in a new EntityManager: Ravi'"'"'s favourites [Platter, Soup]' "$n: a new EntityManager reads Platter and Soup"
  has "$W" "  PROBE statistics: statements prepared (getPrepareStatementCount) $3 | entity inserts 0 | entity updates (getEntityUpdateCount) 0 | collection recreates 0 | collection updates 1" "$n: Statistics - collection updates 1, $3 statements"
  stm "$W" "$n" "$3" "$F" 'after commit'
  [ "$(sqln "$W" "$F" 'before remove' 'select ')" = 2 ] || die "$n: two of the $3 are the SELECTs that read Ravi and his favourites"
  [ "$(sqln "$W" 'before remove' 'before commit' '(delete|insert|update) ')" = 0 ] && [ "$(sqln "$W" 'before commit' 'after commit' '(delete|insert|update) ')" = "$4" ] || die "$n: the $4 writes come after before commit, none at remove()"
  has "$W" "  exit 0 · 'GenerationTarget encountered exception': 0" "$n: exit 0"; }
chk_many() { local M MA MB MC; M=$(cat .r-many.out); ver many 3
  MA=$(blk many 'A - ' 'B - '); MB=$(blk many 'B - ' 'C - '); MC=$(blk many 'C - ' '')
  # A - the hook: delete all (returned 3), insert two back
  mk "$MA" "many A (List)" list_fan_favourites '[1 | 1, 2 | 1, 3 | 1]' '[1 | 1, 3 | 1]' 5 3
  has "$MA" '  PROBE   returned 3 <- delete from list_fan_favourites where list_fan_id=?' "many A: the DELETE returned 3 - all three of Ravi's rows (RED #321)"
  [ "$(cnt "$MA" '  PROBE   returned 1 <- insert into list_fan_favourites (list_fan_id,favourites_id) values (?,?)')" = 2 ] || die "many A: two INSERTs put Platter and Soup back"
  # the DDL: a List's join table has no primary key; a Set's has (favourites_id, set_fan_id); @OrderColumn a position column + key
  has "$MA" '    create table list_fan_favourites (favourites_id bigint not null, list_fan_id bigint not null);' "many A: the List's join table, no primary key"
  ! printf '%s\n' "$MA" | $G -E '^    create table list_fan_favourites ' | $G -qF 'primary key' || die "many A: the List's join table has no primary key"
  has "$MB" '    create table set_fan_favourites (favourites_id bigint not null, set_fan_id bigint not null, primary key (favourites_id, set_fan_id));' "many B: the Set's join table, its primary key"
  has "$MC" '    create table ordered_fan_favourites (favourites_order integer not null check ((favourites_order>=0)), favourites_id bigint not null, ordered_fan_id bigint not null, primary key (favourites_order, ordered_fan_id));' "many C: @OrderColumn's position column and key"
  # B - one DELETE, by both keys, returned 1
  mk "$MB" "many B (Set)" set_fan_favourites '[1 | 1, 2 | 1, 3 | 1]' '[1 | 1, 3 | 1]' 3 1
  has "$MB" '  PROBE   returned 1 <- delete from set_fan_favourites where set_fan_id=? and favourites_id=?' "many B: one DELETE, Salad's row"
  # C - a DELETE of the last position and an UPDATE that moves Soup into Salad's
  mk "$MC" "many C (@OrderColumn)" ordered_fan_favourites '[0 | 1 | 1, 1 | 2 | 1, 2 | 3 | 1]' '[0 | 1 | 1, 1 | 3 | 1]' 4 2
  for l in '  PROBE   returned 1 <- delete from ordered_fan_favourites where ordered_fan_id=? and favourites_order=?' \
      '  PROBE   returned 1 <- update ordered_fan_favourites set favourites_id=? where ordered_fan_id=? and favourites_order=?'; do has "$MC" "$l" "many C: a DELETE and an UPDATE"; done
  echo "  many: Salad removed from three favourites - A List (no primary key on its join table): delete from list_fan_favourites where list_fan_id=? returned 3, then 2 INSERTs (3 writes, 5 statements = 5 SQL lines = getPrepareStatementCount, 2 of them the reads) · B Set (primary key (favourites_id, set_fan_id)): 1 DELETE returned 1 (3 statements) · C @OrderColumn: a DELETE and an UPDATE (Soup into position 1; 4 statements) · each 3 rows -> 2 by a second connection, a new EntityManager reads [Platter, Soup]; Statistics collection updates 1 all three; H2"; }
# the entity in the middle: "how many a day, and since when - a join table has nowhere to put them"
SUBDDL='    create table subscription (meals_per_day integer not null, since date, customer_id bigint not null, id bigint generated by default as identity, meal_id bigint not null, primary key (id));'
chk_middle() { local D; D=$(cat .r-middle.out); ver middle 1
  for l in "$SUBDDL" '  PROBE subscription, read by a second connection (id | customer_id | meal_id | meals_per_day | since): [1 | 1 | 1 | 2 | 2026-11-04]' \
      '  DEBUG org.hibernate.SQL : insert into subscription (customer_id,meal_id,meals_per_day,since,id) values (?,?,?,?,default)' \
      '  PROBE statistics: statements prepared (getPrepareStatementCount) 3 | entity inserts 3 | entity updates (getEntityUpdateCount) 0 | collection recreates 0 | collection updates 0' \
      "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$D" "$l" "middle"; done
  [ "$(printf '%s\n' "$D" | $G -c '^  DEBUG org\.hibernate\.SQL : insert into ')" = 3 ] || die "middle: three INSERTs"
  echo "  middle: subscription (meals_per_day integer not null, since date, customer_id bigint not null, ..., meal_id bigint not null) - 3 INSERTs (meal, customer, subscription), the row 1 | 1 | 1 | 2 | 2026-11-04; H2"; }
# R.212 (RED #308): the harness's script for the anchor's two entities = Boot's as unit 09 captured it, by md5
chk_xcheck() { local XC l; XC=$(cat .r-xcheck.out); ver xcheck 1
  has "$XC" "  md5 of .harness/run/xcheck.sql: $X09" "xcheck: the harness's script is Boot's as the owning-side lesson captured it ($X09)"
  has "$XC" '  the same, byte for byte (md5): yes' "xcheck: the same"
  [ "$(printf '%s\n' "$XC" | sed -n '/xcheck.sql - every line:$/,/^  md5 of/p' | $G -c '^    ')" = 3 ] || die "xcheck: three lines"
  if [ -n "$BOOT09" ]; then printf '%s\n' "$BOOT09" | while IFS= read -r l; do has "$XC" "    $l" "xcheck: Boot's line as ../c7-unit09/.r-xcheck.out holds it"; done; fi
  echo "  xcheck: the harness's DDL for the anchor's CustomerEntity and PauseEntity, md5 $X09 = Boot's script as unit 09 captured it (R.212)"; }
EXQ="Your turn: the README removes one favourite meal and Hibernate rewrites the whole list. Change the collection type so it doesn't."
chk_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    exit 0' "    PROBE Salad removed from Kavya's favourites - executeUpdate calls: 3" '    PROBE   returned 3 <- delete from ex_fan_favourites where ex_fan_id=?' \
        '    PROBE ex_fan_favourites, read by a second connection: 2 rows'; do has "$ER" "$l" "exercise: the README - the List rewrites itself (3 writes)"; done
    [ "$(cnt "$ER" '    PROBE   returned 1 <- insert into ex_fan_favourites (ex_fan_id,favourites_id) values (?,?)')" = 2 ] || die "exercise: the README - two INSERTs back"
    for l in '    exit 0' "    PROBE Salad removed from Kavya's favourites - executeUpdate calls: 1" '    PROBE   returned 1 <- delete from ex_fan_favourites where ex_fan_id=? and favourites_id=?' \
        '    PROBE ex_fan_favourites, read by a second connection: 2 rows'; do has "$ES" "$l" "exercise: the solution - one DELETE (1 write)"; done
    nhas "$ES" 'insert into' "exercise: the solution inserts nothing"
    nhas "$b" 'EXCEPTION' "exercise: no exception"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" = 21 ] || die "exercise: the spoken line is 21 words (R.203)"
  $G -qxF '    private List<ExMeal> favourites = new ArrayList<>();' harness/src/probe/map/ex/ExFan.java || die "exercise: ExFan ships its favourites as a List"
  echo "  exercise: bash and zsh alike - the README as written (a List): exit 0, executeUpdate calls 3 - the DELETE returned 3, two INSERTs back; the solution (one line: a Set): exit 0, 1 - one DELETE returned 1; 2 rows left both times; 21 words"; }
cap one one; chk_one
cap many many; chk_many
cap middle middle; chk_middle
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
! $G -rqiwE '(class|record|String|Long|int|LocalDate|Meal|Wallet|WalletCustomer|SubCustomer|ExMeal) +(order|offset|user|value|key)\b' harness/src/probe/map/one harness/src/probe/map/many harness/src/probe/map/middle harness/src/probe/map/ex || die "a harness entity or field is named after an SQL keyword (R.213; the entities, not the SQL the harness sends)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory"
echo "  hygiene: $(ls .r-*.out | wc -l | tr -d ' ') captures and $LOGS harness logs; 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, port or stack frame in any capture; every JVM pinned; no kill by name; no bare wait; options as arrays; no H2 file; no dish name"

# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19890-19899 at the end; none bound by this unit"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit10: every capture 3/3 and = published; every spoken number asserted; no port bound"
