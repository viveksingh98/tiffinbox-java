#!/bin/bash
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"
cap() { nm=$1; shift; ec=0
  for i in 1 2 3; do { "$@" 2>&1; } | ./jul.sh > ".r-$nm.$i" || true; done
  "$@" >/dev/null 2>&1 || ec=$?
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] && ok=3/3 || ok="*** DRIFTS ***"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; echo "$ec" > ".r-$nm.exit"
  printf "  %-11s md5 %s  %s  exit %s\n" "$nm" "$h" "$ok" "$ec"; }
cap conditions java -cp "$CP" com.tiffinbox.Conditions
cap ordered    java -cp "$CP" com.tiffinbox.Ordered
cap async      java -cp "$CP" com.tiffinbox.AsyncListener
echo
n=$(grep -c 'ByName.*SpelEvaluationException' .r-conditions.out || true); w=$(grep -cE 'By(A0|Args|Event) +total 900 +-> ran' .r-conditions.out || true)
echo "  #e threw on $n of 2 publishes; the other three spellings ran for 900: $w of 3"
[ "$n" = "2" ] && [ "$w" = "3" ] || { echo "  *** condition claim fails ***"; exit 1; }
[ "$(grep -c 'sms loyalty receipt' .r-ordered.out)" = "3" ] && echo "  @Order: the same sequence in 3 of 3 runs" || { echo "  *** order varied ***"; exit 1; }
grep -q 'after publish returned' .r-async.out && ! grep -q 'had NOT returned' .r-async.out && echo "  the async listener ran after publish returned (latched, not timed)" || { echo "  *** async claim fails ***"; exit 1; }
grep -q '^SEVERE: Unexpected exception occurred invoking async method' .r-async.out && echo "  the async listener's exception: logged SEVERE, caller never heard" || { echo "  *** SEVERE line missing ***"; exit 1; }
