#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · JPA, Hibernate, Spring Data: Three Different Things - this unit's receipts. No change to the anchor: anchor/ is the
# link to ../c7-unit03/after (= ../c7-tiffinbox, asserted below). Four captures, each run three times and hashed; cap() DIES when a
# hash differs from receipts.md5; every number the video says is asserted by a check that can fail, right after its capture.
#   tree      the anchor's dependency tree, read from the reactor root (R.181), beside the 4.1.2 tree without the data starter (the
#             first-entity lesson's previous tree with its one line, the parent at 4.1.2): the artifacts added, by name, the ones
#             removed, the scope moves, the versions read off the tree; where the specification's jar prints; BOOT-INF/lib of the
#             two jars, before and after, each difference with its source
#   owners    who owns which class: unzip -l of each jar in .m2-demo, one listing per jar, each class looked for in all of them
#   poms      who needs whom: the POMs as they say it (hibernate-core's dependencies, spring-data-jpa's optional Hibernate and
#             EclipseLink), and the path from the starter to hibernate-core, read off the tree's indentation
#   exercise  exercise/README.md's lines, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i shell
#             - /bin/bash, then again in /bin/zsh -f; each block a fresh Maven run
# The anchor is never built in place: it is copied to .harness/after; the baseline to .harness/base; each is built there, offline.
# Hibernate 8's status is read from ONE dated file outside the repository (../../../data-jpa-hibernate/_research/
# hibernate-core-metadata-2026-11-03.xml, fetched once by this unit's author; its md5 below): no file, no status - the line says
# "refused" and no capture depends on it. Commands are printed exactly as they run: each goes through eval. harness/dur7.py
# (Course 7's builders' duration pattern, byte for byte, md5 asserted) gates this unit's prose. "$M2" is this unit's own
# repository, .m2-demo. Every grep that counts is /usr/bin/grep (BSD grep 2.6.0): an interactive zsh may alias grep to another
# program.
# The network: every Maven run is offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline run missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. At run time nothing is sent anywhere: no port is bound, no JVM starts but Maven's.
# Masks (README.md declares each; awk gsub only): this folder "…", the folder above it "…/..", home "~", your user name "<user>";
# " using Java <version>". No duration is captured: no Maven log line is printed, only what was read from it.
# Ports (§P, 19810-19819): none bound; all ten checked free first and last, 19819 among them.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
G=/usr/bin/grep
TAB=$(printf '\t')
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $mpid
# (a Maven run, with every process under it), $xpid (an exercise shell, with every process under it); then sweep(): any Maven of
# this run still alive in its process group is stopped. After an interrupt a capture's unfinished runs (.r-NAME.1-3) go too;
# after a failed check they stay. The clean-up ignores a second Ctrl-C, and the script still exits 130 after an interrupt
# (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") { print $1 }' | paste -sd' ' -) || l=""
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
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the builds compile with it)"
for t in python3 rsync lsof mvn md5 cmp unzip /bin/zsh $G; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a JVM flag or a build setting (the problem-detail lesson's loop: a canary planted under
# every name first, and the run stops if one survives).
for v in JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS CLASSPATH DEBUG; do export "$v=planted-canary"; done
for v in JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS CLASSPATH DEBUG; do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# No anchor change: anchor/ is the link to ../c7-unit03/after, which IS ../c7-tiffinbox, byte for byte (local repository and build
# output aside)
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit03/after ] || die "anchor must be the link to ../c7-unit03/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
D_=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true)
[ -z "$D_" ] || die "anchor/ is not ../c7-tiffinbox: $(printf '%s\n' "$D_" | head -3 | paste -sd';' -)"
echo "  the anchor: anchor/ -> ../c7-unit03/after; diff -rq -x .m2-demo -x target -x secrets against ../c7-tiffinbox: empty - no anchor change"
# The baseline's source: the first-entity lesson's previous tree (its before/, the link to Course 6's last tree), and its one line
B4=../c7-unit03/before
[ -L $B4 ] && [ "$(readlink $B4)" = ../c6-unit31/after ] && [ -f $B4/pom.xml ] && [ -f ../c7-unit03/README.md ] || die "$B4 must be the link to ../c6-unit31/after, with its pom.xml, beside ../c7-unit03/README.md"
for f in harness/dur7.py harness/pom.py exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = 'dur7.py pom.py' ] || die "harness/ holds another file"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
# Course 7's builders' duration pattern, byte for byte (Section 1 states no duration, R.172)
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="19810 19811 19812 19813 19814 19815 19816 19817 19818 19819"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
[ "$(listeners 19819)" = 0 ] || die "19819 is taken"
# The -pl tree reads tiffinbox-core's POM from the repository when the reactor does not build it: this unit never installs, and a
# tiffinbox POM in .m2-demo would hide the WARNING the exercise is about
[ ! -e .m2-demo/com/tiffinbox ] || die ".m2-demo holds com/tiffinbox - an installed TiffinBox would change what the -pl tree reads; remove .m2-demo/com/tiffinbox (the seed holds none)"
rm -rf .harness
mkdir -p .harness

# ---- duration words: 0 - dur7's DUR over this unit's prose (README.md, the exercise's two files); a match stops the run -----------
cat > .harness/dur.py <<'PY'
import importlib.util, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
n = 0
for f in sys.argv[2:]:
    for i, l in enumerate(open(f, encoding="utf-8"), 1):
        for w in m.DUR.finditer(l):
            n += 1
            print("  %s line %d: %s" % (f, i, w.group(0)))
print("duration words: %d" % n)
PY
DW=$(python3 -I -B .harness/dur.py harness/dur7.py README.md exercise/README.md exercise/SOLUTION.md) || die "dur7's gate did not run"
[ "$(printf '%s\n' "$DW" | tail -1)" = 'duration words: 0' ] || die "dur7.DUR found duration words (Section 1 states none, R.172): $(printf '%s\n' "$DW" | paste -sd';' -)"
echo "  duration words: 0 (dur7.DUR over README.md, exercise/README.md, exercise/SOLUTION.md)"

# ---- the commands: the anchor's own lines and the first-entity lesson's move line, each read from its README and asserted there
# ---- whole; this unit's lines, from README.md, each asserted to be derived from them -------------------------------------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_TREE=$(readme 'mvn -B dependency:tree')
R_PLAIN=$(readme 'mvn -B package')
R_MOVE="sed 's#<version>4.1.1</version>#<version>4.1.2</version>#' pom.xml > pom.xml.new && mv pom.xml.new pom.xml"
$G -m1 -xF -- "$R_MOVE" ../c7-unit03/README.md > /dev/null || die "../c7-unit03/README.md no longer gives its move line: $R_MOVE"
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_TREE=$(mine 'mvn -o -B -Dmaven.repo.local="$M2" dependency:tree -DoutputFile=tree.txt')
L_PKG=$(mine 'mvn -o -B -Dmaven.repo.local="$M2" -DskipTests package')
L_POM=$(mine 'python3 -I -B harness/pom.py deps "$M2/org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.pom"')
[ "${R_TREE/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" } -DoutputFile=tree.txt" = "$L_TREE" ] || die "the tree line must be the anchor's README line made -o -B -Dmaven.repo.local=\"\$M2\", with -DoutputFile=tree.txt, and nothing else"
[ "${R_PLAIN/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" -DskipTests }" = "$L_PKG" ] || die "the package line must be the anchor's README line made -o -B -Dmaven.repo.local=\"\$M2\", with -DskipTests, and nothing else"
echo "  the commands: anchor/README.md gives the 2 lines this script derives from, ../c7-unit03/README.md the move line; README.md the $($G -c '^L_[A-Z]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV · Maven $(mvn -v 2> /dev/null | sed -n 's/^Apache Maven \([0-9.]*\).*/\1/p') · the shell running this script: bash $BASH_VERSION" >&3

