#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · The Executable Jar, Unpacked — this unit's receipts. TiffinBox's jar has always run beside a folder of other
# jars, lib/, named one by one in its manifest. This unit declares Boot's plugin in tiffinbox-web's POM - bare, no version,
# no execution - and deletes the jar plugin's manifest settings and the copy-dependencies execution (the anchor change).
# Then what is inside the new jar, how it starts, what flattening it would cost, how Boot unpacks it again, and what an old
# lib/ folder beside it does. Ten captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is masked
# (gsub) and the last checks count 0 raw copies in every capture.
#   before   the previous tree's jar: its manifest (the Class-Path unfolded and counted), its lib/, and the jar alone
#   change   the previous tree against after/, file by file: every changed code line; Boot's parent's managed execution;
#            the goals the two builds ran in tiffinbox-web
#   inside   after/'s jar: jar tf, counted by place; its manifest; its target/; BOOT-INF/lib against the previous lib/; the
#            starters' manifests; the 31 nested jars against the jars they came from
#   launcher TiffinBox's main class named on a class path that is the jar · the jar run with -verbose:class: the class
#            loaders (jcmd), where five classes came from, the seven responses
#   folder   the break, in a deploy folder holding an older release's lib/ (TiffinBox before its shutdown token):
#            A after/'s jar · B headerkept/'s (the same plugin, the jar plugin's <archive> kept) · A' = A
#   shade    flattened instead: the same-named files the 31 jars carry; Boot's way (shade-boot/); Course 3's way
#            (shade-c3/) as written, then with combine.self="override" - what each jar kept, and what each start does
#   extract  after/README.md's extract command, run as written from after/: the thin jar, lib/, and both of the README's
#            ways to run it, -verbose:class on the first
#   serve    after/README.md's run command, read from the file: the seven responses
#   exercise two main classes (exercise/PrintRoutes.java added), then the start-class property (exercise/solution/pom.xml)
#   files    every demo file against the file it stands in for (diff)
# "before" is ../c5-unit11/after (the anchor as the last unit to change it left it), COPIED to .harness/before; the deploy
# folder's lib/ comes from ../c5-unit10/after, COPIED to .harness/older and built there - this script never writes into
# another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change, built in place, clean
# (extract also writes into after/tiffinbox-web/target/, the build's own output folder); every demo tree is a copy of
# after/ under .harness/ with one file swapped or one added, each built clean.
# Every run starts in a folder under .harness/ that holds a config tree with the demo token: tree/ (and deploy/), because
# TiffinBox does not start without its token (application.yaml imports optional:configtree:./secrets/).
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets
# lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file).
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]", this
# folder's absolute path "…", the folder above it "…/..", and the home folder "~", in every line of every capture (gsub);
# -verbose:class lines lose their uptime/level prefix (sub) and only named classes' lines are shown, the rest counted; jcmd's
# first line (the pid) becomes "<pid>:", and trailing blanks are dropped (sub); a failed start shows the lines that name its
# cause, the rest counted; a manifest's folded lines are unfolded; Maven's build logs are read, never printed whole.
# Ports (brief ⚑10, 18840-18849): launcher 18840 · folder A and A' 18841, B 18842 (never binds) · shade Boot's 18843,
# Course 3's 18844 (never binds) · extract 18845 · serve 18846 · the jar alone 18847 (never binds) · the exercise 18849.
set -e
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the JVM this script started in the background, if it still
# runs, and drop the lock. A background job of a non-interactive shell ignores the terminal's Ctrl-C, so without the kill
# an interrupted run would leave TiffinBox listening. $pid is cleared whenever the JVM has been reaped. The clean-up ignores
# a second Ctrl-C, and nothing in it can fail under set -e (a JVM stopped by SIGTERM exits 143), so it always reaches the
# rmdir; the script still exits 130 after an interrupt (tested: README.md, "Interrupted").
pid=""
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v jcmd > /dev/null && jcmd -h 2>&1 | grep -q . || die "jcmd (the JDK's own) is needed"
# A variable of yours must not become a property source: every TIFFINBOX_* and SPRING_* variable, and the two variables
# that inject JVM flags, are removed from this script's environment before anything runs. MAVEN_OPTS and MAVEN_ARGS too.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\)=.*/\1/p'); do unset "$v"; done
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"
WEB=tiffinbox-web/pom.xml
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It
# is written into files under .harness/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
C3POM=../c3-unit23/pom.xml                           # Course 3's packaging POM: its shade execution's two transformers
PARENT="$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom"
[ -x "$CURLSET" ] || [ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$PARENT" ] || die "Boot's parent POM is not in .m2-demo"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which
# lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18840 18841 18842 18843 18844 18845 18846 18847; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- build: after/, clean, in place; every demo tree a copy under .harness/, clean ------------------------------------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target ../c5-unit11/after/ .harness/before/
rsync -a --exclude target ../c5-unit10/after/ .harness/older/
for d in headerkept shade-boot shade-c3 shade-c3o twomains startclass; do rsync -a --exclude target after/ ".harness/$d/"; done
cp headerkept/pom.xml ".harness/headerkept/$WEB"; cp shade-boot/pom.xml ".harness/shade-boot/$WEB"
cp shade-c3/pom.xml ".harness/shade-c3/$WEB"; cp shade-c3/pom-override.xml ".harness/shade-c3o/$WEB"
TOOLS=tiffinbox-web/src/main/java/com/tiffinbox/web/tools
for d in twomains startclass; do mkdir -p ".harness/$d/$TOOLS"; cp exercise/PrintRoutes.java ".harness/$d/$TOOLS/"; done
cp exercise/solution/pom.xml ".harness/startclass/$WEB"
# build DIR LOG [fails]: a clean build, offline first, its log kept in LOG (never printed whole); Maven Central only if the
# offline build could not resolve something - and the terminal says which (offline: yes / no), so a run that went online is
# never silent. A build that is meant to fail ("fails") must fail for its own reason, not for a missing artifact.
build() { local how=yes ec=0
  (cd "$1" && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package > "$U/$2" 2>&1) || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (cd "$1" && mvn -B -Dmaven.repo.local="$M2" -DskipTests clean package > "$U/$2" 2>&1) || ec=$?; fi
  if [ "$3" = fails ]; then [ $ec != 0 ] || die "$1 was meant to fail its build, and passed"
  else [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $1"; }; fi
  echo "  built $1 · offline: $how · exit $ec"; }
build after .harness/build-after.log; build .harness/before .harness/build-before.log; build .harness/older .harness/build-older.log
build .harness/headerkept .harness/build-headerkept.log
build .harness/shade-boot .harness/build-shade-boot.log
build .harness/shade-c3 .harness/build-shade-c3.log fails; build .harness/shade-c3o .harness/build-shade-c3o.log
build .harness/twomains .harness/build-twomains.log fails; build .harness/startclass .harness/build-startclass.log

# ---- the folders the runs start in -----------------------------------------------------------------------------------------
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
tree .harness/tree
# deploy/: a server folder an older release left - its lib/ (TiffinBox before its shutdown token: ../c5-unit10/after, built
# with the jar plugin's Class-Path and copy-dependencies) - and the token's config tree. A jar is copied in before each run.
tree .harness/deploy; cp -R .harness/older/tiffinbox-web/target/lib .harness/deploy/lib

# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines)
raw() { local t=$1; shift; cat "$@" | grep -oF -- "$t" | wc -l | tr -d ' '; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }
# runf 'COMMAND': print it exactly as typed, run it in the foreground (eval, in a subshell, from this folder), its standard
# output to .harness/run.out and its standard error to .harness/run.err; its exit code in $ec
runf() { echo "\$ $1"; ec=0; (eval "$1") > .harness/run.out 2> .harness/run.err < /dev/null || ec=$?; }
# startjar 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec, so $pid is java's
# own pid), its standard output to .harness/jar.out and its standard error to .harness/jar.err
startjar() { echo "\$ $1"; (eval "${1/&& java /&& exec java }") > .harness/jar.out 2> .harness/jar.err < /dev/null & pid=$!; }
# listening: what the operating system says the process listens on (lsof), once it listens - or "nothing" once it exited
listening() { local a="" i=0
  while [ $i -lt 120 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# up: the line after a start - where it listens, and its WARN/ERROR lines so far; dies if it never listened
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/jar.out >&3; die "it never listened"; }
  echo "  listens on: $l · $(warns .harness/jar.out)"; }
# seven PORT: the comparison set's seven requests (POST /shutdown carries the header, read from tree/'s file), printed as
# run; the JVM must leave within 15 s of them, and the port must be free again. Never call it inside $(...): wait needs
# this shell. $2: the token's file, when not tree/'s.
seven() { local i tf=${2:-.harness/tree/$TF}
  echo "\$ \$CURLSET $1 $tf"
  "$CURLSET" "$1" "$tf" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt || echo "(no POST line)"
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  e=0; wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }
# loaded FILE CLASS...: for each class, its -verbose:class line - the uptime and level prefix cut by sub() - or "(not loaded)"
loaded() { local f=$1 c; shift
  for c in "$@"; do awk -v c="$c" '{ s = $0; sub(/^\[[^]]*\]\[[^]]*\]\[class,load\] /, "", s) } index(s, c " source: ") == 1 { print "  " s; f = 1; exit } END { if (!f) print "  " c " (not loaded)" }' "$f"; done; }
# loadcount FILE: the -verbose:class lines in FILE, and how many name a class of Boot's launcher (org.springframework.boot.loader)
loadcount() { echo "  classes of Boot's launcher (org.springframework.boot.loader.*) that -verbose:class logged: $(grep -c '\[class,load\] org\.springframework\.boot\.loader\.' "$1" || true)"; }
# mf JARFILE: its manifest, folded lines unfolded (a line starting with one space continues the line before)
mf() { unzip -p "$1" META-INF/MANIFEST.MF | tr -d '\r' | awk '/^ / { b = b substr($0, 2); next } { if (n++) print b; b = $0 } END { if (b != "") print b }' | grep .; }
# cpath JARFILE: its manifest's Class-Path, counted - "none" when it has none
cpath() { local c; c=$(mf "$1" | sed -n 's/^Class-Path: //p')
  if [ -z "$c" ]; then echo "none"; else echo "$(echo $c | wc -w | tr -d ' ') entries, the first $(echo $c | awk '{ print $1 }'), every one under lib/: $([ "$(echo $c | tr ' ' '\n' | grep -vc '^lib/' || true)" = 0 ] && echo yes || echo no)"; fi; }

# mask: the demo token becomes a label naming its length; this folder's path "…", the folder above it "…/..", the home
# folder "~" - in every line (gsub)
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)) }
  { gsub(T, "[masked: the 26-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a JVM running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- before: the jar TiffinBox has shipped until now -----------------------------------------------------------------------------
BJ=.harness/before/$JAR
before() {
  echo "\$ unzip -p .harness/before/$JAR META-INF/MANIFEST.MF     (folded lines unfolded; the Class-Path counted)"
  mf "$BJ" | grep -v '^Class-Path: ' | sed 's/^/  /'
  echo "  Class-Path: $(cpath "$BJ")"
  echo "\$ ls .harness/before/tiffinbox-web/target/lib"
  echo "  jars: $(ls .harness/before/tiffinbox-web/target/lib | grep -c '\.jar$') · each named in the Class-Path: $(for j in $(ls .harness/before/tiffinbox-web/target/lib); do mf "$BJ" | sed -n 's/^Class-Path: //p' | tr ' ' '\n' | grep -qxF "lib/$j" && echo y; done | grep -c y)"
  echo "  the jar: $(unzip -Z1 "$BJ" | wc -l | tr -d ' ') entries, $(stat -f %z "$BJ") bytes · jars inside it: $(unzip -Z1 "$BJ" | grep -c '\.jar$' || true)"
  echo "the same jar, copied alone into an empty folder:"
  rm -rf .harness/alone
  runf "mkdir -p .harness/alone && cp $BJ .harness/alone/ && cd .harness/alone && java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18847"
  echo "  exit $ec · standard output $(wc -l < .harness/run.out | tr -d ' ') lines · standard error $(wc -l < .harness/run.err | tr -d ' ') lines · listening on 18847: $(listeners 18847)"
  grep -v '^[[:space:]]' .harness/run.err | sed 's/^/  /' || echo "  (no line)"
  echo "  … and $(grep -c '^[[:space:]]' .harness/run.err || true) stack-frame line(s) of standard error not shown …"; }
cap before before

# ---- change: the previous tree against after/, file by file (README aside) -----------------------------------------------------
# code FILE: its code lines - blank lines and XML comments dropped (a comment may span lines)
code() { awk '{ t = $0; sub(/^[ \t]+/, "", t) }
  inc { if (index(t, "-->")) inc = 0; next }
  index(t, "<!--") == 1 { if (!index(t, "-->")) inc = 1; next }
  t == "" { next }
  { print }' "$1"; }
pm() { git diff --no-index --no-color -U0 "$1" "$2" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' || true; }   # changed lines, +/-
# goals LOG MODULE: the goals the build ran in MODULE, as "plugin:version:goal (execution)", one per line
goals() { sed -nE "s/^\[INFO\] --- ([^ ]+ \([^)]*\)) @ $2 ---\$/\1/p" "$1"; }
change() { local a b n=0 same=0 changed="" gone="" new="" f all cod gb ga
  a=$(cd .harness/before && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  b=$(cd after && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  for f in $a; do if [ -f "after/$f" ]; then n=$((n + 1)); if cmp -s ".harness/before/$f" "after/$f"; then same=$((same + 1)); else changed="$changed $f"; fi; else gone="$gone $f"; fi; done
  for f in $b; do [ -f ".harness/before/$f" ] || new="$new $f"; done
  echo "files, README aside: the previous tree $(echo "$a" | wc -l | tr -d ' ') · after/ $(echo "$b" | wc -l | tr -d ' ') · in both $n: identical $same, changed $(echo $changed | wc -w | tr -d ' ')"
  echo "  only before:${gone:- (none)}"; echo "  only after: ${new:- (none)}"
  mkdir -p .harness/code
  for f in $changed; do
    code ".harness/before/$f" > .harness/code/b; code "after/$f" > .harness/code/a
    all=$(pm ".harness/before/$f" "after/$f" | grep -c . || true); cod=$(pm .harness/code/b .harness/code/a)
    echo "$f, every changed line but comments and blanks ($(( all - $(echo "$cod" | grep -c . || true) )) of those not shown):"
    echo "${cod:-  (none)}"
    echo "  removed $(echo "$cod" | grep -c '^-' || true) · added $(echo "$cod" | grep -c '^+' || true)"; done
  echo "Boot's parent, spring-boot-starter-parent 4.1.1 - what it manages for that plugin:"
  echo '$ sed -n 207,215p "$PARENT"'
  sed -n 207,215p "$PARENT"
  gb=$(goals .harness/build-before.log tiffinbox-web); ga=$(goals .harness/build-after.log tiffinbox-web)
  echo "the goals each build ran in tiffinbox-web (mvn -B clean package, its log): the previous tree $(echo "$gb" | grep -c .) · after/ $(echo "$ga" | grep -c .)"
  echo "  only the previous tree's: $(comm -23 <(echo "$gb" | sort) <(echo "$ga" | sort) | paste -sd'|' - | sed 's/|/ · /g')"
  echo "  only after/'s:            $(comm -13 <(echo "$gb" | sort) <(echo "$ga" | sort) | paste -sd'|' - | sed 's/|/ · /g')"
  echo "  the last goal: the previous tree $(echo "$gb" | tail -1) · after/ $(echo "$ga" | tail -1)"; }
cap change change

# ---- inside: what the new jar holds -----------------------------------------------------------------------------------------
AJ=after/$JAR
inside() { local tf lib n j src ok=0 tot=0
  echo "\$ jar tf $AJ     (counted by place)"
  jar tf "$AJ" > .harness/tf.txt; tf=.harness/tf.txt
  echo "  entries: $(wc -l < $tf | tr -d ' ') · directories among them: $(grep -c '/$' $tf)"
  echo "  under BOOT-INF/classes/: $(grep -c '^BOOT-INF/classes/.' $tf) · classes $(grep -c '^BOOT-INF/classes/.*\.class$' $tf): $(grep '^BOOT-INF/classes/.*\.class$' $tf | sed 's|.*/||; s|\.class$||' | sort | paste -sd' ' -) · YAML files $(grep -c '^BOOT-INF/classes/[^/]*\.yaml$' $tf): $(grep '^BOOT-INF/classes/[^/]*\.yaml$' $tf | sed 's|.*/||' | sort | paste -sd' ' -)"
  echo "  under BOOT-INF/lib/: jars $(grep -c '^BOOT-INF/lib/.*\.jar$' $tf) · other files $(grep '^BOOT-INF/lib/.' $tf | grep -vc '\.jar$' || true)"
  echo "  under org/springframework/boot/loader/: $(grep -c '^org/springframework/boot/loader/.' $tf) · classes $(grep -c '^org/springframework/boot/loader/.*\.class$' $tf)"
  echo "  every other file: $(grep -v '/$' $tf | grep -v '^BOOT-INF/classes/\|^BOOT-INF/lib/\|^org/springframework/boot/loader/' | paste -sd' ' -)"
  echo "  the service file, whole: $(unzip -p "$AJ" META-INF/services/java.nio.file.spi.FileSystemProvider | tr -d '\r' | paste -sd' ' -)"
  echo "  BOOT-INF/classpath.idx: $(unzip -p "$AJ" BOOT-INF/classpath.idx | grep -c .) lines"
  echo "\$ unzip -p $AJ META-INF/MANIFEST.MF"
  mf "$AJ" | sed 's/^/  /'
  echo "\$ ls after/tiffinbox-web/target"
  echo "  $(ls after/tiffinbox-web/target | grep -v '^extracted$' | paste -sd' ' -)"
  echo "  $(stat -f '%N %z bytes' "$AJ" | sed 's|^after/tiffinbox-web/target/||') · $(stat -f '%N %z bytes' "$AJ.original" | sed 's|^after/tiffinbox-web/target/||')"
  unzip -Z1 "$AJ" | sed -n 's|^BOOT-INF/lib/\(.*\.jar\)$|\1|p' | sort > .harness/bootlib.txt
  ls .harness/before/tiffinbox-web/target/lib | sort > .harness/oldlib.txt
  echo "BOOT-INF/lib/ ($(wc -l < .harness/bootlib.txt | tr -d ' ')) against the previous tree's lib/ ($(wc -l < .harness/oldlib.txt | tr -d ' ')):"
  echo "  only in lib/:          $(comm -23 .harness/oldlib.txt .harness/bootlib.txt | paste -sd' ' -)"
  echo "  only in BOOT-INF/lib/: $(comm -13 .harness/oldlib.txt .harness/bootlib.txt | paste -sd' ' -)"
  for j in $(comm -23 .harness/oldlib.txt .harness/bootlib.txt); do
    echo "  $j: classes $(unzip -Z1 ".harness/before/tiffinbox-web/target/lib/$j" | grep -c '\.class$' || true) · $(mf ".harness/before/tiffinbox-web/target/lib/$j" | grep '^Spring-Boot-Jar-Type: ' || echo 'no Spring-Boot-Jar-Type line')"; done
  # each nested jar against the jar it came from: $M2 (found by its file name), core's own build, Boot's loader-tools jar
  mkdir -p .harness/nested; rm -f .harness/nested/*
  for j in $(cat .harness/bootlib.txt); do tot=$((tot + 1)); unzip -p "$AJ" "BOOT-INF/lib/$j" > ".harness/nested/$j"
    case "$j" in
      tiffinbox-core-1.0.0.jar) src=after/tiffinbox-core/target/tiffinbox-core-1.0.0.jar;;
      spring-boot-jarmode-tools-4.1.1.jar) unzip -p "$M2/org/springframework/boot/spring-boot-loader-tools/4.1.1/spring-boot-loader-tools-4.1.1.jar" META-INF/jarmode/spring-boot-jarmode-tools.jar > .harness/jarmode.jar; src=.harness/jarmode.jar;;
      *) n=$(find "$M2" -type f -name "$j" | wc -l | tr -d ' '); [ "$n" = 1 ] || die "inside: $j is in .m2-demo $n times"; src=$(find "$M2" -type f -name "$j");;
    esac
    cmp -s ".harness/nested/$j" "$src" && ok=$((ok + 1)); done
  echo "the $tot nested jars, each against the jar it came from - .m2-demo for $((tot - 2)), core's own build for tiffinbox-core,"
  echo "  Boot's spring-boot-loader-tools jar for the tools jar: byte for byte the same $ok of $tot"; }
cap inside inside

# ---- launcher: how the jar starts -------------------------------------------------------------------------------------------
launcher() {
  echo "TiffinBox's main class, named, with the jar as the class path:"
  runf "java -cp $AJ com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18840"
  echo "  exit $ec · standard output $(wc -l < .harness/run.out | tr -d ' ') lines · listening on 18840: $(listeners 18840)"
  sed 's/^/  /' .harness/run.err
  echo "the jar, run, with java's class-loading log on:"
  startjar "cd .harness/tree && java -verbose:class -jar ../../$AJ --tiffinbox.port=18840"; up
  echo '$ jcmd "$pid" VM.classloaders     ($pid: the java process this script started)'
  jcmd "$pid" VM.classloaders 2>&1 | awk 'NR == 1 && /^[0-9]+:$/ { print "<pid>:"; next } { sub(/[ \t]+$/, ""); if ($0 != "") print }'
  echo "where five classes came from (-verbose:class):"
  loaded .harness/jar.out org.springframework.boot.loader.launch.JarLauncher com.tiffinbox.web.TiffinBoxServer \
    org.springframework.boot.SpringApplication org.springframework.context.ApplicationContext com.tiffinbox.TiffinBoxProperties
  loadcount .harness/jar.out
  seven 18840; }
cap launcher launcher

# ---- folder: the break - a jar in a folder an older release left ---------------------------------------------------------------
# frun LABEL JAR PORT: the jar's Class-Path, then the same command - copy it in, start it - and where two classes came from
FOLDCLS="com.tiffinbox.web.TiffinBoxServer com.tiffinbox.TiffinBoxProperties"
fok() { echo "$1"; echo "  the jar's Class-Path: $(cpath "$2")"
  startjar "cp $2 .harness/deploy/ && cd .harness/deploy && java -verbose:class -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=$3"; up
  loaded .harness/jar.out $FOLDCLS; seven "$3" ".harness/deploy/$TF"; }
fbad() { echo "$1"; echo "  the jar's Class-Path: $(cpath "$2")"
  runf "cp $2 .harness/deploy/ && cd .harness/deploy && java -verbose:class -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=$3"
  echo "  exit $ec · listening on $3: $(listeners "$3") · banner lines $(grep -c ':: Spring Boot ::' .harness/run.out || true) · Boot's failure report (APPLICATION FAILED TO START): $(grep -c '^APPLICATION FAILED TO START$' .harness/run.out || true)"
  loaded .harness/run.out $FOLDCLS
  echo "  Boot: $(said .harness/run.out 'Application run failed') · the \"Caused by:\" lines, each whole:"
  grep '^Caused by: ' .harness/run.out | sed 's/^/  /' || echo "  (none)"
  echo "  … $(( $(cat .harness/run.out .harness/run.err | grep -vc '\[class,load\] ' || true) - 1 - $(grep -c '^Caused by: ' .harness/run.out || true) )) more line(s) of this run's output not shown: the banner, Boot's log, the stack frames - and the class-loading log's own lines, uncounted (their number moves from run to run) …"; }
# said FILE MESSAGE: the first log line whose message starts with MESSAGE, its level kept and the rest of its prefix (time,
# pid, thread, logger) cut by sub() - or "(no such line)"
said() { awk -v m="$2" '{ s = $0; l = ""; if (match(s, /^[0-9][0-9][0-9][0-9]-[^ ]* +[A-Z]+ /)) { l = substr(s, RSTART, RLENGTH); sub(/^[^ ]* +/, "", l); sub(/ +$/, "", l) }
  sub(/^[0-9][0-9][0-9][0-9]-[^ ]* +[A-Z]+ [0-9]+ --- \[[^]]*\] [^:]* : /, "", s) } index(s, m) == 1 { print l " " s; f = 1; exit } END { if (!f) print "(no such line)" }' "$1"; }
folder() {
  echo "deploy/: an older release's server folder - lib/ ($(ls .harness/deploy/lib | grep -c '\.jar$') jars: TiffinBox before its shutdown token, built with the"
  echo "  jar plugin's Class-Path and copy-dependencies) and the token's config tree; each run copies its jar in, then starts it"
  echo "  that lib/'s TiffinBoxProperties: methods named shutdownToken $(javap -cp .harness/deploy/lib/tiffinbox-core-1.0.0.jar com.tiffinbox.TiffinBoxProperties | grep -c ' shutdownToken()' || true) · after/'s: $(javap -cp after/tiffinbox-core/target/tiffinbox-core-1.0.0.jar com.tiffinbox.TiffinBoxProperties | grep -c ' shutdownToken()' || true)"
  fok "A   after/'s jar" "$AJ" 18841
  fbad "B   headerkept/'s jar: the same plugin, the jar plugin's <archive> block kept" ".harness/headerkept/$JAR" 18842
  fok "A′  A, re-run" "$AJ" 18841
  [ "$(listeners 18842)" = 0 ] || die "something listens on 18842"; }
cap folder folder

# ---- shade: one file, flattened - the same-named files, and what two shadings keep ------------------------------------------------
# kept JAR: what a shaded jar holds - entries, jars inside, and for the imports file, spring.factories and the log4j service
# file: its lines (or keys), and whose copy it is, byte for byte, when it is one jar's own (else "none - a merge")
IMP=META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
SVC=META-INF/services/org.apache.logging.log4j.util.PropertySource
whose() { local j w=""; unzip -p "$1" "$2" > .harness/whose.txt
  for j in $(cat .harness/bootlib.txt); do unzip -p ".harness/nested/$j" "$2" 2> /dev/null | cmp -s - .harness/whose.txt && w="$w ${j%.jar}"; done
  echo "${w# }"; }
kept() { local w
  echo "  the jar: entries $(unzip -Z1 "$1" | wc -l | tr -d ' ') · jars inside it $(unzip -Z1 "$1" | grep -c '\.jar$' || true) · its Main-Class: $(mf "$1" | sed -n 's/^Main-Class: //p')"
  w=$(whose "$1" "$IMP"); echo "  the imports file: lines $(unzip -p "$1" "$IMP" | grep -c '^[^#]' || true) · ValidationAutoConfiguration among them $(unzip -p "$1" "$IMP" | grep -c 'ValidationAutoConfiguration$' || true) · one jar's own copy: ${w:-none - a merge}"
  w=$(whose "$1" META-INF/spring.factories); echo "  META-INF/spring.factories: keys $(unzip -p "$1" META-INF/spring.factories | tr -d '\r' | grep -cE '^[A-Za-z][^=]*=' || true) · one jar's own copy: ${w:-none - a merge}"
  echo "    $(reg "$1" META-INF/spring.factories)"
  w=$(whose "$1" "$SVC"); echo "  the log4j service file: lines $(unzip -p "$1" "$SVC" | grep -c '^[^#]' || true) · one jar's own copy: ${w:-none - a merge}"; }
# reg JAR FILE: in that jar's spring.factories, three of the classes spring-boot's own copy registers - the YAML loader, the
# logging listener, the failure analyzers' key - each counted
reg() { unzip -p "$1" "$2" 2> /dev/null | tr -d '\r' > .harness/reg.txt || true
  echo "the YAML loader (YamlPropertySourceLoader) $(grep -c 'YamlPropertySourceLoader' .harness/reg.txt || true) · the logging listener (LoggingApplicationListener) $(grep -c 'LoggingApplicationListener' .harness/reg.txt || true) · failure analyzers (FailureAnalyzer=) $(grep -c '^org\.springframework\.boot\.diagnostics\.FailureAnalyzer=' .harness/reg.txt || true)"; }
# overlap LOG: the shade plugin's warnings that name spring.factories or the imports file - each warning's first line (the jars)
overlap() { awk -v i="$IMP" '/^\[WARNING\] .* define [0-9]+ overlapping / { h = $0; next } /^\[WARNING\]   - / { f = $0; sub(/^\[WARNING\]   - /, "", f); if (f == "META-INF/spring.factories" || f == i) { sub(/^\[WARNING\] /, "", h); print "    " h f } }' "$1"; }
shade() { local j f o
  echo "the same-named files TiffinBox's 31 jars carry - the jars inside after/'s jar, each read where it is:"
  for f in META-INF/spring.factories "$IMP" "$SVC"; do
    echo "  $f: in $(for j in $(cat .harness/bootlib.txt); do unzip -Z1 ".harness/nested/$j" | grep -qxF "$f" && echo "$j"; done | wc -l | tr -d ' ') jars - $(for j in $(cat .harness/bootlib.txt); do unzip -Z1 ".harness/nested/$j" | grep -qxF "$f" && echo "${j%.jar}"; done | paste -sd' ' -)"; done
  echo "  after/'s jar keeps every copy, each inside its own jar - at the top of the jar itself: $(jar tf "$AJ" | grep -cxE "META-INF/spring.factories|$IMP|$SVC" || true)"
  echo "  spring-boot-4.1.1.jar's own spring.factories: keys $(unzip -p .harness/nested/spring-boot-4.1.1.jar META-INF/spring.factories | tr -d '\r' | grep -cE '^[A-Za-z][^=]*=' || true) · $(reg .harness/nested/spring-boot-4.1.1.jar META-INF/spring.factories)"
  echo "Boot's way - shade-boot/: the shade plugin declared bare (Boot's parent: its version, an execution, Boot's transformers)"
  echo "  build: exit 0 · $(grep -E '^\[INFO\] --- shade:' .harness/build-shade-boot.log | sed 's/^\[INFO\] --- //; s/ ---$//') · its warnings naming those two files: $(overlap .harness/build-shade-boot.log | grep -c . || true)"
  kept ".harness/shade-boot/$JAR"
  startjar "cd .harness/tree && java -jar ../shade-boot/$JAR --tiffinbox.port=18843"; up; seven 18843
  echo "Course 3's way - shade-c3/: the shade plugin with Course 3's execution and its two transformers, pasted as written"
  echo "  Boot's parent's transformer list, its first entry:"; echo '  $ sed -n 252,254p "$PARENT"'; sed -n 252,254p "$PARENT"
  echo "  build: exit 1 · $(grep -m1 -oE 'Unable to parse configuration of mojo [^ ]+ for parameter [a-z]+: Cannot find .[a-z]+. in class [A-Za-z.]+' .harness/build-shade-c3.log || echo '(no parse error)')"
  echo "the same file with <transformers combine.self=\"override\"> (shade-c3/pom-override.xml):"
  o=$(overlap .harness/build-shade-c3o.log)
  echo "  build: exit 0 · BUILD SUCCESS lines $(grep -c '^\[INFO\] BUILD SUCCESS$' .harness/build-shade-c3o.log || true) · its warnings naming those two files: $(printf '%s\n' "$o" | grep -c . || true)"
  printf '%s\n' "$o"
  kept ".harness/shade-c3o/$JAR"
  runf "cd .harness/tree && java -jar ../shade-c3o/$JAR --tiffinbox.port=18844"
  echo "  exit $ec · listening on 18844: $(listeners 18844) · banner lines $(grep -c ':: Spring Boot ::' .harness/run.out || true) · APPLICATION FAILED TO START: $(grep -c '^APPLICATION FAILED TO START$' .harness/run.out || true) · standard error $(wc -l < .harness/run.err | tr -d ' ') lines"
  echo "  log lines in Boot's format (date, level, pid, ---): $(grep -cE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +[A-Z]+ [0-9]+ --- ' .harness/run.out || true) · in Logback's own (time [thread] LEVEL logger --): $(grep -cE '^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} \[[^]]+\] [A-Z]+ ' .harness/run.out || true) · the one at ERROR, its time cut:"
  grep -m1 -E '^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} \[[^]]+\] ERROR ' .harness/run.out | sed -E 's/^[0-9:.]+ /  /' || echo "  (none)"
  echo "  the last \"Caused by:\": $(grep '^Caused by: ' .harness/run.out | tail -1 | sed 's/^Caused by: //')"
  echo "  the record's fields it rejects as null: $(cat .harness/run.out .harness/run.err | sed -nE "s/^.*Field error in object 'tiffinbox' on field '([A-Za-z]+)': rejected value \[null\].*$/\1/p" | sort -u | paste -sd' ' -) · port among them: $(grep -c "on field 'port'" .harness/run.out || true)"; }
cap shade shade

# ---- extract: the jar, unpacked by Boot's own tool ------------------------------------------------------------------------
# readme PATTERN: the first line of after/README.md that matches PATTERN - so a label never claims what the README says
readme() { grep -m1 -E "$1" after/README.md || true; }
extract() { local ex xc xj rn
  ex=$(readme '^java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar extract --destination [^ ]+$')
  xc=$(readme '^java -cp "[^"]+" com\.tiffinbox\.web\.TiffinBoxServer --tiffinbox\.port=18431$')
  [ -n "$ex" ] && [ -n "$xc" ] || die "after/README.md no longer gives the extract command and the class-path command"
  xd=${ex##* }                                       # the README's destination, under after/
  rm -rf "after/$xd"                                 # each run starts without it
  echo "after/README.md's extract command, read from the file, run as written from after/:"
  runf "cd after && $ex"
  echo "  exit $ec · printed: $(cat .harness/run.out .harness/run.err | grep -c .) line(s)"
  echo "\$ ls after/$xd"; echo "  $(ls "after/$xd" | paste -sd' ' -)"
  xj="after/$xd/tiffinbox-web-1.0.0.jar"
  echo "  the thin jar: entries $(unzip -Z1 "$xj" | wc -l | tr -d ' ') · classes $(unzip -Z1 "$xj" | grep -c '\.class$') · jars inside it $(unzip -Z1 "$xj" | grep -c '\.jar$' || true) · Main-Class: $(mf "$xj" | sed -n 's/^Main-Class: //p')"
  echo "  its Class-Path: $(cpath "$xj")"
  echo "  lib/: jars $(ls "after/$xd/lib" | grep -c '\.jar$') · the same names as BOOT-INF/lib/: $(ls "after/$xd/lib" | sort | cmp -s - .harness/bootlib.txt && echo yes || echo no) · byte for byte the nested jars: $(n=0; for j in $(ls "after/$xd/lib"); do cmp -s "after/$xd/lib/$j" ".harness/nested/$j" && n=$((n + 1)); done; echo $n)"
  echo "the thin jar, run with java -jar (the README's note), class-loading log on:"
  startjar "cd .harness/tree && java -verbose:class -jar ../../$xj --tiffinbox.port=18845"; up
  loadcount .harness/jar.out
  loaded .harness/jar.out com.tiffinbox.web.TiffinBoxServer org.springframework.boot.SpringApplication
  seven 18845
  rn=$(printf '%s\n' "$xc" | sed "s|tiffinbox-web/target/|../../after/tiffinbox-web/target/|g; s|--tiffinbox.port=18431|--tiffinbox.port=18845|")
  echo "after/README.md's class-path command, read from the file - its paths made relative to tree/, its port 18431 made 18845:"
  startjar "cd .harness/tree && $rn"; up; seven 18845; }
cap extract extract

# ---- serve: the run command, unchanged -------------------------------------------------------------------------------------
serve() { local rc; rc=$(readme '^java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=18431$')
  [ -n "$rc" ] || die "after/README.md no longer gives the run command"
  echo "the run command after/README.md gives: $rc"
  echo "  the same line in the previous tree's README: $(grep -c -xF -- "$rc" .harness/before/README.md || true) time(s)"
  echo "that command, from tree/ (the token's config tree) - the jar's path made relative to tree/, its port 18431 made 18846:"
  rc=${rc/tiffinbox-web\/target/../../after/tiffinbox-web/target}; rc=${rc/18431/18846}
  startjar "cd .harness/tree && $rc"; up; seven 18846; }
cap serve serve

# ---- exercise: two main classes, and the property that chooses -------------------------------------------------------------
exercise() {
  echo "twomains/: after/ plus exercise/PrintRoutes.java in $TOOLS - a second class with a main method"
  echo "  build (mvn -B clean package): exit 1 · $(grep -m1 -oE 'Unable to find a single main class from the following candidates \[[^]]*\]' .harness/build-twomains.log || echo '(no such line)')"
  echo "  the goal that failed: $(grep -m1 -oE 'Failed to execute goal [^ ]+ \([^)]*\)' .harness/build-twomains.log | sed 's/^Failed to execute goal //' || echo '(none)')"
  echo "startclass/: twomains/ with exercise/solution/pom.xml as tiffinbox-web's POM - one property, start-class"
  echo "  build: exit 0 · PrintRoutes in the jar: $(unzip -Z1 ".harness/startclass/$JAR" | grep -c 'BOOT-INF/classes/com/tiffinbox/web/tools/PrintRoutes\.class$' || true)"
  echo "\$ unzip -p .harness/startclass/$JAR META-INF/MANIFEST.MF | grep -E '^(Main|Start)-Class'"
  mf ".harness/startclass/$JAR" | grep -E '^(Main|Start)-Class' | sed 's/^/  /'; }
cap exercise exercise

# ---- files: every demo file, against the file it stands in for -------------------------------------------------------------------
files() {
  against() { if cmp -s "$1" "$2"; then echo "$2: $3, byte for byte"
              else echo "$2, against $3:"; diff "$1" "$2" | sed 's/^/  /' || true; fi; }
  against "after/$WEB" headerkept/pom.xml "after/'s $WEB"
  against "after/$WEB" shade-boot/pom.xml "after/'s $WEB"
  against "after/$WEB" shade-c3/pom.xml "after/'s $WEB"
  against shade-c3/pom.xml shade-c3/pom-override.xml "shade-c3/pom.xml"
  against "after/$WEB" exercise/solution/pom.xml "after/'s $WEB"
  echo "shade-c3's transformers against Course 3's (\$C3POM, its shade execution; leading blanks dropped):"
  diff <(sed -n '/<transformers>/,/<\/transformers>/p' "$C3POM" | head -6 | sed 's/^[ \t]*//') \
       <(sed -n '/<transformers>/,/<\/transformers>/p' shade-c3/pom.xml | sed 's/^[ \t]*//') | sed 's/^/  /' || true
  echo "headerkept/'s jar block against the previous tree's (lines 42-57 of its $WEB):"
  diff <(sed -n 42,57p ".harness/before/$WEB") <(sed -n 42,57p headerkept/pom.xml) > /dev/null && echo "  identical, 16 lines" || echo "  DIFFERENT"; }
cap files files

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has1() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }     # an exact line inside a block
cnt() { printf '%s\n' "$1" | grep -cE -- "$2" || true; }                                 # lines of a block matching a pattern
S115='115c36bac276128e245ca57df11c2891'
M26='[masked: the 26-character token]'
IMPL='META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports'

# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does
# anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 after/README.md; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/' "$f" || die "$f holds an absolute path"; done
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the exercise and receipts.md5; no absolute path in any capture"

# "Its manifest names a main class and thirty-three other jars, in a folder called lib ... Copy the jar somewhere by itself,
# and it can't start: Jackson's ObjectMapper isn't there."
x before '^  Main-Class: com\.tiffinbox\.web\.TiffinBoxServer$'
x before '^  Class-Path: 33 entries, the first lib/tiffinbox-core-1\.0\.0\.jar, every one under lib/: yes$'
x before '^  jars: 33 · each named in the Class-Path: 33$'
x before '^  the jar: [0-9]+ entries, [0-9]+ bytes · jars inside it: 0$'
x before '^  exit 1 · standard output 0 lines · standard error [0-9]+ lines · listening on 18847: 0$'
x before '^  Exception in thread "main" java\.lang\.NoClassDefFoundError: com/fasterxml/jackson/databind/ObjectMapper$'
! grep -q '^  Start-Class: ' .r-before.out || die "before: the previous jar has no Start-Class"
echo "  before: Main-Class TiffinBoxServer, Class-Path 33, lib/ 33 · alone: exit 1, NoClassDefFoundError ObjectMapper"

# "Today TiffinBox declares it: two lines, no version, no execution. The parent supplies both ... the build runs one new
# goal, repackage, and no longer copies the jars into lib."
x change '^files, README aside: the previous tree 18 · after/ 18 · in both 18: identical 17, changed 1$'
x change '^  removed 26 · added 2$'
CP=$(blk change 'tiffinbox-web/pom.xml, every changed line' '  removed ')
has1 "$CP" '+        <groupId>org.springframework.boot</groupId>' change; has1 "$CP" '+        <artifactId>spring-boot-maven-plugin</artifactId>' change
[ "$(cnt "$CP" '^\+')" = 2 ] && [ "$(cnt "$CP" '^\+.*<(version|executions?)>')" = 0 ] || die "change: the plugin is declared bare - two lines, no version, no execution"
has1 "$CP" '-              <classpathPrefix>lib/</classpathPrefix>' change; has1 "$CP" '-            <goals><goal>copy-dependencies</goal></goals>' change
PB=$(blk change '$ sed -n 207,215p "$PARENT"' 'the goals each build ran')
has1 "$PB" '          <artifactId>spring-boot-maven-plugin</artifactId>' change; has1 "$PB" '                <goal>repackage</goal>' change
x change '^the goals each build ran in tiffinbox-web \(mvn -B clean package, its log\): the previous tree 8 · after/ 8$'
x change "^  only the previous tree's: dependency:3\.11\.0:copy-dependencies \(copy-libs\)$"
x change "^  only after/'s:            spring-boot:4\.1\.1:repackage \(repackage\)$"
echo "  change: web's POM -26 +2 (the plugin, bare); the parent's execution: repackage; goals: copy-dependencies out, repackage in"

# "One hundred and sixty-nine entries. TiffinBox's three classes and two YAML files ... thirty-one jars ... each one whole.
# That's the thirty-three, minus the three starters, which hold no code, plus one jar of Boot's own tools. ... ninety-nine
# classes of Boot's launcher ... JarLauncher ... Start-Class"
x inside '^  entries: 169 · directories among them: 28$'
x inside '^  under BOOT-INF/classes/: 8 · classes 3: Route TiffinBoxApp TiffinBoxServer · YAML files 2: application-audit\.yaml application\.yaml$'
x inside '^  under BOOT-INF/lib/: jars 31 · other files 0$'
x inside '^  under org/springframework/boot/loader/: 112 · classes 99$'
x inside '^  the service file, whole: org\.springframework\.boot\.loader\.nio\.file\.NestedFileSystemProvider$'
x inside '^  Main-Class: org\.springframework\.boot\.loader\.launch\.JarLauncher$'; x inside '^  Start-Class: com\.tiffinbox\.web\.TiffinBoxServer$'
x inside '^  classes generated-sources maven-archiver maven-status tiffinbox-web-1\.0\.0\.jar tiffinbox-web-1\.0\.0\.jar\.original$'
x inside '^  only in lib/:          spring-boot-starter-4\.1\.1\.jar spring-boot-starter-logging-4\.1\.1\.jar spring-boot-starter-validation-4\.1\.1\.jar$'
x inside '^  only in BOOT-INF/lib/: spring-boot-jarmode-tools-4\.1\.1\.jar$'
[ "$(grep -c '^  spring-boot-starter[a-z-]*-4\.1\.1\.jar: classes 0 · Spring-Boot-Jar-Type: dependencies-starter$' .r-inside.out)" = 3 ] || die "inside: the three starters hold no class, and say dependencies-starter"
x inside '^  Boot.s spring-boot-loader-tools jar for the tools jar: byte for byte the same 31 of 31$'
echo "  inside: 169 entries · 3 classes, 2 YAML · 31 jars (33 - 3 starters + the tools jar), 31 of 31 byte-identical · 99 launcher classes · JarLauncher / Start-Class"

# "Name TiffinBox's class yourself, with the jar as the class path, and java can't find it ... The launcher builds a class
# loader of its own, under the application's loader ... the launcher from the jar itself, TiffinBox's server and Spring's
# classes from inside the nested jars"
x launcher '^  Caused by: java\.lang\.ClassNotFoundException: com\.tiffinbox\.web\.TiffinBoxServer$'
x launcher '^  exit 1 · standard output 0 lines · listening on 18840: 0$'
LT=$(blk launcher '$ jcmd "$pid" VM.classloaders' 'where five classes')
[ "$(printf '%s\n' "$LT" | grep -n 'LaunchedClassLoader$' | cut -d: -f1)" -gt "$(printf '%s\n' "$LT" | grep -n '"app", ' | cut -d: -f1)" ] \
  && has1 "$LT" '                  +-- org.springframework.boot.loader.launch.LaunchedClassLoader' launcher \
  && has1 "$LT" '            +-- "app", jdk.internal.loader.ClassLoaders$AppClassLoader' launcher || die "launcher: LaunchedClassLoader sits under the app loader"
x launcher '^  org\.springframework\.boot\.loader\.launch\.JarLauncher source: file:…/after/tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar$'
x launcher '^  com\.tiffinbox\.web\.TiffinBoxServer source: jar:nested:…/after/tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar/!BOOT-INF/classes/!/$'
x launcher '^  org\.springframework\.boot\.SpringApplication source: jar:nested:…/after/tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar/!BOOT-INF/lib/spring-boot-4\.1\.1\.jar!/$'
x launcher "^  exit 0 · the seven responses: 7 lines · md5 $S115\$"
echo "  launcher: -cp the jar -> ClassNotFoundException · app -> LaunchedClassLoader · JarLauncher from the jar, the rest jar:nested · 115c36ba..."

# "Drop the new jar in. A: it serves ... B: ... Repackage keeps the Class-Path line ... Exit one: no such method,
# shutdownToken. Two copies of one class name, and the loader asked first wins. A again: it serves."
FA=$(blk folder 'A   ' 'B   '); FB=$(blk folder 'B   ' 'A′  '); FA2=$(blk folder 'A′  ' '')
x folder '^  that lib/.s TiffinBoxProperties: methods named shutdownToken 0 · after/.s: 1$'
has1 "$FA" "  the jar's Class-Path: none" folder; has1 "$FA" "  exit 0 · the seven responses: 7 lines · md5 $S115" folder
has1 "$FA" '  com.tiffinbox.TiffinBoxProperties source: jar:nested:…/.harness/deploy/tiffinbox-web-1.0.0.jar/!BOOT-INF/lib/tiffinbox-core-1.0.0.jar!/' folder
has1 "$FB" "  the jar's Class-Path: 33 entries, the first lib/tiffinbox-core-1.0.0.jar, every one under lib/: yes" folder
has1 "$FB" '  exit 1 · listening on 18842: 0 · banner lines 1 · Boot'"'"'s failure report (APPLICATION FAILED TO START): 0' folder
has1 "$FB" '  com.tiffinbox.web.TiffinBoxServer source: jar:nested:…/.harness/deploy/tiffinbox-web-1.0.0.jar/!BOOT-INF/classes/!/' folder
has1 "$FB" '  com.tiffinbox.TiffinBoxProperties source: file:…/.harness/deploy/lib/tiffinbox-core-1.0.0.jar' folder
has1 "$FB" "  Caused by: java.lang.NoSuchMethodError: 'java.lang.String com.tiffinbox.TiffinBoxProperties.shutdownToken()'" folder
[ "$FA" = "$FA2" ] || die "folder: A' is not A, line for line"
echo "  folder: A no Class-Path, serves 115c36ba... · B Class-Path 33, TiffinBoxProperties from deploy/lib, NoSuchMethodError shutdownToken() · A' = A"

# "Five of TiffinBox's jars carry a file called spring dot factories. Two carry the imports file ... Boot's jar keeps every
# copy ... Boot's way ... thirteen lines, seventeen keys, and it serves. Course three's way doesn't even parse ... spring-aop's
# file wins, with one key ... twelve of thirteen ... the services transformer ... merged: three lines ... exit one; every
# setting from the YAML file is null"
x shade '^  META-INF/spring\.factories: in 5 jars - spring-aop-7\.0\.9 spring-boot-4\.1\.1 spring-boot-autoconfigure-4\.1\.1 spring-boot-jarmode-tools-4\.1\.1 spring-boot-validation-4\.1\.1$'
x shade "^  $IMPL: in 2 jars - spring-boot-autoconfigure-4\.1\.1 spring-boot-validation-4\.1\.1\$"
x shade '^  META-INF/services/org\.apache\.logging\.log4j\.util\.PropertySource: in 2 jars - log4j-api-2\.25\.5 spring-boot-4\.1\.1$'
x shade '^  after/.s jar keeps every copy, each inside its own jar - at the top of the jar itself: 0$'
SB=$(blk shade "Boot's way" "Course 3's way"); SC=$(blk shade "Course 3's way" 'the same file with'); SO=$(blk shade 'the same file with' '')
printf '%s\n' "$SB" | grep -qE '^  build: exit 0 · shade:3\.6\.2:shade \(default\) @ tiffinbox-web · its warnings naming those two files: 0$' || die "shade: Boot's way builds, no warning on those files"
has1 "$SB" "  the imports file: lines 13 · ValidationAutoConfiguration among them 1 · one jar's own copy: none - a merge" shade
has1 "$SB" "  META-INF/spring.factories: keys 17 · one jar's own copy: none - a merge" shade
has1 "$SB" "  exit 0 · the seven responses: 7 lines · md5 $S115" shade
printf '%s\n' "$SB" | grep -qE '^  the jar: entries [0-9]{4,} · jars inside it 0 · its Main-Class: com\.tiffinbox\.web\.TiffinBoxServer$' || die "shade: flattened - thousands of entries, 0 jars inside"
printf '%s\n' "$SC" | grep -qF "  build: exit 1 · Unable to parse configuration of mojo org.apache.maven.plugins:maven-shade-plugin:3.6.2:shade for parameter resource: Cannot find 'resource' in class org.apache.maven.plugins.shade.resource.ManifestResourceTransformer" || die "shade: Course 3's transformers, pasted, do not parse"
has1 "$SO" "  the imports file: lines 12 · ValidationAutoConfiguration among them 0 · one jar's own copy: spring-boot-autoconfigure-4.1.1" shade
has1 "$SO" "  META-INF/spring.factories: keys 1 · one jar's own copy: spring-aop-7.0.9" shade
REG3="the YAML loader (YamlPropertySourceLoader) 1 · the logging listener (LoggingApplicationListener) 1 · failure analyzers (FailureAnalyzer=) 1"
REG0="the YAML loader (YamlPropertySourceLoader) 0 · the logging listener (LoggingApplicationListener) 0 · failure analyzers (FailureAnalyzer=) 0"
has1 "$SO" "    $REG0" shade; has1 "$SB" "    $REG3" shade
x shade "^  spring-boot-4\.1\.1\.jar's own spring\.factories: keys [0-9]+ · the YAML loader \(YamlPropertySourceLoader\) 1 · the logging listener \(LoggingApplicationListener\) 1 · failure analyzers \(FailureAnalyzer=\) 1\$"
has1 "$SC" '                    <resource>META-INF/spring.handlers</resource>' shade
has1 "$SC" '                  <transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">' shade
has1 "$SO" "  the log4j service file: lines 3 · one jar's own copy: none - a merge" shade
printf '%s\n' "$SO" | grep -qE '^  exit 1 · listening on 18844: 0 · banner lines 1 · APPLICATION FAILED TO START: 0 · standard error 0 lines$' || die "shade: Course 3's jar exits 1, before listening"
printf '%s\n' "$SO" | grep -qE "^  log lines in Boot's format \(date, level, pid, ---\): 0 · in Logback's own \(time \[thread\] LEVEL logger --\): [1-9][0-9]* · " || die "shade: Course 3's jar logs in Logback's own format, never Boot's"
has1 "$SO" '  the last "Caused by:": org.springframework.boot.context.properties.bind.validation.BindValidationException: Binding validation errors on tiffinbox' shade
has1 "$SO" "  the record's fields it rejects as null: cooks days jdbcUrl mealTypes shutdownToken · port among them: 0" shade
echo "  shade: 5 / 2 / 2 same-named files · Boot's way 13 lines, 17 keys, serves · Course 3's: no parse; override: 12, 1 key (spring-aop's), log4j merged 3, exit 1, YAML keys null"

# "Extract gives back a thin jar, with a Class-Path of thirty-one, and a lib folder ... It serves the same hash, and loads
# none of the launcher's classes."
x extract '^  exit 0 · printed: 0 line\(s\)$'
x extract '^  the thin jar: entries [0-9]+ · classes 3 · jars inside it 0 · Main-Class: com\.tiffinbox\.web\.TiffinBoxServer$'
x extract '^  its Class-Path: 31 entries, the first lib/tiffinbox-core-1\.0\.0\.jar, every one under lib/: yes$'
x extract '^  lib/: jars 31 · the same names as BOOT-INF/lib/: yes · byte for byte the nested jars: 31$'
x extract "^  classes of Boot's launcher \(org\.springframework\.boot\.loader\.\*\) that -verbose:class logged: 0\$"
x launcher "^  classes of Boot's launcher \(org\.springframework\.boot\.loader\.\*\) that -verbose:class logged: [1-9][0-9]*\$"
[ "$(grep -c "^  exit 0 · the seven responses: 7 lines · md5 $S115\$" .r-extract.out)" = 2 ] || die "extract: both ways serve 115c36ba..."
echo "  extract: thin jar (Main-Class TiffinBoxServer, Class-Path 31) + lib/ 31 · java -jar and java -cp both serve 115c36ba..., 0 launcher classes"

# "And the run command doesn't change ... The seven responses: the same hash."
x serve '^the run command after/README\.md gives: java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=18431$'
x serve '^  the same line in the previous tree.s README: [1-9][0-9]* time\(s\)$'
x serve "^  exit 0 · the seven responses: 7 lines · md5 $S115\$"
echo "  serve: the README's run command, the same line as before; 115c36ba..."

# the exercise's end state: two main classes stop the build; one property chooses
x exercise '^  build \(mvn -B clean package\): exit 1 · Unable to find a single main class from the following candidates \[com\.tiffinbox\.web\.TiffinBoxServer, com\.tiffinbox\.web\.tools\.PrintRoutes\]$'
x exercise '^  the goal that failed: org\.springframework\.boot:spring-boot-maven-plugin:4\.1\.1:repackage \(repackage\)$'
x exercise '^  build: exit 0 · PrintRoutes in the jar: 1$'; x exercise '^  Start-Class: com\.tiffinbox\.web\.TiffinBoxServer$'
echo "  exercise: two mains -> repackage fails, naming both · start-class -> Start-Class: com.tiffinbox.web.TiffinBoxServer"

# the demo files: each differs from after/'s web POM in its one block
x files '^shade-c3/pom-override\.xml, against shade-c3/pom\.xml:$'
[ "$(blk files 'shade-c3/pom-override.xml, against' 'exercise/solution' | grep -c '^  [<>] ')" = 2 ] || die "files: the override is one attribute"
[ "$(blk files "shade-c3's transformers against Course 3's" 'headerkept' | grep -c '^  [<>] ')" = 2 ] || die "files: shade-c3's transformers are Course 3's, the main class written out"
x files '^  identical, 16 lines$'
echo "  files: headerkept/ = after/ + the previous jar block (identical) · override = one attribute · Course 3's transformers, \${main.class} written out"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit13: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture"
