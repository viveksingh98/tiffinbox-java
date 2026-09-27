#!/bin/bash
# Course 5 · Unit 01's receipts. TiffinBox as Course 4 left it (../c4-tiffinbox, frozen) and as Course 5 starts it
# (../c5-tiffinbox: Boot's parent and SpringApplication.run), built and run in ONE run on ONE machine; every number
# the video says is asserted below.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
M2="$PWD/.m2-demo"
JOPTS="-Duser.language=en -Duser.country=US"   # log headers are locale-dependent; the masks expect en-US
die() { echo "  *** $* ***"; exit 1; }
# clean, always: copy-dependencies never deletes, so a lib/ built before a version change keeps BOTH versions.
build() { (cd "$1" && mvn -q -Dmaven.repo.local="$M2" -DskipTests clean package) || die "build failed: $1"; }
jars() { echo "$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$1"/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"; }
# "after" is this unit's own frozen copy of ../c5-tiffinbox as unit 01 left it: later units keep changing the anchor,
# and these receipts must keep measuring unit 01's change (Course 4's lesson: unit 31 broke units 01 and 08's commands).
B=../c4-tiffinbox; A=after; WEB=tiffinbox-web/src/main/java/com/tiffinbox/web
# Serve a build, run Course 4's comparison set, require the server gone after POST /shutdown.
serve() { dir=$1; port=$2; shift 2
  java $JOPTS "$@" -jar "$dir/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" "$port" > ".r-serve-$port.log" 2>&1 & pid=$!
  for i in $(seq 1 60); do curl -s -o /dev/null "http://127.0.0.1:$port/kitchen" && break; sleep 0.25; done
  ../c4-unit31/curlset.sh "$port"
  for i in $(seq 1 40); do kill -0 "$pid" 2>/dev/null || break; sleep 0.25; done
  kill -0 "$pid" 2>/dev/null && { kill "$pid"; die "the server on $port was still running after POST /shutdown"; }
  wait "$pid"; ec=$?
  [ "$(lsof -nP -iTCP:"$port" -sTCP:LISTEN -t 2>/dev/null | wc -l | tr -d ' ')" = 0 ] || die "something still listens on $port"
  printf '  (server exit %s, 0 listeners left)\n' "$ec"; }
# Three runs, hashed; a drift stops the receipts; each hash compared with receipts.md5.
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
  if [ -z "$pub" ]; then note="(no published hash)"; elif [ "$pub" = "$h" ]; then note="= published"; else note="DIFFERS from the published $pub"; fi
  printf '  %-10s md5 %s  3/3  %s\n' "$nm" "$h" "$note"; }
# Boot's log line: "<ISO time> <LEVEL> <pid> --- [<thread>] <logger> : <message>". Masks the time, the pid and the
# two start-up durations; JUL's two-line records (plain Spring) lose their header line - every dropped line counted.
mask() { awk '
  /^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9][0-9][0-9][0-9] [0-9:]+ (AM|PM) / { jul++; next }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { $1 = "<time>"; $3 = "<pid>"; t++ }
  { gsub(/in [0-9.]+ seconds \(process running for [0-9.]+\)/, "in <s> seconds (process running for <s>)"); gsub(/with PID [0-9]+ \([^)]*\)/, "with PID <pid> (<path>)"); print }
  END { printf "… %d JUL header line(s) elided; %d Boot line(s) with time and pid masked …\n", jul, t }'; }

echo "building: Course 4's TiffinBox (frozen) and Course 5's"
build "$B"; build "$A"