# ---- build: the two trees copied under .harness, built there with the anchor's package line, offline; the tree line run once
# ---- on each before the captures (so its plugin is in .m2-demo when the captures run it offline) ----------------------------
M2="$PWD/.m2-demo"
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
# the anchor, copied; the baseline: the first-entity lesson's previous tree, copied, and that lesson's move line run on the copy
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/after/
[ -z "$(diff -rq anchor/ .harness/after/ -x target -x secrets -x .m2-demo 2>&1)" ] || die "the copy of the anchor differs from it"
rsync -a --exclude target --exclude secrets --exclude .m2-demo "$B4/" .harness/base/
(cd .harness/base && eval "$R_MOVE") || die "the move line failed on .harness/base"
MD_=$(diff -U0 "$B4/pom.xml" .harness/base/pom.xml | sed 1,2d || true)
[ "$(printf '%s\n' "$MD_" | paste -sd'|' -)" = '@@ -13 +13 @@|-    <version>4.1.1</version>|+    <version>4.1.2</version>' ] || die "the move must change pom.xml's line 13 from 4.1.1 to 4.1.2 and nothing else: $(printf '%s\n' "$MD_" | paste -sd'|' -)"
[ "$(diff -rq -x target -x secrets -x .m2-demo -x pom.xml "$B4/" .harness/base/ 2>&1 | wc -l | tr -d ' ')" = 0 ] && [ -z "$(diff -rq "$B4/tiffinbox-core" .harness/base/tiffinbox-core -x target -x secrets 2>&1)" ] && [ -z "$(diff -rq "$B4/tiffinbox-web" .harness/base/tiffinbox-web -x target -x secrets 2>&1)" ] || die "the baseline differs from its source in more than the root pom.xml's one line"
echo "  copied anchor/ to .harness/after (diff -rq empty) and $B4/ to .harness/base, where the move line changed pom.xml's line 13, 4.1.1 -> 4.1.2, and nothing else"
mbuild "cd .harness/base && $L_PKG" .harness/build-base.log ".harness/base (the 4.1.2 tree without the starter, the package line)"
mbuild "cd .harness/after && $L_PKG" .harness/build-after.log ".harness/after (the anchor, the package line)"
mbuild "cd .harness/base && $L_TREE" .harness/warm-base.log ".harness/base (the tree line, once, before the captures)"
mbuild "cd .harness/after && $L_TREE" .harness/warm-after.log ".harness/after (the tree line, once, before the captures)"
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
[ -f .harness/base/$JAR ] && [ -f .harness/after/$JAR ] || die "a build left no $JAR"
# The first-entity lesson's own copy of its move tree, if it is beside this folder (it is not in a clone: .harness is never
# committed): the same files, and - read only, on a copy - the same tree (terminal only; no capture depends on it)
if [ -d ../c7-unit03/.harness/move ]; then
  rsync -a --exclude target --exclude secrets --exclude .m2-demo --exclude tree.txt ../c7-unit03/.harness/move/ .harness/m03/
  [ -z "$(diff -rq -x target -x secrets -x tree.txt .harness/base .harness/m03 2>&1)" ] || die "the baseline is not the first-entity lesson's move tree: $(diff -rq -x target -x secrets -x tree.txt .harness/base .harness/m03 2>&1 | head -2 | paste -sd';' -)"
  mbuild "cd .harness/m03 && $L_TREE" .harness/tree-m03.log ".harness/m03 (a copy of ../c7-unit03/.harness/move, the tree line)"
  [ "$(md5 -q .harness/m03/tiffinbox-web/tree.txt)" = "$(md5 -q .harness/base/tiffinbox-web/tree.txt)" ] || die "the baseline's tree differs from the first-entity lesson's move tree's"
  echo "  (terminal only) ../c7-unit03/.harness/move, copied: its files = .harness/base's; its tiffinbox-web/tree.txt md5 $(md5 -q .harness/m03/tiffinbox-web/tree.txt) = the baseline's" >&3
else echo "  (terminal only) ../c7-unit03/.harness/move is not beside this clone: the move line and its one-line diff above are the check" >&3; fi

# ---- helpers ------------------------------------------------------------------------------------------------------------
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting X using Java 25.0.4.1' "$U/x" "$UP/y" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting X using Java <version>' '…/x' '…/../y')" ] || die "mask: the planted JDK version and the two folders must be masked"
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-15s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-15s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-15s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Maven, seed or grep, a variable of yours, or an edited POM; diff .r-$nm.out against its block in README.md"; fi; }
# Checks: each reads a line a program computed - a command's own output, a count of lines - never a label printed unconditionally
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
# show CMD: the command as it runs (one $ line), then what it printed, each line indented; its exit code kept in SE
SE=0
show() { echo "\$ $1"; SE=0; (eval "$1") > .harness/show.out 2>&1 < /dev/null || SE=$?; sed 's/^/  /' .harness/show.out; }
# lval CAPTURE PREFIX: the rest of the capture's one line that starts with PREFIX (none, or more than one: the check fails)
lval() { local n; n=$($G -cF -- "$2" ".r-$1.out" || true); [ "$n" -ge 1 ] || { echo "<none>"; return 0; }
  awk -v p="$2" 'index($0, p) == 1 { print substr($0, length(p) + 1); exit }' ".r-$1.out"; }
# arts TREE.TXT: one row per line of a dependency:tree file - key (groupId:artifactId:type[:classifier]), version, scope (the
# first line, the module itself: -), optional, depth (the tree's indentation: three characters a level), line number
arts() { awk '{ l = $0; d = 0
    while (substr(l, 1, 3) == "|  " || substr(l, 1, 3) == "   " || substr(l, 1, 3) == "+- " || substr(l, 1, 3) == "\\- ") { l = substr(l, 4); d++ }
    o = "-"; if (sub(/ \(optional\)$/, "", l)) o = "optional"
    n = split(l, f, ":")
    if (n == 4) { k = f[1] ":" f[2] ":" f[3]; v = f[4]; s = "-" }
    else if (n == 5) { k = f[1] ":" f[2] ":" f[3]; v = f[4]; s = f[5] }
    else if (n == 6) { k = f[1] ":" f[2] ":" f[3] ":" f[4]; v = f[5]; s = f[6] }
    else { k = "UNREAD:" l; v = "?"; s = "?" }
    printf "%s\t%s\t%s\t%s\t%d\t%d\n", k, v, s, o, d, NR }' "$1"; }
# libs JAR: the jars under BOOT-INF/lib, by file name, from unzip -l (its fourth column; the header and the footer have no date in
# the second)
libs() { unzip -l "$1" | awk '$1 ~ /^[0-9]+$/ && $2 ~ /-/ && NF >= 4 { print $4 }' | $G '^BOOT-INF/lib/.*\.jar$' | sed 's#^BOOT-INF/lib/##' | sort; }

