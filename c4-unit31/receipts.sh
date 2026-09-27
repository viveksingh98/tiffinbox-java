#!/bin/bash
# Unit 31's receipts. The capstone as Course 3 left it (before/, frozen) and as this course leaves it
# (../c4-tiffinbox), built and served in ONE run on ONE machine, and every number the video says asserted.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
M2="$PWD/.m2-demo"
# JUL's header line is locale-dependent ("Sep 27, 2026" in en-US, "Sept 27, 2026" in en-IN); the masks below
# expect en-US, so every JVM here is pinned to it. Without this, three runs on an Indian-locale machine
# give three hashes.
JOPTS="-Duser.language=en -Duser.country=US"
die() { echo "  *** $* ***"; exit 1; }
build() { (cd "$1" && mvn -q -Dmaven.repo.local="$M2" -DskipTests package) || die "build failed: $1"; }
# The application's class path, web jar first (the order `java -jar` uses) - or core jar first.
jars() { echo "$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$1"/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"; }
jars_core_first() { core=$(ls "$1"/tiffinbox-web/target/lib/tiffinbox-core-*.jar)
  echo "$core:$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$1"/tiffinbox-web/target/lib/*.jar | grep -v tiffinbox-core | tr '\n' ':')"; }
# A copy of the rewired anchor with one break laid over it.
overlay() { rm -rf ".work/$1"; mkdir -p .work; rsync -a --exclude target --exclude '.m2*' ../c4-tiffinbox/ ".work/$1/"; rsync -a --exclude README.md "breaks/$1/" ".work/$1/"; }
# Serve a build, run the comparison set against it, and require the server to be GONE after POST /shutdown.
serve() { dir=$1; port=$2; out=$3
  java $JOPTS -jar "$dir/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" "$port" > ".r-$out-server.log" 2>&1 & pid=$!
  for i in $(seq 1 40); do curl -s -o /dev/null "http://127.0.0.1:$port/kitchen" && break; sleep 0.25; done
  ./curlset.sh "$port"
  for i in $(seq 1 40); do kill -0 "$pid" 2>/dev/null || break; sleep 0.25; done
  kill -0 "$pid" 2>/dev/null && { kill "$pid"; die "$out: the server was still running after POST /shutdown"; }
  wait "$pid"; ec=$?
  [ "$(lsof -nP -iTCP:"$port" -sTCP:LISTEN -t 2>/dev/null | wc -l | tr -d ' ')" = 0 ] || die "$out: something still listens on $port"
  printf '  (server exit %s, 0 listeners left on %s)\n' "$ec" "$port"; }
# Three runs, hashed; a drift stops the receipts. Each hash is then compared with the one published in
# receipts.md5 (the README's table): on another machine a difference is information, not a failure.
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
  if [ -z "$pub" ]; then note="(no published hash)"; elif [ "$pub" = "$h" ]; then note="= published"; else note="DIFFERS from the published $pub"; fi
  printf '  %-15s md5 %s  3/3  %s\n' "$nm" "$h" "$note"; }
# Masks jar paths; drops JUL header lines, the server's own INFO lines and stack frames - and COUNTS every
# line it drops, so no cut is uncounted.
mask() { awk '{ gsub(/jar:file:[^]!]*/, "jar:file:<path>") }
  /^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9][0-9][0-9][0-9] [0-9:]+ (AM|PM) / { ts++; next }
  /^INFO: / { info++; next }
  /^\tat / || /^\t\.\.\. [0-9]+ more$/ { st++; next }
  { print } END { printf "… %d JUL header line(s), %d INFO line(s), %d stack line(s) elided …\n", ts, info, st }'; }
CORE=tiffinbox-core/src/main/java/com/tiffinbox; WEB=tiffinbox-web/src/main/java/com/tiffinbox/web
# The checker lists every differing line of the server; the panel keeps the totals and counts what it drops.
elide_differs() { awk '/^  differs: / { d++; next } { print } END { printf "  … %d differing line(s) listed by the checker, elided …\n", d }'; }

echo "building: before/ (as Course 3 left it), the rewired anchor, and the two breaks"
build before; build ../c4-tiffinbox
overlay no-database-component; build .work/no-database-component
overlay one-new; build .work/one-new
overlay fool-the-checker