cap before serve "$B" 18521
cap after  serve "$A" 18522
identical() { printf 'the seven responses (status, content type, body), hashed on their own:\n'
  for r in "Course 4, a context you build|before" "Course 5, SpringApplication.run|after"; do
    printf '  %-34s %s lines  md5 %s\n' "${r%%|*}" "$(grep -c ' -> ' ".r-${r#*|}.out")" "$(grep ' -> ' ".r-${r#*|}.out" | md5 -q)"; done; }
cap identical identical

# What changed in the source tree: every file both trees carry, compared; the changed ones, diffed.
changes() { n=0; changed=""
  for f in $(cd "$A" && git ls-files . 2>/dev/null | grep -v '^README.md$' || find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||'); do
    [ -f "$B/$f" ] || { changed="$changed $f(new)"; continue; }; n=$((n+1)); cmp -s "$B/$f" "$A/$f" || changed="$changed $f"; done
  printf 'files compared (README aside): %s · changed:%s\n' "$n" "$changed"
  printf 'TiffinBoxServer.java, Course 4 -> Course 5, every changed line:\n'
  diff -U0 "$B/$WEB/TiffinBoxServer.java" "$A/$WEB/TiffinBoxServer.java" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' || true; }
cap changes changes

rm -rf .harness; "$JAVA_HOME/bin/javac" -cp "$(jars "$A")" -d .harness harness/com/tiffinbox/harness/WhatBootAdded.java
beans() { java $JOPTS -cp ".harness:$(jars "$A")" com.tiffinbox.harness.WhatBootAdded context 18523 2>&1 | mask
          java $JOPTS -cp ".harness:$(jars "$A")" com.tiffinbox.harness.WhatBootAdded boot 18524 2>&1 | mask; }
cap beans beans

price() { lb=$(ls "$B"/tiffinbox-web/target/lib | sort); la=$(ls "$A"/tiffinbox-web/target/lib | sort)
  printf 'jars the application needs at run time: %s -> %s\n' "$(echo "$lb" | wc -l | tr -d ' ')" "$(echo "$la" | wc -l | tr -d ' ')"
  printf '  added:   %s\n' "$(comm -13 <(echo "$lb" | sed 's/-[0-9][0-9.]*\.jar$//') <(echo "$la" | sed 's/-[0-9][0-9.]*\.jar$//') | paste -sd' ' -)"
  printf '  version moved: %s\n' "$(comm -12 <(echo "$lb" | sed 's/-[0-9][0-9.]*\.jar$//') <(echo "$la" | sed 's/-[0-9][0-9.]*\.jar$//') | while read -r j; do
      vb=$(echo "$lb" | grep -E "^$j-[0-9]"); va=$(echo "$la" | grep -E "^$j-[0-9]"); [ "$vb" = "$va" ] || printf '%s -> %s  ' "$vb" "$va"; done)"
  for t in "Course 4|$B" "Course 5, unit 01|$A"; do printf 'MethodParameters attributes in OrderQueue.class (%s): %s\n' "${t%%|*}" \
      "$("$JAVA_HOME/bin/javap" -v -cp "${t#*|}/tiffinbox-core/target/classes" com.tiffinbox.OrderQueue | grep -c MethodParameters)"; done; }
cap price price

# The break: Course 4's JUL debug config, Course 5's silence, and Boot's own way back (A / B / A').
logging() { for r in "A  Course 4, -Djava.util.logging.config.file=logging-debug.properties|$B|-Djava.util.logging.config.file=$B/tiffinbox-web/logging-debug.properties|" \
                     "B  Course 5, the same flag|$A|-Djava.util.logging.config.file=$B/tiffinbox-web/logging-debug.properties|" \
                     "A' Course 5, --logging.level.tiffinbox=debug|$A||--logging.level.tiffinbox=debug"; do
    IFS='|' read -r label dir flag arg <<< "$r"
    java $JOPTS $flag -jar "$dir/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" 18525 $arg > .r-log-run 2>&1 & pid=$!
    for i in $(seq 1 60); do curl -s -o /dev/null http://127.0.0.1:18525/kitchen && break; sleep 0.25; done
    curl -s -X POST http://127.0.0.1:18525/shutdown > /dev/null; wait "$pid"; ec=$?
    printf '%s\n  exit %s · route DEBUG lines %s · banner %s\n' "$label" "$ec" "$(grep -c 'route [A-Z]* /' .r-log-run)" \
      "$(grep -q ':: Spring Boot ::' .r-log-run && echo "printed ($(grep -o 'v[0-9.]*' .r-log-run | head -1))" || echo "none")"
    if grep -q 'route GET /customers' .r-log-run; then grep -m1 'route GET /customers' .r-log-run | mask | head -1 | sed 's/^/  first route line: /'
    else echo "  first route line: (none)"; fi; done; rm -f .r-log-run; }
cap logging logging

echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
[ "$(awk '/ md5 /{print $NF}' .r-identical.out | sort -u | wc -l | tr -d ' ')" = 1 ] && [ "$(grep -c ' 7 lines ' .r-identical.out)" = 2 ] \
  && echo "  the seven responses: one hash before and after ($(awk '/ md5 /{print $NF; exit}' .r-identical.out))" || die "the responses changed"
grep -q '^  (server exit 0, 0 listeners left)' .r-after.out || die "Course 5's server did not stop cleanly"
x changes 'changed: pom.xml tiffinbox-web/pom.xml tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java$'
[ "$(grep -c '^-' .r-changes.out)" = 3 ] && [ "$(grep -c '^+' .r-changes.out)" = 2 ] || die "changes: expected TiffinBoxServer.java to lose 3 lines (an import, two of main) and gain 2"
echo "  three files changed; TiffinBoxServer.java: an import and two lines of main out, an import and SpringApplication.run in"
[ "$(grep -c '  your definitions (6): \[customerRepository, dashboard, database, orderQueue, tiffinBoxApp, tiffinBoxServer\]$' .r-beans.out)" = 2 ] || die "beans: yours must be the same six both ways"
[ "$(grep -c '  auto-configuration definitions: 0$' .r-beans.out)" = 2 ] || die "beans: SpringApplication.run alone must add no auto-configuration"
x beans 'SpringApplication.run.*' ; x beans 'property sources, in the order they are asked: \[configurationProperties, commandLineArgs, systemProperties, systemEnvironment, random, applicationInfo, class path resource \[tiffinbox.properties\]\]$'
echo "  the same six beans both ways, 0 auto-configuration; Boot adds configurationProperties, commandLineArgs, random, applicationInfo"
x price 'jars the application needs at run time: 15 -> 26$'; x price 'OrderQueue.class \(Course 4\): 0$'; x price 'OrderQueue.class \(Course 5, unit 01\): 3$'
echo "  the price: 15 -> 26 jars; -parameters now on (MethodParameters 0 -> 3)"
x logging "^A  .*" ; [ "$(grep -o 'route DEBUG lines [0-9]*' .r-logging.out | paste -sd' ' -)" = "route DEBUG lines 5 route DEBUG lines 0 route DEBUG lines 5" ] || die "logging: expected 5 / 0 / 5"
[ "$(grep -c 'exit 0 ' .r-logging.out)" = 3 ] || die "logging: every run must exit 0 (the break is silent)"
x logging 'banner printed \(v4\.1\.1\)'
echo "  the break: the JUL debug config prints 5 route lines under Course 4, 0 under Boot, 5 again with Boot's logging.level"