# ---- tree: the anchor's tree from the reactor root, beside the 4.1.2 tree without the starter (R.181, RED #12; RE-MEASURE 9) -----
trun() { local t=$1 ec=0
  rm -f .harness/$t/tree.txt .harness/$t/tiffinbox-core/tree.txt .harness/$t/tiffinbox-web/tree.txt
  echo "\$ cd .harness/$t && $L_TREE"
  (cd .harness/$t && eval "$L_TREE") > .harness/tree-$t.run 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  echo "  exit $ec · read from its log: the plugin $(sed -n -E 's/.*--- dependency:([0-9.]+):tree \(default-cli\) @ tiffinbox-web ---.*/maven-dependency-plugin \1/p' .harness/tree-$t.run) · reactor modules $($G -cE '^\[INFO\] Building TiffinBox' .harness/tree-$t.run || true) · 'The POM for ... is missing' WARNING lines: $($G -cE '^\[WARNING\] The POM for .* is missing' .harness/tree-$t.run || true) · 'Downloaded from' lines: $($G -c '^\[INFO\] Downloaded from ' .harness/tree-$t.run || true) · BUILD SUCCESS lines: $($G -cx '\[INFO\] BUILD SUCCESS' .harness/tree-$t.run || true)"
  echo "  tree.txt written: $(cd .harness/$t && find . -name tree.txt | sed 's#^\./##' | sort | paste -sd' ' -)"
  [ -f .harness/$t/tiffinbox-web/tree.txt ] || { echo "  tiffinbox-web/tree.txt: none"; return 0; }
  arts .harness/$t/tiffinbox-web/tree.txt > .harness/$t.arts
  echo "  tiffinbox-web/tree.txt: md5 $(md5 -q .harness/$t/tiffinbox-web/tree.txt) · lines $(wc -l < .harness/$t/tiffinbox-web/tree.txt | tr -d ' ') · artifacts (every line after the first, the module itself) $(awk -F"$TAB" '$6 > 1' .harness/$t.arts | wc -l | tr -d ' ') · distinct $(awk -F"$TAB" '$6 > 1 { print $1 }' .harness/$t.arts | sort -u | wc -l | tr -d ' ') · lines naming com.h2database:h2: $($G -c 'com\.h2database:h2:' .harness/$t/tiffinbox-web/tree.txt || true) · lines no row could read: $($G -c '^UNREAD:' .harness/$t.arts || true)"; }
tree() { local a t jf k p tb tn ta ti tm
  echo "the anchor's own tree line (anchor/README.md): $R_TREE - made offline, on this unit's repository, and run from the reactor root (the parent POM's folder) with each module's tree written to its own tree.txt (R.181)"
  echo "the baseline, .harness/base: the 4.1.2 tree without the data starter - the first-entity lesson's previous tree, copied, with that lesson's move line (the parent 4.1.1 -> 4.1.2, pom.xml line 13, nothing else):"
  echo "  \$ $R_MOVE"
  trun base
  echo "the anchor, .harness/after (= anchor/, copied):"
  trun after
  echo "the anchor's tiffinbox-web/tree.txt, whole:"
  sed 's/^/  /' .harness/after/tiffinbox-web/tree.txt
  echo "the two trees compared by artifact - groupId:artifactId:type, a classifier if it has one - never by line:"
  awk -F"$TAB" 'FNR == 1 { f++ } $6 == 1 { next }
    f == 1 { bv[$1] = $2; bs[$1] = $3; nb++; next }
    { k[++n] = $1; av[$1] = $2; as[$1] = $3 }
    END { for (i = 1; i <= n; i++) if (!(k[i] in bv)) ad[++na] = k[i]
      for (x in bv) if (!(x in av)) rm[++nr] = x
      for (i = 1; i <= n; i++) if ((k[i] in bv) && bs[k[i]] != as[k[i]]) sm[++ns] = k[i]
      for (i = 1; i <= n; i++) if ((k[i] in bv) && bv[k[i]] != av[k[i]]) vc[++nv] = k[i]
      printf "  added - in the anchor'"'"'s tree, not in the baseline'"'"'s, in the tree'"'"'s order: %d\n", na
      for (i = 1; i <= na; i++) printf "    + %s %s %s\n", ad[i], av[ad[i]], as[ad[i]]
      printf "  removed - in the baseline'"'"'s tree, not in the anchor'"'"'s: %d\n", nr
      for (i = 1; i <= nr; i++) printf "    - %s %s %s\n", rm[i], bv[rm[i]], bs[rm[i]]
      printf "  the same artifact at another scope: %d\n", ns
      for (i = 1; i <= ns; i++) printf "    ~ %s %s %s -> %s\n", sm[i], av[sm[i]], bs[sm[i]], as[sm[i]]
      printf "  the same artifact at another version: %d\n", nv
      for (i = 1; i <= nv; i++) printf "    ~ %s %s -> %s\n", vc[i], bv[vc[i]], av[vc[i]]
      printf "derived: added %d · removed %d · scope moves %d · version changes %d\n", na, nr, ns, nv }' .harness/base.arts .harness/after.arts | tee .harness/cmp.txt
  echo "the versions, read off the anchor's copy - the parent from its pom.xml's <parent>, the rest from tiffinbox-web/tree.txt:"
  echo "  org.springframework.boot:spring-boot-starter-parent (pom.xml <parent>): $(awk '/<parent>/ { p = 1 } p && /<artifactId>/ { a = $0 } p && /<version>/ { v = $0; gsub(/.*<version>|<\/version>.*/, "", v); gsub(/.*<artifactId>|<\/artifactId>.*/, "", a); print a " " v; exit }' .harness/after/pom.xml)"
  for a in org.hibernate.orm:hibernate-core:jar jakarta.persistence:jakarta.persistence-api:jar org.springframework.data:spring-data-jpa:jar org.springframework.data:spring-data-commons:jar org.springframework:spring-orm:jar org.springframework:spring-tx:jar org.springframework:spring-jdbc:jar com.zaxxer:HikariCP:jar com.h2database:h2:jar org.springframework.boot:spring-boot-starter-data-jpa:jar; do
    echo "  $a: $(awk -F"$TAB" -v k="$a" '$1 == k { printf "%s%s", (n++ ? " AND " : ""), $2 } END { if (!n) printf "<none>" }' .harness/after.arts)"; done
  echo "where the specification's jar prints - a tree prints each artifact once, at its first path:"
  for t in base after; do
    echo "  in the $( [ $t = base ] && echo "baseline's" || echo "anchor's") tree: $(awk -F"$TAB" '{ k[$6] = $1; d[$6] = $5 } $1 == "jakarta.persistence:jakarta.persistence-api:jar" { n++; for (j = $6 - 1; j >= 1; j--) if (d[j] == $5 - 1) break; w = w sprintf("line %d, depth %d, under %s (line %d)", $6, $5, k[j], j) } END { printf "%d line(s)%s", n, (n ? " - " w : "") }' .harness/$t.arts)"; done
  echo "BOOT-INF/lib of the two jars, read with unzip -l (each jar built above by the package line, offline):"
  for t in base after; do libs .harness/$t/$JAR > .harness/libs-$t.txt; echo "  \$ unzip -l .harness/$t/$JAR · jars under BOOT-INF/lib: $(wc -l < .harness/libs-$t.txt | tr -d ' ')"; done
  comm -13 .harness/libs-base.txt .harness/libs-after.txt > .harness/libs-new.txt; comm -23 .harness/libs-base.txt .harness/libs-after.txt > .harness/libs-gone.txt
  echo "  in the anchor's jar only: $(wc -l < .harness/libs-new.txt | tr -d ' ') · in the baseline's jar only: $(wc -l < .harness/libs-gone.txt | tr -d ' ')"
  # each jar file name the anchor's tree gives an artifact: artifactId-version[-classifier].jar
  awk -F"$TAB" '$6 > 1 { n = split($1, f, ":"); printf "%s-%s%s.jar\t%s\n", f[2], $2, (n == 4 ? "-" f[4] : ""), $1 }' .harness/after.arts | sort > .harness/jarof.txt
  sed -n 's/^    + \([^ ]*\) .*/\1/p' .harness/cmp.txt | sort > .harness/added.txt
  sed -n -E 's/^    ~ ([^ ]+) [^ ]+ test -> (compile|runtime)$/\1/p' .harness/cmp.txt | sort > .harness/moved.txt
  awk -F"$TAB" 'FILENAME == ARGV[1] { j[$1] = $2; next } FILENAME == ARGV[2] { ad[$1] = 1; next } FILENAME == ARGV[3] { mv[$1] = 1; next }
    { k = ($0 in j) ? j[$0] : "?"; c = (k in ad) ? "added" : ((k in mv) ? "moved" : "neither"); n[c]++; printf "    %s - %s, %s\n", $0, k, (c == "added" ? "the tree added it" : (c == "moved" ? "the tree moved it from test to runtime" : "the tree neither added nor moved it")) }
    END { printf "  of them: the tree added the artifact %d · moved it from test to runtime %d · neither %d\n", n["added"], n["moved"], n["neither"] }' .harness/jarof.txt .harness/added.txt .harness/moved.txt .harness/libs-new.txt
  echo "  the tree's added artifacts with no jar in the anchor's BOOT-INF/lib:"
  while IFS="$TAB" read -r jf k; do
    $G -qxF -- "$k" .harness/added.txt || continue; $G -qxF -- "$jf" .harness/libs-after.txt && continue
    p=$(awk -F"$TAB" -v k="$k" '$1 == k { n = split(k, f, ":"); g = f[1]; gsub(/\./, "/", g); print g "/" f[2] "/" $2 "/" f[2] "-" $2 ".jar" }' .harness/after.arts)
    echo "    $k - its MANIFEST.MF (\$M2/$p): $(unzip -p "$M2/$p" META-INF/MANIFEST.MF 2> /dev/null | tr -d '\r' | $G '^Spring-Boot-Jar-Type: ' || echo 'no Spring-Boot-Jar-Type line')"; done < .harness/jarof.txt
  awk -F"$TAB" 'FILENAME == ARGV[1] { a[$1] = 1; next } ($2 in a) { print $1 }' .harness/added.txt .harness/jarof.txt | sort > .harness/added-jars.txt
  tb=$(wc -l < .harness/libs-base.txt | tr -d ' '); tn=$(wc -l < .harness/libs-after.txt | tr -d ' '); ta=$(wc -l < .harness/added.txt | tr -d ' ')
  ti=$(comm -12 .harness/added-jars.txt .harness/libs-new.txt | wc -l | tr -d ' '); tm=$(wc -l < .harness/moved.txt | tr -d ' ')
  echo "derived: BOOT-INF/lib $tb -> $tn, +$((tn - tb)) = $ta added - $((ta - ti)) left out of the jar + $tm moved from test to runtime"; }
