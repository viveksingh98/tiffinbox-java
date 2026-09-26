#!/bin/bash
# Every capture in the README. Same program run with and without one JVM flag, so the flag is the
# only variable. stdout+stderr, timestamps and jar paths masked and counted, every WARNING kept.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"; AJ=$(tr ':' '\n' < cp.txt | grep aspectjweaver)
cap() { nm=$1; shift; ec=0
  for i in 1 2 3; do { "$@" 2>&1; } | ./mask.sh > ".r-$nm.$i" || true; done
  "$@" >/dev/null 2>&1 || ec=$?
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] && ok=3/3 || ok="*** DRIFTS ***"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; echo "$ec" > ".r-$nm.exit"
  printf "  %-11s md5 %s  %s  exit %s\n" "$nm" "$h" "$ok" "$ec"; [ "$ok" = 3/3 ] || exit 1; }
cap proxies   java -cp "$CP" com.tiffinbox.ProxyLimits
cap no-agent  java -cp "$CP" com.tiffinbox.Limits
cap woven     java -javaagent:"$AJ" -cp "$CP" com.tiffinbox.Limits
cap wrong-pkg java -javaagent:"$AJ" -Dorg.aspectj.weaver.loadtime.configuration=META-INF/aop-wrong.xml -cp "$CP" com.tiffinbox.Limits
# the same two runs with ONE option added (-showWeaveInfo): the weaver reports each join point it wove
cap woven-info java -javaagent:"$AJ" -Dorg.aspectj.weaver.loadtime.configuration=META-INF/aop-info.xml -cp "$CP" com.tiffinbox.Limits
cap wrong-info java -javaagent:"$AJ" -Dorg.aspectj.weaver.loadtime.configuration=META-INF/aop-wrong-info.xml -cp "$CP" com.tiffinbox.Limits
# the agent on the SPRING version: woven AND proxied
cap both      java -javaagent:"$AJ" -cp "$CP" com.tiffinbox.ProxyLimits

echo
row() { grep "$2" ".r-$1.out" | grep -o 'advice ran [0-9]*' | awk '{print $3}'; }
printf "  %-10s outside %s  inside %s  final %s\n" proxies  "$(row proxies outside)"  "$(row proxies INSIDE)"  "$(row proxies final)"
printf "  %-10s outside %s  inside %s  final %s\n" no-agent "$(row no-agent outside)" "$(row no-agent INSIDE)" "$(row no-agent final)"
printf "  %-10s outside %s  inside %s  final %s\n" woven    "$(row woven outside)"    "$(row woven INSIDE)"    "$(row woven final)"
printf "  %-10s outside %s  inside %s  final %s\n" wrong    "$(row wrong-pkg outside)" "$(row wrong-pkg INSIDE)" "$(row wrong-pkg final)"
[ "$(row woven INSIDE)" = "2" ] && [ "$(row woven final)" = "1" ] || { echo "  *** weaving did not reach what proxies cannot ***"; exit 1; }
# THE BREAK'S SHARPEST CLAIM: stderr cannot tell a working weave from a failed one.
a=$(grep -E 'WARNING' .r-woven.out); b=$(grep -E 'WARNING' .r-wrong-pkg.out)
[ "$a" = "$b" ] && echo "  WARNING lines, working weave vs wrong package: IDENTICAL ($(echo "$a" | wc -l | tr -d ' ') each) -> stderr cannot tell them apart" \
                || { echo "  *** the warnings differ - re-read the capture ***"; exit 1; }
# THE FINAL METHOD UNDER A PROXY: the call reaches the proxy object, which cannot override it, so the code runs
# on the proxy's own fields - never set. The advice does not run and the field is null.
grep -q 'declared final    : advice ran 0, then NullPointerException: .*"this.menu" is null' .r-proxies.out \
  && echo "  Spring's proxy, final method: advice 0, then NullPointerException - the code ran on the proxy's empty fields" \
  || { echo "  *** the final-method row changed ***"; exit 1; }
wi=$(grep -c ' weaveinfo ' .r-woven-info.out || true); wx=$(grep -c ' weaveinfo ' .r-wrong-info.out || true)
[ "$wi" = 2 ] && [ "$wx" = 0 ] && echo "  -showWeaveInfo: $wi weaveinfo lines when it worked, $wx when the package was wrong -> the weaver CAN say" \
  || { echo "  *** weaveinfo counts $wi / $wx ***"; exit 1; }
[ "$(row both outside)" = 3 ] && echo "  the agent on the Spring version: ONE call from outside ran the advice $(row both outside) times -> weave OR proxy, never both" \
  || { echo "  *** woven+proxied outside count changed ***"; exit 1; }