cap before   serve before 18441 before
cap after    serve ../c4-tiffinbox 18442 after
cap one-new  serve .work/one-new 18445 one-new
# the seven responses, hashed on their own - the "(server exit…)" line differs by port and is not a response
identical() { printf 'the seven responses (status, content type, body), hashed on their own:\n'
  for r in "before/, as Course 3 left it|before" "the rewired anchor|after" "the one-new break|one-new"; do
    printf '  %-30s %s lines  md5 %s\n' "${r%%|*}" "$(grep -c ' -> ' ".r-${r#*|}.out")" "$(grep ' -> ' ".r-${r#*|}.out" | md5 -q)"; done; }
cap identical identical
cap second-wiring sh second-wiring.sh before ../c4-tiffinbox
cap ledger-before sh ../c4-unit01/ledger.sh before/$CORE/wiring/Wiring.java
# the old ledger on the rewired anchor, and - because its exit 2 would also follow a typo - a search
cap ledger-after  sh -c 'sh ../c4-unit01/ledger.sh ../c4-tiffinbox/'"$CORE"'/wiring/Wiring.java; echo "exit $?"
  printf "files named Wiring.java: under before/ %s, under the rewired anchor %s\n" "$(find before -name Wiring.java | wc -l | tr -d " ")" "$(find ../c4-tiffinbox -name Wiring.java | wc -l | tr -d " ")"'
cap ledger-project sh ledger-project.sh before ../c4-tiffinbox
# the same ledger over the one-new break: two rows move back
cap ledger-one-new sh ledger-project.sh before .work/one-new
# the objects: the core classes must not change beyond annotations; the server is reported, not excused;
# and the checker must catch the fool-the-checker overlay (exit codes taken before anything else runs)
objects() { python3 onlyannotations.py before/$CORE ../c4-tiffinbox/$CORE; echo "exit $?"
  echo "the server, the same check:"; python3 onlyannotations.py before/$WEB ../c4-tiffinbox/$WEB | elide_differs; echo "exit ${PIPESTATUS[0]}"
  echo "the checker, fed breaks/fool-the-checker (one line deleted, one duplicated):"
  python3 onlyannotations.py before/$CORE .work/fool-the-checker/$CORE; echo "exit $?"; }
cap objects objects
rm -rf .harness; "$JAVA_HOME/bin/javac" -cp "$(jars ../c4-tiffinbox)" -d .harness harness/com/tiffinbox/harness/*.java
order() { java $JOPTS -cp ".harness:$(jars ../c4-tiffinbox)" com.tiffinbox.harness.BuildOrder 18446 2>&1 | mask
          java $JOPTS -cp ".harness:$(jars_core_first ../c4-tiffinbox)" com.tiffinbox.harness.BuildOrder 18446 2>&1 | mask; }
cap order    order
# the exit code is JAVA's, taken before any filter touches the output
nodb() { java $JOPTS -jar .work/no-database-component/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18447 > .r-no-db.raw 2>&1; ec=$?
         mask < .r-no-db.raw; echo "exit $ec"; }
cap no-db    nodb
# the break itself, as a diff against the anchor (the two header lines carry file names and times)
breakdiff() { diff -U1 ../c4-tiffinbox/$WEB/TiffinBoxServer.java breaks/one-new/$WEB/TiffinBoxServer.java | tail -n +3
              echo "… 2 diff header line(s) elided …"; }
cap break-diff breakdiff
kitchens() { for r in "A  the rewired anchor|../c4-tiffinbox" "B  the one-new break|.work/one-new" "A' the rewired anchor, again|../c4-tiffinbox"; do
    echo "${r%%|*}"; java $JOPTS -cp ".harness:$(jars "${r#*|}")" com.tiffinbox.harness.TwoKitchens 18448 2>&1 | mask; done; }
cap kitchens kitchens

echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
S=".r-before.out"; A=".r-after.out"
[ "$(grep -c ' -> ' "$S")" = 7 ] && [ "$(grep -c ' -> ' "$A")" = 7 ] && [ "$(grep -c ' -> ' .r-one-new.out)" = 7 ] || die "expected seven responses in every capture"
[ "$(awk '/ md5 /{print $NF}' .r-identical.out | sort -u | wc -l | tr -d ' ')" = 1 ] \
  && echo "  the seven responses: one hash for before, after and the one-new break ($(awk '/ md5 /{print $NF; exit}' .r-identical.out))" || die "the responses differ"
grep -q '^  (server exit 0, 0 listeners left' "$A" && echo "  after POST /shutdown: the rewired server exited 0 and left no listener" || die "the rewired server did not stop cleanly"
x second-wiring 'core: Wiring.java \.+ 4$'; x second-wiring 'web:  TiffinBoxServer.java \.+ 5$'; x second-wiring 'both modules \.+ 9$'
x second-wiring 'mention Wiring: 0$'; [ "$(grep -cE '^ +[0-9]+: ' .r-second-wiring.out)" = 4 ] || die "expected four typed values in the old main()"
echo "  before: 4 + 5 = 9 hand-written constructions; the server never mentions Wiring; its main types 4 values"
x ledger-after 'nothing to count'; x ledger-after '^exit 2$'; x ledger-after 'under before/ 1, under the rewired anchor 0$'
echo "  the old ledger on the rewired project: exit 2, nothing to count - and no Wiring.java left to find"
for row in 'hand-written constructions.* 9 -> 0$' 'held as constants in code .* 3 -> 0$' 'typed as literals into main\(\) .* 4 -> 0$' \
           'values in tiffinbox.properties .* 0 \(no file\) -> 4$' 'startEverything.* 18 -> \(file gone\)$' 'main\(\), comments.* 26 -> 7$' \
           'start\(\) and stop\(\).* 0 -> 25$' 'declares in its pom.xml .* 1 -> 3$' 'at run time .* 5 -> 15$'; do x ledger-project "$row"; done
x ledger-project '^  CustomerRepository Dashboard Database OrderQueue TiffinBoxApp TiffinBoxServer$'
x ledger-one-new 'hand-written constructions.* 9 -> 1$'; x ledger-one-new 'held as constants in code .* 3 -> 1$'
echo "  the one-new break moves two ledger rows back: constructions 9 -> 1, constants 3 -> 1"
echo "  the project ledger: 9->0, 3->0, 4->0, 0->4, 18->gone, 26->7, 0->25; the price 1->3 deps, 5->15 jars; 6 classes"
[ "$(grep -c '^exit ' .r-objects.out)" = 3 ] || die "objects: expected three checker runs"
[ "$(grep '^exit ' .r-objects.out | paste -sd' ' -)" = "exit 0 exit 1 exit 1" ] || die "objects: expected exits 0 (core), 1 (server), 1 (fooled)"
[ "$(grep -c 'code that differs once annotations are set aside, in order \.\.\. 0$' .r-objects.out)" = 1 ] || die "objects: the core classes changed beyond annotations"
x objects 'lines changed \.+ 20$'; x objects 'blank lines \.+ 4$'
x objects 'in order \.\.\. 2$'
echo "  the core objects: 20 changed lines, 0 code; the server changed and says so; the fooled tree is caught (2, exit 1)"
[ "$(grep -c 'handed to the context, before refresh() : \[tiffinBoxApp\]$' .r-order.out)" = 2 ] || die "order: tiffinBoxApp was not the one class handed in"
reg=$(grep 'in the order registered' .r-order.out | sort -u | wc -l | tr -d ' '); fin=$(grep 'in the order finished' .r-order.out | sort -u | wc -l | tr -d ' ')
[ "$reg" = 2 ] && [ "$fin" = 1 ] || die "order: expected two registration orders and one finishing order (got $reg and $fin)"
x order 'finished +: \[tiffinBoxApp, database, customerRepository, dashboard, orderQueue, tiffinBoxServer\]$'
echo "  the order: two class paths, two registration orders, one finishing order - database first, server last"
x no-db "No qualifying bean of type 'com.tiffinbox.Database'"; x no-db "'tiffinBoxServer'"; x no-db "Caused by: .*'customerRepository'"; x no-db '^exit 1$'
echo "  without Database's @Component: startup refuses (exit 1), naming the server, the repository, and Database"
x break-diff '^-.*OrderQueue kitchen,'; x break-diff '^\+    private final OrderQueue kitchen = new OrderQueue\(COOKS\);'; x break-diff '^-        this.kitchen = kitchen;$'
x kitchens "^B  the one-new break$"
[ "$(grep -c 'the kitchen the server cooks with   : kitchen #1$' .r-kitchens.out)" = 2 ] || die "kitchens: A and A' must cook with the container's kitchen"
[ "$(grep -c 'the kitchen the server cooks with   : kitchen #2$' .r-kitchens.out)" = 1 ] || die "kitchens: B must cook with a second kitchen"
x kitchens "the server's kitchen: 120, the container's: 0$"; [ "$(grep -c "the server's kitchen: 120, the container's: 120$" .r-kitchens.out)" = 2 ] || die "kitchens: A/A' counts"
echo "  the break: A and A' cook with the container's kitchen (120 = 120); B with a second one (120 vs 0)"