read -r -d '' EXPECT <<'EOF' || true
org.springframework.boot:spring-boot-starter-parent (pom.xml <parent>): spring-boot-starter-parent 4.1.2
org.hibernate.orm:hibernate-core:jar: 7.4.13.Final
jakarta.persistence:jakarta.persistence-api:jar: 3.2.0
org.springframework.data:spring-data-jpa:jar: 4.1.2
org.springframework.data:spring-data-commons:jar: 4.1.2
org.springframework:spring-orm:jar: 7.0.10
org.springframework:spring-tx:jar: 7.0.10
org.springframework:spring-jdbc:jar: 7.0.10
com.zaxxer:HikariCP:jar: 7.0.2
com.h2database:h2:jar: 2.5.250
org.springframework.boot:spring-boot-starter-data-jpa:jar: 4.1.2
EOF
read -r -d '' ADDED <<'EOF' || true
com.zaxxer:HikariCP:jar
org.springframework.boot:spring-boot-starter-data-jpa:jar
org.springframework.boot:spring-boot-starter-jdbc:jar
org.springframework.boot:spring-boot-data-jpa:jar
org.springframework.boot:spring-boot-data-commons:jar
org.springframework.boot:spring-boot-persistence:jar
org.springframework.data:spring-data-commons:jar
org.springframework.boot:spring-boot-hibernate:jar
org.springframework.boot:spring-boot-jpa:jar
org.hibernate.orm:hibernate-core:jar
jakarta.transaction:jakarta.transaction-api:jar
org.hibernate.models:hibernate-models:jar
org.glassfish.jaxb:jaxb-runtime:jar
org.glassfish.jaxb:jaxb-core:jar
org.eclipse.angus:angus-activation:jar
org.glassfish.jaxb:txw2:jar
com.sun.istack:istack-commons-runtime:jar
jakarta.inject:jakarta.inject-api:jar
org.springframework:spring-orm:jar
org.springframework.data:spring-data-jpa:jar
org.springframework:spring-tx:jar
org.antlr:antlr4-runtime:jar
org.springframework:spring-aspects:jar
org.aspectj:aspectjweaver:jar
org.springframework.boot:spring-boot-jdbc:jar
org.springframework.boot:spring-boot-sql:jar
org.springframework.boot:spring-boot-transaction:jar
org.springframework:spring-jdbc:jar
jakarta.persistence:jakarta.persistence-api:jar
EOF
c_tree() { local T B A n
  T=$(cat .r-tree.out); B=$(blk tree "the baseline, .harness/base" "the anchor, .harness/after"); A=$(blk tree "the anchor, .harness/after" "the anchor's tiffinbox-web/tree.txt, whole:")
  # R.181: each tree from the reactor root - both modules built, tiffinbox-web's tree written, H2 in it once, no POM missing
  for b in "$B" "$A"; do
    printf '%s\n' "$b" | $G -qE '^  exit 0 · read from its log: the plugin maven-dependency-plugin [0-9.]+ · reactor modules 3 · .The POM for \.\.\. is missing. WARNING lines: 0 · .Downloaded from. lines: 0 · BUILD SUCCESS lines: 1$' || die "tree (R.181): each tree run exits 0 from the reactor root (3 modules: the parent, core, web), no 'The POM for ... is missing' WARNING, nothing downloaded"
    has "$b" "  tree.txt written: tiffinbox-core/tree.txt tiffinbox-web/tree.txt tree.txt" "tree (R.181): each module wrote its tree.txt"
    printf '%s\n' "$b" | $G -qE ' · lines naming com\.h2database:h2: 1 · lines no row could read: 0$' || die "tree (R.181): com.h2database:h2 is in tiffinbox-web/tree.txt, 1 line, and every line read"; done
  printf '%s\n' "$A" | $G -qE ' · artifacts \(every line after the first, the module itself\) ([0-9]+) · distinct \1 · ' || die "tree: every artifact of the anchor's tree once"
  printf '%s\n' "$B" | $G -qE ' · artifacts \(every line after the first, the module itself\) ([0-9]+) · distinct \1 · ' || die "tree: every artifact of the baseline's tree once"
  # the comparison, by artifact: 0 removed, 3 scope moves - test -> runtime, the three named apart - 0 version changes (RED #12)
  has "$T" "derived: added 29 · removed 0 · scope moves 3 · version changes 0" "tree: the comparison against the 4.1.2 tree without the starter (never the 4.1.1 one)"
  [ "$(printf '%s\n' "$T" | sed -n 's/^    ~ \([^ ]*\) [^ ]* \([a-z]*\) -> \([a-z]*\)$/\1 \2 \3/p' | sort | paste -sd'|' -)" = 'jakarta.activation:jakarta.activation-api:jar test runtime|jakarta.xml.bind:jakarta.xml.bind-api:jar test runtime|net.bytebuddy:byte-buddy:jar test runtime' ] || die "tree: the three scope moves - byte-buddy, jakarta.xml.bind-api, jakarta.activation-api, each test -> runtime"
  # the added artifacts, by name: the list above, and nothing else
  [ "$(printf '%s\n' "$T" | sed -n 's/^    + \([^ ]*\) .*/\1/p' | sort | paste -sd' ' -)" = "$(printf '%s\n' "$ADDED" | sort | paste -sd' ' -)" ] || die "tree: the 29 added artifacts are not the ones named in this script"
  [ "$(printf '%s\n' "$ADDED" | $G -c .)" = "$(lval tree 'derived: added ' | cut -d' ' -f1)" ] || die "tree: the named list's length is the derived count"
  # the versions: read off the tree, asserted equal to the brief's expected values (R.196, RED #17) - the tree wins on a mismatch
  while IFS= read -r e; do n=${e%%: *}
    has "$T" "  $e" "tree: the version read off the tree is not the expected one for $n - read: $(printf '%s\n' "$T" | $G -F -- "  $n: " | head -1)"; done <<EOF
$EXPECT
EOF
  # the specification's jar prints once, under tiffinbox-core, in the anchor's tree, and nowhere in the baseline's
  has "$T" "  in the anchor's tree: 1 line(s) - line 13, depth 2, under com.tiffinbox:tiffinbox-core:jar (line 2)" "tree: jakarta.persistence-api prints once, under tiffinbox-core"
  has "$T" "  in the baseline's tree: 0 line(s)" "tree: jakarta.persistence-api is not in the baseline's tree"
  # BOOT-INF/lib 61 -> 91, +30 = 29 - 2 + 3, each with its source
  has "$T" "  \$ unzip -l .harness/base/$JAR · jars under BOOT-INF/lib: 61" "tree: the baseline's jar holds 61"
  has "$T" "  \$ unzip -l .harness/after/$JAR · jars under BOOT-INF/lib: 91" "tree: the anchor's jar holds 91"
  has "$T" "  in the anchor's jar only: 30 · in the baseline's jar only: 0" "tree: 30 jars more, none gone"
  has "$T" "  of them: the tree added the artifact 27 · moved it from test to runtime 3 · neither 0" "tree: every new jar has its source in the tree"
  [ "$(blk tree "  the tree's added artifacts with no jar" "derived: BOOT-INF/lib" | paste -sd'|' -)" = "    org.springframework.boot:spring-boot-starter-data-jpa:jar - its MANIFEST.MF (\$M2/org/springframework/boot/spring-boot-starter-data-jpa/4.1.2/spring-boot-starter-data-jpa-4.1.2.jar): Spring-Boot-Jar-Type: dependencies-starter|    org.springframework.boot:spring-boot-starter-jdbc:jar - its MANIFEST.MF (\$M2/org/springframework/boot/spring-boot-starter-jdbc/4.1.2/spring-boot-starter-jdbc-4.1.2.jar): Spring-Boot-Jar-Type: dependencies-starter" ] || die "tree: the two added artifacts left out of the jar are the two starters, each a dependencies-starter by its manifest"
  has "$T" "derived: BOOT-INF/lib 61 -> 91, +30 = 29 added - 2 left out of the jar + 3 moved from test to runtime" "tree: +30 = 29 - 2 + 3"
  echo "  tree: both trees from the reactor root, H2 in each (1), no POM missing; added 29 by name, removed 0, scope moves 3 (byte-buddy, jakarta.xml.bind-api, jakarta.activation-api: test -> runtime), version changes 0; $(printf '%s\n' "$EXPECT" | $G -c .) versions read = expected; jakarta.persistence-api once, under tiffinbox-core; BOOT-INF/lib 61 -> 91, +30 = 29 - 2 starters + 3 moves"; }

# ---- owners: who owns which class - unzip -l of each jar, each class looked for in all of them (R.134) ------------------------
# the jars, at the versions the anchor's tree gives (read, never typed: the tree capture's rows)
read -r -d '' OWNKEYS <<'EOF' || true
jakarta.persistence:jakarta.persistence-api:jar
org.hibernate.orm:hibernate-core:jar
org.springframework.data:spring-data-jpa:jar
org.springframework.data:spring-data-commons:jar
org.springframework:spring-orm:jar
org.springframework:spring-tx:jar
org.springframework.boot:spring-boot-persistence:jar
org.springframework.boot:spring-boot-hibernate:jar
EOF
read -r -d '' CLASSES <<'EOF' || true
jakarta/persistence/Entity.class
jakarta/persistence/EntityManager.class
jakarta/persistence/Table.class
jakarta/persistence/Column.class
org/hibernate/Session.class
org/hibernate/SessionFactory.class
org/hibernate/stat/Statistics.class
org/springframework/data/jpa/repository/JpaRepository.class
org/springframework/data/jpa/repository/support/SimpleJpaRepository.class
org/springframework/data/repository/CrudRepository.class
org/springframework/orm/jpa/LocalContainerEntityManagerFactoryBean.class
org/springframework/orm/jpa/JpaTransactionManager.class
org/springframework/transaction/annotation/Transactional.class
org/springframework/transaction/support/TransactionTemplate.class
org/springframework/boot/persistence/autoconfigure/EntityScan.class
org/springframework/boot/hibernate/autoconfigure/HibernateJpaAutoConfiguration.class
EOF
family() { case "$1" in jakarta.persistence) echo "Jakarta Persistence (J-P-A), the specification" ;; org.hibernate.orm) echo "Hibernate ORM, the implementation" ;; org.springframework.data) echo "Spring Data, the repository layer" ;; org.springframework) echo "Spring Framework" ;; org.springframework.boot) echo "Spring Boot" ;; *) echo "unknown: $1" ;; esac; }
owners() { local k v n g p c f
  mkdir -p .harness/ls; rm -f .harness/ls/*
  echo "each jar, at the version the anchor's tree gives it, listed once (unzip -l, its fourth column: the entry's name) into .harness/ls:"
  while IFS= read -r k; do
    v=$(awk -F"$TAB" -v k="$k" '$1 == k { print $2 }' .harness/after.arts); n=$(printf '%s\n' "$k" | cut -d: -f2); g=$(printf '%s\n' "$k" | cut -d: -f1)
    p="$(printf '%s\n' "$g" | tr . /)/$n/$v/$n-$v.jar"
    show "unzip -l \"\$M2/$p\" | awk '\$1 ~ /^[0-9]+\$/ && \$2 ~ /-/ { print \$4 }' > .harness/ls/$n-$v.jar.txt"
    echo "  $g · entries $(wc -l < ".harness/ls/$n-$v.jar.txt" | tr -d ' ') · .class entries $($G -c '\.class$' ".harness/ls/$n-$v.jar.txt" || true)"; done <<EOF
$OWNKEYS
EOF
  echo "each class, looked for in every listing by its exact name (grep -cxF: a class whose name merely ends the same is not counted) - the listings that hold it, then how many hold it not:"
  while IFS= read -r c; do
    echo "\$ $G -cxF '$c' .harness/ls/*.txt"
    (eval "$G -cxF '$c' .harness/ls/*.txt") > .harness/hits.out 2>&1 < /dev/null || true
    $G -v ':0$' .harness/hits.out | sed 's#^\.harness/ls/##; s#\.txt:#:#; s/^/  /' || true
    echo "  :0 in $($G -c ':0$' .harness/hits.out || true) of $(wc -l < .harness/hits.out | tr -d ' ')"; done <<EOF
$CLASSES
EOF
  echo "the owners - the jar that holds the class, and its family by the jar's groupId (the folder it lives in under \$M2):"
  while IFS= read -r c; do
    f=$( (eval "$G -lxF '$c' .harness/ls/*.txt") 2> /dev/null | sed 's#^\.harness/ls/##; s#\.txt$##' | paste -sd' ' -)
    k=$(awk -F"$TAB" -v f="$f" '$1 == f { print $2 }' .harness/jarof.txt)
    printf '  %s -> %s -> %s\n' "$c" "${f:-none}" "$(family "$(printf '%s\n' "$k" | cut -d: -f1)")"; done <<EOF
$CLASSES
EOF
}
# the expected owner of each class: the jar's artifactId and its family (the brief's table, R.134)
read -r -d '' OWNERS <<'EOF' || true
jakarta/persistence/Entity.class jakarta.persistence-api Jakarta Persistence (J-P-A), the specification
jakarta/persistence/EntityManager.class jakarta.persistence-api Jakarta Persistence (J-P-A), the specification
jakarta/persistence/Table.class jakarta.persistence-api Jakarta Persistence (J-P-A), the specification
jakarta/persistence/Column.class jakarta.persistence-api Jakarta Persistence (J-P-A), the specification
org/hibernate/Session.class hibernate-core Hibernate ORM, the implementation
org/hibernate/SessionFactory.class hibernate-core Hibernate ORM, the implementation
org/hibernate/stat/Statistics.class hibernate-core Hibernate ORM, the implementation
org/springframework/data/jpa/repository/JpaRepository.class spring-data-jpa Spring Data, the repository layer
org/springframework/data/jpa/repository/support/SimpleJpaRepository.class spring-data-jpa Spring Data, the repository layer
org/springframework/data/repository/CrudRepository.class spring-data-commons Spring Data, the repository layer
org/springframework/orm/jpa/LocalContainerEntityManagerFactoryBean.class spring-orm Spring Framework
org/springframework/orm/jpa/JpaTransactionManager.class spring-orm Spring Framework
org/springframework/transaction/annotation/Transactional.class spring-tx Spring Framework
org/springframework/transaction/support/TransactionTemplate.class spring-tx Spring Framework
org/springframework/boot/persistence/autoconfigure/EntityScan.class spring-boot-persistence Spring Boot
org/springframework/boot/hibernate/autoconfigure/HibernateJpaAutoConfiguration.class spring-boot-hibernate Spring Boot
EOF
c_owners() { local O c a fam v line nc B_
  O=$(cat .r-owners.out)
  [ "$(printf '%s\n' "$O" | $G -cE '^  [a-z.]+ · entries [1-9][0-9]* · \.class entries [1-9][0-9]*$')" = 8 ] || die "owners: eight jars listed, each with classes"
  nc=0
  while IFS= read -r line; do c=${line%% *}; a=$(printf '%s\n' "$line" | cut -d' ' -f2); fam=$(printf '%s\n' "$line" | cut -d' ' -f3-)
    v=$(awk -F"$TAB" -v a="$a" '{ split($1, f, ":") } f[2] == a && f[3] == "jar" { print $2 }' .harness/after.arts)
    [ -n "$v" ] || die "owners: $a is not in the anchor's tree"
    has "$O" "  $c -> $a-$v.jar -> $fam" "owners: ${c##*/} belongs to $a-$v.jar, $fam (R.134)"
    # one hit, in that jar, and 0 in the seven others - read under the class's own command line
    B_=$(printf '%s\n' "$O" | CX="\$ $G -cxF '$c' .harness/ls/*.txt" awk 'BEGIN { x = ENVIRON["CX"] } $0 == x { f = 1; next } f && /^  / { print; next } { f = 0 }')
    [ "$(printf '%s\n' "$B_" | paste -sd'|' -)" = "  $a-$v.jar:1|  :0 in 7 of 8" ] || die "owners: ${c##*/} - 1 hit in $a-$v.jar and 0 in each of the seven others: $(printf '%s\n' "$B_" | paste -sd'|' -)"
    nc=$((nc + 1)); done <<EOF
