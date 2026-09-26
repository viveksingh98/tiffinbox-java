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
cap noenable   java -cp "$CP" com.tiffinbox.AsyncListener noenable
# B for the condition claim: the SAME sources compiled with -parameters (the build setting Boot turns on).
rm -rf .params && mkdir -p .params && "$JAVA_HOME/bin/javac" -parameters -cp "$(cat cp.txt)" -d .params src/main/java/com/tiffinbox/*.java
cap params     java -cp ".params:$(cat cp.txt)" com.tiffinbox.Conditions
# Since when: count the class that read parameter names from the debug table, in the last 6.0 and the first 6.1.
for v in 6.0.23 6.1.0; do
  mvn -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:get -Dartifact="org.springframework:spring-core:$v" -Dtransitive=false
  printf "  spring-core %s: LocalVariableTableParameterNameDiscoverer entries = %s\n" "$v" \
    "$(unzip -l ".m2-demo/org/springframework/spring-core/$v/spring-core-$v.jar" | grep -c 'LocalVariableTableParameterNameDiscoverer.class' || true)"
done > .r-reader-since.out
cat .r-reader-since.out
echo
n=$(grep -c 'ByName.*SpelEvaluationException' .r-conditions.out || true); w=$(grep -cE 'By(A0|Args|Event) +total 900 +-> ran' .r-conditions.out || true)
echo "  #e threw on $n of 2 publishes; the other three spellings ran for 900: $w of 3"
[ "$n" = "2" ] && [ "$w" = "3" ] || { echo "  *** condition claim fails ***"; exit 1; }
[ "$(grep -c 'sms loyalty receipt' .r-ordered.out)" = "3" ] && echo "  @Order: the same sequence in 3 of 3 runs" || { echo "  *** order varied ***"; exit 1; }
grep -q 'after publish returned' .r-async.out && ! grep -q 'had NOT returned' .r-async.out && echo "  the async listener ran after publish returned (latched, not timed)" || { echo "  *** async claim fails ***"; exit 1; }
grep -q '^SEVERE: Unexpected exception occurred invoking async method' .r-async.out && echo "  the async listener's exception: logged SEVERE, caller never heard" || { echo "  *** SEVERE line missing ***"; exit 1; }
# RED 2026-09-26 #2: the name IS in the class file (debug table); Spring 7 has no reader for it; 6.0 had one, 6.1 removed it.
grep -q "the name e in the class file's debug table?   true" .r-conditions.out && grep -q "reader of that debug table present? false" .r-conditions.out \
  && grep -q "spring-core 6.0.23: LocalVariableTableParameterNameDiscoverer entries = 1" .r-reader-since.out \
  && grep -q "spring-core 6.1.0: LocalVariableTableParameterNameDiscoverer entries = 0" .r-reader-since.out \
  && echo "  the name is in the debug table; Spring stopped reading that table in 6.1 (1 -> 0 entries)" || { echo "  *** debug-table claim failed ***"; exit 1; }
grep -qE 'ByName +total 900 +-> ran' .r-params.out && grep -qE 'ByName +total 340 +-> did not run' .r-params.out \
  && echo "  B: the same sources with -parameters -> #e works (ran / did not run); A' is the plain build above" || { echo "  *** -parameters B failed ***"; exit 1; }
# RED #4: @Async without @EnableAsync runs on main, synchronously, and nothing is logged.
grep -q '\[async\] on main   (BEFORE publish returned' .r-noenable.out && [ "$(grep -cE '^(INFO|WARNING|SEVERE)' .r-noenable.out)" = 0 ] \
  && echo "  no @EnableAsync: the async listener ran on main, before publish returned, with nothing logged" || { echo "  *** noenable claim failed ***"; exit 1; }
# RED #22: without @Order the sequence is different from the numbered one.
u=$(grep 'without @Order:' .r-ordered.out | sed 's/.*without @Order: *//'); [ -n "$u" ] && [ "$u" != "sms loyalty receipt" ] \
  && echo "  without @Order: '$u' - not the numbered sequence" || { echo "  *** unnumbered row missing or identical ***"; exit 1; }

