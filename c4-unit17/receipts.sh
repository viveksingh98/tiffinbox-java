#!/bin/sh
# Every capture this unit's README quotes.
#
# TWO THINGS HERE ARE NOT PROPERTIES OF THE CODE and the program masks them itself rather than
# letting a filter do it after the fact: the OS-chosen loopback port and the temp-file path. That
# is why these captures hash at all. Nothing here carries a timestamp, and the check below says so
# rather than assuming it.
#
# TEARDOWN IS PART OF THE DELIVERABLE. ThreePlaces stops its server in a finally, so running this
# twice does not meet a port the first run kept.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt \
                     dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"
TS='[0-9]{2}:[0-9]{2}:[0-9]{2}'

cap() { nm=$1; shift
  ec=0
  for i in 1 2 3; do { "$@" 2>&1; } > ".r-$nm.$i" || true; done
  "$@" >/dev/null 2>&1 || ec=$?
  echo "$ec" > ".r-$nm.exit"
  n=$(grep -cE "$TS" ".r-$nm.1" || true)
  [ "$n" -eq 0 ] || { echo "  $nm: NOT HASHABLE -- $n timestamp-shaped line(s)"; exit 1; }
  h=$(md5 -q ".r-$nm.1")
  if [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ]
    then ok="3/3"; else ok="*** DRIFTS ***"; fi
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  printf "  %-11s md5 %s  %s  exit %s\n" "$nm" "$h" "$ok" "$ec"
}

cap three     java -cp "$CP" com.tiffinbox.ThreePlaces
cap ide       java -cp "src/main/java:$CP" com.tiffinbox.WorksInTheIde
cap artefact  java -cp "$CP" com.tiffinbox.WorksInTheIde

# DERIVED off the built jar, not asserted: which of the two csv files actually shipped.
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" package -DskipTests >/dev/null 2>&1
echo
echo "  in the jar:  specials.csv=$(jar tf target/c4-unit17-1.0.0.jar | grep -c 'specials.csv' || true)  menu.csv=$(jar tf target/c4-unit17-1.0.0.jar | grep -c 'menu.csv' || true)"
echo "  (specials.csv lives in src/main/java; menu.csv lives in src/main/resources)"

# TEARDOWN CHECK: nothing of this unit's is still listening. A LISTEN line never contains a directory name
# (the first version grepped for one and could not fail - RED 2026-09-26), so ask each listening java process
# for its working directory instead.
if command -v lsof >/dev/null 2>&1; then
  left=0
  for pid in $(lsof -nP -iTCP -sTCP:LISTEN -a -c java -t 2>/dev/null | sort -u); do
    lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | grep -q "^n$PWD\$" && left=$((left+1))
  done
  echo "  java listeners left behind by this unit: $left"
  [ "$left" = 0 ] || exit 1
fi