$OWNERS
EOF
  [ $nc = "$(printf '%s\n' "$CLASSES" | $G -c .)" ] && [ "$(printf '%s\n' "$OWNERS" | cut -d' ' -f1)" = "$CLASSES" ] || die "owners: every class looked for has its expected owner, in the same order"
  # spring-orm is Spring Framework's - never Spring Data's
  [ "$(printf '%s\n' "$O" | $G -c ' -> spring-orm-[0-9.]*\.jar -> Spring Framework$')" = 2 ] && ! printf '%s\n' "$O" | $G -q ' -> spring-orm-.* -> Spring Data' || die "owners: spring-orm's two classes are Spring Framework's, not Spring Data's"
  echo "  owners: $nc classes, each 1 hit in its jar and 0 in the seven others - J-P-A 4 (jakarta.persistence-api), Hibernate 3 (hibernate-core), Spring Data 3 (spring-data-jpa 2, spring-data-commons 1), Spring Framework 4 (spring-orm 2, spring-tx 2), Spring Boot 2 (spring-boot-persistence, spring-boot-hibernate)"; }

# ---- poms: who needs whom - the POMs as they say it, and the path from the starter, off the tree (RED #18) ------------------------
mp() { local n=$2 v; v=$(awk -F"$TAB" -v k="$1:$n:jar" '$1 == k { print $2 }' .harness/after.arts); printf '%s/%s/%s/%s-%s.pom' "$(printf '%s\n' "$1" | tr . /)" "$n" "$v" "$n" "$v"; }
# pc FIELD WORD: how many of pom.py's lines (groupId:artifactId scope [optional]) have WORD as that field
pc() { awk -v i="$1" -v w="$2" '$i == w' .harness/pom.out | wc -l | tr -d ' '; }
pshow() { echo "\$ $1"; (eval "$1") > .harness/pom.out 2>&1 < /dev/null || echo "  exit $?"; sed 's/^/  /' .harness/pom.out; }
poms() { local HC SDJ SDP BJ
  HC=$(mp org.hibernate.orm hibernate-core); SDJ=$(mp org.springframework.data spring-data-jpa)
  echo "the POMs, read from .m2-demo as each POM says it - each <dependency> directly under <project><dependencies>, its scope (none written: compile, Maven's default) and optional as written; <dependencyManagement>, the build's plugins and the parent's lines are not read (harness/pom.py):"
  echo "hibernate-core - the implementation - and what it needs:"
  pshow "python3 -I -B harness/pom.py deps \"\$M2/$HC\""
  echo "  dependencies $(wc -l < .harness/pom.out | tr -d ' ') · compile $(pc 2 compile) · runtime $(pc 2 runtime) · optional $(pc 3 optional) · jakarta.persistence:jakarta.persistence-api among them: $($G -c '^jakarta\.persistence:jakarta\.persistence-api ' .harness/pom.out || true), at $($G '^jakarta\.persistence:jakarta\.persistence-api ' .harness/pom.out | cut -d' ' -f2-)"
  echo "spring-data-jpa - the repository layer - and what it needs:"
  pshow "python3 -I -B harness/pom.py deps \"\$M2/$SDJ\""
  echo "  dependencies $(wc -l < .harness/pom.out | tr -d ' ') · compile $(pc 2 compile) · provided $(pc 2 provided) · test $(pc 2 test) · optional $(pc 3 optional)"
  echo "  hibernate-core among them: $($G -E ':hibernate-core ' .harness/pom.out || echo none) · EclipseLink among them: $($G -E '^org\.eclipse\.persistence:org\.eclipse\.persistence\.jpa ' .harness/pom.out || echo none) · jakarta.persistence-api among them: $($G -c ':jakarta\.persistence-api ' .harness/pom.out || true)"
  SDP="org/springframework/data/spring-data-jpa-parent/$(awk -F"$TAB" '$1 == "org.springframework.data:spring-data-jpa:jar" { print $2 }' .harness/after.arts)/spring-data-jpa-parent-$(awk -F"$TAB" '$1 == "org.springframework.data:spring-data-jpa:jar" { print $2 }' .harness/after.arts).pom"
  echo "  its hibernate-core's groupId is \${hibernate.groupId}.orm - the property, in its parent's POM:"
  pshow "python3 -I -B harness/pom.py prop \"\$M2/$SDP\" hibernate.groupId"
  echo "  every element of spring-data-jpa's POM whose text is jakarta.persistence-api - none is a dependency:"
  pshow "python3 -I -B harness/pom.py where \"\$M2/$SDJ\" jakarta.persistence-api"
  echo "where spring-data-jpa's side gets the specification's jar - Boot's spring-boot-jpa:"
  BJ=$(mp org.springframework.boot spring-boot-jpa)
  pshow "python3 -I -B harness/pom.py deps \"\$M2/$BJ\""
  echo "the path from the starter TiffinBox declares to hibernate-core, read off the anchor's tiffinbox-web/tree.txt by its indentation - each line's parent is the nearest line above it one level less deep:"
  awk -F"$TAB" '{ k[$6] = $1; v[$6] = $2; d[$6] = $5 } $1 == "org.hibernate.orm:hibernate-core:jar" { h = $6 } END { if (!h) { print "  hibernate-core: not in the tree"; exit } n = 0; j = h; p[++n] = j
      while (d[j] > 1) { for (i = j - 1; i >= 1; i--) if (d[i] == d[j] - 1) break; j = i; p[++n] = j }
      for (i = n; i >= 1; i--) printf "  line %d, depth %d: %s %s\n", p[i], d[p[i]], k[p[i]], v[p[i]]
      printf "derived: the path %s", "" ; for (i = n; i >= 1; i--) { s = k[p[i]]; sub(/:jar$/, "", s); sub(/^[^:]*:/, "", s); printf "%s%s", s, (i > 1 ? " -> " : "\n") } }' .harness/after.arts
  echo "and each POM on that path names the next one as its dependency:"
  for a in spring-boot-starter-data-jpa spring-boot-data-jpa spring-boot-hibernate; do
    pshow "python3 -I -B harness/pom.py deps \"\$M2/$(mp org.springframework.boot $a)\""; done; }
