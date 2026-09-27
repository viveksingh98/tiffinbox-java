#!/bin/bash
# Unit 31's receipts. The capstone as Course 3 left it (before/, frozen) and as this course leaves it
# (../c4-tiffinbox), built and served in ONE run on ONE machine, and every claim the video makes asserted.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
M2="$PWD/.m2-demo"
die() { echo "  *** $* ***"; exit 1; }
build() { (cd "$1" && mvn -q -Dmaven.repo.local="$M2" -DskipTests package) || die "build failed: $1"; }
jars() { echo "$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$1"/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"; }
# A copy of the rewired anchor with one break laid over it.
overlay() { rm -rf ".work/$1"; mkdir -p .work; rsync -a --exclude target --exclude '.m2*' ../c4-tiffinbox/ ".work/$1/"; rsync -a "breaks/$1/" ".work/$1/"; }
# Serve a build, run the comparison set against it, and require the server to be GONE after POST /shutdown.
serve() { dir=$1; port=$2; out=$3
  java -jar "$dir/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" "$port" > ".r-$out-server.log" 2>&1 & pid=$!
  for i in $(seq 1 40); do curl -s -o /dev/null "http://127.0.0.1:$port/kitchen" && break; sleep 0.25; done
  ./curlset.sh "$port"
  for i in $(seq 1 40); do kill -0 "$pid" 2>/dev/null || break; sleep 0.25; done
  kill -0 "$pid" 2>/dev/null && { kill "$pid"; die "$out: the server was still running after POST /shutdown"; }
  wait "$pid"; ec=$?
  [ "$(lsof -nP -iTCP:"$port" -sTCP:LISTEN -t 2>/dev/null | wc -l | tr -d ' ')" = 0 ] || die "$out: something still listens on $port"
  printf '  (server exit %s, 0 listeners left on %s)\n' "$ec" "$port"; }
# Three runs, hashed; a drift stops the receipts.
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; printf '  %-12s md5 %s  3/3\n' "$nm" "$h"; }
# Masks jar paths; drops JUL header lines, the server's own INFO lines and stack frames - and COUNTS every
# line it drops, so no cut is uncounted.
mask() { awk '{ gsub(/jar:file:[^]!]*/, "jar:file:<path>") }
  /^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9][0-9][0-9][0-9] [0-9:]+ (AM|PM) / { ts++; next }
  /^INFO: / { info++; next }
  /^\tat / || /^\t\.\.\. [0-9]+ more$/ { st++; next }
  { print } END { printf "… %d JUL header line(s), %d INFO line(s), %d stack line(s) elided …\n", ts, info, st }'; }

echo "building: before/ (as Course 3 left it), the rewired anchor, and the two breaks"
build before; build ../c4-tiffinbox
overlay no-database-component; build .work/no-database-component
overlay one-new; build .work/one-new

cap before   serve before 18441 before
cap after    serve ../c4-tiffinbox 18442 after
cap one-new  serve .work/one-new 18445 one-new
cap ledger-before sh ../c4-unit01/ledger.sh before/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java
cap ledger-after  sh -c 'sh ../c4-unit01/ledger.sh ../c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java; echo "exit $?"'
cap ledger-project sh ledger-project.sh before ../c4-tiffinbox
cap objects  python3 onlyannotations.py before/tiffinbox-core/src/main/java/com/tiffinbox ../c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox
rm -rf .harness; "$JAVA_HOME/bin/javac" -cp "$(jars ../c4-tiffinbox)" -d .harness harness/com/tiffinbox/harness/*.java
order()    { java -cp ".harness:$(jars ../c4-tiffinbox)" com.tiffinbox.harness.BuildOrder 18446 2>&1 | mask; }
cap order    order
# the exit code is JAVA's, taken before any filter touches the output
nodb() { java -jar .work/no-database-component/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18447 > .r-no-db.raw 2>&1; ec=$?
         mask < .r-no-db.raw; echo "exit $ec"; }
cap no-db    nodb
kitchens() { java -cp ".harness:$(jars .work/one-new)" com.tiffinbox.harness.TwoKitchens 18448 2>&1 | mask; }
cap kitchens kitchens

echo
S=".r-before.out"; A=".r-after.out"
diff <(grep -v '^  (server exit' "$S") <(grep -v '^  (server exit' "$A") > /dev/null \
  && echo "  curl, before vs after: IDENTICAL, $(grep -c ' -> ' "$A") of $(grep -c ' -> ' "$S") requests (status, content type, body)" || die "the rewire changed the curl output"
diff <(grep -v '^  (server exit' "$S") <(grep -v '^  (server exit' .r-one-new.out) > /dev/null \
  && echo "  curl, before vs the one-new break: IDENTICAL too - the break still works" || die "the one-new break changed the output"
grep -q '^  (server exit 0, 0 listeners left' "$A" && echo "  after POST /shutdown: the rewired server exited 0 and left no listener" || die "the rewired server did not stop cleanly"
grep -q 'nothing to count' .r-ledger-after.out && grep -q '^exit 2$' .r-ledger-after.out && echo "  the old ledger on the rewired project: exit 2, nothing to count" || die "the old ledger did not report the deletion"
grep -q 'hand-written constructions of those classes .* [1-9][0-9]* -> 0$' .r-ledger-project.out && echo "  hand-written constructions: $(grep 'hand-written' .r-ledger-project.out | grep -oE '[0-9]+ -> 0$')" || die "constructions did not go to 0"
grep -q 'not an annotation or an import ...... 0$' .r-objects.out && echo "  the objects: every changed line is an annotation or an import" || die "an object changed beyond annotations"
grep -q "No qualifying bean of type 'com.tiffinbox.Database'" .r-no-db.out && grep -q '^exit 1$' .r-no-db.out && echo "  the container checks it: without Database's @Component, startup refuses (exit 1) and names the type" || die "the missing bean was not refused"
grep -q 'the server cooks with that one?  : false' .r-kitchens.out && grep -q "the container's: 0" .r-kitchens.out && echo "  the break: two kitchens - the server's is not the container's, and the container's cooked nothing" || die "the two-kitchens claim failed"