c_poms() { local P H S
  P=$(cat .r-poms.out)
  H=$(blk poms "hibernate-core - the implementation" "spring-data-jpa - the repository layer"); S=$(blk poms "spring-data-jpa - the repository layer" "where spring-data-jpa's side")
  # hibernate-core: 9 dependencies, counted as the POM writes them, the specification's API at compile scope
  has "$H" "  dependencies 9 · compile 2 · runtime 7 · optional 0 · jakarta.persistence:jakarta.persistence-api among them: 1, at compile" "poms: hibernate-core 7.4.13.Final's POM - 9 direct dependencies, jakarta.persistence-api compile"
  [ "$(printf '%s\n' "$H" | $G -c '^  [a-z][^ ]*:[^ ]* \(compile\|runtime\)$')" = 9 ] || die "poms: the 9 lines are the 9 dependencies"
  # spring-data-jpa: Hibernate optional, EclipseLink optional, no jakarta.persistence-api dependency
  has "$S" "  hibernate-core among them: \${hibernate.groupId}.orm:hibernate-core compile optional · EclipseLink among them: org.eclipse.persistence:org.eclipse.persistence.jpa compile optional · jakarta.persistence-api among them: 0" "poms: spring-data-jpa 4.1.2's POM marks hibernate-core and EclipseLink optional and has no jakarta.persistence-api dependency"
  has "$P" "  org.hibernate" "poms: \${hibernate.groupId} is org.hibernate"
  [ "$(blk poms "  every element of spring-data-jpa's POM" "where spring-data-jpa's side" | $G -c '^  line [0-9]*: project/dependencies/')" = 0 ] || die "poms: no element of spring-data-jpa's POM under <dependencies> names jakarta.persistence-api"
  has "$(blk poms "where spring-data-jpa's side" "the path from the starter")" "  jakarta.persistence:jakarta.persistence-api compile" "poms: spring-boot-jpa brings the specification's jar"
  # the path, from the tree (RED #18): the tree wins - if it differs, this line is changed and the README says so
  has "$P" "derived: the path spring-boot-starter-data-jpa -> spring-boot-data-jpa -> spring-boot-hibernate -> hibernate-core" "poms: the path from the starter to hibernate-core, read off the tree"
  for x in "spring-boot-starter-data-jpa:org.springframework.boot:spring-boot-data-jpa compile" "spring-boot-data-jpa:org.springframework.boot:spring-boot-hibernate compile" "spring-boot-hibernate:org.hibernate.orm:hibernate-core compile"; do
    a=${x%%:*}; l=${x#*:}
    printf '%s\n' "$P" | awk -v a="/$a-" -v l="  $l" 'index($0, "$ python3") == 1 { f = index($0, a) > 0; next } f && $0 == l { ok = 1 } END { exit !ok }' || die "poms: $a's POM names the next step, $l"; done
  echo "  poms: hibernate-core's POM - 9 direct dependencies (compile 2, runtime 7), jakarta.persistence-api compile; spring-data-jpa's - hibernate-core optional, EclipseLink optional, 0 jakarta.persistence-api dependencies (its one mention: an annotation-processor path in the build); spring-boot-jpa brings the API; the path off the tree: spring-boot-starter-data-jpa -> spring-boot-data-jpa -> spring-boot-hibernate -> hibernate-core, each POM naming the next"; }

# ---- exercise: the README's lines, then the solution's - in ONE shell, bash, then zsh; each block a fresh Maven run (R.164, R.196)
# block FILE N: the Nth bash block of FILE
block() { awk -v n="${2:-1}" '/^```bash$/ { k++; if (k == n) f = 1; next } f && /^```$/ { f = 0 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -f .harness/ex-*.st .harness/ex-*.out
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 120 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $($G -c . .harness/ex-shell.out || true) lines"; }
exercise() { local setup sol
  setup=$(block exercise/README.md 1); sol=$(block exercise/SOLUTION.md 1)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ -z "$(block exercise/README.md 2)" ] && [ -z "$(block exercise/SOLUTION.md 2)" ] || die "exercise/README.md and SOLUTION.md give one block each"
  printf '%s\n' "$setup" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' && printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "the exercise's blocks must start by exporting this script's JAVA_HOME"
  [ "$(printf '%s\n' "$setup" | $G -c .)" = "$(printf '%s\n' "$sol" | $G -c .)" ] && [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 4 ] || die "SOLUTION.md's block must be the README's with two lines changed (the Maven line and the file the last grep reads)"
  printf '%s\n' "$sol" | $G -qxF -- "${L_TREE} > ../ex-tree.log; echo \"exit \$?\"" || die "SOLUTION.md's Maven line must be this script's tree line, as the receipt runs it"
  printf '%s\n' "$setup" | $G -qxF -- "${L_TREE/ -DoutputFile=tree.txt/ -pl tiffinbox-web} > ../ex-tree.log; echo \"exit \$?\"" || die "exercise/README.md's Maven line must be the tree line with -DoutputFile=tree.txt made -pl tiffinbox-web, and nothing else"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  echo "exercise/README.md's $(printf '%s\n' "$setup" | $G -c .) lines, then exercise/SOLUTION.md's, exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), started in this folder; each block a fresh Maven run:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's lines that differ:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }
c_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/^  then the solution.s lines/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/^  then the solution.s lines/,$p')
    # the failure receipt: Maven exits 0 with a WARNING, and the tree it printed has no H2; the solution: no WARNING, H2 once
    [ "$(printf '%s\n' "$ER" | sed -n 's/^    //p' | paste -sd'|' -)" = 'exit 0|1|0' ] || die "exercise: the README as written - Maven exit 0, the WARNING 1 line, com.h2database:h2 0 lines"
    [ "$(printf '%s\n' "$ES" | sed -n 's/^    //p' | paste -sd'|' -)" = 'exit 0|0|1' ] || die "exercise: the solution - Maven exit 0, the WARNING 0 lines, com.h2database:h2 1 line"
    has "$ER" "  the block's exit 1 · what it printed:" "exercise: the README's block ends on a grep that found nothing (exit 1)"
    has "$ES" "  then the solution's lines, in the same shell - the block's exit 0 · what it printed:" "exercise: the solution's block exits 0"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: .harness/ex")" = 2 ] || die "exercise: each block leaves the shell in .harness/ex, the copy"
    has "$ES" "  the shell is now in: .harness/ex · the shell's own output: 0 lines" "exercise: the shell itself printed nothing"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  EXQ="Your turn: the README's tree has no database driver in it. Run it the way the receipt does, and find H2."
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
  [ -z "$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true)" ] || die "exercise: the anchor changed"
  echo "  exercise: bash and zsh alike - the README as written (-pl tiffinbox-web): Maven exit 0, the WARNING 1, com.h2database:h2 0; the solution (from the root, -DoutputFile=tree.txt): exit 0, WARNING 0, h2 1; broken 0 != solved 1, each a fresh Maven run on a fresh copy"; }

# ---- the captures, each followed by its checks ------------------------------------------------------------------------------------
cap tree tree; c_tree
cap owners owners; c_owners
cap poms poms; c_poms
cap exercise exercise; c_exercise

# ---- Hibernate 8's status: one dated file, read offline; no file, no status (⚑10, RE-MEASURE 9) - terminal only, no capture ------
CHIPF=../../../data-jpa-hibernate/_research/hibernate-core-metadata-2026-11-03.xml
CHIPMD5=5af4b46c5ee1ffb8a6165c9e29668f6a
chip() { local d v8 n8 ga lat rel fin
  case "${CHIPF##*/}" in hibernate-core-metadata-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].xml) ;; *) echo "refused - the metadata file's name carries no date: ${CHIPF##*/}"; return 1 ;; esac
  [ -f "$CHIPF" ] || { echo "refused - no dated metadata file at $CHIPF: Hibernate 8's status: not read"; return 1; }
  [ "$(md5 -q "$CHIPF")" = "$CHIPMD5" ] || { echo "refused - $CHIPF is not the file this unit read (md5 $(md5 -q "$CHIPF"), expected $CHIPMD5)"; return 1; }
  d=${CHIPF##*metadata-}; d=${d%.xml}
  v8=$(sed -n 's#^ *<version>\(8\.[^<]*\)</version>$#\1#p' "$CHIPF"); n8=$(printf '%s\n' "$v8" | $G -c . || true)
  [ "$n8" -ge 1 ] || { echo "refused - no 8.x version in $CHIPF"; return 1; }
  ga=$(printf '%s\n' "$v8" | $G -c '\.Final$' || true)
  lat=$(sed -n 's#^ *<latest>\([^<]*\)</latest>$#\1#p' "$CHIPF"); rel=$(sed -n 's#^ *<release>\([^<]*\)</release>$#\1#p' "$CHIPF")
  fin=$(sed -n 's#^ *<version>\([0-9.]*\.Final\)</version>$#\1#p' "$CHIPF" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)
  echo "Hibernate 8's status, read from ${CHIPF##*/} (dated $d, md5 $CHIPMD5): 8.x versions $n8 ($(printf '%s\n' "$v8" | paste -sd' ' -)) · the newest 8.x: $(printf '%s\n' "$v8" | tail -1) · an 8.x .Final (GA): $( [ "$ga" = 0 ] && echo "none - not GA" || echo "$ga") · <latest> $lat · <release> $rel (Maven's newest non-snapshot, not a GA mark) · the newest .Final: $fin · Course 7 is written to Hibernate 7 ($(awk -F"$TAB" '$1 == "org.hibernate.orm:hibernate-core:jar" { print $2 }' .harness/after.arts), Boot 4.1.2's)"; }
CH=$(chip) && echo "  (terminal only) $CH" >&3 || echo "  (terminal only) the Hibernate 8 status chip: $CH" >&3

# ---- hygiene: paths, times, pins - every capture, every file this unit ships -----------------------------------------------------
# no capture prints a path, a version token of the OS or the JDK, a time, a pid, a unit number, a Maven duration, or a stack frame
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) | in [0-9.]+ seconds|Total time|Finished at' "$f" || die "$f holds a process line, seconds or a Maven duration"
  ! $G -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}:[0-9]{2}|[0-9]{2}:[0-9]{2}:[0-9]{2}' "$f" || die "$f holds a time"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE '^ +at [a-z]|Exception in thread' "$f" || die "$f holds a stack frame or an uncaught exception"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -oE 'https?://[^ '"'"']+' > /dev/null || die "$f runs a command with a URL"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -E '(^|[ |(])grep ' | $G -vE "(^|[ |(])$G " > /dev/null || die "$f runs a bare grep - every count here is $G's"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -qE '(^|[ &(])java ' || die "$f starts a JVM - this unit starts none but Maven's"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -E '(^|[ &(;])mvn ' | $G -vF -- 'mvn -o -B -Dmaven.repo.local="$M2" ' > /dev/null || die "$f runs a Maven that is not offline on this unit's repository"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
# R.193: run options travel as an array - no variable holds several options in one string
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--?[^ "]+ +--?' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
[ ! -e .m2-demo/com/tiffinbox ] || die ".m2-demo gained com/tiffinbox - something installed TiffinBox"
echo "  hygiene: no path, no unit number, no time, no Maven duration, no stack frame in any capture; every command's grep /usr/bin/grep's; no JVM but Maven's, every Maven offline on .m2-demo; no kill by name; no bare wait; no one-string option list; nothing installed into .m2-demo"

D_=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true); [ -z "$D_" ] || die "anchor/ is no longer ../c7-tiffinbox at the end"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 19810-19819 at the end; none was bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit02: every capture 3/3 and = published; every spoken number asserted; duration words 0; anchor/ = ../c7-tiffinbox (no anchor change)"
